import { ref } from 'vue'
import { createSupabaseClient } from '~/lib/supabase'

export function useAuth() {
  const supabase = createSupabaseClient()
  const loading = ref(false)
  const error = ref<string | null>(null)

  async function login(email: string, password: string) {
    loading.value = true
    error.value = null

    const { data, error: authError } = await supabase.auth.signInWithPassword({ email, password })

    if (authError) {
      loading.value = false
      if (authError.message === 'Email not confirmed') {
        error.value = 'Confirme seu e-mail antes de entrar. Verifique sua caixa de entrada.'
      } else if (authError.message === 'Invalid login credentials') {
        error.value = 'E-mail ou senha incorretos.'
      } else {
        error.value = authError.message
      }
      return false
    }

    // Atualiza JWT com empresa_id (lido do profile criado pelo trigger) para cache do RLS
    if (data.user && !data.user.user_metadata?.empresa_id) {
      const { data: profile } = await supabase
        .from('profiles')
        .select('empresa_id, perfil')
        .eq('id', data.user.id)
        .maybeSingle()

      if (profile?.empresa_id) {
        await supabase.auth.updateUser({
          data: { empresa_id: profile.empresa_id, perfil: profile.perfil ?? 'admin' },
        })
        await supabase.auth.refreshSession()
      }
    }

    loading.value = false
    return true
  }

  async function register(name: string, email: string, password: string, nomeEmpresa: string) {
    loading.value = true
    error.value = null

    // O trigger handle_new_user no Supabase cria empresa + profile automaticamente
    const { data, error: authError } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: { full_name: name, perfil: 'admin', empresa_nome: nomeEmpresa.trim() },
      },
    })

    loading.value = false

    if (authError) {
      error.value = authError.message
      return { ok: false, needsConfirmation: false }
    }

    const needsConfirmation = !data.session

    // Se não precisar de confirmação de e-mail, atualiza JWT com empresa_id
    if (data.session && data.user) {
      const { data: profile } = await supabase
        .from('profiles')
        .select('empresa_id')
        .eq('id', data.user.id)
        .maybeSingle()

      if (profile?.empresa_id) {
        await supabase.auth.updateUser({
          data: { empresa_id: profile.empresa_id, perfil: 'admin', empresa_nome: nomeEmpresa.trim() },
        })
        await supabase.auth.refreshSession()
      } else {
        // Trigger ainda não rodou ou falhou — cria empresa + profile diretamente
        const nomeFinal = nomeEmpresa.trim() || name.trim() || email.split('@')[0]
        const { data: emp } = await supabase
          .from('empresas')
          .insert({ nome_fantasia: nomeFinal })
          .select('id')
          .single()
        if (emp?.id) {
          await supabase.from('profiles').upsert({
            id: data.user.id, empresa_id: emp.id,
            email, nome: name.trim(), perfil: 'admin', status: 'ativo',
          })
          await supabase.auth.updateUser({
            data: { empresa_id: emp.id, perfil: 'admin', empresa_nome: nomeFinal },
          })
          await supabase.auth.refreshSession()
        }
      }
    }

    return { ok: true, needsConfirmation }
  }

  async function logout() {
    const empresaId     = useState<number | null>('empresa_id',          () => null)
    const userPerfil    = useState<string | null>('user_perfil',         () => null)
    const loadedForUser = useState<string | null>('empresa_loaded_user', () => null)
    empresaId.value     = null
    userPerfil.value    = null
    loadedForUser.value = null
    await supabase.auth.signOut()
  }

  return { login, register, logout, loading, error }
}



import { ref } from 'vue'
import { createSupabaseClient } from '~/lib/supabase'

export function useAuth() {
  const supabase = createSupabaseClient()
  const loading = ref(false)
  const error = ref<string | null>(null)

  async function login(email: string, password: string) {
    loading.value = true
    error.value = null

    const { error: authError } = await supabase.auth.signInWithPassword({ email, password })

    loading.value = false

    if (authError) {
      if (authError.message === 'Email not confirmed') {
        error.value = 'Confirme seu e-mail antes de entrar. Verifique sua caixa de entrada.'
      } else if (authError.message === 'Invalid login credentials') {
        error.value = 'E-mail ou senha incorretos.'
      } else {
        error.value = authError.message
      }
      return false
    }

    return true
  }

  async function register(name: string, email: string, password: string, nomeEmpresa: string) {
    loading.value = true
    error.value = null

    // Step 1: SignUp com perfil e empresa_nome no metadata (para o trigger e loadEmpresa)
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

    // Step 2: Com sessão ativa, usa RPC SECURITY DEFINER para criar empresa + vincular profile
    if (data.session && data.user) {
      const { data: rpcResult, error: rpcError } = await supabase.rpc('setup_admin_account', {
        p_empresa_nome: nomeEmpresa.trim() || name.trim(),
      })

      if (!rpcError && rpcResult?.empresa_id) {
        // Salva empresa_id no JWT metadata — necessário para current_empresa_id() via JWT
        await supabase.auth.updateUser({
          data: {
            perfil: 'admin',
            empresa_id: rpcResult.empresa_id,
            empresa_nome: nomeEmpresa.trim(),
          },
        })
        // Força refresh do JWT para que o RLS reconheça o empresa_id imediatamente
        await supabase.auth.refreshSession()
      }
    }

    return { ok: true, needsConfirmation }
  }

  async function logout() {
    // Limpa o cache de empresa/perfil para que o próximo login recarregue do zero
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

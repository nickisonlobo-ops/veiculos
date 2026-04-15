import { useState } from '#app'
import { createSupabaseClient } from '~/lib/supabase'

export function useEmpresa() {
  const empresaId      = useState<number | null>('empresa_id',          () => null)
  const userPerfil     = useState<string | null>('user_perfil',         () => null)
  const loadedForUser  = useState<string | null>('empresa_loaded_user', () => null)

  async function loadEmpresa() {
    const supabase = createSupabaseClient()
    const { data: { session } } = await supabase.auth.getSession()
    if (!session?.user) return

    // Só usa o cache se for o mesmo usuário logado
    if (empresaId.value !== null && loadedForUser.value === session.user.id) return

    loadedForUser.value = session.user.id

    // Try to load existing profile
    const { data: profile } = await supabase
      .from('profiles')
      .select('empresa_id, perfil')
      .eq('id', session.user.id)
      .maybeSingle()

    if (profile?.empresa_id) {
      empresaId.value  = profile.empresa_id
      userPerfil.value = profile.perfil ?? 'funcionario'
      return
    }

    // Profile exists but empresa_id is null (trigger ran first), OR no profile yet
    // Preserve perfil from profile if the trigger already set it; fall back to metadata or 'admin'
    const perfilToUse: string =
      profile?.perfil ??
      (session.user.user_metadata?.perfil as string | undefined) ??
      'admin'

    // Fast path: empresa_id was stored in signUp metadata by useAuth
    const metaEmpresaId = session.user.user_metadata?.empresa_id as number | null | undefined
    if (metaEmpresaId) {
      await supabase.from('profiles').upsert({
        id: session.user.id,
        empresa_id: metaEmpresaId,
        email: session.user.email,
        nome: session.user.user_metadata?.full_name ?? null,
        perfil: perfilToUse,
      })
      empresaId.value  = metaEmpresaId
      userPerfil.value = perfilToUse
      return
    }

    // Try to find an accessible empresa (requires empresas_select policy fix)
    const { data: empresa } = await supabase
      .from('empresas')
      .select('id')
      .order('id', { ascending: true })
      .limit(1)
      .maybeSingle()

    if (empresa?.id) {
      await supabase.from('profiles').upsert({
        id: session.user.id,
        empresa_id: empresa.id,
        email: session.user.email,
        nome: session.user.user_metadata?.full_name ?? null,
        perfil: perfilToUse,
      })
      empresaId.value  = empresa.id
      userPerfil.value = perfilToUse
      return
    }

    // Last resort: create empresa via SECURITY DEFINER RPC (ignores RLS)
    const nomeEmpresa: string =
      (session.user.user_metadata?.empresa_nome as string | undefined) ??
      (session.user.user_metadata?.full_name as string | undefined) ??
      session.user.email?.split('@')[0] ??
      'Minha Empresa'

    const { data: rpcResult } = await supabase.rpc('setup_admin_account', {
      p_empresa_nome: nomeEmpresa,
    })

    if (rpcResult?.empresa_id) {
      // Salva empresa_id no JWT e força refresh para o RLS reconhecer
      await supabase.auth.updateUser({
        data: { empresa_id: rpcResult.empresa_id, perfil: 'admin' },
      })
      await supabase.auth.refreshSession()
      empresaId.value  = rpcResult.empresa_id
      userPerfil.value = 'admin'
    }
  }

  return { empresaId, userPerfil, loadEmpresa }
}


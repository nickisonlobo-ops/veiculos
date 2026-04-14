import { useState } from '#app'
import { createSupabaseClient } from '~/lib/supabase'

export function useEmpresa() {
  const empresaId = useState<number | null>('empresa_id', () => null)

  async function loadEmpresa() {
    if (empresaId.value !== null) return
    const supabase = createSupabaseClient()
    const { data: { session } } = await supabase.auth.getSession()
    if (!session?.user) return
    const { data } = await supabase
      .from('profiles')
      .select('empresa_id')
      .eq('id', session.user.id)
      .single()
    if (data?.empresa_id) empresaId.value = data.empresa_id
  }

  return { empresaId, loadEmpresa }
}

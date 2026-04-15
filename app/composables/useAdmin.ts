import { computed, onMounted, ref } from 'vue'
import { useEmpresa } from './useEmpresa'
import { createSupabaseClient } from '~/lib/supabase'

export function useAdmin() {
  const { userPerfil, loadEmpresa } = useEmpresa()
  const adminLoading = ref(true)

  onMounted(async () => {
    await loadEmpresa()

    // Se o loadEmpresa não conseguiu setar o perfil (RLS bloqueou),
    // usa o fallback do user_metadata gravado no signUp/updateUser
    if (!userPerfil.value) {
      const supabase = createSupabaseClient()
      const { data: { session } } = await supabase.auth.getSession()
      const metaPerfil = session?.user?.user_metadata?.perfil as string | undefined
      if (metaPerfil) {
        userPerfil.value = metaPerfil
      }
    }

    adminLoading.value = false
  })

  const isAdmin          = computed(() => userPerfil.value === 'admin')
  const isAdminOrGerente = computed(() => userPerfil.value === 'admin' || userPerfil.value === 'gerente')

  return { perfil: userPerfil, isAdmin, isAdminOrGerente, adminLoading }
}

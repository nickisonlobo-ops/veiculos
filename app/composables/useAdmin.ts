import { computed, onMounted, ref } from 'vue'
import { useEmpresa } from './useEmpresa'

export function useAdmin() {
  const { userPerfil, loadEmpresa } = useEmpresa()
  const adminLoading = ref(true)

  onMounted(async () => {
    await loadEmpresa()
    adminLoading.value = false
  })

  const isAdmin          = computed(() => userPerfil.value === 'admin')
  const isAdminOrGerente = computed(() => userPerfil.value === 'admin' || userPerfil.value === 'gerente')

  return { perfil: userPerfil, isAdmin, isAdminOrGerente, adminLoading }
}

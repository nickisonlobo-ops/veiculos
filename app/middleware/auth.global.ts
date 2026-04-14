import { createSupabaseClient } from '~/lib/supabase'

// Routes that require admin or gerente perfil
const MANAGER_ROUTES = ['/contas-pagar']

export default defineNuxtRouteMiddleware(async (to) => {
  const supabase = createSupabaseClient()
  const { data: { session } } = await supabase.auth.getSession()

  if (to.path === '/login') {
    if (session) return navigateTo('/')
    return
  }

  if (!session) {
    return navigateTo('/login')
  }

  if (MANAGER_ROUTES.includes(to.path)) {
    const { data: profile } = await supabase
      .from('profiles')
      .select('perfil')
      .eq('id', session.user.id)
      .single()

    const perfil = profile?.perfil
    if (perfil !== 'admin' && perfil !== 'gerente') {
      return navigateTo('/')
    }
  }
})

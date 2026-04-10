import { createSupabaseClient } from '~/lib/supabase'

const ADMIN_ROUTES = ['/funcionarios', '/contas-pagar', '/atividades']

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

  const isAdmin = session.user?.email === 'admin@zoocultura.com'
  if (ADMIN_ROUTES.includes(to.path) && !isAdmin) {
    return navigateTo('/')
  }
})

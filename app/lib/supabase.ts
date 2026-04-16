import { createClient, type SupabaseClient } from '@supabase/supabase-js'

let _client: SupabaseClient | null = null

export function createSupabaseClient(): SupabaseClient {
  if (_client) return _client
  const config = useRuntimeConfig()
  _client = createClient(
    config.public.supabaseUrl as string,
    config.public.supabaseKey as string,
  )
  return _client
}

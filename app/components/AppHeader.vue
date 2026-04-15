<template>
  <header class="h-16 bg-gray-950 border-b border-white/[0.07] flex items-center justify-between px-6 shrink-0 shadow-lg">
    <!-- Logo -->
    <div class="flex items-center gap-2.5">
      <div class="w-8 h-8 rounded-xl bg-gradient-to-br from-amber-400 to-amber-600 flex items-center justify-center shadow-md shadow-amber-900/40">
        <svg class="w-4.5 h-4.5 w-[18px] h-[18px] text-gray-950" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24" aria-hidden="true"><path stroke-linecap="round" stroke-linejoin="round" d="M8.25 18.75a1.5 1.5 0 01-3 0m3 0a1.5 1.5 0 00-3 0m3 0h6m-9 0H3.375a1.125 1.125 0 01-1.125-1.125V14.25m17.25 4.5a1.5 1.5 0 01-3 0m3 0a1.5 1.5 0 00-3 0m3 0h1.125c.621 0 1.129-.504 1.09-1.124a17.902 17.902 0 00-3.213-9.193 2.056 2.056 0 00-1.58-.86H14.25M16.5 18.75h-2.25m0-11.177v-.958c0-.568-.422-1.048-.987-1.106a48.554 48.554 0 00-10.026 0 1.106 1.106 0 00-.987 1.106v7.635m12-6.677v6.677m0 4.5v-4.5m0 0h-12"/></svg>
      </div>
      <span class="text-lg font-black text-white tracking-tight">AutoFlow</span>
    </div>

    <!-- Ações -->
    <div class="flex items-center gap-3">
      <span class="text-sm text-gray-400 hidden sm:block">Olá, {{ displayName }}</span>
      <div class="w-9 h-9 rounded-full bg-amber-500 flex items-center justify-center text-gray-950 font-black text-sm select-none shadow">
        {{ initials }}
      </div>
      <button
        type="button"
        class="flex items-center gap-1.5 text-sm text-gray-400 hover:text-white transition-colors px-3 py-1.5 rounded-lg hover:bg-white/10"
        @click="handleLogout"
      >
        <span>Sair</span>
        <svg class="w-4 h-4" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M15.75 9V5.25A2.25 2.25 0 0013.5 3h-6a2.25 2.25 0 00-2.25 2.25v13.5A2.25 2.25 0 007.5 21h6a2.25 2.25 0 002.25-2.25V15m3 0l3-3m0 0l-3-3m3 3H9"/></svg>
      </button>
    </div>
  </header>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useAuth } from '~/composables/useAuth'
import { createSupabaseClient } from '~/lib/supabase'

defineOptions({ name: 'AppHeader' })

const router = useRouter()
const { logout } = useAuth()
const supabase = createSupabaseClient()

const userName = ref('')

onMounted(async () => {
  const { data: { user } } = await supabase.auth.getUser()
  userName.value = user?.user_metadata?.full_name ?? user?.email ?? ''
})

const displayName = computed(() => {
  if (!userName.value) return ''
  return userName.value.split('@')[0]
})

const initials = computed(() => {
  const name = userName.value
  if (!name) return 'U'
  const parts = name.split(' ').filter(Boolean)
  if (parts.length >= 2) return ((parts[0]?.[0] ?? '') + (parts[1]?.[0] ?? '')).toUpperCase()
  return (name[0] ?? 'U').toUpperCase()
})

async function handleLogout() {
  await logout()
  await router.push('/login')
}
</script>


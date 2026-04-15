<template>
  <nav class="fixed bottom-0 inset-x-0 z-40 md:hidden bg-gray-950 border-t border-white/[0.07] flex items-stretch h-16 shadow-2xl">
    <NuxtLink
      v-for="item in navItems"
      :key="item.to"
      :to="item.to"
      exact-active-class="text-amber-400 bg-amber-500/10"
      class="flex-1 flex flex-col items-center justify-center gap-0.5 text-gray-500 hover:text-white hover:bg-white/[0.07] transition-colors text-[10px] font-semibold"
    >
      <AppNavIcon :name="item.icon" class="w-5 h-5" />
      <span>{{ item.label }}</span>
    </NuxtLink>
  </nav>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useAdmin } from '~/composables/useAdmin'
import AppNavIcon from '~/components/AppNavIcon.vue'

defineOptions({ name: 'AppBottomNav' })

const { isAdminOrGerente } = useAdmin()

const allNavItems = [
  { to: '/',             icon: 'home',           label: 'Início',       minPerfil: 'all' },
  { to: '/veiculos',     icon: 'car',            label: 'Veículos',      minPerfil: 'all' },
  { to: '/clientes',     icon: 'identification', label: 'Clientes',     minPerfil: 'all' },
  { to: '/propostas',    icon: 'document',       label: 'Propostas',    minPerfil: 'all' },
  { to: '/vendas',       icon: 'receipt',        label: 'Vendas',       minPerfil: 'all' },
  { to: '/funcionarios', icon: 'users',          label: 'Equipe',       minPerfil: 'manager' },
  { to: '/contas-pagar', icon: 'wallet',         label: 'Contas',       minPerfil: 'manager' },
]

const navItems = computed(() =>
  allNavItems.filter(item => item.minPerfil === 'all' || isAdminOrGerente.value)
)
</script>

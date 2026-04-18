<template>
  <nav class="fixed bottom-0 inset-x-0 z-40 md:hidden bg-white border-t border-pink-100 flex items-stretch h-16 shadow-2xl">
    <NuxtLink
      v-for="item in navItems"
      :key="item.to"
      :to="item.to"
      exact-active-class="nav-item-active"
      class="flex-1 flex flex-col items-center justify-center gap-0.5 transition-colors text-[10px] font-semibold nav-item"
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
  { to: '/',              icon: 'home',           label: 'Início',    minPerfil: 'all' },
  { to: '/agendamentos',  icon: 'calendar',       label: 'Agenda',    minPerfil: 'all' },
  { to: '/veiculos',      icon: 'car',            label: 'Veículos',  minPerfil: 'all' },
  { to: '/clientes',      icon: 'identification', label: 'Clientes',  minPerfil: 'all' },
  { to: '/vendas',        icon: 'receipt',        label: 'Vendas',    minPerfil: 'all' },
  { to: '/estoque',       icon: 'package',        label: 'Estoque',   minPerfil: 'all' },
  { to: '/funcionarios',  icon: 'users',          label: 'Equipe',    minPerfil: 'manager' },
  { to: '/contas-pagar',  icon: 'wallet',         label: 'Contas',    minPerfil: 'manager' },
  { to: '/configuracoes', icon: 'settings',       label: 'Config',    minPerfil: 'manager' },
]

const navItems = computed(() =>
  allNavItems.filter(item => item.minPerfil === 'all' || isAdminOrGerente.value)
)
</script>

<style scoped>
.nav-item {
  color: var(--color-icon, var(--color-primary, #ec4899));
  opacity: 0.45;
}
.nav-item:hover {
  background: var(--color-icon-10, var(--color-primary-10, rgba(236,72,153,0.1)));
  opacity: 0.8;
}
.nav-item-active {
  color: var(--color-icon, var(--color-primary, #ec4899)) !important;
  background-color: var(--color-icon-10, var(--color-primary-10, rgba(236,72,153,0.1))) !important;
  opacity: 1 !important;
}
</style>

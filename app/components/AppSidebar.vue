<template>
  <aside
    class="shrink-0 bg-gray-950 border-r border-white/[0.07] flex flex-col min-h-0 overflow-hidden transition-all duration-300 ease-in-out"
    :class="expanded ? 'w-64' : 'w-16'"
    @mouseenter="expanded = true"
    @mouseleave="expanded = false"
  >
    <!-- Marca lateral -->
    <div class="px-4 py-5 border-b border-white/[0.07] flex items-center gap-3 overflow-hidden">
      <div class="w-7 h-7 rounded-lg bg-amber-500 flex items-center justify-center shrink-0">
        <AppNavIcon name="car" class="w-4 h-4 text-gray-950" />
      </div>
      <p
        class="text-xs font-black uppercase tracking-widest text-amber-400 whitespace-nowrap transition-opacity duration-200"
        :class="expanded ? 'opacity-100' : 'opacity-0'"
      >
        AutoFlow
      </p>
    </div>

    <!-- Links -->
    <nav class="flex-1 px-2 py-4 flex flex-col gap-3 overflow-y-auto overflow-x-hidden">
      <div v-for="section in navSections" :key="section.title" class="flex flex-col gap-1">
        <p
          class="px-3 text-[10px] font-semibold uppercase tracking-widest text-gray-500 whitespace-nowrap transition-opacity duration-200"
          :class="expanded ? 'opacity-100' : 'opacity-0 h-0 overflow-hidden'"
        >
          {{ section.title }}
        </p>
        <NuxtLink
          v-for="item in section.items"
          :key="item.to"
          :to="item.to"
          class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium text-gray-400 hover:bg-white/[0.07] hover:text-white transition-colors overflow-hidden"
          active-class="bg-amber-500/15 text-amber-400 border border-amber-500/20"
        >
          <AppNavIcon :name="item.icon" class="w-5 h-5 shrink-0" />
          <span
            class="whitespace-nowrap transition-opacity duration-200"
            :class="expanded ? 'opacity-100' : 'opacity-0'"
          >
            {{ item.label }}
          </span>
        </NuxtLink>
      </div>
    </nav>

    <!-- Rodapé da sidebar -->
    <div class="px-4 py-4 border-t border-white/[0.07] overflow-hidden">
      <p
        class="text-xs text-gray-600 whitespace-nowrap transition-opacity duration-200"
        :class="expanded ? 'opacity-100' : 'opacity-0'"
      >
        v1.0.0
      </p>
    </div>
  </aside>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useAdmin } from '~/composables/useAdmin'
import AppNavIcon from '~/components/AppNavIcon.vue'

defineOptions({ name: 'AppSidebar' })

const expanded = ref(false)
const { isAdminOrGerente } = useAdmin()

const allNavSections = [
  {
    title: 'Geral',
    items: [
      { to: '/', icon: 'home', label: 'Início', minPerfil: 'all' },
    ],
  },
  {
    title: 'Estoque',
    items: [
      { to: '/veiculos', icon: 'car', label: 'Veículos', minPerfil: 'all' },
    ],
  },
  {
    title: 'Comercial',
    items: [
      { to: '/clientes', icon: 'identification', label: 'Clientes', minPerfil: 'all' },
      { to: '/propostas', icon: 'document', label: 'Propostas', minPerfil: 'all' },
      { to: '/vendas', icon: 'receipt', label: 'Vendas', minPerfil: 'all' },
    ],
  },
  {
    title: 'Operação',
    items: [
      { to: '/funcionarios', icon: 'users', label: 'Funcionários', minPerfil: 'manager' },
      { to: '/atividades', icon: 'clipboard', label: 'Atividades', minPerfil: 'all' },
    ],
  },
  {
    title: 'Financeiro',
    items: [
      { to: '/contas-pagar', icon: 'wallet', label: 'Contas a Pagar', minPerfil: 'manager' },
    ],
  },
]

const navSections = computed(() =>
  allNavSections
    .map(section => ({
      ...section,
      items: section.items.filter(item => item.minPerfil === 'all' || isAdminOrGerente.value),
    }))
    .filter(section => section.items.length > 0)
)
</script>

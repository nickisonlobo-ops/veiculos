<template>
  <div class="min-h-screen bg-gray-50 flex flex-col">
    <!-- Barra superior simples -->
    <header class="px-4 sm:px-8 h-12 flex items-center gap-3 shadow-sm shrink-0" :style="{ background: 'var(--color-primary-bg, #6b7280)' }">
      <div class="w-8 h-8 rounded-lg flex items-center justify-center shrink-0 bg-white/20">
        <svg class="w-4 h-4" :style="{ color: 'var(--color-primary-text, #ffffff)' }" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" d="M8.25 18.75a1.5 1.5 0 01-3 0m3 0a1.5 1.5 0 00-3 0m3 0h6m-9 0H3.375a1.125 1.125 0 01-1.125-1.125V14.25m17.25 4.5a1.5 1.5 0 01-3 0m3 0a1.5 1.5 0 00-3 0m3 0h1.125c.621 0 1.129-.504 1.09-1.124a17.902 17.902 0 00-3.213-9.193 2.056 2.056 0 00-1.58-.86H14.25M16.5 18.75h-2.25m0-11.177v-.958c0-.568-.422-1.048-.987-1.106a48.554 48.554 0 00-10.026 0 1.106 1.106 0 00-.987 1.106v7.635m12-6.677v6.677m0 4.5v-4.5m0 0h-12" />
        </svg>
      </div>
      <span class="text-sm font-black uppercase tracking-widest" :style="{ color: 'var(--color-primary-text, #ffffff)' }">{{ nomeEmpresa }}</span>
    </header>

    <main class="flex-1 p-3 sm:p-8">
      <!-- Logo centralizado entre o header e o catálogo -->
      <div v-if="tema.logo_url" class="flex items-center justify-center mb-6">
        <img
          :src="tema.logo_url"
          alt="Logo"
          class="object-contain"
          :style="{ height: '140px', width: 'auto', maxWidth: '400px' }"
        />
      </div>
      <slot />
    </main>

    <footer class="text-center text-xs text-gray-400 py-6 border-t border-gray-200">
      {{ nomeEmpresa }}
    </footer>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { usePersonalizacao } from '~/composables/usePersonalizacao'

const route = useRoute()
const { config: tema, loadPersonalizacaoPublic } = usePersonalizacao()

const nomeEmpresa = computed(() => tema.value.nome_empresa || '')

function logoSizeToPx(s: string): number {
  const num = parseInt(s)
  if (!isNaN(num)) return num
  switch (s) {
    case 'sm':  return 28
    case 'lg':  return 44
    case 'xl':  return 56
    case '2xl': return 72
    default:    return 32
  }
}

const logoSizePx = computed(() => logoSizeToPx(tema.value.logo_size ?? 'md'))

const headerHeight = computed(() => {
  if (!tema.value.logo_url) return 48
  const px = logoSizePx.value
  if (px <= 28) return 48
  if (px <= 32) return 56
  if (px <= 44) return 64
  if (px <= 56) return 72
  if (px <= 72) return 88
  return 104
})

onMounted(async () => {
  const eId = Number(route.query.e ?? 0)
  if (eId) {
    await loadPersonalizacaoPublic(eId)
  }
})
</script>

<template>
  <div>
    <!-- Loading -->
    <div v-if="loading" class="flex flex-col items-center justify-center gap-4 py-32">
      <span class="inline-block w-12 h-12 border-4 border-amber-500 border-t-transparent rounded-full animate-spin" />
      <span class="text-sm text-gray-400 font-medium">Carregando veículo...</span>
    </div>

    <!-- Não encontrado -->
    <div v-else-if="!veiculo" class="flex flex-col items-center justify-center gap-4 py-32">
      <svg class="w-16 h-16 text-gray-300" fill="none" stroke="currentColor" stroke-width="1.25" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M8.25 18.75a1.5 1.5 0 01-3 0m3 0a1.5 1.5 0 00-3 0m3 0h6m-9 0H3.375a1.125 1.125 0 01-1.125-1.125V14.25m17.25 4.5a1.5 1.5 0 01-3 0m3 0a1.5 1.5 0 00-3 0m3 0h1.125c.621 0 1.129-.504 1.09-1.124a17.902 17.902 0 00-3.213-9.193 2.056 2.056 0 00-1.58-.86H14.25M16.5 18.75h-2.25m0-11.177v-.958c0-.568-.422-1.048-.987-1.106a48.554 48.554 0 00-10.026 0 1.106 1.106 0 00-.987 1.106v7.635m12-6.677v6.677m0 4.5v-4.5m0 0h-12"/></svg>
      <p class="text-base font-semibold text-gray-400">Veículo não encontrado.</p>
      <NuxtLink :to="voltarUrl" class="inline-flex items-center gap-2 text-sm font-bold text-amber-600 hover:underline">
        <svg class="w-4 h-4" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M10.5 19.5L3 12m0 0l7.5-7.5M3 12h18"/></svg>
        Voltar ao catálogo
      </NuxtLink>
    </div>

    <!-- Conteúdo -->
    <div v-else>
      <NuxtLink :to="voltarUrl" class="inline-flex items-center gap-2 text-sm font-semibold text-gray-500 hover:text-gray-800 mb-6 group transition-colors">
        <svg class="w-4 h-4 group-hover:-translate-x-0.5 transition-transform" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M10.5 19.5L3 12m0 0l7.5-7.5M3 12h18"/></svg>
        Voltar ao catálogo
      </NuxtLink>

      <div class="grid grid-cols-1 lg:grid-cols-5 gap-6 lg:gap-8">

        <!-- Galeria -->
        <div class="lg:col-span-3 flex flex-col gap-3">
          <div class="relative rounded-2xl overflow-hidden bg-gradient-to-br from-gray-100 to-gray-200 shadow-md" style="aspect-ratio:16/9">
            <img
              v-if="fotos.length > 0"
              :src="fotos[fotoAtiva]"
              :alt="`${veiculo.marca} ${veiculo.modelo}`"
              class="absolute inset-0 w-full h-full object-cover"
            />
            <div v-else class="absolute inset-0 flex items-center justify-center">
              <svg class="w-24 h-24 text-gray-300" fill="none" stroke="currentColor" stroke-width="1" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M8.25 18.75a1.5 1.5 0 01-3 0m3 0a1.5 1.5 0 00-3 0m3 0h6m-9 0H3.375a1.125 1.125 0 01-1.125-1.125V14.25m17.25 4.5a1.5 1.5 0 01-3 0m3 0a1.5 1.5 0 00-3 0m3 0h1.125c.621 0 1.129-.504 1.09-1.124a17.902 17.902 0 00-3.213-9.193 2.056 2.056 0 00-1.58-.86H14.25M16.5 18.75h-2.25m0-11.177v-.958c0-.568-.422-1.048-.987-1.106a48.554 48.554 0 00-10.026 0 1.106 1.106 0 00-.987 1.106v7.635m12-6.677v6.677m0 4.5v-4.5m0 0h-12"/></svg>
            </div>

            <template v-if="fotos.length > 1">
              <button type="button" class="absolute left-3 top-1/2 -translate-y-1/2 w-9 h-9 rounded-full bg-black/50 hover:bg-black/70 flex items-center justify-center text-white transition-colors" @click="fotoAtiva = (fotoAtiva - 1 + fotos.length) % fotos.length">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M15.75 19.5L8.25 12l7.5-7.5"/></svg>
              </button>
              <button type="button" class="absolute right-3 top-1/2 -translate-y-1/2 w-9 h-9 rounded-full bg-black/50 hover:bg-black/70 flex items-center justify-center text-white transition-colors" @click="fotoAtiva = (fotoAtiva + 1) % fotos.length">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M8.25 4.5l7.5 7.5-7.5 7.5"/></svg>
              </button>
              <span class="absolute bottom-3 right-3 text-[11px] font-bold bg-black/60 text-white px-2.5 py-1 rounded-full">
                {{ fotoAtiva + 1 }} / {{ fotos.length }}
              </span>
            </template>

            <span
              class="absolute top-3 left-3 text-xs font-black px-3 py-1 rounded-full uppercase tracking-wide shadow"
              :class="veiculo.status === 'disponivel' ? 'bg-amber-400 text-gray-950' : veiculo.status === 'reservado' ? 'bg-blue-500 text-white' : 'bg-gray-700 text-white'"
            >
              {{ statusLabel(veiculo.status) }}
            </span>
          </div>

          <div v-if="fotos.length > 1" class="flex gap-2 overflow-x-auto pb-1">
            <button
              v-for="(url, i) in fotos" :key="i"
              type="button"
              class="flex-shrink-0 w-16 h-12 rounded-xl overflow-hidden border-2 transition-all"
              :class="fotoAtiva === i ? 'border-amber-500 shadow-md' : 'border-transparent opacity-60 hover:opacity-90'"
              @click="fotoAtiva = i"
            >
              <img :src="url" class="w-full h-full object-cover" />
            </button>
          </div>
        </div>

        <!-- Painel de informações -->
        <div class="lg:col-span-2 flex flex-col gap-4">

          <!-- Título + Preço -->
          <div class="bg-white rounded-2xl border border-gray-100 shadow-sm px-6 py-5">
            <div class="flex items-start justify-between gap-3 mb-1">
              <h1 class="text-2xl sm:text-3xl font-black text-gray-900 leading-tight">{{ veiculo.marca }} {{ veiculo.modelo }}</h1>
              <span v-if="veiculo.tipo" class="shrink-0 text-xs font-bold bg-gray-100 text-gray-600 px-3 py-1 rounded-full mt-1">{{ veiculo.tipo }}</span>
            </div>
            <p class="text-sm text-gray-400 mb-4">{{ anoLabel }}<span v-if="veiculo.cor"> • {{ veiculo.cor }}</span></p>
            <div class="h-px bg-gray-100 mb-4" />
            <p class="text-xs text-gray-400 uppercase tracking-widest font-semibold mb-1">Preço de venda</p>
            <p class="text-3xl font-black text-gray-900">{{ formatCurrency(veiculo.preco_venda) }}</p>
          </div>

          <!-- Especificações -->
          <div class="bg-white rounded-2xl border border-gray-100 shadow-sm px-6 py-5">
            <h2 class="text-sm font-bold text-gray-700 uppercase tracking-widest mb-4">Especificações</h2>
            <div class="grid grid-cols-2 gap-x-6 gap-y-3">
              <div v-if="veiculo.ano_fabricacao" class="flex flex-col gap-0.5">
                <span class="text-[10px] font-semibold text-gray-400 uppercase tracking-widest">Ano Fab.</span>
                <span class="text-sm font-bold text-gray-800">{{ veiculo.ano_fabricacao }}</span>
              </div>
              <div v-if="veiculo.ano_modelo" class="flex flex-col gap-0.5">
                <span class="text-[10px] font-semibold text-gray-400 uppercase tracking-widest">Ano Modelo</span>
                <span class="text-sm font-bold text-gray-800">{{ veiculo.ano_modelo }}</span>
              </div>
              <div v-if="veiculo.km != null" class="flex flex-col gap-0.5">
                <span class="text-[10px] font-semibold text-gray-400 uppercase tracking-widest">Quilometragem</span>
                <span class="text-sm font-bold text-gray-800">{{ veiculo.km.toLocaleString('pt-BR') }} km</span>
              </div>
              <div v-if="veiculo.combustivel" class="flex flex-col gap-0.5">
                <span class="text-[10px] font-semibold text-gray-400 uppercase tracking-widest">Combustível</span>
                <span class="text-sm font-bold text-gray-800">{{ veiculo.combustivel }}</span>
              </div>
              <div v-if="veiculo.cambio" class="flex flex-col gap-0.5">
                <span class="text-[10px] font-semibold text-gray-400 uppercase tracking-widest">Câmbio</span>
                <span class="text-sm font-bold text-gray-800">{{ veiculo.cambio }}</span>
              </div>
              <div v-if="veiculo.cor" class="flex flex-col gap-0.5">
                <span class="text-[10px] font-semibold text-gray-400 uppercase tracking-widest">Cor</span>
                <span class="text-sm font-bold text-gray-800">{{ veiculo.cor }}</span>
              </div>
              <div v-if="veiculo.cilindrada" class="flex flex-col gap-0.5">
                <span class="text-[10px] font-semibold text-gray-400 uppercase tracking-widest">Cilindrada</span>
                <span class="text-sm font-bold text-gray-800">{{ veiculo.cilindrada }} cc</span>
              </div>
              <div v-if="veiculo.placa" class="flex flex-col gap-0.5">
                <span class="text-[10px] font-semibold text-gray-400 uppercase tracking-widest">Placa</span>
                <span class="text-sm font-black text-gray-800 font-mono bg-gray-100 px-2 py-0.5 rounded-lg inline-block">{{ veiculo.placa }}</span>
              </div>
            </div>
          </div>

          <!-- Observações -->
          <div v-if="veiculo.observacao" class="bg-amber-50 border border-amber-100 rounded-2xl px-6 py-5">
            <h2 class="text-sm font-bold text-amber-700 uppercase tracking-widest mb-2">Observações</h2>
            <p class="text-sm text-amber-900 leading-relaxed whitespace-pre-line">{{ veiculo.observacao }}</p>
          </div>

        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { createSupabaseClient } from '~/lib/supabase'

definePageMeta({ layout: 'public' })

interface Veiculo {
  id: number
  marca: string
  modelo: string
  ano_fabricacao: number | null
  ano_modelo: number | null
  tipo: string | null
  placa: string | null
  cor: string | null
  km: number | null
  combustivel: string | null
  cambio: string | null
  cilindrada: number | null
  preco_venda: number
  status: string | null
  fotos: string[] | null
  observacao: string | null
}

const route = useRoute()
const supabase = createSupabaseClient()

const veiculo   = ref<Veiculo | null>(null)
const loading   = ref(true)
const fotoAtiva = ref(0)

const fotos = computed(() => veiculo.value?.fotos ?? [])
const voltarUrl = computed(() => `/loja?e=${route.query.e ?? ''}`)
const anoLabel = computed(() => {
  if (!veiculo.value) return ''
  const fab = veiculo.value.ano_fabricacao
  const mod = veiculo.value.ano_modelo
  if (!fab) return ''
  return mod && mod !== fab ? `${fab}/${mod}` : String(fab)
})

onMounted(async () => {
  const id = Number(route.params.id)
  if (!id) { loading.value = false; return }
  const { data } = await supabase
    .from('veiculos')
    .select('id,marca,modelo,ano_fabricacao,ano_modelo,tipo,placa,cor,km,combustivel,cambio,cilindrada,preco_venda,status,fotos,observacao')
    .eq('id', id)
    .maybeSingle()
  veiculo.value = data as Veiculo | null
  loading.value = false
})

function formatCurrency(val: number | null | undefined) {
  if (val == null) return '—'
  return val.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' })
}
function statusLabel(s: string | null) {
  const map: Record<string, string> = { disponivel: 'Disponível', reservado: 'Reservado', vendido: 'Vendido', manutencao: 'Manutenção' }
  return map[s ?? ''] ?? s ?? '—'
}
</script>

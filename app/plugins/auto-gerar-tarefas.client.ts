import { gerarTarefasDiarias, chaveGeracaoHoje } from '~/composables/useGerarTarefas'
import { createSupabaseClient } from '~/lib/supabase'

/**
 * Plugin client-side: roda uma vez por dia (controle via localStorage).
 * Somente o admin dispara a geraÃ§Ã£o automÃ¡tica de tarefas.
 * Qualquer usuÃ¡rio admin que abrir o app no dia ainda sem geraÃ§Ã£o irÃ¡ criar as instÃ¢ncias.
 */
export default defineNuxtPlugin(async () => {
  // SÃ³ roda no cliente
  if (typeof window === 'undefined') return

  const chave = chaveGeracaoHoje()

  // JÃ¡ gerou hoje? Sai sem fazer nada
  if (localStorage.getItem(chave)) return

  const supabase = createSupabaseClient()
  const { data: { session } } = await supabase.auth.getSession()

  if (!session) return

  // Somente admin dispara a geraÃ§Ã£o automÃ¡tica
  if (session.user?.email !== 'admin@zoocultura.com') return

  const resultado = await gerarTarefasDiarias()

  // Marca como gerado hoje (mesmo se nÃ£o havia modelos, evita chamadas repetidas)
  localStorage.setItem(chave, String(resultado.geradas))

  if (resultado.erro) {
    console.error('[PetFlow] Erro ao gerar tarefas diÃ¡rias:', resultado.erro)
  } else if (resultado.geradas > 0) {
    console.info(`[PetFlow] ${resultado.geradas} tarefa(s) gerada(s) automaticamente para hoje.`)
  }
})

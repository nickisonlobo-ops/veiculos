-- ============================================================
-- AutoFlow — Vincular estoque de veículos às vendas
-- Execute este arquivo no SQL Editor do Supabase
-- ============================================================

-- 1. Adiciona coluna de vínculo com o veículo vendido
ALTER TABLE public.vendas
  ADD COLUMN IF NOT EXISTS veiculo_id bigint REFERENCES public.veiculos(id) ON DELETE SET NULL;

-- 2. Armazena o preço negociado do veículo no momento da venda
ALTER TABLE public.vendas
  ADD COLUMN IF NOT EXISTS preco_veiculo numeric(12,2);

-- Índice para facilitar buscas por venda de um veículo específico
CREATE INDEX IF NOT EXISTS idx_vendas_veiculo_id ON public.vendas(veiculo_id);

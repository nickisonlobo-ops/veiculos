-- ============================================================
-- AutoFlow — Política de acesso público (anônimo) ao catálogo
-- Execute este arquivo no SQL Editor do Supabase
-- ============================================================

-- Permite que usuários NÃO autenticados (anon) leiam veículos
-- disponíveis ou reservados, sem exigir login.
DROP POLICY IF EXISTS "veiculos_public_read" ON public.veiculos;
CREATE POLICY "veiculos_public_read" ON public.veiculos
  FOR SELECT TO anon
  USING (status IN ('disponivel', 'reservado'));

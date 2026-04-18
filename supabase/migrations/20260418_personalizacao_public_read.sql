-- ============================================================
-- Permite leitura pública (anon) da personalização da empresa
-- e do nome da empresa — necessário para páginas públicas /loja
-- ============================================================

DROP POLICY IF EXISTS "personalizacao_public_read" ON public.empresa_personalizacao;

CREATE POLICY "personalizacao_public_read" ON public.empresa_personalizacao
  FOR SELECT TO anon
  USING (true);

-- Permite que usuários anônimos leiam o nome da empresa (usado como fallback)
DROP POLICY IF EXISTS "empresas_public_read" ON public.empresas;
DROP POLICY IF EXISTS "empresas_select" ON public.empresas;

CREATE POLICY "empresas_public_read" ON public.empresas
  FOR SELECT TO anon
  USING (true);

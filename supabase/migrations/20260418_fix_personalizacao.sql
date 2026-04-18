-- ============================================================
-- FIX: Garante que a tabela empresa_personalizacao existe
-- com todas as colunas necessárias. Execute no SQL Editor.
-- ============================================================

-- 1. Cria a tabela caso não exista (com TODOS os campos)
CREATE TABLE IF NOT EXISTS public.empresa_personalizacao (
  id                 bigserial    PRIMARY KEY,
  empresa_id         bigint       NOT NULL UNIQUE REFERENCES public.empresas(id) ON DELETE CASCADE,
  cor_primaria       text         NOT NULL DEFAULT '#6b7280',
  cor_primaria_texto text         NOT NULL DEFAULT '#ffffff',
  cor_fundo          text         NOT NULL DEFAULT '#f9fafb',
  cor_sidebar        text         NOT NULL DEFAULT '#ffffff',
  cor_primaria_grad  text,
  cor_fundo_grad     text,
  cor_sidebar_grad   text,
  cor_card           text         NOT NULL DEFAULT '#ffffff',
  cor_card_texto     text         NOT NULL DEFAULT '#374151',
  cor_card_grad      text,
  grad_direction     text         NOT NULL DEFAULT '135deg',
  logo_size          text         NOT NULL DEFAULT 'md',
  nome_empresa       text,
  logo_url           text,
  updated_at         timestamptz  DEFAULT now(),
  created_at         timestamptz  DEFAULT now()
);

-- 2. Adiciona colunas que podem estar faltando em tabelas já existentes
ALTER TABLE public.empresa_personalizacao
  ADD COLUMN IF NOT EXISTS cor_card        text NOT NULL DEFAULT '#ffffff',
  ADD COLUMN IF NOT EXISTS cor_card_texto  text NOT NULL DEFAULT '#374151',
  ADD COLUMN IF NOT EXISTS cor_card_grad   text,
  ADD COLUMN IF NOT EXISTS logo_size       text NOT NULL DEFAULT 'md',
  ADD COLUMN IF NOT EXISTS cor_botao       text NOT NULL DEFAULT '#6b7280',
  ADD COLUMN IF NOT EXISTS cor_botao_texto text NOT NULL DEFAULT '#ffffff',
  ADD COLUMN IF NOT EXISTS cor_icone       text NOT NULL DEFAULT '#6b7280';

-- 3. RLS
ALTER TABLE public.empresa_personalizacao ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "personalizacao_select" ON public.empresa_personalizacao;
DROP POLICY IF EXISTS "personalizacao_upsert" ON public.empresa_personalizacao;
DROP POLICY IF EXISTS "personalizacao_insert" ON public.empresa_personalizacao;
DROP POLICY IF EXISTS "personalizacao_update" ON public.empresa_personalizacao;

-- Leitura: qualquer autenticado da empresa
CREATE POLICY "personalizacao_select" ON public.empresa_personalizacao
  FOR SELECT TO authenticated
  USING (
    empresa_id IN (
      SELECT empresa_id FROM public.profiles WHERE id = auth.uid()
    )
  );

-- Escrita: apenas admin/gerente
CREATE POLICY "personalizacao_upsert" ON public.empresa_personalizacao
  FOR ALL TO authenticated
  USING (
    empresa_id IN (
      SELECT empresa_id FROM public.profiles
      WHERE id = auth.uid() AND perfil IN ('admin', 'gerente')
    )
  )
  WITH CHECK (
    empresa_id IN (
      SELECT empresa_id FROM public.profiles
      WHERE id = auth.uid() AND perfil IN ('admin', 'gerente')
    )
  );

-- 4. Storage bucket para logos
INSERT INTO storage.buckets (id, name, public)
VALUES ('empresa-assets', 'empresa-assets', true)
ON CONFLICT (id) DO NOTHING;

DROP POLICY IF EXISTS "logos_public_read"   ON storage.objects;
DROP POLICY IF EXISTS "logos_auth_upload"   ON storage.objects;
DROP POLICY IF EXISTS "logos_auth_update"   ON storage.objects;
DROP POLICY IF EXISTS "logos_auth_delete"   ON storage.objects;

CREATE POLICY "logos_public_read" ON storage.objects
  FOR SELECT TO public
  USING (bucket_id = 'empresa-assets');

CREATE POLICY "logos_auth_upload" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'empresa-assets');

CREATE POLICY "logos_auth_update" ON storage.objects
  FOR UPDATE TO authenticated
  USING (bucket_id = 'empresa-assets');

CREATE POLICY "logos_auth_delete" ON storage.objects
  FOR DELETE TO authenticated
  USING (bucket_id = 'empresa-assets');

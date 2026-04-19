-- Adiciona colunas extras usadas pelo sistema em atividades_funcionarios

ALTER TABLE public.atividades_funcionarios
  ADD COLUMN IF NOT EXISTS periodicidade text NULL,
  ADD COLUMN IF NOT EXISTS prioridade text NOT NULL DEFAULT 'media',
  ADD COLUMN IF NOT EXISTS hora_inicio time NULL,
  ADD COLUMN IF NOT EXISTS hora_fim time NULL,
  ADD COLUMN IF NOT EXISTS observacao text NULL;

ALTER TABLE public.atividades_funcionarios
  ADD CONSTRAINT atividades_funcionarios_periodicidade_check CHECK (
    periodicidade IS NULL OR periodicidade = ANY (ARRAY['diaria'::text, 'quinzenal'::text, 'mensal'::text])
  ),
  ADD CONSTRAINT atividades_funcionarios_prioridade_check CHECK (
    prioridade = ANY (ARRAY['baixa'::text, 'media'::text, 'alta'::text, 'urgente'::text])
  );

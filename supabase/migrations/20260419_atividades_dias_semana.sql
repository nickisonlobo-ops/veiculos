-- Adiciona coluna dias_semana para modelos de atividade
-- Array de dias: 'dom', 'seg', 'ter', 'qua', 'qui', 'sex', 'sab'
-- NULL ou array vazio = gera em todos os dias conforme periodicidade

ALTER TABLE public.atividades_funcionarios
  ADD COLUMN IF NOT EXISTS dias_semana text[] NULL;

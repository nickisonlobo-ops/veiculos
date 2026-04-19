-- Torna data_atividade nullable para suportar modelos recorrentes
-- Modelos têm data_atividade = NULL (recorrência via periodicidade)
-- Instâncias têm data_atividade preenchida (geradas pelo sistema ou manualmente)

ALTER TABLE public.atividades_funcionarios
  ALTER COLUMN data_atividade DROP NOT NULL;

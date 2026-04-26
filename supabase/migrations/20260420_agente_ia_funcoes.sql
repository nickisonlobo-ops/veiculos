-- ============================================================
-- FUNÇÕES RPC PARA O AGENTE DE IA NO N8N
-- Execute no Supabase SQL Editor
-- Cada função se torna uma "Tool" disponível para o agente
-- ============================================================


-- ══════════════════════════════════════════════════════════════
-- 1. VEÍCULOS
-- ══════════════════════════════════════════════════════════════

-- Buscar veículos com filtros opcionais
CREATE OR REPLACE FUNCTION public.agente_buscar_veiculos(
  p_empresa_id   bigint,
  p_status       text    DEFAULT NULL,
  p_marca        text    DEFAULT NULL,
  p_modelo       text    DEFAULT NULL,
  p_preco_min    numeric DEFAULT NULL,
  p_preco_max    numeric DEFAULT NULL,
  p_limite       int     DEFAULT 20
)
RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER
AS $$
BEGIN
  RETURN (
    SELECT jsonb_agg(row_to_json(v))
    FROM (
      SELECT id, marca, modelo, ano_fabricacao, ano_modelo, tipo,
             placa, cor, km, combustivel, cambio, preco_venda, status, observacao
      FROM public.veiculos
      WHERE empresa_id = p_empresa_id
        AND (p_status  IS NULL OR status = p_status)
        AND (p_marca   IS NULL OR marca  ILIKE '%' || p_marca  || '%')
        AND (p_modelo  IS NULL OR modelo ILIKE '%' || p_modelo || '%')
        AND (p_preco_min IS NULL OR preco_venda >= p_preco_min)
        AND (p_preco_max IS NULL OR preco_venda <= p_preco_max)
      ORDER BY created_at DESC
      LIMIT p_limite
    ) v
  );
END;
$$;

-- Resumo do estoque de veículos
CREATE OR REPLACE FUNCTION public.agente_resumo_estoque(
  p_empresa_id bigint
)
RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER
AS $$
DECLARE
  v_result jsonb;
BEGIN
  SELECT jsonb_build_object(
    'total',      COUNT(*),
    'disponivel', COUNT(*) FILTER (WHERE status = 'disponivel'),
    'reservado',  COUNT(*) FILTER (WHERE status = 'reservado'),
    'vendido',    COUNT(*) FILTER (WHERE status = 'vendido'),
    'valor_total_estoque', COALESCE(SUM(preco_venda) FILTER (WHERE status = 'disponivel'), 0),
    'por_marca', (
      SELECT jsonb_agg(jsonb_build_object('marca', marca, 'quantidade', qtd))
      FROM (
        SELECT marca, COUNT(*) AS qtd
        FROM public.veiculos
        WHERE empresa_id = p_empresa_id AND status = 'disponivel'
        GROUP BY marca ORDER BY qtd DESC
      ) m
    )
  )
  INTO v_result
  FROM public.veiculos
  WHERE empresa_id = p_empresa_id;

  RETURN v_result;
END;
$$;


-- ══════════════════════════════════════════════════════════════
-- 2. CLIENTES
-- ══════════════════════════════════════════════════════════════

-- Buscar clientes por nome, email ou CPF
CREATE OR REPLACE FUNCTION public.agente_buscar_clientes(
  p_empresa_id bigint,
  p_busca      text    DEFAULT NULL,
  p_limite     int     DEFAULT 20
)
RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER
AS $$
BEGIN
  RETURN (
    SELECT jsonb_agg(row_to_json(c))
    FROM (
      SELECT id, nome, email, telefone, cpf, endereco, ativo, created_at
      FROM public.clientes
      WHERE empresa_id = p_empresa_id
        AND (
          p_busca IS NULL
          OR nome     ILIKE '%' || p_busca || '%'
          OR email    ILIKE '%' || p_busca || '%'
          OR cpf      ILIKE '%' || p_busca || '%'
          OR telefone ILIKE '%' || p_busca || '%'
        )
        AND ativo = true
      ORDER BY nome ASC
      LIMIT p_limite
    ) c
  );
END;
$$;

-- Criar novo cliente
CREATE OR REPLACE FUNCTION public.agente_criar_cliente(
  p_empresa_id bigint,
  p_nome       text,
  p_email      text    DEFAULT NULL,
  p_telefone   text    DEFAULT NULL,
  p_cpf        text    DEFAULT NULL,
  p_endereco   text    DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER
AS $$
DECLARE
  v_id bigint;
BEGIN
  INSERT INTO public.clientes (empresa_id, nome, email, telefone, cpf, endereco)
  VALUES (p_empresa_id, p_nome, p_email, p_telefone, p_cpf, p_endereco)
  RETURNING id INTO v_id;

  RETURN jsonb_build_object(
    'sucesso', true,
    'id', v_id,
    'mensagem', 'Cliente ' || p_nome || ' criado com sucesso.'
  );
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('sucesso', false, 'erro', SQLERRM);
END;
$$;


-- ══════════════════════════════════════════════════════════════
-- 3. VENDAS
-- ══════════════════════════════════════════════════════════════

-- Registrar uma venda
CREATE OR REPLACE FUNCTION public.agente_registrar_venda(
  p_empresa_id   bigint,
  p_veiculo_id   bigint,
  p_cliente_id   bigint,
  p_preco_venda  numeric,
  p_observacoes  text    DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER
AS $$
DECLARE
  v_venda_id bigint;
  v_veiculo  record;
BEGIN
  -- Verificar se o veículo pertence à empresa e está disponível
  SELECT id, marca, modelo, status
  INTO v_veiculo
  FROM public.veiculos
  WHERE id = p_veiculo_id AND empresa_id = p_empresa_id;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('sucesso', false, 'erro', 'Veículo não encontrado.');
  END IF;

  IF v_veiculo.status != 'disponivel' THEN
    RETURN jsonb_build_object(
      'sucesso', false,
      'erro', 'Veículo não está disponível. Status atual: ' || v_veiculo.status
    );
  END IF;

  -- Criar a venda
  INSERT INTO public.vendas (empresa_id, cliente_id, veiculo_id, preco_veiculo, status, observacoes)
  VALUES (p_empresa_id, p_cliente_id, p_veiculo_id, p_preco_venda, 'concluida', p_observacoes)
  RETURNING id INTO v_venda_id;

  -- Atualizar status do veículo
  UPDATE public.veiculos SET status = 'vendido' WHERE id = p_veiculo_id;

  RETURN jsonb_build_object(
    'sucesso', true,
    'venda_id', v_venda_id,
    'mensagem', 'Venda do veículo ' || v_veiculo.marca || ' ' || v_veiculo.modelo || ' registrada com sucesso.'
  );
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('sucesso', false, 'erro', SQLERRM);
END;
$$;

-- Listar vendas com detalhes
CREATE OR REPLACE FUNCTION public.agente_listar_vendas(
  p_empresa_id bigint,
  p_mes        int     DEFAULT NULL,
  p_ano        int     DEFAULT NULL,
  p_limite     int     DEFAULT 20
)
RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER
AS $$
BEGIN
  RETURN (
    SELECT jsonb_agg(row_to_json(v))
    FROM (
      SELECT
        v.id,
        v.data_venda,
        v.preco_veiculo,
        v.status,
        v.observacoes,
        c.nome  AS cliente_nome,
        c.telefone AS cliente_telefone,
        ve.marca || ' ' || ve.modelo || ' (' || COALESCE(ve.ano_modelo::text, '') || ')' AS veiculo
      FROM public.vendas v
      LEFT JOIN public.clientes  c  ON c.id  = v.cliente_id
      LEFT JOIN public.veiculos  ve ON ve.id = v.veiculo_id
      WHERE v.empresa_id = p_empresa_id
        AND (p_mes IS NULL OR EXTRACT(MONTH FROM v.data_venda) = p_mes)
        AND (p_ano IS NULL OR EXTRACT(YEAR  FROM v.data_venda) = p_ano)
      ORDER BY v.data_venda DESC
      LIMIT p_limite
    ) v
  );
END;
$$;


-- ══════════════════════════════════════════════════════════════
-- 4. PROPOSTAS
-- ══════════════════════════════════════════════════════════════

-- Criar proposta de venda
CREATE OR REPLACE FUNCTION public.agente_criar_proposta(
  p_empresa_id bigint,
  p_cliente_id bigint,
  p_veiculo_id bigint,
  p_valor      numeric,
  p_observacoes text   DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER
AS $$
DECLARE
  v_id bigint;
BEGIN
  INSERT INTO public.propostas (empresa_id, cliente_id, veiculo_id, valor, observacoes)
  VALUES (p_empresa_id, p_cliente_id, p_veiculo_id, p_valor, p_observacoes)
  RETURNING id INTO v_id;

  RETURN jsonb_build_object('sucesso', true, 'proposta_id', v_id,
    'mensagem', 'Proposta criada com sucesso no valor de R$ ' || p_valor || '.');
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('sucesso', false, 'erro', SQLERRM);
END;
$$;

-- Listar propostas abertas
CREATE OR REPLACE FUNCTION public.agente_listar_propostas(
  p_empresa_id bigint,
  p_status     text   DEFAULT 'aberta'
)
RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER
AS $$
BEGIN
  RETURN (
    SELECT jsonb_agg(row_to_json(p))
    FROM (
      SELECT
        pr.id,
        pr.valor,
        pr.status,
        pr.observacoes,
        pr.created_at,
        c.nome  AS cliente_nome,
        c.telefone AS cliente_telefone,
        ve.marca || ' ' || ve.modelo AS veiculo,
        ve.preco_venda AS preco_veiculo
      FROM public.propostas pr
      LEFT JOIN public.clientes c  ON c.id  = pr.cliente_id
      LEFT JOIN public.veiculos ve ON ve.id = pr.veiculo_id
      WHERE pr.empresa_id = p_empresa_id
        AND (p_status IS NULL OR pr.status = p_status)
      ORDER BY pr.created_at DESC
    ) p
  );
END;
$$;


-- ══════════════════════════════════════════════════════════════
-- 5. FINANCEIRO
-- ══════════════════════════════════════════════════════════════

-- Resumo financeiro do mês
CREATE OR REPLACE FUNCTION public.agente_resumo_financeiro(
  p_empresa_id bigint,
  p_mes        int    DEFAULT EXTRACT(MONTH FROM CURRENT_DATE)::int,
  p_ano        int    DEFAULT EXTRACT(YEAR  FROM CURRENT_DATE)::int
)
RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER
AS $$
DECLARE
  v_vendas      numeric;
  v_despesas    numeric;
  v_qtd_vendas  int;
  v_contas      jsonb;
BEGIN
  -- Total de vendas no mês
  SELECT
    COALESCE(SUM(preco_veiculo), 0),
    COUNT(*)
  INTO v_vendas, v_qtd_vendas
  FROM public.vendas
  WHERE empresa_id = p_empresa_id
    AND status = 'concluida'
    AND EXTRACT(MONTH FROM data_venda) = p_mes
    AND EXTRACT(YEAR  FROM data_venda) = p_ano;

  -- Total de contas a pagar no mês
  SELECT COALESCE(SUM(valor), 0)
  INTO v_despesas
  FROM public.contas_pagar
  WHERE empresa_id = p_empresa_id
    AND EXTRACT(MONTH FROM data_vencimento) = p_mes
    AND EXTRACT(YEAR  FROM data_vencimento) = p_ano
    AND status IN ('pendente', 'pago');

  -- Contas vencidas
  SELECT jsonb_agg(jsonb_build_object(
    'id', id, 'descricao', descricao,
    'valor', valor, 'vencimento', data_vencimento
  ))
  INTO v_contas
  FROM public.contas_pagar
  WHERE empresa_id = p_empresa_id
    AND status = 'pendente'
    AND data_vencimento < CURRENT_DATE;

  RETURN jsonb_build_object(
    'mes',               p_mes,
    'ano',               p_ano,
    'receita_vendas',    v_vendas,
    'quantidade_vendas', v_qtd_vendas,
    'despesas_mes',      v_despesas,
    'lucro_estimado',    v_vendas - v_despesas,
    'contas_vencidas',   COALESCE(v_contas, '[]'::jsonb)
  );
END;
$$;

-- Listar contas a pagar
CREATE OR REPLACE FUNCTION public.agente_listar_contas_pagar(
  p_empresa_id bigint,
  p_status     text   DEFAULT NULL,
  p_limite     int    DEFAULT 20
)
RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER
AS $$
BEGIN
  RETURN (
    SELECT jsonb_agg(row_to_json(c))
    FROM (
      SELECT id, descricao, valor, data_vencimento, data_pagamento, status, categoria
      FROM public.contas_pagar
      WHERE empresa_id = p_empresa_id
        AND (p_status IS NULL OR status = p_status)
      ORDER BY data_vencimento ASC
      LIMIT p_limite
    ) c
  );
END;
$$;


-- ══════════════════════════════════════════════════════════════
-- 6. AGENDAMENTOS
-- ══════════════════════════════════════════════════════════════

-- Buscar agendamentos por data
CREATE OR REPLACE FUNCTION public.agente_buscar_agendamentos(
  p_empresa_id bigint,
  p_data_inicio date   DEFAULT CURRENT_DATE,
  p_data_fim    date   DEFAULT CURRENT_DATE,
  p_status      text   DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER
AS $$
BEGIN
  RETURN (
    SELECT jsonb_agg(row_to_json(a))
    FROM (
      SELECT
        ag.id,
        ag.data_hora,
        ag.status,
        ag.valor_total,
        ag.observacoes,
        c.nome     AS cliente_nome,
        c.telefone AS cliente_telefone
      FROM public.agendamentos ag
      LEFT JOIN public.clientes c ON c.id = ag.cliente_id
      WHERE ag.empresa_id = p_empresa_id
        AND ag.data_hora::date BETWEEN p_data_inicio AND p_data_fim
        AND (p_status IS NULL OR ag.status = p_status)
      ORDER BY ag.data_hora ASC
    ) a
  );
END;
$$;


-- ══════════════════════════════════════════════════════════════
-- 7. DASHBOARD GERAL (usado como primeira chamada do agente)
-- ══════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.agente_dashboard(
  p_empresa_id bigint
)
RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER
AS $$
DECLARE
  v_mes int := EXTRACT(MONTH FROM CURRENT_DATE)::int;
  v_ano int := EXTRACT(YEAR  FROM CURRENT_DATE)::int;
BEGIN
  RETURN jsonb_build_object(
    'data_hoje', CURRENT_DATE,
    'veiculos', (
      SELECT jsonb_build_object(
        'disponivel', COUNT(*) FILTER (WHERE status = 'disponivel'),
        'reservado',  COUNT(*) FILTER (WHERE status = 'reservado'),
        'vendido_mes', (
          SELECT COUNT(*) FROM public.vendas
          WHERE empresa_id = p_empresa_id
            AND EXTRACT(MONTH FROM data_venda) = v_mes
            AND EXTRACT(YEAR  FROM data_venda) = v_ano
            AND status = 'concluida'
        )
      )
      FROM public.veiculos WHERE empresa_id = p_empresa_id
    ),
    'propostas_abertas', (
      SELECT COUNT(*) FROM public.propostas
      WHERE empresa_id = p_empresa_id AND status = 'aberta'
    ),
    'agendamentos_hoje', (
      SELECT COUNT(*) FROM public.agendamentos
      WHERE empresa_id = p_empresa_id
        AND data_hora::date = CURRENT_DATE
        AND status NOT IN ('cancelado')
    ),
    'contas_vencidas', (
      SELECT COUNT(*) FROM public.contas_pagar
      WHERE empresa_id = p_empresa_id
        AND status = 'pendente'
        AND data_vencimento < CURRENT_DATE
    ),
    'receita_mes', (
      SELECT COALESCE(SUM(preco_veiculo), 0) FROM public.vendas
      WHERE empresa_id = p_empresa_id
        AND status = 'concluida'
        AND EXTRACT(MONTH FROM data_venda) = v_mes
        AND EXTRACT(YEAR  FROM data_venda) = v_ano
    )
  );
END;
$$;


-- ══════════════════════════════════════════════════════════════
-- PERMISSÕES: service_role já tem acesso total.
-- Se quiser chamar com anon/authenticated, habilite abaixo:
-- ══════════════════════════════════════════════════════════════
-- GRANT EXECUTE ON FUNCTION public.agente_buscar_veiculos    TO authenticated;
-- GRANT EXECUTE ON FUNCTION public.agente_resumo_estoque     TO authenticated;
-- GRANT EXECUTE ON FUNCTION public.agente_buscar_clientes    TO authenticated;
-- GRANT EXECUTE ON FUNCTION public.agente_criar_cliente      TO authenticated;
-- GRANT EXECUTE ON FUNCTION public.agente_registrar_venda    TO authenticated;
-- GRANT EXECUTE ON FUNCTION public.agente_listar_vendas      TO authenticated;
-- GRANT EXECUTE ON FUNCTION public.agente_criar_proposta     TO authenticated;
-- GRANT EXECUTE ON FUNCTION public.agente_listar_propostas   TO authenticated;
-- GRANT EXECUTE ON FUNCTION public.agente_resumo_financeiro  TO authenticated;
-- GRANT EXECUTE ON FUNCTION public.agente_listar_contas_pagar TO authenticated;
-- GRANT EXECUTE ON FUNCTION public.agente_buscar_agendamentos TO authenticated;
-- GRANT EXECUTE ON FUNCTION public.agente_dashboard          TO authenticated;

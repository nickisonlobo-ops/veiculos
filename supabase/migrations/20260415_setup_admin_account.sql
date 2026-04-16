-- ============================================================
-- AutoFlow — Setup inicial do banco de dados
-- Execute este arquivo no SQL Editor do Supabase
-- ============================================================

-- ── 1. TABELAS ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.empresas (
  id        bigserial PRIMARY KEY,
  nome      text NOT NULL,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.profiles (
  id         uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  empresa_id bigint REFERENCES public.empresas(id),
  perfil     text NOT NULL DEFAULT 'funcionario' CHECK (perfil IN ('admin','gerente','funcionario')),
  email      text,
  nome       text,
  created_at timestamptz DEFAULT now()
);

-- ── 2. RLS ──────────────────────────────────────────────────

ALTER TABLE public.empresas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Veículos: todos os usuários da mesma empresa podem operar
ALTER TABLE public.veiculos ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "veiculos_select" ON public.veiculos;
CREATE POLICY "veiculos_select" ON public.veiculos
  FOR SELECT TO authenticated
  USING (
    empresa_id IN (
      SELECT empresa_id FROM public.profiles WHERE id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "veiculos_insert" ON public.veiculos;
CREATE POLICY "veiculos_insert" ON public.veiculos
  FOR INSERT TO authenticated
  WITH CHECK (
    empresa_id IN (
      SELECT empresa_id FROM public.profiles WHERE id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "veiculos_update" ON public.veiculos;
CREATE POLICY "veiculos_update" ON public.veiculos
  FOR UPDATE TO authenticated
  USING (
    empresa_id IN (
      SELECT empresa_id FROM public.profiles WHERE id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "veiculos_delete" ON public.veiculos;
CREATE POLICY "veiculos_delete" ON public.veiculos
  FOR DELETE TO authenticated
  USING (
    empresa_id IN (
      SELECT empresa_id FROM public.profiles WHERE id = auth.uid()
    )
  );

-- Empresas: usuário autenticado que pertença à empresa pode ler
DROP POLICY IF EXISTS "empresas_select" ON public.empresas;
CREATE POLICY "empresas_select" ON public.empresas
  FOR SELECT TO authenticated
  USING (
    id IN (
      SELECT empresa_id FROM public.profiles WHERE id = auth.uid()
    )
  );

-- Profiles: cada user lê/edita apenas o próprio registro
DROP POLICY IF EXISTS "profiles_select_own" ON public.profiles;
CREATE POLICY "profiles_select_own" ON public.profiles
  FOR SELECT TO authenticated
  USING (id = auth.uid());

DROP POLICY IF EXISTS "profiles_insert_own" ON public.profiles;
CREATE POLICY "profiles_insert_own" ON public.profiles
  FOR INSERT TO authenticated
  WITH CHECK (id = auth.uid());

DROP POLICY IF EXISTS "profiles_update_own" ON public.profiles;
CREATE POLICY "profiles_update_own" ON public.profiles
  FOR UPDATE TO authenticated
  USING (id = auth.uid());

-- ── 3. FUNÇÃO setup_admin_account (SECURITY DEFINER) ────────
-- Cria a empresa e vincula o usuário como admin no profiles.
-- SECURITY DEFINER: ignora RLS, permitindo INSERT mesmo sem política.

DROP FUNCTION IF EXISTS public.setup_admin_account(text);

CREATE OR REPLACE FUNCTION public.setup_admin_account(p_empresa_nome text)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_empresa_id bigint;
  v_user_id    uuid;
  v_email      text;
  v_nome       text;
BEGIN
  v_user_id := auth.uid();
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Usuário não autenticado.';
  END IF;

  SELECT email, raw_user_meta_data->>'full_name'
    INTO v_email, v_nome
    FROM auth.users
   WHERE id = v_user_id;

  -- Verifica se já existe empresa vinculada ao profile
  SELECT empresa_id INTO v_empresa_id
    FROM public.profiles
   WHERE id = v_user_id AND empresa_id IS NOT NULL
   LIMIT 1;

  IF v_empresa_id IS NULL THEN
    -- Cria nova empresa
    INSERT INTO public.empresas (nome)
    VALUES (COALESCE(NULLIF(trim(p_empresa_nome), ''), 'Minha Empresa'))
    RETURNING id INTO v_empresa_id;
  END IF;

  -- Cria ou atualiza o profile como admin
  INSERT INTO public.profiles (id, empresa_id, perfil, email, nome)
  VALUES (v_user_id, v_empresa_id, 'admin', v_email, v_nome)
  ON CONFLICT (id) DO UPDATE SET
    empresa_id = v_empresa_id,
    perfil     = 'admin',
    email      = COALESCE(EXCLUDED.email, profiles.email),
    nome       = COALESCE(EXCLUDED.nome, profiles.nome);

  RETURN json_build_object('empresa_id', v_empresa_id);
END;
$$;

GRANT EXECUTE ON FUNCTION public.setup_admin_account(text) TO authenticated;

-- ── 4. TRIGGER: cria profile vazio ao registrar novo usuário ─
-- (opcional — acelera loadEmpresa, setup_admin_account completa o resto)

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, email, nome, perfil)
  VALUES (
    NEW.id,
    NEW.email,
    NEW.raw_user_meta_data->>'full_name',
    COALESCE(NEW.raw_user_meta_data->>'perfil', 'funcionario')
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Verificar políticas existentes e criar apenas as que faltam

-- Revogar acesso público imediatamente para proteger dados sensíveis
REVOKE ALL ON alunos_ativos FROM anon;
REVOKE ALL ON clientes FROM anon;  
REVOKE ALL ON registros_atendimento FROM anon;
REVOKE ALL ON pendencias FROM anon;

-- Garantir que apenas authenticated users tenham acesso básico
GRANT USAGE ON SCHEMA public TO authenticated;

-- Criar função para verificar se usuário é admin (caso não exista)
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = 'public'
AS $$
  SELECT has_role(auth.uid(), 'admin'::app_role);
$$;

-- Função para verificar se usuário está autenticado
CREATE OR REPLACE FUNCTION public.is_authenticated()
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = 'public'
AS $$
  SELECT auth.uid() IS NOT NULL;
$$;

-- Adicionar rate limiting para funções sensíveis
CREATE OR REPLACE FUNCTION public.check_rate_limit(operation_type text)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
DECLARE
  user_id uuid := auth.uid();
  recent_ops int;
BEGIN
  -- Verificar se usuário está autenticado
  IF user_id IS NULL THEN
    RETURN false;
  END IF;
  
  -- Rate limit básico: máximo 100 operações por minuto por usuário
  SELECT count(*) INTO recent_ops
  FROM auth.audit_log_entries 
  WHERE created_at > now() - interval '1 minute'
    AND payload->>'user_id' = user_id::text;
    
  RETURN recent_ops < 100;
END;
$$;
-- Restore n8n functionality without exposing sensitive data
-- 1) Restrict alunos_ativos public access to non-sensitive columns only
-- 2) Keep existing admin-only full access policy

-- Ensure schema usage for anon (in case it was lost)
GRANT USAGE ON SCHEMA public TO anon;

-- Revoke any previous grants and re-grant limited column access on alunos_ativos
REVOKE ALL ON public.alunos_ativos FROM anon;

-- Grant SELECT only on SAFE columns (no CPF, email, data_nascimento, or financial totals)
GRANT SELECT (id, telefone, nome_completo, status, curso, data_matricula, vencimento, pendencias, observacoes, created_at, updated_at)
ON public.alunos_ativos TO anon;

-- Re-create a SELECT policy to allow row access (column restrictions above still apply)
DROP POLICY IF EXISTS "public select alunos_ativos (restricted columns)" ON public.alunos_ativos;
CREATE POLICY "public select alunos_ativos (restricted columns)"
ON public.alunos_ativos
FOR SELECT
USING (true);

-- Re-affirm grants for other resources used by n8n (no-op if already set)
GRANT SELECT, INSERT ON public.clientes TO anon;
GRANT INSERT ON public.registros_atendimento TO anon;
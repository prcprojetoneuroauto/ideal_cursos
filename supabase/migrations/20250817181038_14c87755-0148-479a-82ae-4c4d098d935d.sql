-- EMERGÊNCIA DE SEGURANÇA: Remover acesso público às tabelas sensíveis
-- Todas as tabelas com dados pessoais DEVEM ter RLS habilitado para usuários autenticados apenas

-- 1. Criar política para administradores acessarem tudo
DROP POLICY IF EXISTS "Authenticated users can view all alunos_ativos" ON alunos_ativos;
DROP POLICY IF EXISTS "Authenticated users can insert alunos_ativos" ON alunos_ativos;
DROP POLICY IF EXISTS "Authenticated users can update alunos_ativos" ON alunos_ativos;
DROP POLICY IF EXISTS "Authenticated users can delete alunos_ativos" ON alunos_ativos;

CREATE POLICY "Only admins can access alunos_ativos" 
ON alunos_ativos 
FOR ALL 
TO authenticated
USING (has_role(auth.uid(), 'admin'::app_role))
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

-- 2. Clientes - apenas admins
DROP POLICY IF EXISTS "Authenticated users can view all clientes" ON clientes;
DROP POLICY IF EXISTS "Authenticated users can insert clientes" ON clientes;
DROP POLICY IF EXISTS "Authenticated users can update clientes" ON clientes;

CREATE POLICY "Only admins can access clientes" 
ON clientes 
FOR ALL 
TO authenticated
USING (has_role(auth.uid(), 'admin'::app_role))
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

-- 3. Registros de atendimento - apenas admins
DROP POLICY IF EXISTS "Authenticated users can view all registros_atendimento" ON registros_atendimento;
DROP POLICY IF EXISTS "Authenticated users can insert registros_atendimento" ON registros_atendimento;
DROP POLICY IF EXISTS "Authenticated users can update registros_atendimento" ON registros_atendimento;

CREATE POLICY "Only admins can access registros_atendimento" 
ON registros_atendimento 
FOR ALL 
TO authenticated
USING (has_role(auth.uid(), 'admin'::app_role))
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

-- 4. Pendências - apenas admins
DROP POLICY IF EXISTS "Authenticated users can view all pendencias" ON pendencias;
DROP POLICY IF EXISTS "Authenticated users can insert pendencias" ON pendencias;
DROP POLICY IF EXISTS "Authenticated users can update pendencias" ON pendencias;
DROP POLICY IF EXISTS "Authenticated users can delete pendencias" ON pendencias;

CREATE POLICY "Only admins can access pendencias" 
ON pendencias 
FOR ALL 
TO authenticated
USING (has_role(auth.uid(), 'admin'::app_role))
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

-- 5. Revogar acesso público a todas as tabelas
REVOKE ALL ON alunos_ativos FROM anon;
REVOKE ALL ON clientes FROM anon;
REVOKE ALL ON registros_atendimento FROM anon;
REVOKE ALL ON pendencias FROM anon;

-- 6. Apenas authenticated users com permissões específicas
GRANT SELECT, INSERT, UPDATE, DELETE ON alunos_ativos TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON clientes TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON registros_atendimento TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON pendencias TO authenticated;
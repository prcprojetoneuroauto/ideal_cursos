-- Reabrir acesso REST temporário para o n8n usando o anon key
-- Atenção: políticas permissivas, apenas para restabelecer funcionamento rapidamente

-- Garantir RLS habilitado
ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.alunos_ativos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.registros_atendimento ENABLE ROW LEVEL SECURITY;

-- Conceder privilégios básicos ao papel anon (em caso de ambientes com privilégios restritos)
GRANT USAGE ON SCHEMA public TO anon;
GRANT SELECT, INSERT ON public.clientes TO anon;
GRANT SELECT ON public.alunos_ativos TO anon;
GRANT INSERT ON public.registros_atendimento TO anon;

-- Políticas temporárias amplas (USING/ CHECK = true)
-- Clientes
CREATE POLICY "public select clientes (temporary)"
ON public.clientes
FOR SELECT
USING (true);

CREATE POLICY "public insert clientes (temporary)"
ON public.clientes
FOR INSERT
WITH CHECK (true);

-- Alunos ativos
CREATE POLICY "public select alunos_ativos (temporary)"
ON public.alunos_ativos
FOR SELECT
USING (true);

-- Registros de atendimento
CREATE POLICY "public insert registros_atendimento (temporary)"
ON public.registros_atendimento
FOR INSERT
WITH CHECK (true);

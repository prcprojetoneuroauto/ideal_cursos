-- Adicionar campos financeiros à tabela alunos_ativos
ALTER TABLE public.alunos_ativos 
ADD COLUMN pendencias DECIMAL(10,2) DEFAULT 0.00,
ADD COLUMN valor_pago DECIMAL(10,2) DEFAULT 0.00,
ADD COLUMN valor_total DECIMAL(10,2) DEFAULT 0.00,
ADD COLUMN vencimento DATE;

-- Adicionar comentários para documentar os campos
COMMENT ON COLUMN public.alunos_ativos.pendencias IS 'Valor em reais das pendências do aluno';
COMMENT ON COLUMN public.alunos_ativos.valor_pago IS 'Valor em reais já pago pelo aluno';
COMMENT ON COLUMN public.alunos_ativos.valor_total IS 'Valor total do curso em reais';
COMMENT ON COLUMN public.alunos_ativos.vencimento IS 'Data de vencimento do pagamento';

-- Criar índices para consultas financeiras
CREATE INDEX idx_alunos_ativos_pendencias ON public.alunos_ativos(pendencias);
CREATE INDEX idx_alunos_ativos_vencimento ON public.alunos_ativos(vencimento);
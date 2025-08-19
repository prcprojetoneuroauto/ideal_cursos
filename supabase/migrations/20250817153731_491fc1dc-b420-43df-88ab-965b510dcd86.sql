-- Tornar campos da tabela pendencias opcionais para maior flexibilidade
ALTER TABLE public.pendencias 
ALTER COLUMN descricao DROP NOT NULL,
ALTER COLUMN responsavel DROP NOT NULL,
ALTER COLUMN session_id DROP NOT NULL;

-- Adicionar valores padrão para campos essenciais
ALTER TABLE public.pendencias 
ALTER COLUMN tipo SET DEFAULT 'Financeiro',
ALTER COLUMN status SET DEFAULT 'Pendente';

-- Comentário explicativo
COMMENT ON TABLE public.pendencias IS 'Tabela de pendências com campos flexíveis para diferentes tipos de atendimento';
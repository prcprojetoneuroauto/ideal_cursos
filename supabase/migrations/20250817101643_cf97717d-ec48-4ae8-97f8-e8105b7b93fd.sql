-- Adicionar novo status 'Cancelado' ao campo status_geral
-- Primeiro, vamos verificar os valores existentes e adicionar a nova opção
-- Atualizar registros existentes se necessário e garantir que o campo aceite os novos valores

-- Adicionar comentário para documentar os valores permitidos
COMMENT ON COLUMN registros_atendimento.status_geral IS 'Status do atendimento: Pendente, Em Andamento, Concluído, Cancelado';

-- Adicionar campo para controle de status da gestão se não existir
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'registros_atendimento' 
                   AND column_name = 'status_gestao') THEN
        ALTER TABLE registros_atendimento 
        ADD COLUMN status_gestao TEXT DEFAULT 'Pendente' CHECK (status_gestao IN ('Pendente', 'Em Andamento', 'Concluído', 'Cancelado'));
    END IF;
END $$;
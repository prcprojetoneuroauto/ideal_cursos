-- Corrigir problema de duplicate key na tabela registros_atendimento
-- Adicionar valor padrão para gerar IDs únicos automaticamente
ALTER TABLE public.registros_atendimento 
  ALTER COLUMN id SET DEFAULT gen_random_uuid()::text;

-- Criar constraint UNIQUE no session_id para evitar registros duplicados da mesma sessão
ALTER TABLE public.registros_atendimento 
  ADD CONSTRAINT unique_session_id UNIQUE (session_id);
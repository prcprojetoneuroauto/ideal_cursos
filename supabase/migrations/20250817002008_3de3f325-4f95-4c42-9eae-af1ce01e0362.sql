-- Definir IDs automáticos para evitar duplicate key quando o n8n enviar id repetido ou vazio
ALTER TABLE public.registros_atendimento 
  ALTER COLUMN id SET DEFAULT gen_random_uuid()::text;

ALTER TABLE public.pendencias 
  ALTER COLUMN id SET DEFAULT gen_random_uuid()::text;
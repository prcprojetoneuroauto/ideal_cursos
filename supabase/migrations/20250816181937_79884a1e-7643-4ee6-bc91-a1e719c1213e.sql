-- Alterar o tipo da coluna data_nascimento para aceitar timestamp with time zone
ALTER TABLE public.clientes 
ALTER COLUMN data_nascimento TYPE timestamp with time zone 
USING data_nascimento::timestamp with time zone;
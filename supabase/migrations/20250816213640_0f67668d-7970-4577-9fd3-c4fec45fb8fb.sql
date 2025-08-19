-- Converter a coluna data_nascimento para TEXT para aceitar qualquer formato
ALTER TABLE public.clientes
  ALTER COLUMN data_nascimento TYPE text USING to_char(data_nascimento, 'YYYY-MM-DD');
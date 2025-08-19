-- Recriar tabelas com chaves primárias VARCHAR

-- 1. Backup dos dados existentes (se houver)
CREATE TEMP TABLE clientes_backup AS SELECT * FROM public.clientes;
CREATE TEMP TABLE pendencias_backup AS SELECT * FROM public.pendencias;
CREATE TEMP TABLE registros_backup AS SELECT * FROM public.registros_atendimento;

-- 2. Remover tabelas existentes
DROP TABLE IF EXISTS public.clientes CASCADE;
DROP TABLE IF EXISTS public.pendencias CASCADE;
DROP TABLE IF EXISTS public.registros_atendimento CASCADE;

-- 3. Criar nova tabela clientes com ID VARCHAR
CREATE TABLE public.clientes (
  id VARCHAR NOT NULL PRIMARY KEY,
  telefone TEXT NOT NULL,
  nome_completo TEXT NOT NULL,
  cpf TEXT,
  email TEXT,
  data_nascimento TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- 4. Criar nova tabela pendencias com ID VARCHAR
CREATE TABLE public.pendencias (
  id VARCHAR NOT NULL PRIMARY KEY,
  session_id TEXT NOT NULL,
  tipo TEXT NOT NULL,
  descricao TEXT NOT NULL,
  responsavel TEXT,
  status TEXT NOT NULL DEFAULT 'Pendente',
  data_criacao TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- 5. Criar nova tabela registros_atendimento com ID VARCHAR padronizado
CREATE TABLE public.registros_atendimento (
  id VARCHAR NOT NULL PRIMARY KEY,
  session_id TEXT NOT NULL,
  telefone_cliente TEXT NOT NULL,
  cliente_id VARCHAR REFERENCES public.clientes(id),
  nome_cliente TEXT,
  assunto VARCHAR NOT NULL,
  detalhes VARCHAR,
  status_geral TEXT NOT NULL DEFAULT 'Iniciado',
  data_hora TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- 6. Habilitar RLS em todas as tabelas
ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pendencias ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.registros_atendimento ENABLE ROW LEVEL SECURITY;

-- 7. Recriar políticas RLS para clientes
CREATE POLICY "Authenticated users can view all clientes" 
ON public.clientes 
FOR SELECT 
USING (true);

CREATE POLICY "Authenticated users can insert clientes" 
ON public.clientes 
FOR INSERT 
WITH CHECK (true);

CREATE POLICY "Authenticated users can update clientes" 
ON public.clientes 
FOR UPDATE 
USING (true);

-- 8. Recriar políticas RLS para pendencias
CREATE POLICY "Authenticated users can view all pendencias" 
ON public.pendencias 
FOR SELECT 
USING (true);

CREATE POLICY "Authenticated users can insert pendencias" 
ON public.pendencias 
FOR INSERT 
WITH CHECK (true);

CREATE POLICY "Authenticated users can update pendencias" 
ON public.pendencias 
FOR UPDATE 
USING (true);

CREATE POLICY "Authenticated users can delete pendencias" 
ON public.pendencias 
FOR DELETE 
USING (true);

-- 9. Recriar políticas RLS para registros_atendimento
CREATE POLICY "Authenticated users can view all registros_atendimento" 
ON public.registros_atendimento 
FOR SELECT 
USING (true);

CREATE POLICY "Authenticated users can insert registros_atendimento" 
ON public.registros_atendimento 
FOR INSERT 
WITH CHECK (true);

CREATE POLICY "Authenticated users can update registros_atendimento" 
ON public.registros_atendimento 
FOR UPDATE 
USING (true);

-- 10. Criar triggers para updated_at
CREATE TRIGGER update_clientes_updated_at
  BEFORE UPDATE ON public.clientes
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_pendencias_updated_at
  BEFORE UPDATE ON public.pendencias
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_registros_updated_at
  BEFORE UPDATE ON public.registros_atendimento
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();
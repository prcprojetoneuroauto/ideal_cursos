-- Criar tabela alunos_ativos
CREATE TABLE public.alunos_ativos (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  nome_completo TEXT NOT NULL,
  telefone TEXT NOT NULL,
  email TEXT,
  cpf TEXT,
  data_nascimento TEXT,
  curso TEXT,
  data_matricula TIMESTAMP WITH TIME ZONE DEFAULT now(),
  status TEXT NOT NULL DEFAULT 'Ativo',
  observacoes TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Habilitar RLS
ALTER TABLE public.alunos_ativos ENABLE ROW LEVEL SECURITY;

-- Criar políticas RLS
CREATE POLICY "Authenticated users can view all alunos_ativos" 
ON public.alunos_ativos 
FOR SELECT 
USING (true);

CREATE POLICY "Authenticated users can insert alunos_ativos" 
ON public.alunos_ativos 
FOR INSERT 
WITH CHECK (true);

CREATE POLICY "Authenticated users can update alunos_ativos" 
ON public.alunos_ativos 
FOR UPDATE 
USING (true);

CREATE POLICY "Authenticated users can delete alunos_ativos" 
ON public.alunos_ativos 
FOR DELETE 
USING (true);

-- Criar trigger para atualizar updated_at
CREATE TRIGGER update_alunos_ativos_updated_at
BEFORE UPDATE ON public.alunos_ativos
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

-- Criar índices para performance
CREATE INDEX idx_alunos_ativos_telefone ON public.alunos_ativos(telefone);
CREATE INDEX idx_alunos_ativos_email ON public.alunos_ativos(email);
CREATE INDEX idx_alunos_ativos_status ON public.alunos_ativos(status);
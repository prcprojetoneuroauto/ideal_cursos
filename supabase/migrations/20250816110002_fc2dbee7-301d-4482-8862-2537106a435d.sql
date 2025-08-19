-- Criar tabela RegistrosAtendimento (O Diário de Bordo da Conversa)
CREATE TABLE public.registros_atendimento (
  registro_id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  session_id TEXT NOT NULL,
  telefone_cliente TEXT NOT NULL,
  nome_cliente TEXT,
  data_hora TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  assunto TEXT NOT NULL,
  detalhes TEXT,
  status_geral TEXT NOT NULL DEFAULT 'Iniciado' CHECK (status_geral IN ('Iniciado', 'Em Andamento', 'Finalizado')),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Criar tabela Pendencias (A Lista de Tarefas da Equipe)
CREATE TABLE public.pendencias (
  pendencia_id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  session_id TEXT NOT NULL,
  tipo TEXT NOT NULL CHECK (tipo IN ('Secretaria', 'Financeiro', 'Contrato')),
  descricao TEXT NOT NULL,
  responsavel TEXT,
  status TEXT NOT NULL DEFAULT 'Pendente' CHECK (status IN ('Pendente', 'Concluída')),
  data_criacao TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE public.registros_atendimento ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pendencias ENABLE ROW LEVEL SECURITY;

-- Create policies for authenticated users
CREATE POLICY "Authenticated users can view all registros_atendimento" 
ON public.registros_atendimento 
FOR SELECT 
TO authenticated
USING (true);

CREATE POLICY "Authenticated users can insert registros_atendimento" 
ON public.registros_atendimento 
FOR INSERT 
TO authenticated
WITH CHECK (true);

CREATE POLICY "Authenticated users can update registros_atendimento" 
ON public.registros_atendimento 
FOR UPDATE 
TO authenticated
USING (true);

CREATE POLICY "Authenticated users can view all pendencias" 
ON public.pendencias 
FOR SELECT 
TO authenticated
USING (true);

CREATE POLICY "Authenticated users can insert pendencias" 
ON public.pendencias 
FOR INSERT 
TO authenticated
WITH CHECK (true);

CREATE POLICY "Authenticated users can update pendencias" 
ON public.pendencias 
FOR UPDATE 
TO authenticated
USING (true);

CREATE POLICY "Authenticated users can delete pendencias" 
ON public.pendencias 
FOR DELETE 
TO authenticated
USING (true);

-- Create function to update timestamps
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for automatic timestamp updates
CREATE TRIGGER update_registros_atendimento_updated_at
  BEFORE UPDATE ON public.registros_atendimento
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_pendencias_updated_at
  BEFORE UPDATE ON public.pendencias
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

-- Create indexes for better performance
CREATE INDEX idx_registros_session_id ON public.registros_atendimento(session_id);
CREATE INDEX idx_registros_status ON public.registros_atendimento(status_geral);
CREATE INDEX idx_pendencias_session_id ON public.pendencias(session_id);
CREATE INDEX idx_pendencias_status ON public.pendencias(status);
CREATE INDEX idx_pendencias_tipo ON public.pendencias(tipo);
-- Criar tabela de clientes
CREATE TABLE public.clientes (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  telefone TEXT NOT NULL UNIQUE,
  nome_completo TEXT NOT NULL,
  cpf TEXT UNIQUE,
  email TEXT,
  data_nascimento DATE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;

-- Create policies
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

-- Add trigger for timestamps
CREATE TRIGGER update_clientes_updated_at
BEFORE UPDATE ON public.clientes
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

-- Modificar tabela registros_atendimento para referenciar cliente
ALTER TABLE public.registros_atendimento 
ADD COLUMN cliente_id UUID REFERENCES public.clientes(id);

-- Atualizar registros existentes (se houver) baseado no telefone
DO $$
DECLARE
    registro RECORD;
    cliente_uuid UUID;
BEGIN
    FOR registro IN SELECT DISTINCT telefone_cliente, nome_cliente FROM public.registros_atendimento WHERE telefone_cliente IS NOT NULL LOOP
        -- Inserir ou buscar cliente existente
        INSERT INTO public.clientes (telefone, nome_completo)
        VALUES (registro.telefone_cliente, COALESCE(registro.nome_cliente, 'Cliente'))
        ON CONFLICT (telefone) DO NOTHING;
        
        -- Buscar ID do cliente
        SELECT id INTO cliente_uuid FROM public.clientes WHERE telefone = registro.telefone_cliente;
        
        -- Atualizar registros de atendimento
        UPDATE public.registros_atendimento 
        SET cliente_id = cliente_uuid 
        WHERE telefone_cliente = registro.telefone_cliente;
    END LOOP;
END $$;
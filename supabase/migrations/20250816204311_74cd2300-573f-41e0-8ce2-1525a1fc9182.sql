-- Criar trigger para buscar/criar cliente automaticamente quando um atendimento é registrado
CREATE OR REPLACE FUNCTION public.processar_cliente_atendimento()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
DECLARE
  cliente_encontrado RECORD;
  novo_cliente_id uuid;
BEGIN
  -- Se cliente_id não foi preenchido, tentar buscar pelo telefone
  IF NEW.cliente_id IS NULL AND NEW.telefone_cliente IS NOT NULL THEN
    -- Buscar cliente pelo telefone
    SELECT id, nome_completo INTO cliente_encontrado 
    FROM public.clientes 
    WHERE telefone = NEW.telefone_cliente 
    LIMIT 1;
    
    -- Se encontrou o cliente, atualizar os dados
    IF FOUND THEN
      NEW.cliente_id = cliente_encontrado.id;
      NEW.nome_cliente = cliente_encontrado.nome_completo;
    ELSE
      -- Se não encontrou cliente e temos nome_cliente, criar um novo cliente
      IF NEW.nome_cliente IS NOT NULL AND NEW.nome_cliente != '' THEN
        novo_cliente_id = gen_random_uuid();
        
        INSERT INTO public.clientes (
          id,
          telefone,
          nome_completo,
          created_at,
          updated_at
        ) VALUES (
          novo_cliente_id,
          NEW.telefone_cliente,
          NEW.nome_cliente,
          now(),
          now()
        );
        
        NEW.cliente_id = novo_cliente_id;
      END IF;
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$;

-- Criar o trigger para processar cliente automaticamente
DROP TRIGGER IF EXISTS trigger_processar_cliente_atendimento ON public.registros_atendimento;
CREATE TRIGGER trigger_processar_cliente_atendimento
  BEFORE INSERT OR UPDATE ON public.registros_atendimento
  FOR EACH ROW
  EXECUTE FUNCTION public.processar_cliente_atendimento();
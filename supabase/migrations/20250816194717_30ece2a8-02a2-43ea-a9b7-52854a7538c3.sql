-- Criar função para buscar cliente por telefone e preencher dados automaticamente
CREATE OR REPLACE FUNCTION public.buscar_cliente_por_telefone()
RETURNS TRIGGER AS $$
DECLARE
  cliente_encontrado RECORD;
BEGIN
  -- Se cliente_id não foi preenchido, tentar buscar pelo telefone
  IF (NEW.cliente_id IS NULL OR NEW.nome_cliente IS NULL) AND NEW.telefone_cliente IS NOT NULL THEN
    -- Buscar cliente pelo telefone
    SELECT id, nome_completo INTO cliente_encontrado 
    FROM public.clientes 
    WHERE telefone = NEW.telefone_cliente 
    LIMIT 1;
    
    -- Se encontrou o cliente, atualizar os dados
    IF FOUND THEN
      NEW.cliente_id = cliente_encontrado.id;
      NEW.nome_cliente = cliente_encontrado.nome_completo;
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public';

-- Criar trigger BEFORE INSERT/UPDATE para buscar cliente automaticamente
DROP TRIGGER IF EXISTS trigger_buscar_cliente_telefone ON public.registros_atendimento;
CREATE TRIGGER trigger_buscar_cliente_telefone
  BEFORE INSERT OR UPDATE ON public.registros_atendimento
  FOR EACH ROW
  EXECUTE FUNCTION public.buscar_cliente_por_telefone();
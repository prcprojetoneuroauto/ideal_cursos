-- Garantir criação de cliente mesmo sem nome ao registrar atendimento via chat/WhatsApp
CREATE OR REPLACE FUNCTION public.processar_cliente_atendimento()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
DECLARE
  cliente_encontrado RECORD;
  novo_cliente_id text;
  nome_final text;
BEGIN
  -- Sempre tentar vincular pelo telefone
  IF NEW.telefone_cliente IS NOT NULL AND NEW.telefone_cliente <> '' THEN
    -- Buscar cliente existente pelo telefone
    SELECT id, nome_completo INTO cliente_encontrado
    FROM public.clientes
    WHERE telefone = NEW.telefone_cliente
    LIMIT 1;

    IF NOT FOUND THEN
      -- Se não existe, cria usando nome informado ou placeholder com telefone
      nome_final := COALESCE(NULLIF(NEW.nome_cliente, ''), 'Sem Nome ' || NEW.telefone_cliente);
      novo_cliente_id := gen_random_uuid()::text;

      INSERT INTO public.clientes (
        id, telefone, nome_completo, created_at, updated_at
      ) VALUES (
        novo_cliente_id, NEW.telefone_cliente, nome_final, now(), now()
      );

      NEW.cliente_id := novo_cliente_id;
      NEW.nome_cliente := nome_final;
    ELSE
      -- Já existe: apenas vincula
      NEW.cliente_id := cliente_encontrado.id;
      IF NEW.nome_cliente IS NULL OR NEW.nome_cliente = '' THEN
        NEW.nome_cliente := cliente_encontrado.nome_completo;
      END IF;
    END IF;
  END IF;

  NEW.updated_at := now();
  RETURN NEW;
END;
$$;

-- Garantir o trigger na tabela de registros de atendimento
DROP TRIGGER IF EXISTS trigger_processar_cliente_atendimento ON public.registros_atendimento;
CREATE TRIGGER trigger_processar_cliente_atendimento
  BEFORE INSERT OR UPDATE ON public.registros_atendimento
  FOR EACH ROW
  EXECUTE FUNCTION public.processar_cliente_atendimento();

-- Sincronizar nome nos registros quando o cliente for atualizado
DROP TRIGGER IF EXISTS trig_sincronizar_registros_cliente ON public.clientes;
CREATE TRIGGER trig_sincronizar_registros_cliente
  AFTER UPDATE ON public.clientes
  FOR EACH ROW
  EXECUTE FUNCTION public.sincronizar_registros_cliente();
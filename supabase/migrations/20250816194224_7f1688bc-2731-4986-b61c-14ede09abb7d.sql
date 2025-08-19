-- Remover trigger existente e recriar com nova funcionalidade
DROP TRIGGER IF EXISTS trigger_atualizar_dados_cliente ON public.registros_atendimento;

-- Atualizar a função existente para funcionar também com INSERT
CREATE OR REPLACE FUNCTION public.atualizar_dados_cliente()
RETURNS TRIGGER AS $$
BEGIN
  -- Se cliente_id foi preenchido, buscar dados do cliente
  IF NEW.cliente_id IS NOT NULL THEN
    -- Buscar dados do cliente e atualizar o registro atual
    SELECT nome_completo INTO NEW.nome_cliente 
    FROM public.clientes 
    WHERE id = NEW.cliente_id;
    
    NEW.updated_at = now();
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public';

-- Criar trigger para INSERT e UPDATE
CREATE TRIGGER trigger_atualizar_dados_cliente
  BEFORE INSERT OR UPDATE OF cliente_id ON public.registros_atendimento
  FOR EACH ROW
  WHEN (NEW.cliente_id IS NOT NULL)
  EXECUTE FUNCTION public.atualizar_dados_cliente();

-- Função para sincronizar quando dados do cliente mudam
CREATE OR REPLACE FUNCTION public.sincronizar_registros_cliente()
RETURNS TRIGGER AS $$
BEGIN
  -- Atualizar todos os registros_atendimento que referenciam este cliente
  UPDATE public.registros_atendimento 
  SET 
    nome_cliente = NEW.nome_completo,
    updated_at = now()
  WHERE cliente_id = NEW.id;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public';

-- Trigger para sincronizar quando dados do cliente são atualizados
CREATE TRIGGER trigger_sincronizar_registros_cliente
  AFTER UPDATE OF nome_completo ON public.clientes
  FOR EACH ROW
  WHEN (OLD.nome_completo IS DISTINCT FROM NEW.nome_completo)
  EXECUTE FUNCTION public.sincronizar_registros_cliente();
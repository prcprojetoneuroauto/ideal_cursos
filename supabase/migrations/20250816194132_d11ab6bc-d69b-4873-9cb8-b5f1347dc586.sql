-- Criar triggers para sincronização automática entre clientes e registros_atendimento

-- 1. Trigger para sincronizar dados quando cliente_id é preenchido em registros_atendimento
CREATE TRIGGER trigger_atualizar_dados_cliente
  AFTER UPDATE OF cliente_id ON public.registros_atendimento
  FOR EACH ROW
  WHEN (NEW.cliente_id IS NOT NULL AND (OLD.cliente_id IS NULL OR OLD.cliente_id != NEW.cliente_id))
  EXECUTE FUNCTION public.atualizar_dados_cliente();

-- 2. Função para atualizar registros quando dados do cliente mudam
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

-- 3. Trigger para sincronizar quando dados do cliente são atualizados
CREATE TRIGGER trigger_sincronizar_registros_cliente
  AFTER UPDATE OF nome_completo ON public.clientes
  FOR EACH ROW
  WHEN (OLD.nome_completo IS DISTINCT FROM NEW.nome_completo)
  EXECUTE FUNCTION public.sincronizar_registros_cliente();
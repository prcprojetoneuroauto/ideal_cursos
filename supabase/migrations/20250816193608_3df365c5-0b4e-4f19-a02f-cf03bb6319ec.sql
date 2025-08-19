-- Função para atualizar dados do cliente nos registros de atendimento
CREATE OR REPLACE FUNCTION public.atualizar_dados_cliente()
RETURNS TRIGGER AS $$
BEGIN
  -- Se cliente_id foi preenchido, buscar dados do cliente
  IF NEW.cliente_id IS NOT NULL THEN
    UPDATE public.registros_atendimento 
    SET 
      nome_cliente = (SELECT nome_completo FROM public.clientes WHERE id = NEW.cliente_id),
      updated_at = now()
    WHERE id = NEW.id;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para executar após inserção ou atualização
CREATE TRIGGER trigger_atualizar_dados_cliente
  AFTER INSERT OR UPDATE OF cliente_id
  ON public.registros_atendimento
  FOR EACH ROW
  EXECUTE FUNCTION public.atualizar_dados_cliente();
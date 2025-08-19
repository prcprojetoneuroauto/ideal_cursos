-- Atualizar função para usar search_path seguro
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
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public';
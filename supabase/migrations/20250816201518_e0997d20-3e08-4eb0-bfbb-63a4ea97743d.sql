-- Adicionar triggers similares para a tabela de pendências
-- para buscar dados do cliente automaticamente

-- Criar trigger para buscar cliente por telefone nas pendências (se houver campo telefone)
-- Por enquanto, vamos focar nos triggers de atualização

-- Criar trigger para atualizar dados quando cliente_id é preenchido nas pendências
CREATE OR REPLACE FUNCTION public.atualizar_dados_cliente_pendencias()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
BEGIN
  -- Se temos informações que podem conectar a um cliente
  -- (assumindo que pendências podem ter referência a cliente)
  NEW.updated_at = now();
  RETURN NEW;
END;
$function$;

-- Criar trigger para sincronizar quando cliente é atualizado
CREATE OR REPLACE FUNCTION public.sincronizar_pendencias_cliente()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
BEGIN
  -- Atualizar pendências relacionadas ao cliente se aplicável
  -- Por enquanto, apenas atualizar timestamp
  NEW.updated_at = now();
  RETURN NEW;
END;
$function$;

-- Adicionar coluna para marcar atendimentos como concluídos pelo gestor
ALTER TABLE registros_atendimento 
ADD COLUMN IF NOT EXISTS concluido_gestor BOOLEAN DEFAULT FALSE;

-- Adicionar coluna para data de conclusão pelo gestor
ALTER TABLE registros_atendimento 
ADD COLUMN IF NOT EXISTS data_conclusao_gestor TIMESTAMP WITH TIME ZONE;

-- Criar função para marcar atendimento como concluído
CREATE OR REPLACE FUNCTION public.marcar_atendimento_concluido(session_id_param TEXT)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
BEGIN
  UPDATE registros_atendimento 
  SET 
    concluido_gestor = TRUE,
    data_conclusao_gestor = now(),
    status_geral = 'Finalizado',
    updated_at = now()
  WHERE session_id = session_id_param;
END;
$function$;
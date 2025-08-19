-- Corrigir security warnings: adicionar SET search_path nas funções criadas
ALTER FUNCTION public.has_permission(_user_id UUID, _permissao permissao_tipo) 
SET search_path TO 'public';

ALTER FUNCTION public.get_user_plano(_user_id UUID) 
SET search_path TO 'public';
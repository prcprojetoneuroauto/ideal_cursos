-- Corrigir search_path nas funções de segurança
CREATE OR REPLACE FUNCTION public.has_role(_user_id uuid, _role app_role)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path = 'public'
AS $function$
  SELECT EXISTS (
    SELECT 1
    FROM public.user_roles
    WHERE user_id = _user_id
      AND role = _role
  )
$function$;

CREATE OR REPLACE FUNCTION public.promote_user_to_admin(user_email text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path = 'public'
AS $function$
DECLARE
  user_uuid uuid;
BEGIN
  -- Buscar o UUID do usuário pelo email
  SELECT id INTO user_uuid 
  FROM auth.users 
  WHERE email = user_email;
  
  IF user_uuid IS NULL THEN
    RAISE EXCEPTION 'Usuário não encontrado: %', user_email;
  END IF;
  
  -- Inserir role admin
  INSERT INTO public.user_roles (user_id, role) 
  VALUES (user_uuid, 'admin')
  ON CONFLICT (user_id, role) DO NOTHING;
  
  -- Inserir configurações habilitando simulação
  INSERT INTO public.user_settings (user_id, simulation_enabled) 
  VALUES (user_uuid, true)
  ON CONFLICT (user_id) 
  DO UPDATE SET simulation_enabled = true;
  
  RAISE NOTICE 'Usuário % promovido a administrador com sucesso', user_email;
END;
$function$;
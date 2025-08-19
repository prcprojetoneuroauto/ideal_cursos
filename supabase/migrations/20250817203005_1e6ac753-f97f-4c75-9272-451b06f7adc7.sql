-- Promover idealappcursos@gmail.com para admin
DO $$
DECLARE
  user_uuid uuid;
BEGIN
  -- Buscar o UUID do usuário pelo email
  SELECT id INTO user_uuid 
  FROM auth.users 
  WHERE email = 'idealappcursos@gmail.com';
  
  IF user_uuid IS NULL THEN
    RAISE EXCEPTION 'Usuário não encontrado: idealappcursos@gmail.com';
  END IF;
  
  -- Inserir role admin (se ainda não existir)
  INSERT INTO public.user_roles (user_id, role) 
  VALUES (user_uuid, 'admin')
  ON CONFLICT (user_id, role) DO NOTHING;
  
  -- Inserir configurações habilitando simulação (se ainda não existir)
  INSERT INTO public.user_settings (user_id, simulation_enabled) 
  VALUES (user_uuid, true)
  ON CONFLICT (user_id) 
  DO UPDATE SET simulation_enabled = true;

  -- Atribuir plano Admin ao usuário
  INSERT INTO public.user_planos (user_id, plano_id, ativo)
  SELECT user_uuid, p.id, true
  FROM public.planos p 
  WHERE p.tipo = 'admin'
  ON CONFLICT (user_id) 
  DO UPDATE SET 
    plano_id = (SELECT id FROM public.planos WHERE tipo = 'admin'),
    ativo = true,
    data_inicio = now();
  
  RAISE NOTICE 'Usuário idealappcursos@gmail.com promovido a administrador com sucesso';
END $$;
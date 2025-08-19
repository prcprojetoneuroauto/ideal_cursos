-- Inserir um usuário administrador inicial (substitua pelo ID real do usuário quando criado)
-- Este é apenas um exemplo - o ID real deve ser obtido após criar o usuário via interface

-- Comentário: Para criar o primeiro administrador:
-- 1. Cadastre-se normalmente via interface /auth
-- 2. Obtenha o user_id da tabela auth.users
-- 3. Execute manualmente: INSERT INTO user_roles (user_id, role) VALUES ('seu-user-id-aqui', 'admin');
-- 4. Execute manualmente: INSERT INTO user_settings (user_id, simulation_enabled) VALUES ('seu-user-id-aqui', true);

-- Função helper para promover usuário a admin (apenas para facilitar)
CREATE OR REPLACE FUNCTION promote_user_to_admin(user_email text)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
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
$$;
-- Promover usuário para admin
INSERT INTO public.user_roles (user_id, role) 
SELECT id, 'admin'::app_role 
FROM auth.users 
WHERE email = 'idealappcursos@gmail.com'
ON CONFLICT (user_id, role) DO NOTHING;

-- Habilitar simulação para o usuário
INSERT INTO public.user_settings (user_id, simulation_enabled) 
SELECT id, true 
FROM auth.users 
WHERE email = 'idealappcursos@gmail.com'
ON CONFLICT (user_id) 
DO UPDATE SET simulation_enabled = true;
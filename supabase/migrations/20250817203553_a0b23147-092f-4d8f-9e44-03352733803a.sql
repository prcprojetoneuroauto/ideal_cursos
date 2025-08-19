-- Atualizar valor mensal do plano para R$ 137,99
UPDATE public.planos 
SET preco_mensal = 137.99
WHERE tipo = 'admin';
-- Limpar todas as tabelas para refazer testes do zero
-- Ordem de limpeza: primeiro registros que dependem de outros

-- 1. Limpar pendencias
DELETE FROM public.pendencias;

-- 2. Limpar registros_atendimento 
DELETE FROM public.registros_atendimento;

-- 3. Limpar clientes por último
DELETE FROM public.clientes;

-- Resetar sequências se houver (não aplicável para UUID)
-- As tabelas estão agora vazias e prontas para novos testes
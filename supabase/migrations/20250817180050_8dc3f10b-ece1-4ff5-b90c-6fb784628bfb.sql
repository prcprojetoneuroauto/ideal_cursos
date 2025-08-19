-- Limpar clientes duplicados mantendo apenas o mais recente de cada telefone
WITH duplicados AS (
  SELECT 
    id,
    telefone,
    ROW_NUMBER() OVER (PARTITION BY telefone ORDER BY created_at DESC) as rn
  FROM clientes
),
ids_para_deletar AS (
  SELECT id 
  FROM duplicados 
  WHERE rn > 1
)
DELETE FROM clientes 
WHERE id IN (SELECT id FROM ids_para_deletar);

-- Criar constraint única para evitar duplicatas futuras
ALTER TABLE clientes ADD CONSTRAINT unique_telefone UNIQUE (telefone);
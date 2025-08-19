-- Primeiro, atualizar referências nos registros_atendimento para apontar para o cliente mais recente
WITH duplicados AS (
  SELECT 
    id,
    telefone,
    ROW_NUMBER() OVER (PARTITION BY telefone ORDER BY created_at DESC) as rn
  FROM clientes
),
cliente_principal AS (
  SELECT telefone, id as id_principal
  FROM duplicados 
  WHERE rn = 1
),
clientes_para_deletar AS (
  SELECT d.id, cp.id_principal
  FROM duplicados d
  JOIN cliente_principal cp ON d.telefone = cp.telefone
  WHERE d.rn > 1
)
UPDATE registros_atendimento 
SET cliente_id = cpd.id_principal
FROM clientes_para_deletar cpd
WHERE registros_atendimento.cliente_id = cpd.id;

-- Agora deletar os clientes duplicados
WITH duplicados AS (
  SELECT 
    id,
    telefone,
    ROW_NUMBER() OVER (PARTITION BY telefone ORDER BY created_at DESC) as rn
  FROM clientes
)
DELETE FROM clientes 
WHERE id IN (
  SELECT id FROM duplicados WHERE rn > 1
);

-- Criar constraint única para evitar duplicatas futuras  
ALTER TABLE clientes ADD CONSTRAINT unique_telefone UNIQUE (telefone);
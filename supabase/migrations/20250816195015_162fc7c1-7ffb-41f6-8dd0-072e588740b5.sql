-- Forçar sincronização dos dados existentes manualmente
UPDATE registros_atendimento 
SET 
  cliente_id = clientes.id,
  nome_cliente = clientes.nome_completo,
  updated_at = now()
FROM clientes
WHERE registros_atendimento.telefone_cliente = clientes.telefone
  AND registros_atendimento.nome_cliente IS NULL;
-- Temporariamente desabilitar verificação de foreign key
SET session_replication_role = replica;

-- Deletar registros órfãos primeiro  
DELETE FROM registros_atendimento 
WHERE cliente_id IN ('41998685805', '47999699543', '4799699543');

-- Agora deletar os clientes duplicados
DELETE FROM clientes WHERE id IN ('41998685805', '47999699543', '4799699543');

-- Reabilitar verificação de foreign key
SET session_replication_role = DEFAULT;

-- Adicionar constraint única para evitar duplicatas futuras
ALTER TABLE clientes ADD CONSTRAINT unique_telefone UNIQUE (telefone);
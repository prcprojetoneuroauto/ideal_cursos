-- Solução em etapas: primeiro atualizar as referências específicas
-- Cliente Paolo (id=1) é o mais antigo, vamos manter ele e atualizar para o mais recente

-- Atualizar registros que referenciam cliente "41998685805" para o cliente "4198685805" (mais recente)
UPDATE registros_atendimento 
SET cliente_id = '4198685805'
WHERE cliente_id = '41998685805';

-- Atualizar registros que referenciam cliente "47999699543" e "4799699543" para o cliente "1" (mais antigo que vamos manter)
UPDATE registros_atendimento 
SET cliente_id = '1'
WHERE cliente_id IN ('47999699543', '4799699543');

-- Agora deletar os clientes duplicados específicos
DELETE FROM clientes WHERE id IN ('41998685805', '47999699543', '4799699543');

-- Adicionar constraint única para evitar duplicatas futuras
ALTER TABLE clientes ADD CONSTRAINT unique_telefone UNIQUE (telefone);
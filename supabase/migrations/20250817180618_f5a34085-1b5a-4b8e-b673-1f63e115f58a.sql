-- Verificar se existe cliente com id '4198685805'
-- Se não existir, vamos criar baseado no cliente duplicado

DO $$
BEGIN
  -- Se não existe cliente com id 4198685805, vamos criá-lo baseado no 41998685805
  IF NOT EXISTS (SELECT 1 FROM clientes WHERE id = '4198685805') THEN
    INSERT INTO clientes (id, telefone, nome_completo, cpf, email, data_nascimento, created_at, updated_at)
    SELECT '4198685805', telefone, nome_completo, cpf, email, data_nascimento, now(), now()
    FROM clientes 
    WHERE id = '41998685805'
    LIMIT 1;
  END IF;
  
  -- Agora atualizar as referências
  UPDATE registros_atendimento 
  SET cliente_id = '4198685805'
  WHERE cliente_id = '41998685805';
  
  -- Deletar o cliente duplicado
  DELETE FROM clientes WHERE id = '41998685805';
  
  -- Fazer o mesmo para o cliente Paolo se necessário
  UPDATE registros_atendimento 
  SET cliente_id = '1'
  WHERE cliente_id IN ('47999699543', '4799699543');
  
  DELETE FROM clientes WHERE id IN ('47999699543', '4799699543');
  
END $$;
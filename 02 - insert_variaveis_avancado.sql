-- Vamos usar a tabela de vendas já feita no 
-- exercicio anterior
USE db1609_vendas
GO

-- insere a coluna de valor total que falta na tabela de vendas
ALTER TABLE vendas
ADD valor_total DECIMAL(10,2);

-- a logica aqui é realizar m,ultiplas inserções 
-- de forma controlada, usadno variaveis para 
-- armazenar dados

--inicializar transação
BEGIN TRANSACTION;

--  declarar as variaveis
DECLARE @cliente_id INT = 1; -- Cliente para o pedido (Jotael)
DECLARE @produto_id INT = 2; -- Produto comprado (Smartphone)
DECLARE @quantidade INT = 3; -- Quantidade comprada (3 unidades)
DECLARE @valor_total DECIMAL(10,2); -- Valor total do pedido
DECLARE @data_venda DATETIME = GETDATE() -- Data atual da venda
DECLARE @status_transacao VARCHAR(50);

-- calcular o valor total da venda
SELECT @valor_total = p.preco * @quantidade
FROM produtos p
WHERE p.produto_id = @produto_id;

-- validacao para garantir que a quantidade seja valida
IF @quantidade <= 0 
BEGIN
	SET @status_transacao = 'Falha: Quantidade inválida!';
	ROLLBACK TRANSACTION; -- reverte a transacão caso a quantidade seja invalida
	PRINT @status_transacao;
	RETURN;
END

-- inserindo outra venda usando nosso novo 'metodo'
INSERT INTO vendas (cliente_id, produto_id, quantidade, valor_total, data_venda)
VALUES (@cliente_id, @produto_id, @quantidade, @valor_total, @data_venda);

-- validando o sucesso da inserção
IF @@ERROR <> 0
BEGIN
	SET @status_transacao = 'Falha: Erro na inserção da venda';
	ROLLBACK TRANSACTION;
	PRINT @status_transacao;
	RETURN;
END

-- se todas as inserções forem OK, confirma a transação
SET @status_transacao = 'Sucesso: Vendas inseridas com sucesso!';
COMMIT TRANSACTION; -- confirmando a transação

-- verificando o status da transação
PRINT @status_transacao

-- verificando os dados inseridos
SELECT * FROM vendas;
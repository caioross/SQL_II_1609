CREATE DATABASE db1609_transacoesComplexas
GO

USE db1609_transacoesComplexas
GO

CREATE TABLE clientes (
	cliente_id INT PRIMARY KEY,
    nome_cliente VARCHAR(100),
	saldo DECIMAL(10,2) DEFAULT 0.00
);

CREATE TABLE pedidos (
	pedido_id INT PRIMARY KEY,
	cliente_id INT,
	valor DECIMAL(10,2),
	data_pedido DATETIME,
	FOREIGN KEY (cliente_id) REFERENCES clientes(cliente_id)
);

INSERT INTO clientes (cliente_id, nome_cliente, saldo)
VALUES
(1, 'Mozart Frans Herald', 1000.00),
(2, 'Bethoven da Silva', 2000.00);

INSERT INTO pedidos  (pedido_id, cliente_id, valor, data_pedido)
VALUES
(1, 1, 300, '2025-03-10'),
(2, 2, 150, '2025-03-11');

-- Iniciando a transação
BEGIN TRANSACTION;

	--Atualizando o saldo do cliente após o pedido
	UPDATE clientes
	SET saldo = saldo - 300
	WHERE cliente_id = 1;

	SAVE TRANSACTION SaldoAtualizado;

-- inserir o novo pedido
-- vamps simular um erro-, forçando a falha pra testar o roolback
BEGIN TRY 
	INSERT INTO pedidos 
	(pedido_id, cliente_id, valor, data_pedido)
	VALUES (3, 1, 500, '2025-03-12');
	
	-- simulando um erro, demosntrando o rollback parcial
	-- isso da erro pois o valor do pedido é maior que o saldo
	UPDATE clientes
	SET saldo = saldo - 500
	WHERE cliente_id = 1;
	-- se tudo ocorrer bem, confirmamos a transação
	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
	PRINT 'Erro detectado: ' + ERROR_MESSAGE();
	-- reverte as alterações após o savepoint em caso de erro
	ROLLBACK TRANSACTION SaldoAtualizado;
	PRINT 'Transação revertida parcialmente. O Saldo do
	cliente não foi alterado, mas o pedido foi adicionado';
END CATCH;

SELECT * FROM clientes;
SELECT * FROM pedidos;



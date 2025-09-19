--                    19 - isolamento_transacional.sql
CREATE DATABASE db1609_isolamentoTransacional
GO

USE db1609_isolamentoTransacional
GO

CREATE TABLE produtos(
	produto_id INT PRIMARY KEY,
	nome_produto VARCHAR(100),
	quantidade INT,
	preco DECIMAL(10,2)
);

INSERT INTO produtos 
(produto_id, nome_produto, quantidade, preco)
VALUES
(1, 'Camiseta', 100, 50.00),
(2, 'Calça', 50, 100.00),
(3, 'Tênis', 75, 150.00);

SELECT * FROM produtos;

/*
Exemplo de controle de isolamento transacional
Para observar o comportamento vamos realizar algumas operações
A) Usar diferentes niveis de isolamento
B) Simular transações recorrentes
*/
-- começando com uma transação com nivel de 
-- isolamento "READ UNCOMMITTED"
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
BEGIN TRANSACTION;
	-- Vamos ler os dados da tabela produtos,
	-- permitindo dados não confirmados (dirty read)
	PRINT 'Transação 1 (READ UNCOMMITTED)';
	SELECT * FROM produtos;

	-- alterando dados de quantidade sem confirmar a transação
	UPDATE produtos
	SET quantidade = quantidade -10
	WHERE produto_id = 1;

	-- simulando algum processamento
	WAITFOR DELAY '00:00:10'; -- Atraso de 10 segundos
COMMIT TRANSACTION;

-- agora , começamos uma transação com o nivel de isolamento
-- "serializable"
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRANSACTION;

	-- Vamos tentar ler e bloquear a linha de produto_id 1
	PRINT 'Transação 2 (SERIALIZABLE)';
	SELECT * FROM produtos WHERE produto_id = 1;
	WAITFOR DELAY '00:00:10';
COMMIT TRANSACTION;

SELECT * FROM produtos;
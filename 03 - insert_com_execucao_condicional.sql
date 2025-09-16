USE db1609_vendas
GO

CREATE TABLE pedidos (
	pedido_id INT PRIMARY KEY,
	cliente_id INT,
	produto_id INT,
	quantidade  INT,
	valor_total DECIMAL(10,2),
	data_pedido DATETIME,
	status_pedido VARCHAR(50)
);

DECLARE @cliente_id INT = 1;
DECLARE @produto_id INT = 1;
DECLARE @quantidade INT = 2;
DECLARE @valor_total DECIMAL(10,2);
DECLARE @status_pedido VARCHAR(50);

SELECT @valor_total = p.preco * @quantidade
FROM produtos p
WHERE p.produto_id = @produto_id;

IF @quantidade <= 0
BEGIN
	PRINT 'Erro: Quantidade invalida para o pedido';
	SET @status_pedido = 'Erro';
END

ELSE IF @valor_total < 500
BEGIN
	PRINT 'Erro: O valor do pedido é inferior ao valor minimo de R$500.00!';
	SET @status_pedido = 'Erro'; 
END

ELSE
BEGIN
	PRINT 'Pedido válido. Realizando a inserção na tabela...';
	SET @status_pedido = 'Pendente'; 

	INSERT INTO pedidos (
		pedido_id, 
		cliente_id, 
		produto_id,
		quantidade, 
		valor_total, 
		data_pedido, 
		status_pedido
	)
	VALUES (NEXT VALUE FOR 
		seq_pedido_id, 
		@cliente_id, 
		@produto_id, 
		@quantidade, 
		@valor_total, 
		GETDATE(), 
		@status_pedido
		)
END

CREATE SEQUENCE seq_pedido_id
	START WITH 1
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 1000000
	CACHE 10;
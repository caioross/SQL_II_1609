--           07 - delete_com_cascade.sql

CREATE DATABASE db1609_fallscompany;
GO

USE db1609_fallscompany
GO

CREATE TABLE clientes (
	cliente_id INT PRIMARY KEY,
	nome_cliente VARCHAR(100),
	email_cliente  VARCHAR(100)
);

CREATE TABLE pedidos (
	pedido_id INT PRIMARY KEY,
	cliente_id INT,
	data_pedido DATETIME,
	valor_total DECIMAL(10,2),
	FOREIGN KEY (cliente_id) 
		REFERENCES clientes(cliente_id)
		ON DELETE CASCADE
);

INSERT INTO clientes(cliente_id, nome_cliente, email_cliente)
VALUES
(10, 'Caio Ross','kio199@gmail.com'),
(20, 'Gabriel Sousa', 'gabriel@gmail.com'),
(30, 'Jotael Genuino', 'jotael@gmail.com'),
(40, 'Natalia Sales', 'natalia@gmail.com');

INSERT INTO pedidos 
(pedido_id, cliente_id, data_pedido, valor_total)
VALUES
(1, 10, '2025-01-01', 150.00),
(2, 10, '2025-01-01', 200.00),
(3, 20, '2025-01-01', 300.00),
(4, 30, '2025-02-05', 450.00);

SELECT * FROM clientes;
SELECT * FROM pedidos;

BEGIN TRY 
	BEGIN TRANSACTION;
		DELETE FROM clientes WHERE  cliente_id = 10;
	COMMIT TRANSACTION;
	PRINT 'Cliente e seus respectivos pedidos foram excluidos com sucesso';
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 
	BEGIN
		ROLLBACK TRANSACTION;
	END
	PRINT 'Erro durante a exclusão: ' + ERROR_MESSAGE(); 
END CATCH;

SELECT * FROM clientes;
SELECT *FROM pedidos;
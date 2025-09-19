--             16 -  update_com_joins_avancados.sql

CREATE DATABASE db1609_updateJoins
GO

USE db1609_updateJoins
GO


CREATE TABLE clientes (
	cliente_id INT PRIMARY KEY,
    nome_cliente VARCHAR(100),
	total_pedidos DECIMAL(10,2) DEFAULT 0.00,
	status_cliente VARCHAR(50) DEFAULT 'Ativo'
);

CREATE TABLE pedidos (
	pedido_id INT PRIMARY KEY,
	cliente_id INT,
	valor_pedido DECIMAL(10,2),
	data_pedido DATETIME,
	FOREIGN KEY (cliente_id) REFERENCES clientes(cliente_id)
);

INSERT INTO clientes
(cliente_id, nome_cliente, status_cliente)
VALUES
(1, 'Caio Ross','Ativo'),
(2, 'Gabriel Sousa','Ativo'),
(3, 'Jotael Genuino','Inativo'),
(4, 'Natalia Sales','Ativo');

INSERT INTO pedidos 
(pedido_id, cliente_id, valor_pedido, data_pedido)
VALUES
(1, 1, 100.00,	'2025-01-10'),
(2, 1, 150.00,	'2025-01-10'),
(3, 2, 200.00,	'2025-01-12'),
(4, 3, 50.00,	'2025-02-05'),
(5, 3, 75.00,	'2025-02-10');

/*
 Atualizando os totais de pedidos na tabela de clientes com 
 base nos valores da tabela de pedidos
 vou usar os joins entre as tabelas para aplicar o SET
 somente nos clientes ativos
*/

UPDATE clientes
	SET total_pedidos = (
		SELECT SUM(valor_pedido) 
		FROM pedidos
		WHERE pedidos.cliente_id = clientes.cliente_id
	)
	FROM clientes 
	JOIN pedidos ON clientes.cliente_id = pedidos.cliente_id
	WHERE clientes.status_cliente = 'Ativo';

SELECT * FROM clientes

SELECT
 c.nome_cliente,
 c.total_pedidos
 FROM clientes c;

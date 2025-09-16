-- insert_select_complexo.sql

CREATE DATABASE db1609_vendas;
GO

USE db1609_vendas
GO

-- Criar as 3 tabelas principais de exemplo
-- para simular a inserção complexa
CREATE TABLE clientes(
	cliente_id INT PRIMARY KEY IDENTITY(1,1),
	nome_cliente VARCHAR(100),
	email_cliente VARCHAR(100)
);
CREATE TABLE produtos(
	produto_id INT PRIMARY KEY IDENTITY(1,1),
	nome_produto VARCHAR(100),
	preco DECIMAL(10, 2)
);

CREATE TABLE vendas(
	venda_id INT PRIMARY KEY IDENTITY(1,1),
	cliente_id INT,
	produto_id INT,
	quantidade INT,
	data_venda DATE,

	FOREIGN KEY (cliente_id) REFERENCES clientes(cliente_id),
	FOREIGN KEY (produto_id) REFERENCES produtos(produto_id)
);

-- Inserindo dados de exemplos nas tabelas
INSERT INTO clientes (nome_cliente, email_cliente) VALUES
('Jotael Genuino', 'jota@gmail.com'),
('Gabriel Sousa', 'gabriel@hotmail.com'),
('Natalia Sales','nath@outlook.com')

INSERT INTO produtos (nome_produto, preco) VALUES
('Laptop',3600.00),
('Smartphone',800.00),
('Cadeira Gamer',1800.00)

INSERT INTO vendas (cliente_id, produto_id, quantidade, data_venda) 
VALUES
(1,1,2, '2025-03-01'),
(2,2,1, '2025-03-01'),
(1,3,1, '2025-03-02'),
(2,1,1, '2025-03-02'),
(3,3,3, '2025-03-03');

-- Realizando a inserção avançada com INSERT ... SELECT
-- agora vamos realizar um insert avançado onde iremos
--calcular o total de vendas para cada cliente
-- agrupando resultados e inserindo em uma nova tabela

CREATE TABLE relatorio_vendas_clientes(
	cliente_id INT,
	nome_cliente VARCHAR(100),
	produto_id INT,
	nome_produto VARCHAR(100),
	total_gasto DECIMAL(10,2)
);

INSERT INTO relatorio_vendas_clientes
(cliente_id, nome_cliente, produto_id, nome_produto, total_gasto)
SELECT	c.cliente_id,
		c.nome_cliente,
		p.produto_id,
		p.nome_produto,
		SUM(v.quantidade * p.preco) AS total_gasto
FROM vendas v
JOIN clientes c ON v.cliente_id = c.cliente_id
JOIN produtos p ON v.produto_id = p.produto_id
GROUP BY 
c.cliente_id, c.nome_cliente, p.produto_id, p.nome_produto

-- Exibir o resultado do insert complexo
SELECT * FROM relatorio_vendas_clientes


-- inserindo apenas os clientes ue gastaram mais de 3000 no total
-- com filtro adicional na hora de agregar

INSERT INTO relatorio_vendas_clientes 
(cliente_id, nome_cliente, produto_id, nome_produto, total_gasto)
SELECT	c.cliente_id,
		c.nome_cliente,
		p.produto_id,
		p.nome_produto,
		SUM(v.quantidade * p.preco) AS  total_gasto
FROM vendas v
JOIN clientes c ON v.cliente_id = c.cliente_id
JOIN produtos p ON v.produto_id = p.produto_id
GROUP BY c.cliente_id, c.nome_cliente, p.produto_id, p.nome_produto
HAVING SUM(v.quantidade * p.preco) > 3000; 




IF NOT EXISTS (SELECT 1 FROM sys.databases 
WHERE name = 'db1609_sistema_vendas')
	CREATE DATABASE db1609_sistema_vendas;
GO

USE db1609_sistema_vendas;
GO

--- Idempotencia das Triggers
IF OBJECT_ID('trg_VendasInsersao','tr') IS NOT NULL DROP TRIGGER trg_VendasInsersao;
IF OBJECT_ID('trg_VendasExclusao','tr') IS NOT NULL DROP TRIGGER trg_VendasExclusao;
IF OBJECT_ID('trg_VendasAtualizacao','tr') IS NOT NULL DROP TRIGGER trg_VendasAtualizacao;
GO

--- Idempotencia das Tabelas
IF OBJECT_ID('clientes','U')		 IS NOT NULL DROP TABLE clientes;
IF OBJECT_ID('produtos','U')		 IS NOT NULL DROP TABLE produtos;
IF OBJECT_ID('vendas','U')			 IS NOT NULL DROP TABLE vendas;
IF OBJECT_ID('auditoria_vendas','U') IS NOT NULL DROP TABLE auditoria_vendas;
GO



------------------------- Criando as tabelas -------------------
CREATE TABLE clientes(
	cliente_id INT PRIMARY KEY,
	nome_cliente VARCHAR(100) NOT NULL,
	email_cliente VARCHAR(100),
	data_cadastro DATETIME DEFAULT GETDATE()
);
CREATE TABLE produtos(
	produto_id INT PRIMARY KEY,
	nome_produto VARCHAR(100) NOT NULL,
	preco DECIMAL(10,2) NOT NULL
);
CREATE TABLE vendas(
	venda_id INT IDENTITY(1,1) PRIMARY KEY,
	cliente_id INT NOT NULL,  
	produto_id INT NOT NULL, 
	quantidade INT NOT NULL,
	valor_total DECIMAL(10,2),
	data_venda DATETIME DEFAULT GETDATE(),
	FOREIGN KEY (cliente_id) 
		REFERENCES clientes(cliente_id) 
		ON DELETE CASCADE, 

	FOREIGN KEY (produto_id) 
		REFERENCES produtos(produto_id) 
		ON DELETE CASCADE
);

CREATE TABLE auditoria_vendas(
	id_auditoria INT IDENTITY(1,1) PRIMARY KEY,
	venda_id INT,
	cliente_id INT, 
	produto_id INT, 
	quantidade INT,
	valor_total DECIMAL(10,2),
	data_venda DATETIME,
	operacao NVARCHAR(20),
	data_operacao DATETIME DEFAULT GETDATE(),
	usuario NVARCHAR(50) DEFAULT SYSTEM_USER
);
GO

-------------------- Triggers --------------------------------

CREATE TRIGGER trg_VendasInsersao
	ON vendas
	AFTER INSERT
	AS
		BEGIN
			INSERT INTO auditoria_vendas
			(venda_id, cliente_id, produto_id, quantidade, valor_total, 
			data_venda, operacao)
			SELECT venda_id, cliente_id, produto_id, quantidade, 
			valor_total, data_venda, 'INSERT' FROM inserted
		END;
	GO
CREATE TRIGGER trg_VendasExclusao
	ON vendas
	AFTER DELETE
	AS
		BEGIN 
			INSERT INTO auditoria_vendas
			(venda_id, cliente_id, produto_id, quantidade, valor_total, 
			data_venda, operacao)
			SELECT venda_id, cliente_id, produto_id, quantidade, 
			valor_total, data_venda, 'DELETE' FROM deleted;
		END;
	GO
CREATE TRIGGER trg_VendasAtualizacao
	ON vendas
	AFTER UPDATE
	AS
		BEGIN 
			INSERT INTO auditoria_vendas
			(venda_id, cliente_id, produto_id, quantidade, valor_total, 
			data_venda, operacao)
			SELECT venda_id, cliente_id, produto_id, quantidade, 
			valor_total, data_venda, 'UPDATE' FROM inserted
		END;
	GO


------------------- Inserindo dados ----------------------

INSERT INTO clientes 
(cliente_id, nome_cliente, email_cliente)
VALUES
(1, 'Caio', 'caio@gmail.com'),
(2, 'Gabriel', 'caio@gmail.com'),
(3, 'Jotael', 'caio@gmail.com'),
(4, 'Nathalia', 'caio@gmail.com');

INSERT INTO produtos 
(produto_id, nome_produto, preco)
VALUES
(1, 'Notebook',			3500.00),
(2, 'Smartphone',		2000.00),
(3, 'TV 900',			2500.00),
(4, 'Fone Cebrutius',	300.00);

INSERT INTO vendas 
(cliente_id, produto_id, quantidade, valor_total)
VALUES
(1, 1, 1, 3500.00),
(2, 2, 2, 4000.00),
(3, 4, 3,  900.00),
(4, 3, 1, 2800.00),
(1, 2, 1, 2000.00);

---------------------- CONSULTAS ---------------------------

PRINT '-------- Total de Vendas por Cliente ------------';
SELECT c.nome_cliente, SUM(v.valor_total) AS total_vendas
FROM vendas v
JOIN clientes c ON v.cliente_id = c.cliente_id
GROUP BY c.nome_cliente
ORDER BY total_vendas DESC;

PRINT '----------- Top 3 produtos mais vendidos ----------';
SELECT p.nome_produto, SUM(v.quantidade) AS total_vendido
FROM vendas v
JOIN produtos p ON v.produto_id = p.produto_id
GROUP BY p.nome_produto
ORDER BY total_vendido DESC
OFFSET 0 ROWS FETCH NEXT 3 ROWS ONLY;

------------- Visualizando o resultado final ------------------
PRINT '----- Auditoria de operações. --------------';
SELECT * FROM auditoria_vendas;
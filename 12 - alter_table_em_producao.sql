--            12 - alter_table_em_producao.sql

CREATE DATABASE db1609_AlterProducao;
GO

USE db1609_AlterProducao;
GO

CREATE TABLE clientes (
    cliente_id INT PRIMARY KEY,
    nome_cliente VARCHAR(100),
	data_cadastro DATETIME
);

INSERT INTO clientes
(cliente_id, nome_cliente, data_cadastro)
VALUES
(1, 'Caio Ross','2025-01-01'),
(2, 'Gabriel Sousa', '2025-01-01'),
(3, 'Jotael Genuino', '2025-01-01'),
(4, 'Natalia Sales', '2025-01-01');

/*
Para efetuar uma alteração no banco de dados em produção
devemos criar uma nova tabela e migrar os dados para ela
por segurança
*/

-- passo 1, primeiro criamos a tabela temporaria
CREATE TABLE clientes_temp (
	cliente_id INT PRIMARY KEY,
	nome_cliente VARCHAR(100),
	data_cadastro DATETIME,
	email_cliente VARCHAR(100)
);

-- passo 2 aqui vamos migrar a tabela origina para a nova tabela
--temporaria
INSERT INTO clientes_temp 
(cliente_id, nome_cliente, data_cadastro)
SELECT cliente_id, nome_cliente, data_cadastro 
FROM clientes;

-- vocÊ pode usar o bloqueio explicito de transação (transaction)
BEGIN TRANSACTION;
		-- eliminar a tabela original 
		DROP TABLE clientes;

		-- renomear a tabela temporaria
		EXEC sp_rename 'clientes_temp', 'clientes';
COMMIT TRANSACTION;

SELECT * FROM clientes;
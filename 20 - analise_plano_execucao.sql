---                     20 - analise_plano_execucao.sql
CREATE DATABASE db1609_analisePlanoExecucao
GO

USE db1609_analisePlanoExecucao
GO

CREATE TABLE clientes (
	id INT PRIMARY KEY,
	nome VARCHAR(100),
	cidade  VARCHAR(100),
	endereco VARCHAR(100),
	uf VARCHAR(10)
);

INSERT INTO clientes
(id, nome, cidade, endereco, uf)
VALUES 
(1, 'Caio', 'São Paulo','Rua dos Instrutores','SP'),
(2, 'Jotael', 'Lisboa','Alameda dos Bancos','PT'),
(3, 'Gabriel', 'Brasilia','Quadra da Asa Sul','DF'),
(4, 'Natalia', 'Londres','Avenida dos Numeros','UK');

SELECT 
nome,
endereco
FROM clientes
WHERE cidade = 'São Paulo'

-- Usando o atalho CTRL+L abrimos o plano de execução do SMSS


SET STATISTICS PROFILE ON;
SELECT nome,
endereco
FROM clientes
WHERE cidade = 'São Paulo';
SET STATISTICS PROFILE OFF;

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
SELECT nome,
endereco
FROM clientes
WHERE cidade = 'São Paulo';
SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
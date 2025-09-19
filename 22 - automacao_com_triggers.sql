--                  22 - automacao_com_triggers.sql
------------------------------
-- Criação de triggers avançadas
-- Objetivo: Usar as triggers para automaç~]ao de tarefas
-- A trigger será configurada para realizar auditoria
-- automatica após as inserções , atualizações e exclusões
-------------------------------

IF NOT EXISTS (SELECT 1 FROM sys.databases 
WHERE name = 'db1609_automacaoTriggers')
	CREATE DATABASE db1609_automacaoTriggers;
GO

USE db1609_automacaoTriggers;
GO

--  Idempotencia, ou seja
-- rodar varias vezes sem quebrar
IF OBJECT_ID('trg_AuditoriaInsercao', 'TR') IS NOT NULL
	DROP TRIGGER trg_AuditoriaInsercao;
GO
IF OBJECT_ID('trg_AuditoriaExclusao', 'TR') IS NOT NULL
	DROP TRIGGER trg_AuditoriaExclusao;
GO
IF OBJECT_ID('trg_AuditoriaAtualizacao', 'TR') IS NOT NULL
	DROP TRIGGER trg_AuditoriaAtualizacao;
GO
IF OBJECT_ID('auditoria_vendas', 'U') IS NOT NULL
	DROP TABLE auditoria_vendas;
GO
IF OBJECT_ID('vendas', 'U') IS NOT NULL
	DROP TABLE vendas;
GO

-- 1. Criação da tabela de auditoria para registrar 
-- alterações nos dados
CREATE TABLE auditoria_vendas(
	id_auditoria INT IDENTITY(1,1) PRIMARY KEY,
	id_venda INT,
	valor_venda DECIMAL(10,2),
	data_venda DATE, -- somente a data
	operacao NVARCHAR(50), -- Tipo: INSERT, UPDATE...
	data_operacao DATETIME, -- data e hora
	usuario NVARCHAR(50) -- usuario que efetuou a operação
);

-- 2.  Criando a tabela de vendas complementar ao exercicio
CREATE TABLE vendas (
	id_venda INT PRIMARY KEY,
	valor_venda DECIMAL(10,2),
	data_venda DATE
);
GO

-- 3. Criação da trigger para a auditoria após a inserção 
-- da tabela vendas
CREATE TRIGGER trg_AuditoriaInsercao
	ON vendas
	AFTER INSERT 
	AS
	BEGIN
		INSERT INTO auditoria_vendas(id_venda, valor_venda, data_venda, operacao, data_operacao, usuario)
		SELECT id_venda, valor_venda, data_venda, 'INSERT', GETDATE(), SYSTEM_USER
		FROM inserted; --'inserted' contem os dados da linha inserida
		PRINT 'Dados inseridos na tabela de auditoria apos inserir a venda na tabela de vendas';
	END;
GO

-- 4. Criação da trigger para a auditoria após a exclusão 
-- da tabela vendas
CREATE TRIGGER trg_AuditoriaExclusao
	ON vendas
	AFTER DELETE
	AS
	BEGIN
		INSERT INTO auditoria_vendas (id_venda, valor_venda, data_venda, operacao, data_operacao, usuario)
		SELECT id_venda, valor_venda, data_venda, 'DELETE', GETDATE(), SYSTEM_USER
		FROM deleted;
		PRINT 'Dados inseridos na tabela de auditoria apos excluir a venda na tabela de vendas';
	END;
	GO

-- 5. Criação da trigger para a auditoria após a atualização 
-- da tabela vendas
CREATE TRIGGER trg_AuditoriaAtualizacao
	ON vendas
	AFTER UPDATE
	AS
	BEGIN
		INSERT INTO auditoria_vendas (id_venda, valor_venda, data_venda, operacao, data_operacao, usuario)
		SELECT id_venda, valor_venda, data_venda,'UPDATE', GETDATE(), SYSTEM_USER
		FROM inserted;
		PRINT 'Dados inseridos na tabela de auditoria apos atualizar a venda na tabela de vendas';
	END;
	GO

-- inserindo dados das vendas, 
-- e acionando o gatilho correspondente
INSERT INTO vendas (id_venda, valor_venda, data_venda)
VALUES (1, 150.00, '2025-01-01');

-- atualizando dados das vendas, 
-- e acionando o gatilho correspondente
UPDATE vendas SET valor_venda = 200.00 WHERE id_venda = 1;

--excluindo registros da vendas, 
-- e acionando o gatilho correspondente
DELETE FROM VENDAS WHERE id_venda = 1;

-- verificando os dados da auditoria
SELECT * FROM auditoria_vendas

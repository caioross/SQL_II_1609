--          23 - trigger_performace.sql

IF NOT EXISTS (SELECT 1 FROM sys.databases
WHERE name = 'db1609_triggersPerformance')
	CREATE DATABASE db1609_triggersPerformance;
GO

USE db1609_triggersPerformance;
GO

IF OBJECT_ID('vendas', 'U') IS NOT NULL
	DROP TABLE vendas;
GO

IF OBJECT_ID('auditoria_vendas', 'U') IS NOT NULL
	DROP TABLE auditoria_vendas;
GO

IF OBJECT_ID('trg_AuditoriaInsercao', 'TR') IS NOT NULL
	DROP TRIGGER trg_AuditoriaInsercao;
GO

IF OBJECT_ID('trg_AuditoriaExclusao', 'TR') IS NOT NULL
	DROP TRIGGER trg_AuditoriaExclusao;
GO

CREATE TABLE vendas(
	id_venda INT PRIMARY KEY,
	valor_venda DECIMAL(18,2),
	data_venda DATE,
	status NVARCHAR(20) DEFAULT 'Ativa'
);
GO

CREATE TABLE auditoria_vendas(
	id_auditoria INT IDENTITY(1,1) PRIMARY KEY,
	id_venda INT,
	operacao NVARCHAR(10),
	data_operacao DATETIME,
	usuario NVARCHAR(50)
);
GO
--------------   TRIGGERS  --------------------

CREATE TRIGGER trg_AuditoriaInsercao
ON vendas
AFTER INSERT
AS 
BEGIN
	INSERT INTO auditoria_vendas 
	(id_venda, operacao,data_operacao,usuario)
	SELECT id_venda, 'INSERT', GETDATE(), SYSTEM_USER
	FROM inserted;
	PRINT 'Operação de inserir realizada com sucesso!';
END;
GO

CREATE TRIGGER trg_AuditoriaAtualizacao
ON vendas
AFTER UPDATE
AS 
BEGIN
	INSERT INTO auditoria_vendas
	(id_venda, operacao,data_operacao,usuario)
	SELECT id_venda, 'UPDATE', GETDATE(), SYSTEM_USER
	FROM inserted
	WHERE EXISTS(
	-- Registra apenas quando há mudanças reais nos dados
		SELECT 1
		FROM deleted
		WHERE deleted.id_venda = inserted.id_venda
		AND (
			deleted.valor_venda <> inserted.valor_venda
			OR
			deleted.status <> inserted.status
		)
	);
END;
GO

CREATE TRIGGER trg_AuditoriaExclusao
ON vendas
AFTER DELETE
AS 
BEGIN
	INSERT INTO auditoria_vendas 
	(id_venda, operacao,data_operacao,usuario)
	SELECT id_venda, 'DELETE', GETDATE(), SYSTEM_USER
	FROM deleted;
	PRINT 'Operação de excluir realizada com sucesso!'; 
END;
GO

-----------------------------------------------

INSERT INTO vendas (id_venda, valor_venda, data_venda)
VALUES (1, 150.00, '2025-01-01');

UPDATE vendas SET valor_venda = 200 WHERE id_venda = 1;

DELETE FROM vendas WHERE id_venda = 1;

SELECT * FROM auditoria_vendas;
SELECT * FROM vendas;
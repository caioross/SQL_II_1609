CREATE DATABASE db1609_Eficiente02
GO

USE db1609_Eficiente02
GO

CREATE TABLE clientes (
    cliente_id INT PRIMARY KEY,
    nome_cliente VARCHAR(100),
	data_cadastro DATETIME
);
CREATE TABLE pedidos (
	pedido_id INT PRIMARY KEY,
	cliente_id INT,
	data_pedido DATETIME,
	valor_total DECIMAL(10,2)
);

INSERT INTO clientes (cliente_id, nome_cliente, data_cadastro)
SELECT TOP 1000000
	/*
	Gerar o valor sequencial de 1 a Inf por cada linha. 
	O over exige ordenar. isso é um truque do instrutor para
	dizer que nao quero em ordem pré-defida.
	*/
	ROW_NUMBER() OVER( ORDER BY (SELECT NULL)),
	'Cliente ' + CAST(ROW_NUMBER() OVER( ORDER BY (SELECT NULL)) AS VARCHAR(10)),
	DATEADD(DAY, -(ROW_NUMBER() OVER( ORDER BY (SELECT NULL)) % 3650), GETDATE())
FROM master.dbo.spt_values a , master.dbo.spt_values b;
--DELETE FROM clientes

INSERT INTO pedidos 
(pedido_id, cliente_id, data_pedido, valor_total)
SELECT TOP 1000000
	ROW_NUMBER() OVER( ORDER BY (SELECT NULL)),
	(ABS(CHECKSUM(NEWID())) % 1000000) + 1, --Atribuimos um cliente aleatorio
	DATEADD(DAY, -(ROW_NUMBER() OVER( ORDER BY (SELECT NULL)) % 3650), GETDATE()),
	CAST(RAND() * 1000 AS DECIMAL(10,2))
FROM master.dbo.spt_values a, master.dbo.spt_values b;

SELECT TOP 10 * FROM clientes;
SELECT TOP 10 * FROM pedidos;

BEGIN TRY
	BEGIN TRANSACTION;
		--declarando as variaveis para o controle dos lotes
		DECLARE @BatchSize INT = 1000;
		DECLARE @RowCount INT;

		-- inicializando a variavel de controle da 
		--contagem de registros excluidos
		SET @RowCount  = 1;

		-- LOOP para excluir os dados em lotes
		WHILE @RowCount > 0
		BEGIN
			-- Excluindo os dados em lotes de 1000
			DELETE TOP (@BatchSize)
			FROM clientes
			WHERE data_cadastro < DATEADD(YEAR,-5 ,GETDATE());

			-- obtendo a contagem de registros na iteração atual
			SET @RowCount = @@ROWCOUNT;

			-- exibindo o progresso
			PRINT 'Excluidos ' + CAST(@RowCount AS VARCHAR) + ' registros de clientes.';

			-- Espera de 1 segundo entre lotes, visando evitar o bloqueio
			WAITFOR DELAY '00:00:01'; 
		END
	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 
	BEGIN
		ROLLBACK TRANSACTION;
	END
	PRINT 'Erro durante a exclusão '+ERROR_MESSAGE();
END CATCH;

SELECT COUNT(*) FROM clientes;
SELECT COUNT(*) FROM pedidos;
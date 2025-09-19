CREATE DATABASE db1609_updateBatch
GO

USE db1609_updateBatch
GO

CREATE TABLE clientes (
	cliente_id INT PRIMARY KEY,
    nome_cliente VARCHAR(100),
	status_cliente VARCHAR(50) DEFAULT 'Ativo',
	ultimo_pedido DATETIME
);

INSERT INTO clientes
(cliente_id, nome_cliente, status_cliente, ultimo_pedido)
VALUES
(1, 'Caio Ross','Ativo','2025-01-06'),
(2, 'Gabriel Sousa','Ativo','2025-02-05'),
(3, 'Jotael Genuino','Ativo','2025-03-04'),
(4, 'Natalia Sales','Ativo','2025-04-03'),
(5, 'Mark Zuckerberg','Ativo','2025-05-02'),
(6, 'Bill Gates','Ativo','2025-06-01');

DECLARE @batchSize INT = 2; -- Tamanho do lote de atualização
DECLARE @rows_updated INT = 0; -- contar registros atualziados
DECLARE @total_rows INT; --total de registros a serem atualiziados

-- contando total de clientes a serem atualizados
-- (clientes que nao realizaram pedidos nos ultimos 6 meses)
SELECT @total_rows = COUNT(*) FROM clientes
WHERE ultimo_pedido <= DATEADD(MONTH, -6, GETDATE()) 
AND status_cliente = 'Ativo';

WHILE @rows_updated < @total_rows
BEGIN
	UPDATE TOP (@batchSize) clientes
	SET status_cliente = 'Inativo'
	WHERE ultimo_pedido <= DATEADD(MONTH, -6, GETDATE())
	AND status_cliente = 'Ativo';

	SET @rows_updated = @rows_updated + @@ROWCOUNT;

	PRINT 'Registros atualizados: '
	+ CAST(@rows_updated AS VARCHAR)
	+ ' de '
	+ CAST(@total_rows AS VARCHAR);
END;

SELECT * FROM clientes;
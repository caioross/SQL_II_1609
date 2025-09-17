/*
Este script demonstra como realizar inser��es em lotes 
utilizando transa��es 
Ou seja, inserir grandes volumes de dados de forma eficiente
dividindo as inser��es em pequenos lotes ('batches' ou 'chunks')
ajuda a evitar quebras e melhora o desempenho do banco
*/

-- 00 seleciona o banco de dados que vamos usar
USE db1609_empresa_muito_legal
GO

-- 01 criar a tabela
CREATE TABLE vendas (
	venda_id INT IDENTITY(1,1) PRIMARY KEY,
	cliente_id INT,
	produto_id INT,
	quantidade INT,
	valor_total DECIMAL(10,2),
	data_venda DATETIME
);

-- 02 variaveis para controle dos lotes
DECLARE @batch_size INT = 1000; -- tamanho do lote (quantidade max de registros)
DECLARE @total_registros INT = 10000; -- total de registros que desejamos inserir
DECLARE @contador INT = 0; --contador de inser��es realizadas

BEGIN TRY
		-- iniciar a transacao para garantir que 
		-- inser��es de cada lote sejam atomicas
	WHILE @contador < @total_registros
		BEGIN
			-- iniciando a transa��o
			BEGIN TRANSACTION
			-- inserindo um lote de registros na tabela de vendas
			INSERT INTO vendas (cliente_id, produto_id, quantidade, valor_total, data_venda)
			SELECT
			--Gerando um cliente_id aleatorio entre 1 e 1000
				ABS(CHECKSUM(NEWID())) % 1000 + 1, 
			--Gerando um produto_id aleatorio entre 1 e 100
				ABS(CHECKSUM(NEWID())) % 100 + 1,
			--Gerando um quantidade aleatorio entre 1 e 10
				ABS(CHECKSUM(NEWID())) % 10 + 1,
			--Gerando um valor_total aleatorio entre 1 e 1000
				(ABS(CHECKSUM(NEWID())) % 1000 + 1) * 10,
			--Data da venda ser� a data e hora atual
				GETDATE()
			FROM master.dbo.spt_values t1
			CROSS JOIN master.dbo.spt_values t2
			WHERE t1.type = 'P' AND t2.type = 'P'
			ORDER BY NEWID()
			-- inser��o de apenas um lote
			OFFSET @contador ROWS FETCH NEXT @batch_size ROWS ONLY;

			-- atualizar o contador de registros inseridos
			SET @contador = @contador + @batch_size;
			-- confirmando a transa��o e comitando
			COMMIT TRANSACTION

			-- exibindo uma pensagem de progresso
			PRINT 'Lote: ' + CAST(@contador / @batch_size AS VARCHAR) + ' inseridos com sucesso!'
		END
END TRY
BEGIN CATCH
-- caso ocorra algum erro realizamos um rollback da transa��o
	IF @@TRANCOUNT > 0
	BEGIN
		ROLLBACK TRANSACTION
	END
	PRINT 'Erro: '+ ERROR_MESSAGE();
END CATCH

--Bora ver oq tem dentro da tabela??
SELECT COUNT(*) AS Total_Vendas FROM vendas;
--     09 - drop_tabela_otimizada.sql
CREATE DATABASE db1609_DropOtimizado;
GO

USE db1609_DropOtimizado;
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

CREATE TABLE #clientes_temp(
	cliente_id INT,
	nome_cliente VARCHAR(100)
);

INSERT INTO #clientes_temp 
(cliente_id, nome_cliente)
VALUES
(4, 'Nicola Tesla'),
(5, 'Heidy Lamar');

-- Exclui todos os dados da tabela clientes.
-- n�o registra a exclus�o no log
-- n�o pode ser revertido
TRUNCATE TABLE clientes;

--aqui excluimos a tabela temporaria.
-- n�o apenas limpando seus dados
-- n�o reversivel
DROP TABLE #clientes_temp;



CREATE DATABASE db1609_addDropColuna;
GO

USE db1609_addDropColuna;
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

-- adicionar uma coluna com um valor default (padrão) ou NUll, se
-- necessario para evitar impacto nos dados existentes
ALTER TABLE clientes ADD email_cliente VARCHAR(150) NULL;

-- verificar se acoiluna email_cliente contem dados!
SELECT COUNT(*) AS dados_email_cliente 
FROM clientes 
WHERE email_cliente IS NOT NULL;

BEGIN TRANSACTION;
	ALTER TABLE clientes DROP COLUMN email_cliente;
COMMIT TRANSACTION;

SELECT * FROM clientes




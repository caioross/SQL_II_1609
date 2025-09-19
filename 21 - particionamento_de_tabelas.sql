-- 21 - particionamento_de_tabelas.sql

--CREATE DATABASE db_particionamentoTabelas
--GO

USE db_particionamentoTabelas
GO

/* 
Objetivo: Dividir as tabelas grandes em 
partições para melhor o desempenho e facilitar o 
gerenciamento de dados

O particionamento vai dividir a tabela com base 
em um valor de coluna, nesse exemplo usaremos Datas
*/

if EXISTS(
	SELECT * FROM sys.partition_schemes WHERE name = 'ps_ano')
		DROP PARTITION SCHEME ps_ano;
GO
IF EXISTS (
	SELECT * FROM sys.partition_functions WHERE name = 'pf_ano')
		DROP PARTITION FUNCTION pf_ano;
GO	
-- criar a funcao de particionamento
-- ela que define como tudo vai ser distribuido
CREATE PARTITION FUNCTION pf_ano (date)
AS RANGE RIGHT FOR VALUES (
'2010-12-31',
'2011-12-31',
'2012-12-31',
'2013-12-31',
'2014-12-31',
'2015-12-31'
);
GO

--  criaremos um esquema de particionamento.
-- o equema define como as partições serão distribuidas
-- ( não os dados ☺ )

CREATE PARTITION SCHEME ps_ano
AS PARTITION pf_ano
TO (
--cada partição será mapeada aqui no TO, Nesse caso
-- todas particoes estão sendo alocadas no Primary!
[PRIMARY],
[PRIMARY],
[PRIMARY],
[PRIMARY],
[PRIMARY],
[PRIMARY],
[PRIMARY]
);
GO

-- agora vamos efetivamente criar a tabela, usando 
-- o esquema de particionamento definido anteriormente
CREATE TABLE vendas(
	id INT NOT NULL,
	data DATE NOT NULL,
	valor DECIMAL(10,2),
	cliente_id INT,
	CONSTRAINT PK_vendas PRIMARY KEY NONCLUSTERED(id, data)
)
ON ps_ano (data);
GO

-- inserir os dados na tabela particionada
-- o SQL vai colocar automaticamente os dados
-- nas partições corretas conforme a coluna data

INSERT INTO vendas (id, data, valor, cliente_id)
VALUES
(1, '2010-05-01', 150.00, 101),
(2, '2011-06-15', 150.00, 102),
(3, '2012-08-20', 150.00, 103),
(4, '2013-02-20', 150.00, 104),
(5, '2014-11-12', 150.00, 105),
(6, '2015-07-30', 150.00, 106);

-- vocÊ pode consultar a tabela normalmente, e o sql
-- vai usar a tabela particionada para acelerar a 
-- busca

SELECT * FROM vendas WHERE data = '2012-08-20';



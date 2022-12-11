﻿--O CLIENTE "Thiago Andrade Fiuza", ANTES MORADOR DA CIDADE DE ITAMBACURI, MUDOU DE ENDEREÇO 
--E SOLICITOU A ALTERÇÃO DE SEUS DADOS NO BANCO. O NOVO ENDEREÇO PASSA A SER NA CIDADE DE 
--UBERLANDIA, À AVENIDA AFONSO PENA. ATUALIZE OS DADOS DO CLIENTE:

--ANTES
SELECT * FROM CLIENTE WHERE CIDADE_CLIENTE = 'Itambacuri';

UPDATE CLIENTE 
	SET CIDADE_CLIENTE = 'Uberlandia', RUA_CLIENTE ='Avenida Afonso Pena'
		WHERE 	NOME_CLIENTE = 'Thiago Andrade Fiuza' 
		AND CIDADE_CLIENTE = 'Itambacuri';

--DEPOIS
SELECT * FROM CLIENTE WHERE CIDADE_CLIENTE = 'Uberlandia';

--AO FINAL DO MÊS É NECESSÁRIO ATUALIZAR O SALDO DAS CONTAS DOS CLIENTES APLICANDO
--A CORREÇÃO DA INFLAÇÃO DE 1% SOBRE AS MESMAS. IMPLEMENTE ESTA ATUALIZAÇÃO VIA SQL.

--ANTES E DEPOIS
SELECT d.nome_cliente , SUM(d.saldo_deposito)
	FROM DEPOSITO as d 
		GROUP BY d.nome_cliente ORDER BY SUM(d.saldo_deposito); -- ok

UPDATE deposito SET saldo_deposito = saldo_deposito * 1.01; -- ok

--AO FINAL DO MÊS É NECESSÁRIO ATUALIZAR O SALDO DAS CONTAS DOS CLIENTES APLICANDO
--OS JUROS DOS INVESTIMENTOS SOBRE AS MESMAS. 
--CLIENTES COM SALDO ATÉ DEZ MIL RECEBEM 3% DE ACRÉSCIMO.
--CLIENTES COM SALDO MAIOR QUE DEZ MIL RECEBEM 5% DE ACRÉSCIMO.

--ANTES E DEPOIS
SELECT d.nome_cliente , SUM(d.saldo_deposito)
	FROM deposito d  
	GROUP by d.nome_cliente 
	ORDER BY SUM(d.saldo_deposito);

update deposito  SET saldo_deposito  = saldo_deposito * 1.05
	WHERE saldo_deposito <= 10000; -- ok

UPDATE deposito  SET saldo_deposito  = saldo_deposito * 1.03
	WHERE saldo_deposito  > 10000; -- ok

--A ORDEM DE EXECUÇÃO DAS CONSULTAS É IMPORTANTE PORQUE SENÃO UM 
--CLIENTE COM SALDO LIGEIRAMENTE INFERIOR A DEZ MIL PODE RECEBER 
--UM ACRÉSCIMO DE 8.15% = (1.03*1.05)

--INSERIR NOVOS DEPOSITOS NO BANCO DE DADOS
INSERT INTO deposito (numero_deposito ,numero_conta, nome_agencia, nome_cliente , saldo_deposito) 
VALUES (1256841,54801,  'UFMG', 'Carolina Soares', 1200); -- ok

--INCLUIR PARA TODOS OS CLIENTES COM EMPRESTIMOS NA AGENCIA PUC
--UMA CONTA DE DEPÓSITO NO VALOR DE R$ 200,00.
select max(d2.numero_deposito) from deposito d2;
create sequence firt_sequence2_deposito increment 1 start 8795330; -- ok


select * from deposito d ;
INSERT INTO deposito  (numero_deposito, numero_conta, nome_agencia, nome_cliente, saldo_deposito)
	select nextval('firt_sequence2_deposito'), e.numero_conta, e.nome_agencia, e.nome_cliente, 200
		FROM EMPRESTIMO as e 
		WHERE e.nome_agencia = 'PUC'; -- erro! tique que criar um sequence para consertar o erro!

--VERIFICANDO:
SELECT * 
	FROM DEPOSITO 
	WHERE NOME_AGENCIA = 'PUC' 
	AND SALDO_DEPOSITO = 200; -- ok

--O MAIS CORRETO AQUI É A CRIAÇÃO DE UM NÚMERO SEQUENCIAL PARA 
--IDENTIFICAR O NÚMERO DO DEPÓSITO. SUPONDO QUE JÁ TEMOS 
--ALGUNS NÚMEROS TEMOS QUE COMEÇAR A NOSSA SEQUENCIA DE MAX+1
SELECT max(NUMERO_DEPOSITO) FROM DEPOSITO;

--use letras minúsculas no nome da sequencia para evitar problemas

--AGORA NÃO PRECISAMOS INSERIR O NÚMERO DO DEPÓSITO MANUALMENTE
INSERT INTO DEPOSITO
	SELECT nextval('firt_sequence2_deposito'), NUMERO_CONTA, NOME_AGENCIA, NOME_CLIENTE, 200
		FROM EMPRESTIMO 
		WHERE NOME_AGENCIA = 'PUC'; -- ok

--07- UM MILIONÁRIO DECIDIU DOAR PARTE DE SUA FORTUNA PARA CLIENTES 
--DO BANCO COM DÍVIDAS ALTAS. O CRITÉRIO SERÁ DEPOSITAR 2 MIL REAIS
--PARA TODOS OS CLIENTES DO BANCO QUE FIZERAM EMPRESTIMOS CUJAS
--SOMAS ULTRAPASSEM A SOMA DE DEPÓSITOS. CRIE UM SQL PARA INSERIR
-- NA TABELA DE DEPÓSITOS QUANTIAS DE 2 MIL REAIS PARA TODAS AS CONTAS
-- QUE ESTÃO COM SALDO NEGATIVO EM MAIS DE DOIS MIL REAIS.
INSERT INTO DEPOSITO
	SELECT nextval('firt_sequence2_deposito'), NUMERO_CONTA, NOME_AGENCIA, NOME_CLIENTE, 2000
		FROM emprestimo ;

--VALORES NEGATIVOS
SELECT NUMERO_CONTA, NOME_AGENCIA, NOME_CLIENTE, SUM(VALOR_EMPRESTIMO) * -1 AS SOMA_DIVIDAS
     FROM EMPRESTIMO 
     GROUP BY NUMERO_CONTA, NOME_AGENCIA, NOME_CLIENTE; -- ok

--VALORES POSITIVOS
SELECT NUMERO_CONTA, NOME_AGENCIA, NOME_CLIENTE, SUM(SALDO_DEPOSITO) AS SOMA_
     FROM DEPOSITO 
     group BY NUMERO_CONTA, NOME_AGENCIA, NOME_CLIENTE; -- ok

--JUNÇÃO DOS DADOS NEGATIVOS E POSITIVOS
SELECT NUMERO_CONTA , NOME_AGENCIA , NOME_CLIENTE , SOMA
	from (
     		SELECT NUMERO_CONTA, NOME_AGENCIA, NOME_CLIENTE, SUM(VALOR_EMPRESTIMO) AS SOMA 
     			FROM EMPRESTIMO 
     			GROUP BY NUMERO_CONTA, NOME_AGENCIA, NOME_CLIENTE
     	union
     		SELECT NUMERO_CONTA, NOME_AGENCIA, NOME_CLIENTE, SUM(SALDO_DEPOSITO) AS SOMA 
     			FROM DEPOSITO   
     			GROUP BY NUMERO_CONTA, NOME_AGENCIA, NOME_CLIENTE
	) AS RELATORIO1 -- ok

--JUNÇÃO DOS DADOS NEGATIVOS E POSITIVOS E FILTRAGEM DOS REGISTROS
SELECT NUMERO_CONTA , NOME_AGENCIA , NOME_CLIENTE
	FROM (
     	SELECT NUMERO_CONTA, NOME_AGENCIA, NOME_CLIENTE, SUM(VALOR_EMPRESTIMO)*(-1) AS SOMA
     		FROM EMPRESTIMO 
     		GROUP BY NUMERO_CONTA, NOME_AGENCIA, NOME_CLIENTE
     union
     	SELECT NUMERO_CONTA, NOME_AGENCIA, NOME_CLIENTE, SUM(SALDO_DEPOSITO)        AS SOMA 
     		FROM DEPOSITO
     		GROUP BY NUMERO_CONTA, NOME_AGENCIA, NOME_CLIENTE
   ) AS RELATORIO1
	GROUP BY NUMERO_CONTA, NOME_AGENCIA, NOME_CLIENTE
	having  sum(SOMA) < -2000; -- ok

--ENTÃO:
select * from deposito d ;
INSERT INTO DEPOSITO (numero_deposito , numero_conta , nome_agencia , nome_cliente , saldo_deposito  )
	SELECT nextval('firt_sequence2_deposito'), NUMERO_CONTA, NOME_AGENCIA, NOME_CLIENTE, 2000 
		FROM 
			(select NUMERO_CONTA , NOME_AGENCIA , NOME_CLIENTE  
				FROM (SELECT NUMERO_CONTA, NOME_AGENCIA, NOME_CLIENTE, SUM(VALOR_EMPRESTIMO)*(-1) AS SOMA 
     					FROM EMPRESTIMO 
     					GROUP BY NUMERO_CONTA, NOME_AGENCIA, NOME_CLIENTE
     			UNION
     				SELECT NUMERO_CONTA, NOME_AGENCIA, NOME_CLIENTE, SUM(SALDO_DEPOSITO)        AS SOMA 
     					FROM deposito  
     					GROUP by NUMERO_CONTA, NOME_AGENCIA, NOME_CLIENTE
     			) AS RELATORIO1
				GROUP BY NUMERO_CONTA, NOME_AGENCIA, NOME_CLIENTE
				having sum(SOMA) < -2000
			) as RELATORIO2; -- ok
 
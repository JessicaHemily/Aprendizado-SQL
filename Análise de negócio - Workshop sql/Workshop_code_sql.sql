-- workshop

-- 1 - ANÁLISE DE DOCENTES POR ÁREA:

SELECT * FROM Disciplinas
SELECT * FROM Staff
SELECT * FROM Area

SELECT
a.Nome AS area,
COUNT(DISTINCT s.Documento) AS num_docentes,
FORMAT(AVG(d.Custo  * 0.33), 'C3') AS media_salario_docentes
FROM
Staff as s
INNER JOIN Disciplinas d ON s.Disciplina = d.DisciplinaID
INNER JOIN Area a ON d.Area = a.AreaID
GROUP BY
a.Nome
ORDER BY
num_docentes DESC;

-- VERSÃO ALONE
SELECT
	A.Nome AS Nome_Area,
	COUNT(DISTINCT S.Documento) AS Num_doscentes,
	AVG(d.Custo  * 0.33) AS Média_salário
FROM Staff S
INNER JOIN Disciplinas D ON S.Disciplina = D.DisciplinaID
INNER JOIN Area A ON A.AreaID = D.Area
GROUP BY A.Nome
ORDER BY Num_doscentes DESC

-- 2 - ANÁLISE DIÁRIA DE ESTUDANTES:

SELECT * FROM Estudantes

SELECT
	YEAR([Data de Ingresso]) AS Ano_ingresso,
	MONTH([Data de Ingresso]) AS Mes_ingresso,
	DAY([Data de Ingresso]) AS Dia_ingresso,
	COUNT(*) AS Quant_Estudantes
FROM Estudantes
GROUP BY 
	YEAR([Data de Ingresso]),
	MONTH([Data de Ingresso]),
	DAY([Data de Ingresso])
ORDER BY COUNT(*) DESC

-- 3 - ANÁLISE DE COORDENADORES COM MAIS DOCENTES A SEU CARGO:

Select TOP(10) 
	Staff.Supervisor,
	count(*) as total_docentes, 
	Supervisor.Nome, 
	Supervisor.Sobrenome,
	Supervisor.Telefone
From Staff
INNER JOIN Supervisor on Supervisor.Supervisor_ID = Staff.Supervisor
group by Staff.Supervisor, Supervisor.Nome, Supervisor.Sobrenome, Supervisor.Telefone
order by total_docentes DESC;

-- Considerando que vários coordenadores possuem 5 docentes ao seu cargo, estes então, compartilham a décima colocação.
-- Para mostrar o TOP(10) completo, sem 'truncar' no índice 10, usamos a clausula WITH TIES.

Select TOP(10) WITH TIES
	Staff.Supervisor,
	count(*) as total_docentes, 
	Supervisor.Nome, 
	Supervisor.Sobrenome,
	Supervisor.Telefone
From Staff
INNER JOIN Supervisor on Supervisor.Supervisor_ID = Staff.Supervisor
group by Staff.Supervisor, Supervisor.Nome, Supervisor.Sobrenome, Supervisor.Telefone
order by total_docentes DESC;


-- 4 - ANÁLISE DE PROFISSÕES COM MAIS ESTUDANTES:

SELECT * FROM Area

SELECT * FROM Staff
SELECT * FROM Supervisor
SELECT * FROM Disciplinas
SELECT * FROM Profissões
SELECT * FROM Estudantes
SELECT * FROM Area

select Profissões.Profissões, count(*) as total_estudantes
from Estudantes
inner join Profissões on Profissões.ProfissõesID = Estudantes.Profissão
group by Profissões.Profissões
Having count(*) > 5
order by total_estudantes DESC;

-- 5 - ANÁLISE DE ESTUDANTES POR ÁREA DE EDUCAÇÃO:

SELECT * FROM Estudantes
SELECT * FROM Area
SELECT * FROM Disciplinas
SELECT * FROM Staff

SELECT 
	A.Nome AS Nome_Area,
	D.Nome AS Curso,
	D.Tipo AS Tipo,
	D.Custo AS Custo,
	d.Jornada AS Período,
	COUNT(E.EstudantesID) AS Quant_Estudantes

FROM Disciplinas D
LEFT JOIN Area A ON D.Area = A.AreaID
LEFT JOIN Staff S ON S.Disciplina  = D.DisciplinaID
LEFT JOIN Estudantes E ON E.Docente = S.DocentesID
GROUP BY 
	A.Nome, 
	D.Nome,
	D.Tipo,
	d.Jornada,
	d.Custo
ORDER BY Quant_Estudantes DESC;


-- 6 ANÁLISE MENSAL DE ESTUDANTES POR ÁREA:

SELECT * FROM Estudantes
SELECT * FROM Area
SELECT * FROM Disciplinas
SELECT * FROM Staff

SELECT
	A.AreaID,
	A.Nome AS Nome_Area,
	CONCAT(YEAR(E.[Data de Ingresso]),'/',MONTH(E.[Data de Ingresso])) AS AnoMes,
	COUNT(E.EstudantesID) AS Quant_estudantes,
	SUM(D.Custo) AS Custo_total
FROM Area A
INNER JOIN Disciplinas D ON A.AreaID = D.Area
INNER JOIN Staff S ON S.Disciplina = D.DisciplinaID
INNER JOIN Estudantes E ON E.Docente = S.DocentesID
GROUP BY A.AreaID,A.Nome, CONCAT(YEAR(E.[Data de Ingresso]),'/',MONTH(E.[Data de Ingresso]))
ORDER BY AnoMes DESC, Quant_estudantes DESC;

-- 7 ANÁLISE COORDENADOR ORIENTADORES PERÍODO NOTURNO:

SELECT * FROM Supervisor
SELECT * FROM Area
SELECT * FROM Staff
SELECT * FROM Disciplinas

SELECT
	SUP.Nome AS Nome_Coordenador,
	SUP.Documento,
	A.AreaID
	
FROM Supervisor SUP
INNER JOIN Staff S ON SUP.Supervisor_ID = S.Supervisor
INNER JOIN Disciplinas D ON S.Disciplina = D.DisciplinaID
INNER JOIN Area A ON D.Area = A.AreaID
WHERE D.Jornada =	'Noite'
ORDER BY A.AreaID DESC;


-- 8 ANÁLISE DISCIPLINAS SEM DOCENTES OU ORIENTADORES:


SELECT COUNT(*) FROM Disciplinas WHERE DisciplinaID IS NULL;

WHERE Disciplina IS NULL
SELECT * FROM Disciplinas

-- PARTE 1
SELECT 
	Tipo,
	Nome,
	Jornada,
	Area,
	COUNT (*) AS Total_Disciplinas
FROM Disciplinas
WHERE DisciplinaID NOT IN 
	(SELECT DISTINCT(Disciplina) from  Staff)
GROUP BY 
	Tipo,
	Nome,
	Jornada,
	Area
ORDER BY Tipo DESC
	

-- PARTE 2
SELECT
	Area,
	COUNT(*) AS Quant_sem_docente
FROM Disciplinas
WHERE DisciplinaID NOT IN 
	(SELECT DISTINCT(Disciplina) from  Staff)
GROUP BY Area


-- 9 ANÁLISE AUMENTO DE SALÁRIO POR MÉDIA:

SELECT
	D2.Nome,
	D2.Custo AS Custo,
	D2.Area,
	(SELECT
		AVG(D1.Custo) 
		FROM Disciplinas D1
		WHERE D1.Area = D2.Area) AS Média	
	
FROM Disciplinas D2
WHERE D2.Custo > (SELECT
		AVG(D1.Custo) 
		FROM Disciplinas D1
		WHERE D1.Area = D2.Area)

-- 10 ANÁLISE AUMENTO DE SALÁRIO DOCENTES:

SELECT * FROM Disciplinas
SELECT * FROM Staff
SELECT * FROM Area


SELECT
	CONCAT(S.Nome,' - ',S.Sobrenome) AS Docente,
	S.Documento,
	A.Nome AS Area,
	D.Nome AS Disciplina,
	0.3*(D.Custo) AS Salário_antigo,
	CASE 
		WHEN A.Nome = 'Ux Design' THEN
			FORMAT(1.2*(0.3*(D.Custo)),'C3')
		WHEN A.Nome = 'Marketing Digital' THEN
			FORMAT(1.17*(0.3*(D.Custo)),'C3')
		WHEN A.Nome = 'Programação' THEN
			FORMAT(1.23*(0.3*(D.Custo)),'C3')
		WHEN A.Nome = 'Produtos' THEN
			FORMAT(1.13*(0.3*(D.Custo)),'C3')
		WHEN A.Nome = 'Dados' THEN
			FORMAT(1.15*(0.3*(D.Custo)),'C3')
		WHEN A.Nome = 'Ferramentas' THEN
			FORMAT(1.08*(0.3*(D.Custo)),'C3')
	END AS Salário_com_Aumento
FROM Staff S
LEFT JOIN Disciplinas D ON D.DisciplinaID = S.Disciplina
LEFT JOIN Area A ON A.AreaID = D.Area





--SQL AVANÇADO - AULA 23 - 09/05

-- TESTE - APRENDENDO A USAR SUBQUERY

WITH TESTE (Nome, idade) AS
(
SELECT 
	E.Nome as Nome,
	E.Idade as idade
	FROM Estudantes E
)
SELECT *
from TESTE

---- USANDO SUBQUERY - RESULTADO FINAL

SELECT * FROM Disciplinas
SELECT * FROM Estudantes
SELECT * FROM Staff

WITH consulta_cte -- (area_id,	nome_area_periodo,	Custo_area,	Data_ingresso,	indice)
AS
(
SELECT 
	A.AreaID AS area_id,
	CONCAT(A.Nome,'-',D.Jornada) as nome_area_periodo,
	D.Custo AS Custo_area,
	CONVERT(VARCHAR(10),E.[Data de Ingresso],103) AS Data_ingresso,
	ROW_NUMBER() OVER(
						PARTITION BY CONCAT(A.Nome,'-',D.Jornada)
						ORDER BY E.[Data de Ingresso] ASC)
					AS indice
FROM Estudantes E
LEFT JOIN Staff S ON S.DocentesID = E.Docente
LEFT JOIN Disciplinas D ON D.DisciplinaID = S.Disciplina
LEFT JOIN Area A ON A.AreaID = D.Area
WHERE 
	YEAR(E.[Data de Ingresso])=2021 
)

SELECT 
	nome_area_periodo,
	FORMAT(sum(custo_area),'C3') as soma_primeiro_meses
	FROM consulta_cte
WHERE indice <4
GROUP BY nome_area_periodo,area_id
ORDER BY area_id	


-- workshop

-- 1 - AN�LISE DE DOCENTES POR �REA:

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

-- 2 - AN�LISE DI�RIA DE ESTUDANTES:

SELECT 
	COUNT(*) AS Quant_Estudantes,
	YEAR([Data de Ingresso]) AS Ano,
	MONTH([Data de Ingresso]) AS Mes,
	DAY([Data de Ingresso]) AS Dia

FROM Estudantes

	GROUP BY
		YEAR([Data de Ingresso]),
		MONTH([Data de Ingresso]),
		DAY([Data de Ingresso])
	ORDER BY COUNT(*) DESC;

-- 3 - AN�LISE DE COORDENADORES COM MAIS DOCENTES A SEU CARGO:

SELECT * FROM Staff
SELECT * FROM Supervisor

SELECT TOP(10)
	CONCAT(SUP.Nome,'-',SUP.Sobrenome) AS Nome_Supervisor,
	SUP.Telefone AS Contato,
	COUNT(*) AS N_Docentes
FROM Staff S
INNER JOIN Supervisor SUP	ON S.Supervisor = SUP.Supervisor_ID
GROUP BY CONCAT(SUP.Nome,'-',SUP.Sobrenome), SUP.Telefone
ORDER BY N_Docentes DESC


-- 4 - AN�LISE DE PROFISS�ES COM MAIS ESTUDANTES:

SELECT * FROM Area

SELECT * FROM Staff
SELECT * FROM Supervisor
SELECT * FROM Disciplinas
SELECT * FROM Profiss�es
SELECT * FROM Estudantes
SELECT * FROM Area

select Profiss�es.Profiss�es, count(*) as total_estudantes
from Estudantes
inner join Profiss�es on Profiss�es.Profiss�esID = Estudantes.Profiss�o
group by Profiss�es.Profiss�es
Having count(*) > 5
order by total_estudantes DESC;

-- 5 - AN�LISE DE ESTUDANTES POR �REA DE EDUCA��O:

SELECT * FROM Estudantes
SELECT * FROM Area
SELECT * FROM Disciplinas
SELECT * FROM Staff

SELECT 
	A.Nome AS Nome_Area,
	D.Nome AS Curso,
	D.Tipo AS Tipo,
	D.Custo AS Custo,
	d.Jornada AS Per�odo,
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


-- 6 AN�LISE MENSAL DE ESTUDANTES POR �REA:

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

-- 7 AN�LISE COORDENADOR ORIENTADORES PER�ODO NOTURNO:

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


-- 8 AN�LISE DISCIPLINAS SEM DOCENTES OU ORIENTADORES:


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


-- 9 AN�LISE DISCIPLINA MAIOR POR M�DIA:





SELECT

FROM Disciplinas

-- 9 AN�LISE AUMENTO DE SAL�RIO POR M�DIA:

SELECT
	D2.Nome,
	D2.Custo AS Custo,
	D2.Area,
	(SELECT
		AVG(D1.Custo) 
		FROM Disciplinas D1
		WHERE D1.Area = D2.Area) AS M�dia	
	
FROM Disciplinas D2
WHERE D2.Custo > (SELECT
		AVG(D1.Custo) 
		FROM Disciplinas D1
		WHERE D1.Area = D2.Area)

-- 10 AN�LISE AUMENTO DE SAL�RIO DOCENTES:

SELECT * FROM Disciplinas
SELECT * FROM Staff
SELECT * FROM Area

SELECT
	S.Nome AS Docente,
	S.Documento,
	A.AreaID AS Area,
	d.Nome AS Disciplina,
	CASE 	WHEN A.Nome = 'Ux Design' THEN
		(0.33*D.Custo) +(0.33*D.Custo)*0.20
		
	WHEN A.Nome = 'Marketing Digital' THEN
		(0.33*D.Custo) +(0.33*D.Custo)*0.17

	WHEN A.Nome = 'Programa��o' THEN
		(0.33*D.Custo) +(0.33*D.Custo)*0.23

	WHEN A.Nome = 'Produtos' THEN
		(0.33*D.Custo) +(0.33*D.Custo)*0.13

	WHEN A.Nome = 'Dados' THEN
		(0.33*D.Custo) +(0.33*D.Custo)*0.15

	WHEN A.Nome = 'Ferramentas' THEN
		(0.33*D.Custo) +(0.33*D.Custo)*0.08

	END AS Aumento
FROM Staff S
INNER JOIN Disciplinas D ON S.Disciplina = D.DisciplinaID
INNER JOIN Area A ON D.Area = A.AreaID


GROUP BY Area
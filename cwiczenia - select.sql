-- FILTROWANIE WIERSZY DANYCH
--1) Zmodyfikuj poni¿sze zapytanie tak aby zwraca³o ró¿ne litery (niepowtarzaj¹ce siê) których cyfra jest niemniejsza (wiêksza lub równa) 2
--	i mniejsza od 5
SELECT DISTINCT litera
FROM (
	VALUES(1, 'a')
		, (2, 'd')
		, (2, 'd')
		, (3, 'f')
		, (null, 'd')
		, (5, 'f')
		, (null, 'f')
		, (5, 'h')
	) zbiór(cyfra, litera)
	ORDER BY litera DESC;

--2) Zmodyfikuj powy¿sze zapytanie aby zróci³o tylko te literki których wiesze zawieraj¹ nieokreœlon¹ wartoœæ cyfry (NULL)
--3) Zmodyfikuj powy¿sze zapytanie (z zad 1.) aby zwróci³o drug¹ i trzeci¹ w kolejnoœci alfabetycznej literê ze zbioru (wykorzystaj stronicowanie)
--4) Dlaczego poni¿sze zapytanie nie zwraca wiersza
SELECT 'OK'
WHERE 1 NOT IN (2, NULL, 3)

-- GRUPOWANIE LUB PARTYCJONOWANIE 
--1) Dlaczego poni¿sze zapytanie jest nieprawid³owe
SELECT litera
	--, cyfra
	, iloœæ = COUNT(*)
	, suma = SUM(cyfra)
FROM (
VALUES(1, 'a')
	, (2, 'b')
	, (3, 'c')
	, (4, 'b')
	, (5, 'c')) zbiór(cyfra, litera)
GROUP BY litera;
--2) Przerobiæ powy¿sze zapytanie tak aby zwraca³o (tyle wierszy ile jest unikalnych wyst¹pieñ litery w zbiorze) z³o¿onych z:
--	litery, mninimalnej cyfry w ramach litery, iloœci wierszy w ramach litery i sumy cyfr w ramach litery

--3) Przerobiæ zapytanie z zadania 2. tak aby zwraca³o wiersze z literkami maj¹cymi sumê cyfr wiêksz¹ od 6

--4) Przerobiæ powy¿sze zapytanie (z zadanie 1.) tak aby zwraca³o pierwotny zbiór wierszy z³o¿ony z liter i cyfr z doklejon¹ do ka¿dego wiersza informacj¹ o iloœci w ramach litery
--	i sumie wszyskich cyfr w ca³ym zbiorze (rozwa¿ u¿ycie klausuli OVER)

-- £¥CZENIE ZBIORÓW
--1) W poni¿szym zapytaniu zamiast NOT EXISTS zastosowaæ LEFT JOIN tak aby wynik by³ identyczny
SELECT edh.*
FROM HumanResources.EmployeeDepartmentHistory edh
WHERE NOT EXISTS(
	SELECT *
	FROM HumanResources.JobCandidate jc
	WHERE jc.BusinessEntityID = edh.BusinessEntityID
	);
--2) W poni¿szym zapytaniu zamiast INTERSECT zastosowaæ JOIN, DISTINCT i ISNULL tak aby wynik by³ identyczny
SELECT *
FROM (VALUES(1,'a')
		, (1, 'b')
		, (1, 'b')
		, (2, NULL)
		) A(c,l)
INTERSECT
SELECT *
FROM (VALUES(1,'d')
		, (1, 'b')
		, (2, NULL)
		, (2, 'b')
		) B(c,l)

-- CTE (common table expression)
-- 1) przerobiæ na cte tak aby w pierwszej klausuli FROM nie by³o podzapytania (SELECTa), a by³o ono wczeœniej przygotowane
--	zapytanie zwraca œredni¹ iloœæ wyst¹pienia liter w zbiorze
SELECT AVG(CAST(licznik AS money))
FROM (SELECT COUNT(*)
	FROM (VAlues('a')
		,('a')
		,('b')
		,('c')
		,('c')
		,('c')
		,('c')
		) zbiór(litera)
	GROUP BY litera) liczniki(licznik)

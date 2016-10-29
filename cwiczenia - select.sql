-- FILTROWANIE WIERSZY DANYCH
--1) Zmodyfikuj poni�sze zapytanie tak aby zwraca�o r�ne litery (niepowtarzaj�ce si�) kt�rych cyfra jest niemniejsza (wi�ksza lub r�wna) 2
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
	) zbi�r(cyfra, litera)
	ORDER BY litera DESC;

--2) Zmodyfikuj powy�sze zapytanie aby zr�ci�o tylko te literki kt�rych wiesze zawieraj� nieokre�lon� warto�� cyfry (NULL)
--3) Zmodyfikuj powy�sze zapytanie (z zad 1.) aby zwr�ci�o drug� i trzeci� w kolejno�ci alfabetycznej liter� ze zbioru (wykorzystaj stronicowanie)
--4) Dlaczego poni�sze zapytanie nie zwraca wiersza
SELECT 'OK'
WHERE 1 NOT IN (2, NULL, 3)

-- GRUPOWANIE LUB PARTYCJONOWANIE 
--1) Dlaczego poni�sze zapytanie jest nieprawid�owe
SELECT litera
	--, cyfra
	, ilo�� = COUNT(*)
	, suma = SUM(cyfra)
FROM (
VALUES(1, 'a')
	, (2, 'b')
	, (3, 'c')
	, (4, 'b')
	, (5, 'c')) zbi�r(cyfra, litera)
GROUP BY litera;
--2) Przerobi� powy�sze zapytanie tak aby zwraca�o (tyle wierszy ile jest unikalnych wyst�pie� litery w zbiorze) z�o�onych z:
--	litery, mninimalnej cyfry w ramach litery, ilo�ci wierszy w ramach litery i sumy cyfr w ramach litery

--3) Przerobi� zapytanie z zadania 2. tak aby zwraca�o wiersze z literkami maj�cymi sum� cyfr wi�ksz� od 6

--4) Przerobi� powy�sze zapytanie (z zadanie 1.) tak aby zwraca�o pierwotny zbi�r wierszy z�o�ony z liter i cyfr z doklejon� do ka�dego wiersza informacj� o ilo�ci w ramach litery
--	i sumie wszyskich cyfr w ca�ym zbiorze (rozwa� u�ycie klausuli OVER)

-- ��CZENIE ZBIOR�W
--1) W poni�szym zapytaniu zamiast NOT EXISTS zastosowa� LEFT JOIN tak aby wynik by� identyczny
SELECT edh.*
FROM HumanResources.EmployeeDepartmentHistory edh
WHERE NOT EXISTS(
	SELECT *
	FROM HumanResources.JobCandidate jc
	WHERE jc.BusinessEntityID = edh.BusinessEntityID
	);
--2) W poni�szym zapytaniu zamiast INTERSECT zastosowa� JOIN, DISTINCT i ISNULL tak aby wynik by� identyczny
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
-- 1) przerobi� na cte tak aby w pierwszej klausuli FROM nie by�o podzapytania (SELECTa), a by�o ono wcze�niej przygotowane
--	zapytanie zwraca �redni� ilo�� wyst�pienia liter w zbiorze
SELECT AVG(CAST(licznik AS money))
FROM (SELECT COUNT(*)
	FROM (VAlues('a')
		,('a')
		,('b')
		,('c')
		,('c')
		,('c')
		,('c')
		) zbi�r(litera)
	GROUP BY litera) liczniki(licznik)

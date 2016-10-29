

--wyświetlenie wartości
SELECT 'ala', 1, cast(3.43);

--nazwanie kolumn
--1 tradycyjny sposób
SELECT 'ala' as imię
	, 1 as [liczba przyjaciół]
	, 3.4 as "średnia ocen";
--2 sposób bez as
SELECT 'ala' imię
	, 1 [liczba przyjaciół]
	, 3.4  "średnia ocen";
--3 sposób preferowany przeze mnie jako najbardziej czytelny
SELECT imię = 'ala' 
	, [liczba przyjaciół] = 1 
	, [średnia ocen] = 3.4;

-- zamiast pojedyńczej stałej mamy możliwość zdefiniowania stałego zbioru danych
-- tabeli złożonej ze stałych
--VALUES(1, 'a')
--	, (2, 'b')
--	, (3, 'c')

--3
-- podobnie jak pojedyńcza stała dla SQL to jeszcze nic nie znaczy
-- wybranie danych z nazwanego zbioru realizuje się za pomocą select from
-- aby nazwać zbiór obejmujemy go nawiasami i specyfikujemy nazwę
-- aby ze zbioru wybrać dane musimy też wprowadzić nazwy kolumn tego zbioru
SELECT *
	, [dodatkowe wyrażenie(maxInt)]= abs(power(-2,31)+1)
FROM (VALUES(1, 'a')
	, (2, 'b')
	, (3, 'c')) x(c,l)
--jak widać wyżej zamiast konkretnych wartości mogą tu być dowolne wyrażenia zwracające pojedyńczą wartość
--w szczególności:
-- wartość kolumny, przy czym * oznacza listę wszystkich kolumn
-- wartość wyrażenia będącym m.in.:
-- działaniami arytmetycznymi na wartościach kolumn, stałych i/lub zmiennych
-- zastosowaniem funkcji skalarnych na wyrażeniu
-- podzapytanie będące wybraniem pojedyńczej wartości ze zbioru
-- lub zastosowaniem funkcji agregującej na zbiorze
SELECT imię = 'Ala'
	, średnia = (
		SELECT AVG(ocena)
		FROM (VALUES(2),(3),(3),(4),(5),(5)) oceny(ocena));--typ danych całkowity
--		FROM (VALUES(2.0),(3),(3),(4),(5),(5)) oceny(ocena));--typ danych zmiennoprzecinkowy

-- FILTROWANIE WIERSZY: klausula where
/*
poniższe instrukcje nie są treścią wykładu, ale tworzą coś co pozwoli porównać wydajność dobrego i złego tworzenia filtrów
zazwaczamy cały poniższy blok i wykonujemy (klawisz F5)
*/
IF NOT EXISTS(
	SELECT * 
	FROM sys.indexes 
	WHERE name = 'idx_transactionDate_incl' AND object_id =OBJECT_ID('[Production].[TransactionHistory]'))
create index idx_transactionDate_incl on [Production].[TransactionHistory](TransactionDate)include(quantity,actualcost)--to tworzy potrzebny indeks

set statistics time on--to włącza wypisywanie czasu zapytania
/*
koniec bloku dodatkowego
*/
USE AdventureWorks;--to przełącza kontekst okienka na bazę AdventureWorks
-- Weźmy wartość transakcji z sierpnia 2008
--niewydajne rozwiązanie
SELECT SUM(Quantity*ActualCost)
FROM [Production].[TransactionHistory]
WHERE MONTH(TransactionDate) = 8 AND YEAR(TransactionDate) = 2008
--optymalne rozwiązanie
SELECT SUM(Quantity*ActualCost)
FROM [Production].[TransactionHistory]
WHERE TransactionDate >= '20080801' AND TransactionDate < '20080901'
--DOBRA PRAKTYKA pisać warunki filtrujące tak aby na kolumnach nie było wykonywane żadne działanie
--ani nawet niejawna konwersja
--weź wszystkie dane karty kredytowej o numerze 77779999252881
--niewydajne
SELECT *
FROM Sales.CreditCard
WHERE CardNumber = 77779999252881
--wydajnie
SELECT *
FROM Sales.CreditCard
WHERE CardNumber = '77779999252881'
--weź wszystkie dane kart kredytowych zaczynające się od '77779999'
--typowe rozwiązanie
SELECT *
FROM Sales.CreditCard
WHERE CardNumber LIKE N'77779999%'
--najszybsze (ryzykowny mikrotuning)
SELECT *
FROM Sales.CreditCard
WHERE CardNumber >= N'77779999' AND CardNumber < N'7777999A'
--najwolniejsze
SELECT *
FROM Sales.CreditCard
WHERE SUBSTRING(CardNumber, 1, 8) = N'77779999'--w SQL indeks pierwszego znaku to 1 a nie 0 jak w wielu innych językach programowania

--GRUPOWANIE: group by
	--ile razy występuje literka w danym zbiorze i jaka jest suma jej cyfr
SELECT litera
	, ilość = COUNT(*)
	, suma = SUM(cyfra)
FROM (
VALUES(1, 'a')
	, (2, 'b')
	, (3, 'c')
	, (4, 'b')
	, (5, 'c')) zbiór(cyfra, litera)
GROUP BY litera
--FILTROWANIE GRUP: having na podstawie zagregowanych wartości
-- dla liter występujących więcej niż raz Wyświetlić średnią ich cyfr
SELECT litera
	, średnia = AVG(CAST(cyfra AS money))
FROM (
VALUES(1, 'a')
	, (2, 'b')
	, (3, 'c')
	, (4, 'C')
	, (5, 'B')) zbiór(cyfra, litera)
GROUP BY litera
HAVING COUNT(*) > 1
--DOBRA PRAKTYKA: co można odrzucić za pomocą filtrowania wierszy (where), należy tam to zrobić
-- a za pomocą filtrowania grup (having) odrzucamy warunkami zawierającymi agregacje

--SORTOWANIE(PORZĄDTKOWANIE): order by
--wyświetlić zbiór uporządkowany rosnąco wg liter i malejąco wg cyfr  
SELECT cyfra, litera
FROM (
VALUES(1, 'a')
	, (2, 'b')
	, (3, 'c')
	, (4, 'C')
	, (5, 'B')) zbiór(cyfra, litera)
ORDER BY litera ASC, cyfra DESC
--ORDER BY 2, 1 DESC

--TOP (pierwsze n wierszy)
SELECT TOP(2) litera
FROM (
VALUES(1, 'D')
	, (2, 'b')
	, (3, 'c')
	, (4, 'C')
	, (5, 'B')) zbiór(cyfra, litera)
ORDER BY 1
--STRONICOWANIE
SELECT litera, cyfra
FROM (
VALUES(1, 'D')
	, (2, 'b')
	, (3, 'c')
	, (4, 'C')
	, (5, 'B')) zbiór(cyfra, litera)
ORDER BY litera OFFSET 2 ROWS FETCH NEXT 2 ROWS ONLY;

--DISTINCT (niepowtarzające się wiersze; nie gwarantuje sortowania)
SELECT DISTINCT litera
FROM (
VALUES(1, 'D')
	, (2, 'b')
	, (3, 'c')
	, (4, 'C')
	, (5, 'B')) zbiór(cyfra, litera);
--distinct top
SELECT DISTINCT TOP(2) litera
FROM (
VALUES(1, 'D')
	, (2, 'b')
	, (3, 'c')
	, (4, 'C')
	, (5, 'B')) zbiór(cyfra, litera)
ORDER BY 1

--operatory godne uwagi
-- <> oznacza "jest różne"
SELECT *
FROM HumanResources.JobCandidate jc
WHERE jc.BusinessEntityID <> NULL;--nie porównuje się z null!!! bo pusty wynik zawsze

SELECT *
FROM HumanResources.JobCandidate jc
WHERE jc.BusinessEntityID <> 212;
--IS NULL, IS NOT NULL
SELECT *
FROM HumanResources.JobCandidate jc
WHERE jc.BusinessEntityID IS NULL;
--zdecydowana większość operacji i fnkcji na wartości null daje w wyniku null
--null oznacza coś nieokreślonego
SELECT *
FROM HumanResources.JobCandidate jc
WHERE jc.BusinessEntityID = NULL;--nie porównuje się z null!!! bo pusty wynik zawsze
--IN, NOT IN
SELECT *
FROM HumanResources.JobCandidate jc
WHERE jc.JobCandidateID IN (1,3,5);

SELECT *
FROM HumanResources.EmployeeDepartmentHistory edh
WHERE edh.BusinessEntityID IN (
	SELECT jc.BusinessEntityID
	FROM HumanResources.JobCandidate jc);
-- UWAGA na not in
SELECT *
FROM HumanResources.EmployeeDepartmentHistory edh
WHERE edh.BusinessEntityID NOT IN (
	SELECT jc.BusinessEntityID
	FROM HumanResources.JobCandidate jc
	--WHERE jc.BusinessEntityID IS NOT NULL-- bez tego filtru wynik jest pusty
	);

-- EXISTS
SELECT *
FROM HumanResources.EmployeeDepartmentHistory edh
WHERE NOT EXISTS(
	SELECT *
	FROM HumanResources.JobCandidate jc
	WHERE jc.BusinessEntityID = edh.BusinessEntityID
	);
-- CASE
SELECT   ProductNumber
	, Category =
		CASE ProductLine
			WHEN 'R' THEN 'Road'
			WHEN 'M' THEN 'Mountain'
			WHEN 'T' THEN 'Touring'
			--WHEN 'S' THEN 'Other sale items'
			--ELSE 'Not for sale'
		END
	, ProductLine
	, Name
FROM Production.Product
ORDER BY ProductNumber;

SELECT   ProductNumber
	, Name
	, [Price Range] = 
		CASE 
			WHEN ListPrice =  0 THEN 'Mfg item - not for resale'
			WHEN ListPrice < 50 THEN 'Under $50'
			WHEN ListPrice >= 50 and ListPrice < 250 THEN 'Under $250'
			WHEN ListPrice >= 250 and ListPrice < 1000 THEN 'Under $1000'
			ELSE 'Over $1000'
		END
FROM Production.Product
ORDER BY ProductNumber ;

-- PIVOT UNPIVOT
--SELECT *
--FROM (
SELECT FirstName, LastName, TelephoneNumber
	, [iif] = IIF(TelephoneSpecialInstructions IS NULL, 'Any time', TelephoneSpecialInstructions)
	, [ISNULL] = ISNULL(TelephoneSpecialInstructions, 'Any time')
	, [coalesce] = COALESCE(TelephoneSpecialInstructions, 'Any time')
    , [case] = CASE
          WHEN TelephoneSpecialInstructions IS NULL THEN 'Any time'
          ELSE TelephoneSpecialInstructions
     END
	, TelephoneSpecialInstructions
FROM Person.vAdditionalContactInfo
--) x
--UNPIVOT(
--	wartość FOR kolumna IN (iif, isnull, [coalesce], [case],TelephoneSpecialInstructions)) upvt
--PIVOT(
--	max(wartość) FOR kolumna IN (iif, isnull, [coalesce], [case],TelephoneSpecialInstructions)) upvt

-- OPERACJE NA ZBIORACH
-- intersect - część wspólna zbiorów A ∩ B bez powtórzeń 
SELECT *
FROM (VALUES(1,'a')
		, (1, 'b')
		, (2, 'b')
		, (2, NULL)
		, (2, 'b')) A(c,l)
INTERSECT
SELECT *
FROM (VALUES(1,'d')
		, (1, 'b')
		, (2, NULL)
		, (2, 'b')
		, (2, 'b')) B(c,l)

-- except - różnica zbiorów A \ B bez powtórzeń
SELECT *
FROM (VALUES(1,'a')
		, (1, 'b')
		, (1, 'b')
		, (2, 'b')
		, (2, 'b')) A(c,l)
EXCEPT
SELECT *
FROM (VALUES(1,'d')
		, (2, 'b')
		, (2, 'b')) B(c,l)

-- union - suma zbiorów A ∪ B bez powtórzeń
SELECT *
FROM (VALUES(1,'a')
		, (1, 'b')
		, (1, 'b')
		, (2, 'b')
		, (2, 'b')) A(c,l)
UNION
SELECT *
FROM (VALUES(1,'d')
		, (2, 'b')
		, (2, 'b')) B(c,l)
-- union all - suma zbiorów A ∪ B z powtórzeniami
SELECT *
FROM (VALUES(1,'a')
		, (1, 'b')
		, (1, 'b')
		, (2, 'b')
		, (2, 'b')) A(c,l)
UNION ALL
SELECT *
FROM (VALUES(1,'d')
		, (2, 'b')
		, (2, 'b')) B(c,l)

-- ŁĄCZENIE ZBIORÓW
-- cross join - iloczyn kartezjański zbiorów A x B
SELECT *
FROM (VALUES(1,'a')
		, (2, 'b')) A(c,l)
CROSS JOIN (VALUES(1,'c')
		, (2, 'd')) B(c,l)

-- inner join (krócej join) - iloczony kartezjański z warunkiem (pełne dopasowanie)
SELECT *
FROM (VALUES(1,'a')
		, (2, 'b')
		--, (2, 'b')
		, (3, 'b')
		) A(c,l)
	JOIN (VALUES(1,'c')
		, (2, 'd')
		--, (2, 'd')
		, (4, 'e')
		) B(c,l)
	ON A.c = B.c
-- left outer join (krócej left join) jak join + wiersze z lewego zbioru które się nie dopasowały
SELECT *
FROM (VALUES(1,'a')
		, (2, 'b')
		, (3, 'b')
		, (3, 'b')
		) A(c,l)
	LEFT JOIN (VALUES(1,'c')
		, (2, 'd')
		, (4, 'e')
		) B(c,l)
	ON A.c = B.c
-- right outer join (krócej right join) jak join + wiersze z prawego zbioru które się nie dopasowały
SELECT *
FROM (VALUES(1,'a')
		, (2, 'b')
		, (3, 'b')
		) A(c,l)
	RIGHT JOIN (VALUES(1,'c')
		, (2, 'd')
		, (4, 'e')
		) B(c,l)
	ON A.c = B.c
-- full outer join (krócej full join) jak join + wiersze z prawego i lewego zbioru które się nie dopasowały
SELECT *
FROM (VALUES(1,'a')
		, (2, 'b')
		, (3, 'b')
		) A(c,l)
	FULL JOIN (VALUES(1,'c')
		, (2, 'd')
		, (4, 'e')
		) B(c,l)
	ON A.c = B.c;

-- cross apply, outer apply -- zastosowanie funkcji zbiorowej na elementach zbioru bazowego
SELECT p.ProductID, p.Name, h.TransactionDate
FROM Production.Product p
CROSS APPLY(
	SELECT TOP(2) th.TransactionDate
	FROM Production.TransactionHistory th
	WHERE p.ProductID = th.ProductID
	ORDER BY th.TransactionDate) h;

-- CTE - common table expession (wprowadzanie nazwanych wyrażeń tabelarycznych/zbiorowych: nazwane selecty do wykorzystania w poniższym zapytaniu)
--stara wersja zapytania
SELECT *
FROM (
SELECT FirstName, LastName, TelephoneNumber
	, [iif] = IIF(TelephoneSpecialInstructions IS NULL, 'Any time', TelephoneSpecialInstructions)
	, [ISNULL] = ISNULL(TelephoneSpecialInstructions, 'Any time')
	, [coalesce] = COALESCE(TelephoneSpecialInstructions, 'Any time')
    , [case] = CASE
          WHEN TelephoneSpecialInstructions IS NULL THEN 'Any time'
          ELSE TelephoneSpecialInstructions
     END
	, TelephoneSpecialInstructions
FROM Person.vAdditionalContactInfo
) x
UNPIVOT(
	wartość FOR kolumna IN (iif, isnull, [coalesce], [case],TelephoneSpecialInstructions)) upvt;
-- to samo zapytanie z CTE
WITH x AS(
	SELECT FirstName, LastName, TelephoneNumber
		, [iif] = IIF(TelephoneSpecialInstructions IS NULL, 'Any time', TelephoneSpecialInstructions)
		, [ISNULL] = ISNULL(TelephoneSpecialInstructions, 'Any time')
		, [coalesce] = COALESCE(TelephoneSpecialInstructions, 'Any time')
		, [case] = CASE
			  WHEN TelephoneSpecialInstructions IS NULL THEN 'Any time'
			  ELSE TelephoneSpecialInstructions
		 END
		, TelephoneSpecialInstructions
	FROM Person.vAdditionalContactInfo
)
SELECT *
FROM x
UNPIVOT(
	wartość FOR kolumna IN (iif, isnull, [coalesce], [case],TelephoneSpecialInstructions)) upvt;
-- tu tabelka x użyta jest 2 razy więc bez CTE kod byłby wyraźnie dłuższy
WITH x AS(
	SELECT FirstName, LastName
		, [iif] = IIF(TelephoneSpecialInstructions IS NULL, 'Any time', TelephoneSpecialInstructions)
		, [ISNULL] = ISNULL(TelephoneSpecialInstructions, 'Any time')
	FROM Person.vAdditionalContactInfo
)
SELECT *
FROM x xIf 
	FULL JOIN x xNull ON xIf.FirstName = xNull.FirstName
		AND xIf.LastName = xNull.LastName 
		AND  ISNULL(xIf.iif,'') = ISNULL(xNull.ISNULL, '')
WHERE xIf.FirstName IS NULL OR xNull.FirstName IS NULL;

SELECT iif(@@ROWCOUNT = 0
	, 'iif działa tu tak samo jak isnull'
	, 'iif działa tu inaczej niż isnull');

-- rekurencyjne CTE
WITH pracownicy as(
	SELECT *
	FROM (VALUES
		('a', 'b')
		, ('b', NULL)
		, ('c', 'a')
		, ('d', 'b')) x(pracownik, kierownik)
)
, hierarchia as(
	SELECT *, poziom= 1
	FROM pracownicy p
	WHERE p.kierownik IS NULL
	UNION ALL
	SELECT p.*, poziom+1
	FROM pracownicy p
		JOIN hierarchia h ON p.kierownik = h.pracownik)
SELECT * 
FROM hierarchia;

WITH pracownicy as(
	SELECT *
	FROM (VALUES
		('a', 'b')
		, ('b', NULL)
		, ('c', 'a')
		, ('d', 'b')) x(pracownik, kierownik)
)
, hierarchia as(
	SELECT pracownik, kierownik = cast(ISNULL(kierownik,'') as varchar(max)), poziom= 1
	FROM pracownicy p
	WHERE p.kierownik IS NULL
	UNION ALL
	SELECT p.pracownik, kierownik = cast('>'+h.pracownik+h.kierownik as varchar(max)), poziom+1
	FROM pracownicy p
		JOIN hierarchia h ON p.kierownik = h.pracownik)
SELECT pracownik
	, * 
FROM hierarchia;

-- funkcje szeregujące, funkcje okna: ranking functions, aggregate functions, analytic functions	 (over clause)
WITH x AS (
	SELECT *
	FROM (VALUES
		('a', 1, 3.0)
		,('a', 2, 1.0)
		,('a', 4, 0.0)
		,('b', 0, 1.1)
		,('b', 1, 2.2)
		,('b', 2, 3.3)
		,('b', 3, 4.4)
		) x(l, c,  v)
)
SELECT *,
	 noTab= row_number()OVER(ORDER BY l,c)
	 --[nr wiersza w tabeli]
	, noLit = row_number()OVER(PARTITION BY l ORDER BY c)
	--[nr wiersza w ramach litery]
	, preV = lag(v)OVER(PARTITION BY x.l ORDER BY c)
	--[poprzednia wartość w ramach litery wg cyfr]
	, sumPreV = sum(v)OVER(PARTITION BY l ORDER BY c ROWS UNBOUNDED PRECEDING)
	--[suma wszyskich poprzednich wartości wraz z bieżcą w ramach litery wg cyfr]
	, sum0_1NextV = sum(v)OVER(PARTITION BY l ORDER BY c ROWS BETWEEN CURRENT ROW AND 1 FOLLOWING)
	--[suma bieżącej i 1 następnej wartości w ramach litery wg cyfr]
	, sum1_2NextV = sum(v)OVER(PARTITION BY l ORDER BY c ROWS BETWEEN 1 FOLLOWING AND 2 FOLLOWING)
	--[suma 2 następnych wartości w ramach litery wg cyfr]
	, count = count(*) OVER()
FROM x;

--zaawansowane grupowanie
SELECT a,b, c, SUM(v)
FROM (VALUES
	  (0,0,0,1)
	, (0,0,0,2)
	, (0,0,1,2)
	, (0,1,0,3)
	, (0,1,1,4)
	, (1,0,0,5)
	, (1,0,1,6)
	, (1,1,0,7)
	, (1,1,1,8)
	) x(a,b,c,v)
GROUP BY a, b, c
--GROUP BY ROLLUP (a, b, c)
--GROUP BY CUBE (a, b, c)
--GROUP BY GROUPING SETS ((a, b), (c))


--KOLEJNOŚĆ WYKONYWANIA DZIAŁAŃ W ZAPYTANIACH:
--KOLEJNOŚĆ BEZ UNION:
--FROM, JOIN, ON, APPLY
--WHERE
--GROUP BY i funkcje agregujące czyli SUM() AVG() itd.
--HAVING
--SELECT
--ORDER BY
--TOP
--FOR XML
--KOLEJNOŚĆ W ZAPYTANIACH Z UNIĄ:
--FROM, JOIN, ON, APPLY
--WHERE
--GROUP BY i funkcje agregujące czyli SUM() AVG() itd.
--HAVING
--TOP
--UNION i SELECT
--ORDER BY
--FOR XML
--KOLEJNOŚĆ ZAPISU DZIAŁAŃ W ZAPYTANIACH:
--SELECT TOP wyrażenia
--FROM
-- JOIN ON, APPLY
--WHERE
--GROUP BY 
--HAVING
--UNION 
--ORDER BY
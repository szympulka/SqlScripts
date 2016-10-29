USE AdventureWorks2012;
GO
-------------------------------------------------------------------
--- Zad 1 ---
-- W COLUMNS_UPDATED bajty u³o¿one s¹ od lewej do prawej a bity od prawej do lewej zgodnie z opisem w MSDN
-- warto ten opis przeczytaæ: https://msdn.microsoft.com/pl-pl/library/ms186329(v=sql.110).aspx
-- zaœ m.in. w liczbach bajty u³o¿one s¹ od prawej do lewej i bity te¿ od prawej do lewej
-- wolumny w tabeli s¹ numerowane zgodnie z kolejnoœci¹ ich utworzenia od 1 do n
-- zatem aby sprawdziæ czy zaktualizowano trzeci¹ kolumnê w tabeli, która ma nie wiêcej ni¿ osiem kolumn mo¿emy u¿yæ wyra¿enia 
-- CAST(COLUMNS_UPDATED() AS INT)&4 <> 0
-- a) Jakiego wyra¿enia musimy u¿yæ aby sprawdziæ te¿ trzeci¹ kolumnê w tabeli, która ma miêdzy 9 a 16 kolumn?
-- Przyk³adem takiej tabeli jest tabela Person.Person
-- b) Aby sprawdziæ odpowiedŸ a. napisz wyzwalacz na powy¿szej tabeli który nic nie robi tylko wyœwietla CAST(COLUMNS_UPDATED() AS INT)
-- dzia³aj¹cy po lub zamiast UPDATE i wykonaæ nastêpuj¹ce zapytanie
UPDATE TOP(0) Person.Person
SET NameStyle = NameStyle;
-- aktualizuje ono 0 wierszy i ustawia wartoœæ 3 kolumny na tak¹ sam¹
-- c) dlaczego wyzwalacz siê odpala i COLUMNS_UPDATED() nie jest zerem skoro realnie wartoœæ kolumny siê nie zmienia
-- d) po wykonaniu zadania b) mo¿na po sobie posprz¹taæ usuwaj¹c wyzwalacz za pomoc¹ DROP TRIGGER

--- Zad 2 ---
-- W materiale do wyk³adu (plik wyzwalacze rekurencja.sql; pod koniec pliku) jest wyzwalacz z komentarzem REKOMENDOWANE ROZWI¥ZANIE
-- W warunku if jest b³¹d bo nie jest on równowa¿ny NOT UPDATE(j) AND NOT UPDATE(k)
-- Poprawiæ warunek tak aby wyzwalacz poprawia³ nie poprawia³ danych tylko w przypadku jednoczesnej aktualizacji i,j,k lub j,k
-- w ka¿dym innym przypadku wyzwalacz ma poprawiaæ dane

--- Zad 3 ---
--Mamy nastêpuj¹ce rozwi¹zanie
go
create table dbo.t(i int);
go
create trigger dbo.tT_I on dbo.t after insert
as
print 'Odpali³em tT_I'
if @@rowcount > 0
	print 'wstawiono wiersze'
else
	print 'nie wstawiono wierszy'
go
insert into dbo.t values(1);
go
drop table dbo.t;
go
--poprawiæ wyzwalacz tak aby wypisa³ dwie linijki tekstu w tej kolejnoœci (gdy conajmniej jeden wiersz jest wstawiony)
--Odpali³em tT_I
--wstawiono wiersze

--- Zad 4 ---
declare @i int = 2;
if @i <> 2
	begin
		declare @s varchar(max) = 'Niespodziewana wartoœæ: '+cast(@i as varchar);
		print @s;
	end
else
begin
	declare @s varchar(max) = 'Wartoœæ '+cast(@i as varchar) + ' jest ok:-)';--dokonaæ zmian w tej linijce
	print @s
end
go
-- poprawiæ powy¿szy skrypt we wskazanej w komentarzu lini tak aby siê wykonywa³
-- i wypisywa³: Wartosc 2 jest ok:-)

--- Zad 4 ---
--Co nale¿y zrobiæ aby zmieniona wartoœ prarametru wewn¹trz procedury by³a widoczna po jej wykonaniu?

--- Zad 5 ---
-- Dlaczego warto posiadaæ nie wiêcej ni¿ jeden wyzwalacz DML na jedno zdarzenie (wstawwianie, usuwanie, modyfikowanie)?

--- Zad 6 ---
-- Jaki jest najprostrzy sposów aby w wyzwalaczu AFTER jednoczeœnie wycofaæ zmiany, które go odpali³y, przerwaæ wykonywanie i wyœwietliæ komunikat o b³êdzie? 

--- Zad 7 ---
--- mamy nastêpuj¹cy kod ---
create table A(i int primary key, v char);
go
create trigger tA on A AFTER INSERT, DELETE, UPDATE
AS
set nocount on
DECLARE @dCount INT = 0
	, @iCount INT = 0

PRINT 'Liczba wierszy w DELETED: '+cast(@dCount as varchar)
PRINT 'Liczba wierszy w INSERTED: '+cast(@dCount as varchar)
GO
PRINT 'Wstawienie jednego wiersza'
INSERT INTO A VALUES(1, 'a');
PRINT 'Aktualizacja jednego wiersza'
UPDATE A SET v = 'b' WHERE i = 1;
PRINT 'Usuniêcie jednego wiersza'
DELETE TOP(1) FROM A; 
GO
DROP TABLE A;
GO
-- a) Ile wierszy bêdzie w tabelach logicznych INSERTED i DELETED podczas odpowiednio: wstawiania, aktualizacji i usuwania pojedyñczego wiersza
-- b) Zmodyfikuj wyzwalacz tA tak aby wypisywa³ faktyczn¹ liczbê wierszy w tabelach INSERTED i DELETED

--- Zad 8 ---
--- mamy nastêpuj¹cy kod ---
create table B(i int, v char);
go
create view vB 
as 
select i, v, iv = cast(i as varchar)+v from B;
go
print 'przed usuniêciem kolumny'
alter table B drop column v;-- to nie mo¿e siê udaæ bo potem bêdzie problem
print 'bezpoœrednio po usuniêciu kolumny'
go
print 'po usuniêciu kolumny'
select * from vB;
-- sprz¹tanie
drop table B;
drop view vB;
go
-- Zmodyfikowaæ w powy¿szym kodzie definicjê widoku vB aby potem nie uda³o siê usuniêcie kolumny v z tabeli B, która w tym widoku jest u¿ywana
-- oraz ustawiæ kolejnoœæ usuwania tabeli i widoku tak aby nie by³o dodatkowych b³edów (jedyny b³¹d ma byæ zwi¹zanych tylko z usuniêciem tabeli
-- jedyny b³¹d ma wystêpowaæ pomiêdzy napisami "przed usuniêciem kolumny" i "po usuniêciu kolumny"

--- Zad 9 ---
-- Który z typów funkcji: skalarne, wielowyra¿eniowe, czy online sprawiaj¹ najmniej problemów wydajnoœciowych?

--- Zad 10 ---
-- mamy nasêpuj¹c¹ procedurê
create procedure #p
	@d int output,
	@a int = 1, 
	@b int = 2,
	@c int = 3
as 
set @d = @a*@b*@c;
go
declare @x int = 3
	, @y int;

exec #p @y --tu uzupe³niæ parametry w ten sposób, ¿e za parametr @b podstawiamy wartoœæ zmiannej @x, oraz tak aby po wykonaniu wartoœæ zmiennej @y by³a taka sama jak wartoœæ parametru @d
select @y -- spodziewamy siê tu liczby 9
drop procedure #p
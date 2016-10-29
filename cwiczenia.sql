USE AdventureWorks2012;
GO
-------------------------------------------------------------------
--- Zad 1 ---
-- W COLUMNS_UPDATED bajty u�o�one s� od lewej do prawej a bity od prawej do lewej zgodnie z opisem w MSDN
-- warto ten opis przeczyta�: https://msdn.microsoft.com/pl-pl/library/ms186329(v=sql.110).aspx
-- za� m.in. w liczbach bajty u�o�one s� od prawej do lewej i bity te� od prawej do lewej
-- wolumny w tabeli s� numerowane zgodnie z kolejno�ci� ich utworzenia od 1 do n
-- zatem aby sprawdzi� czy zaktualizowano trzeci� kolumn� w tabeli, kt�ra ma nie wi�cej ni� osiem kolumn mo�emy u�y� wyra�enia 
-- CAST(COLUMNS_UPDATED() AS INT)&4 <> 0
-- a) Jakiego wyra�enia musimy u�y� aby sprawdzi� te� trzeci� kolumn� w tabeli, kt�ra ma mi�dzy 9 a 16 kolumn?
-- Przyk�adem takiej tabeli jest tabela Person.Person
-- b) Aby sprawdzi� odpowied� a. napisz wyzwalacz na powy�szej tabeli kt�ry nic nie robi tylko wy�wietla CAST(COLUMNS_UPDATED() AS INT)
-- dzia�aj�cy po lub zamiast UPDATE i wykona� nast�puj�ce zapytanie
UPDATE TOP(0) Person.Person
SET NameStyle = NameStyle;
-- aktualizuje ono 0 wierszy i ustawia warto�� 3 kolumny na tak� sam�
-- c) dlaczego wyzwalacz si� odpala i COLUMNS_UPDATED() nie jest zerem skoro realnie warto�� kolumny si� nie zmienia
-- d) po wykonaniu zadania b) mo�na po sobie posprz�ta� usuwaj�c wyzwalacz za pomoc� DROP TRIGGER

--- Zad 2 ---
-- W materiale do wyk�adu (plik wyzwalacze rekurencja.sql; pod koniec pliku) jest wyzwalacz z komentarzem REKOMENDOWANE ROZWI�ZANIE
-- W warunku if jest b��d bo nie jest on r�wnowa�ny NOT UPDATE(j) AND NOT UPDATE(k)
-- Poprawi� warunek tak aby wyzwalacz poprawia� nie poprawia� danych tylko w przypadku jednoczesnej aktualizacji i,j,k lub j,k
-- w ka�dym innym przypadku wyzwalacz ma poprawia� dane

--- Zad 3 ---
--Mamy nast�puj�ce rozwi�zanie
go
create table dbo.t(i int);
go
create trigger dbo.tT_I on dbo.t after insert
as
print 'Odpali�em tT_I'
if @@rowcount > 0
	print 'wstawiono wiersze'
else
	print 'nie wstawiono wierszy'
go
insert into dbo.t values(1);
go
drop table dbo.t;
go
--poprawi� wyzwalacz tak aby wypisa� dwie linijki tekstu w tej kolejno�ci (gdy conajmniej jeden wiersz jest wstawiony)
--Odpali�em tT_I
--wstawiono wiersze

--- Zad 4 ---
declare @i int = 2;
if @i <> 2
	begin
		declare @s varchar(max) = 'Niespodziewana warto��: '+cast(@i as varchar);
		print @s;
	end
else
begin
	declare @s varchar(max) = 'Warto�� '+cast(@i as varchar) + ' jest ok:-)';--dokona� zmian w tej linijce
	print @s
end
go
-- poprawi� powy�szy skrypt we wskazanej w komentarzu lini tak aby si� wykonywa�
-- i wypisywa�: Wartosc 2 jest ok:-)

--- Zad 4 ---
--Co nale�y zrobi� aby zmieniona warto� prarametru wewn�trz procedury by�a widoczna po jej wykonaniu?

--- Zad 5 ---
-- Dlaczego warto posiada� nie wi�cej ni� jeden wyzwalacz DML na jedno zdarzenie (wstawwianie, usuwanie, modyfikowanie)?

--- Zad 6 ---
-- Jaki jest najprostrzy spos�w aby w wyzwalaczu AFTER jednocze�nie wycofa� zmiany, kt�re go odpali�y, przerwa� wykonywanie i wy�wietli� komunikat o b��dzie? 

--- Zad 7 ---
--- mamy nast�puj�cy kod ---
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
PRINT 'Usuni�cie jednego wiersza'
DELETE TOP(1) FROM A; 
GO
DROP TABLE A;
GO
-- a) Ile wierszy b�dzie w tabelach logicznych INSERTED i DELETED podczas odpowiednio: wstawiania, aktualizacji i usuwania pojedy�czego wiersza
-- b) Zmodyfikuj wyzwalacz tA tak aby wypisywa� faktyczn� liczb� wierszy w tabelach INSERTED i DELETED

--- Zad 8 ---
--- mamy nast�puj�cy kod ---
create table B(i int, v char);
go
create view vB 
as 
select i, v, iv = cast(i as varchar)+v from B;
go
print 'przed usuni�ciem kolumny'
alter table B drop column v;-- to nie mo�e si� uda� bo potem b�dzie problem
print 'bezpo�rednio po usuni�ciu kolumny'
go
print 'po usuni�ciu kolumny'
select * from vB;
-- sprz�tanie
drop table B;
drop view vB;
go
-- Zmodyfikowa� w powy�szym kodzie definicj� widoku vB aby potem nie uda�o si� usuni�cie kolumny v z tabeli B, kt�ra w tym widoku jest u�ywana
-- oraz ustawi� kolejno�� usuwania tabeli i widoku tak aby nie by�o dodatkowych b�ed�w (jedyny b��d ma by� zwi�zanych tylko z usuni�ciem tabeli
-- jedyny b��d ma wyst�powa� pomi�dzy napisami "przed usuni�ciem kolumny" i "po usuni�ciu kolumny"

--- Zad 9 ---
-- Kt�ry z typ�w funkcji: skalarne, wielowyra�eniowe, czy online sprawiaj� najmniej problem�w wydajno�ciowych?

--- Zad 10 ---
-- mamy nas�puj�c� procedur�
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

exec #p @y --tu uzupe�ni� parametry w ten spos�b, �e za parametr @b podstawiamy warto�� zmiannej @x, oraz tak aby po wykonaniu warto�� zmiennej @y by�a taka sama jak warto�� parametru @d
select @y -- spodziewamy si� tu liczby 9
drop procedure #p
use AdventureWorks2012;
go
create procedure #test--przy okazji pokazuj� procedur� tymczasow� i to �e mo�e si� utworzy� przed tabel� na kt�rej operuje
as
update aa set i = 4;

if @@ROWCOUNT > 0
	select 'ok',*  from aa;
else
	select '�le';
go
ALTER DATABASE AdventureWorks2012 SET RECURSIVE_TRIGGERS OFF--to jest domy�lne ustawienie ale gdyby kto� mia� inaczej to wykonuj� na pocz�tku
go
create table aa(i int primary key, j int, k int)
go
insert into aa values(1,2,3)
go
create trigger taa on aa after update
as
print 'taa'
update aa set j = i
where i in (select i from inserted)
go
-- gdy jeden wyzwalacz i brak rekursi lokalnej wyzwalacza w bazie to wszystko ok
exec #test
go
ALTER DATABASE AdventureWorks2012 SET RECURSIVE_TRIGGERS ON
go
-- gdy jeden wyzwalacz i rekursja lokalna wyzwalacza w bazie w��czona to problem
exec #test
go
ALTER DATABASE AdventureWorks2012 SET RECURSIVE_TRIGGERS OFF--to jest domy�lne ustawienie ale gdyby kto� mia� inaczej to wykonuj� na pocz�tku
go
create trigger taa2 on aa after update
as
print 'taa2'
update aa set k = i
where i in (select i from inserted)
go
--gdy brak rekursji lokalnej ale dwa wyzwalacze to problem
exec #test
go
exec sys.sp_configure 'nested triggers', 0

reconfigure
go
--gdy brak rekursji lokalnej i na serwerze wy��czone jest zagnie�d�anie wyzwalaczy
exec #test
go
ALTER DATABASE AdventureWorks2012 SET RECURSIVE_TRIGGERS ON
GO
--nawet gdy na bazie jest w��czona rekursja lokalna, ale na serwerze wy��czone jest zagnie�d�anie wyzwalaczy
exec #test
go
--PYTANIE: jak sobie poradzi� bez prze��czania domy�lnej opcji ca�ego serwera (mo�e inna baza tego potrzebuje)
--przywracam warto�� domy�ln� tego ustawienia i kombinujemy zmieniaj�c tre�� wyzwalacza
exec sys.sp_configure 'nested triggers', 1

reconfigure
ALTER DATABASE AdventureWorks2012 SET RECURSIVE_TRIGGERS OFF
go
alter trigger taa on aa after update
as
print ' taa: '+ cast(cast(columns_updated() as bigint) as varchar)
if not UPDATE(j)
update aa set j = i
where i in (select i from inserted)
print 'taa'
go
alter trigger taa2 on aa after update
as
print ' taa2: '+ cast(cast(columns_updated() as bigint) as varchar)
if not UPDATE(k)
update aa set k = i
where i in (select i from inserted)
print 'taa2'
go
exec #test
go
--skoro update dotyczy tylko bie��cej zmiany (nie kumuluje si�)
--to musimy sprawdzi� na kt�rym poziomie zagnie�d�enia jeste�my
go
alter trigger taa on aa after update
as
IF TRIGGER_NESTLEVEL() <= 1
	update aa set j = i
	where i in (select i from inserted)
print ' taa'
go
alter trigger taa2 on aa after update
as
IF TRIGGER_NESTLEVEL() <= 1
	update aa set k = i
	where i in (select i from inserted)
print 'taa2'
go
--przy ograniczeniu si� do poziomu zagnie�d�enia osi�gamy cel
exec #test;
go
ALTER DATABASE AdventureWorks2012 SET RECURSIVE_TRIGGERS ON
go
--nawet przy dopuszczeniu rekursji lokalnej wyzwalaczy ostatnie rozwi�zanie dzia�a
exec #test;
go
--niemniej by�oby pro�ciej gdyby�my mieli jeden wyzwalacz
drop trigger taa2
go
--REKOMENDOWANE ROZWI�ZANIE
alter trigger dbo.taa on dbo.aa after update
as
if (cast(columns_updated() as bigint)&6) = 0--PRZY DW�CH KOLUMNACH CZYTELNIEJSZE BY�OBY: NOT UPDATE(j) AND NOT UPDATE(k)
	--a przy domy�lnych ustawieniach bazy lokalna rekursja wyzwalaczy wy��czona �aden warunek nie jest potrzebny
	update aa set j = i, k = i
	where i in (select i from inserted)
print 'taa'
go
exec #test
--sukcess :-)
--sprz�tamy po sobie
drop table aa
drop procedure #test
go
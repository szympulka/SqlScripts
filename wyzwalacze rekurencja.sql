use AdventureWorks2012;
go
create procedure #test--przy okazji pokazujê procedurê tymczasow¹ i to ¿e mo¿e siê utworzyæ przed tabel¹ na której operuje
as
update aa set i = 4;

if @@ROWCOUNT > 0
	select 'ok',*  from aa;
else
	select 'Ÿle';
go
ALTER DATABASE AdventureWorks2012 SET RECURSIVE_TRIGGERS OFF--to jest domyœlne ustawienie ale gdyby ktoœ mia³ inaczej to wykonujê na pocz¹tku
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
-- gdy jeden wyzwalacz i rekursja lokalna wyzwalacza w bazie w³¹czona to problem
exec #test
go
ALTER DATABASE AdventureWorks2012 SET RECURSIVE_TRIGGERS OFF--to jest domyœlne ustawienie ale gdyby ktoœ mia³ inaczej to wykonujê na pocz¹tku
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
--gdy brak rekursji lokalnej i na serwerze wy³¹czone jest zagnie¿d¿anie wyzwalaczy
exec #test
go
ALTER DATABASE AdventureWorks2012 SET RECURSIVE_TRIGGERS ON
GO
--nawet gdy na bazie jest w³¹czona rekursja lokalna, ale na serwerze wy³¹czone jest zagnie¿d¿anie wyzwalaczy
exec #test
go
--PYTANIE: jak sobie poradziæ bez prze³¹czania domyœlnej opcji ca³ego serwera (mo¿e inna baza tego potrzebuje)
--przywracam wartoœæ domyœln¹ tego ustawienia i kombinujemy zmieniaj¹c treœæ wyzwalacza
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
--skoro update dotyczy tylko bie¿¹cej zmiany (nie kumuluje siê)
--to musimy sprawdziæ na którym poziomie zagnie¿d¿enia jesteœmy
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
--przy ograniczeniu siê do poziomu zagnie¿d¿enia osi¹gamy cel
exec #test;
go
ALTER DATABASE AdventureWorks2012 SET RECURSIVE_TRIGGERS ON
go
--nawet przy dopuszczeniu rekursji lokalnej wyzwalaczy ostatnie rozwi¹zanie dzia³a
exec #test;
go
--niemniej by³oby proœciej gdybyœmy mieli jeden wyzwalacz
drop trigger taa2
go
--REKOMENDOWANE ROZWI¥ZANIE
alter trigger dbo.taa on dbo.aa after update
as
if (cast(columns_updated() as bigint)&6) = 0--PRZY DWÓCH KOLUMNACH CZYTELNIEJSZE BY£OBY: NOT UPDATE(j) AND NOT UPDATE(k)
	--a przy domyœlnych ustawieniach bazy lokalna rekursja wyzwalaczy wy³¹czona ¿aden warunek nie jest potrzebny
	update aa set j = i, k = i
	where i in (select i from inserted)
print 'taa'
go
exec #test
--sukcess :-)
--sprz¹tamy po sobie
drop table aa
drop procedure #test
go
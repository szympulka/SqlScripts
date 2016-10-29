--zakres zmiennych
CREATE PROC dbo.ala
--ALTER PROC dbo.ala
	@a int=1
	,@b int=2
	,@c int=3
	, @x INT = 4
AS
BEGIN TRY
--DECLARE @a int =2
SELECT @a, @b, @c, @x
IF @a = 1
BEGIN
	DECLARE @d date = getdate()
END
DECLARE-- @d int=2,
	@e time = getdate()
	, @f money = 5
SELECT @d, @e, @f
	
END TRY
BEGIN CATCH
	/* 
		SELECT
			ERROR_NUMBER() AS ErrorNumber,
			ERROR_SEVERITY() AS ErrorSeverity,
			ERROR_STATE() AS ErrorState,
			ERROR_PROCEDURE() AS ErrorProcedure,
			ERROR_LINE() AS ErrorLine,
			ERROR_MESSAGE() AS ErrorMessage
	*/
END CATCH
go
EXEC dbo.ala 2, @c=2--sposób przekazywania parametrów
--, 3
go
alter proc dbo.ala @i int  --output
as
set @i+=10;
go
--brak output
declare @a int = 10
exec dbo.ala @a;
select @a

-- output musi byæ i w deklaracji i w wywo³aniu
declare @b int = 10
exec dbo.ala @b output;
select @b
go
PRINT @@ROWCOUNT
PRINT @@ROWCOUNT
SELECT * FROM (VALUES(1),(2),(3))x(c);
PRINT @@ROWCOUNT
DECLARE @i int = 1
PRINT @@ROWCOUNT

SET @i = 2
PRINT @@ROWCOUNT
SELECT * FROM (VALUES(1),(2),(3))x(c);
DECLARE @j int
IF @@ROWCOUNT=3
	PRINT 'jak w selekt'
ELSE
	PRINT 'declare zamaza³o selekt'

SELECT 'jeden wiersz';
IF @@ROWCOUNT = 0
	PRINT 'tu nie powinniœmy siê znaleŸæ'
ELSE IF @@ROWCOUNT = 1
	PRINT 'wydaje sie to logiczne'
ELSE
	PRINT 'pierszy if ustawi³ '+cast(@@ROWCOUNT AS varchar)+' rows'

--ustawienie kilku zmiennych na raz
SELECT @i = 10, @j = 20
SELECT i = @i, j = @j, rNo = @@ROWCOUNT

--ustawienie kilkukrotne
DECLARE @sum int = 0;
SELECT @sum+=c FROM (VALUES(1),(2),(3))x(c);
SELECT sum=@sum, @@ROWCOUNT

--z @@error tak samo jak z @@rowcount
SELECT 'UPS' WHERE 1/0=0
--PRINT 'UPS...'
PRINT @@ERROR

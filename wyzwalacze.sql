--USE master;
GO
CREATE PROC #test @i int
as
INSERT INTO dbo.a VALUES(1);
PRINT 'po insert '+CAST(@I AS VARCHAR)
SELECT * FROM dbo.a
GO
CREATE TABLE dbo.a(i int)
GO
--wyzwalacz z throw
CREATE TRIGGER dbo.ta ON dbo.a
AFTER INSERT
AS
PRINT 'przed throw';
THROW 50000,'ala',1;
PRINT 'po throw';
GO
EXEC #test 1
GO
--wyzwalaccz z samym raiserror
ALTER TRIGGER dbo.ta ON dbo.a
AFTER INSERT
AS
PRINT 'przed raiserror'
RAISERROR('ala',16,1);
PRINT 'po raiserror'
GO
EXEC #test 2
GO
--wyzwalacz z jawnym wycofaniem transakcji
ALTER TRIGGER dbo.ta ON dbo.a
AFTER INSERT
AS
RAISERROR('ala',16,1);
ROLLBACK;
PRINT 'po rollback'
GO
EXEC #test 3
GO
--sprz¹tam po sobie
DROP TABLE dbo.a
DROP PROC #test
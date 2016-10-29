USE [baza];
GO

CREATE TABLE [dbo].[Studenci]
    (
      [StudentId] INT IDENTITY(1, 1) PRIMARY KEY CLUSTERED ,
      [Nazwisko] NVARCHAR(250) ,
      [Imie] NVARCHAR(250) ,
      [NumerIndeksu] INT CHECK ( [NumerIndeksu] > 0 ) ,
      [Zdjecie] VARBINARY(MAX) --nie zalecane trzymanie danych binarnych w bazie!
    );
-- sprawdziæ nazwê PK oraz constraint check
DROP TABLE [dbo].[Studenci];

--poprawna sk³adnia z nazwanymi obiektami
CREATE TABLE [dbo].[Studenci]
    (
      [StudentId] [INT] IDENTITY(1, 1) NOT NULL ,
      [Nazwisko] [NVARCHAR](250) NULL ,
      [Imie] [NVARCHAR](250) NULL ,
      [NumerIndeksu] [INT] NULL ,
      [Zdjecie] [VARBINARY](MAX) NULL ,
      CONSTRAINT [PK_Studenci] PRIMARY KEY CLUSTERED ( [StudentId] ASC ) ,
      CONSTRAINT [CK_Studenci_IndexNumber_Gt0] CHECK ( [NumerIndeksu] > ( 0 ) )
    ); 

-- pokazaæ z GUI -----------

CREATE TABLE [dbo].[Budynki](
	[BudynekId] [INT] IDENTITY(1,1) NOT NULL,
	[Symbol] [VARCHAR](10) NULL,
	[Adres] [NVARCHAR](255) NOT NULL,
 CONSTRAINT [PK_Budynki] PRIMARY KEY CLUSTERED ([BudynekId] ASC)
) 

--pokazaæ APEX ----------

CREATE TABLE [dbo].[Kursy](
	[KursId] INT IDENTITY(1,1) NOT NULL,
	[Symbol] NVARCHAR(30),
	[Temat] NVARCHAR(300),
	[Uruchomiony] BIT,
	[BudynekId] INT CONSTRAINT FK_Kursy_Budynki REFERENCES [dbo].[Budynki]([BudynekId]),
	CONSTRAINT [PK_Kursy] PRIMARY KEY CLUSTERED ([KursId] ASC)
)

---- DEFAULT -----

ALTER TABLE [dbo].[Kursy] ADD CONSTRAINT [DF_Uruchomiony] DEFAULT (0) FOR [Uruchomiony];

---------- Relacja wiele do wielu student -> kursy ------------
CREATE TABLE [dbo].[StudentKursy](
	[Id] INT IDENTITY(1,1) NOT NULL,
	[StudentId] INT CONSTRAINT FK_StudentKursy_Studenci REFERENCES [dbo].[Studenci]([StudentId]),
	[KursId] INT CONSTRAINT FK_StudentKursy_Kursy REFERENCES [dbo].[Kursy]([KursId])
)

-- ALTER TABLE - ADD COLUMN

ALTER TABLE [dbo].[Kursy] ADD [Prowadz¹cy] INT;

-- ALTER TABLE - CHANGE TYPE

ALTER TABLE [dbo].[Kursy] ALTER COLUMN [Prowadz¹cy] NVARCHAR(250);
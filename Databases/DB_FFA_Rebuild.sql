-- Full Rebuild Script for FFA Database (with Created_Date + Last_Modified on all tables)

USE [master]
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = N'FFA')
BEGIN
    ALTER DATABASE [FFA] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [FFA];
END
GO

CREATE DATABASE [FFA];
GO

USE [FFA];
GO

-- Create the table
CREATE TABLE Bible_Verses (
	ID INT IDENTITY(1,1) PRIMARY KEY,
	Bible_Version VARCHAR(3),
    Book_Name VARCHAR(50),
    Chapter TINYINT,
    Verse TINYINT,
    Verse_Text NVARCHAR(MAX),
	Verified BIT NOT NULL DEFAULT 0,
	Date_Added DATETIME NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

---- Run Bible Verse Inserts on FFA
---- Enable xp_cmdshell if disabled
--EXEC sp_configure 'show advanced options', 1;
--RECONFIGURE;
--EXEC sp_configure 'xp_cmdshell', 1;
--RECONFIGURE;
---- Run your SQL file using sqlcmd via xp_cmdshell
--EXEC xp_cmdshell 'sqlcmd -S ServerName,1433 -U sa -P password -d FFA -i C:\SQLInsert\BIBLE_INSERT.sql';
--GO

-- =============================
-- TABLES
-- =============================
CREATE TABLE dbo.File_Store (
    File_ID         INT IDENTITY(1,1) PRIMARY KEY,
    File_Hash       VARCHAR(64) NOT NULL UNIQUE,       -- SHA-256
    File_Name       NVARCHAR(255) NOT NULL,
    File_Size_Bytes INT NULL,
    File_Format     NVARCHAR(10) NOT NULL DEFAULT 'mp3',
    File_Binary     VARBINARY(MAX) NOT NULL,
    Created_Date    DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

CREATE TABLE dbo.Voices (
    Voice_ID          INT IDENTITY(1,1) PRIMARY KEY,
    Voice_Name        NVARCHAR(100) NOT NULL UNIQUE, -- e.g., 'en-US-AndrewNeural'
    Engine_Name       NVARCHAR(100) NULL,            -- e.g., 'AzureTTS', 'ChatGPT'
    Model_Name        NVARCHAR(100) NULL,            -- e.g., 'gpt-4o' or 'multilingualNeural'
    Notes             NVARCHAR(255) NULL,
    Active            BIT NOT NULL DEFAULT 1,
    Created_Date      DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    Last_Modified     DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

CREATE TABLE [dbo].[Articles] (
    [Article_ID] INT IDENTITY(1,1) NOT NULL,
    [Article_Name] NVARCHAR(500) NULL,
    [Article_File_Name] NVARCHAR(150) NULL,
    [Article_Date] DATE NULL,
    [Article_Image_Location] NVARCHAR(150) NULL,
    [Article_Audio_Link] NVARCHAR(150) NULL,
    [Article_Found] BIT NOT NULL DEFAULT 0,
    [Article_URL] NVARCHAR(150) NULL,
    [WordPress_ID] INT NULL,
    [WordPress_Slug] NVARCHAR(150) NULL,
    [WordPress_Category] NVARCHAR(150) NULL,
    [WordPress_Last_Modified] DATETIME NULL,
	[Active] BIT NOT NULL DEFAULT 1,
    [Created_Date] DATETIME NOT NULL DEFAULT SYSUTCDATETIME(),
    [Last_Modified] DATETIME NULL,
    CONSTRAINT PK_Articles__Article_ID PRIMARY KEY CLUSTERED ([Article_ID] ASC)
);
GO

CREATE TABLE [dbo].[Articles_Contents] (
    [Content_ID] INT IDENTITY(1,1) NOT NULL,
	[Article_ID] INT NOT NULL,
	[Content_Type_ID] INT NOT NULL DEFAULT 1,
    [Post_Content] NVARCHAR(MAX) NOT NULL,
    [WordPress_Last_Modified] DATETIME NULL,
	[Active] BIT NOT NULL DEFAULT 1,
    [Created_Date] DATETIME NOT NULL DEFAULT SYSUTCDATETIME(),
    [Last_Modified] DATETIME NULL,
    CONSTRAINT PK_Articles_Contents__Content_ID PRIMARY KEY CLUSTERED ([Content_ID] ASC)
);
GO

-- types table
CREATE TABLE [dbo].[Types] (
    [Type_ID] INT IDENTITY(1,1) NOT NULL,
	[Type_Name] NVARCHAR(MAX) NOT NULL,
	[Active] BIT NOT NULL DEFAULT 1,
    [Created_Date] DATETIME NOT NULL DEFAULT SYSUTCDATETIME(),
    [Last_Modified] DATETIME NULL,
    CONSTRAINT PK_Types__Type_ID PRIMARY KEY CLUSTERED ([Type_ID] ASC)
);
GO
-- types initial inserts
INSERT INTO [Types]([Type_Name]) VALUES('Default')
GO
INSERT INTO [Types]([Type_Name], [Active]) VALUES ('Content', 1);
GO
INSERT INTO [Types]([Type_Name], [Active]) VALUES ('Separator', 1);
GO
INSERT INTO [Types]([Type_Name], [Active]) VALUES ('Break', 1);
GO
INSERT INTO [Types]([Type_Name], [Active]) VALUES ('List Item', 1);
go
INSERT INTO [Types]([Type_Name], [Active]) VALUES ('Sub List Item', 1);
go
INSERT INTO [Types]([Type_Name], [Active]) VALUES ('Title', 1);
GO
INSERT INTO [Types]([Type_Name], [Active]) VALUES ('Key Takeaways', 1);
GO
INSERT INTO [Types]([Type_Name], [Active]) VALUES ('Bullets', 1);
go

-- Insert 7 levels of bullet types
INSERT INTO Types (Type_Name, Active)
SELECT 'List Item Level 1', 1
WHERE NOT EXISTS (SELECT 1 FROM Types WHERE Type_Name = 'List Item Level 1');

INSERT INTO Types (Type_Name, Active)
SELECT 'List Item Level 2', 1
WHERE NOT EXISTS (SELECT 1 FROM Types WHERE Type_Name = 'List Item Level 2');

INSERT INTO Types (Type_Name, Active)
SELECT 'List Item Level 3', 1
WHERE NOT EXISTS (SELECT 1 FROM Types WHERE Type_Name = 'List Item Level 3');

INSERT INTO Types (Type_Name, Active)
SELECT 'List Item Level 4', 1
WHERE NOT EXISTS (SELECT 1 FROM Types WHERE Type_Name = 'List Item Level 4');

INSERT INTO Types (Type_Name, Active)
SELECT 'List Item Level 5', 1
WHERE NOT EXISTS (SELECT 1 FROM Types WHERE Type_Name = 'List Item Level 5');

INSERT INTO Types (Type_Name, Active)
SELECT 'List Item Level 6', 1
WHERE NOT EXISTS (SELECT 1 FROM Types WHERE Type_Name = 'List Item Level 6');

INSERT INTO Types (Type_Name, Active)
SELECT 'List Item Level 7', 1
WHERE NOT EXISTS (SELECT 1 FROM Types WHERE Type_Name = 'List Item Level 7');
GO

-- languages table
CREATE TABLE [dbo].[Languages] (
    [Language_ID] INT IDENTITY(1,1) NOT NULL,
    [Language_Name] NVARCHAR(255) NOT NULL,
    [Language_Abbreviation] NVARCHAR(3) NOT NULL,
    [Foreign_Name] NVARCHAR(255) NULL,
    [Text_Direction] NVARCHAR(3) NOT NULL DEFAULT 'LTR',
    [Locale_Code] NVARCHAR(10) NULL,
    [Translation_Priority] TINYINT NOT NULL DEFAULT 255,
	[Create_MP3] BIT NOT NULL DEFAULT 0,
    [Active] BIT NOT NULL DEFAULT 0,
	[Created_Date] DATETIME NOT NULL DEFAULT SYSUTCDATETIME(),
    [Last_Modified] DATETIME NULL,
    CONSTRAINT PK_Languages__Language_ID PRIMARY KEY CLUSTERED ([Language_ID] ASC)
);
GO

INSERT INTO [dbo].[Languages]
           ([Language_Name]
           ,[Language_Abbreviation]
           ,[Foreign_Name]
           ,[Translation_Priority]
           ,[Create_MP3]
           ,[Active])
     VALUES
           ('English',
		   'en',
		   'English',
		   1,
		   1,
		   1)
GO

CREATE TABLE [dbo].[Articles_Paragraphs] (
    [Paragraph_ID] INT IDENTITY(1,1) NOT NULL,
    [Translation_ID] INT NOT NULL,
    [Paragraph_Number] INT NOT NULL,
	[Content_Type_ID] INT NOT NULL DEFAULT 1,
    [Paragraph_Raw] NVARCHAR(MAX) NULL,
	[Paragraph_Clean] NVARCHAR(MAX) NULL,
    [Paragraph_Text] NVARCHAR(MAX) NULL,
	[Active] BIT NOT NULL DEFAULT 1,
    [Created_Date] DATETIME NOT NULL DEFAULT SYSUTCDATETIME(),
    [Last_Modified] DATETIME NULL,
    CONSTRAINT PK_Articles_Paragraphs__Paragraph_ID PRIMARY KEY CLUSTERED ([Paragraph_ID] ASC)
);
GO

CREATE TABLE [dbo].[Articles_Paragraphs_Translated] (
    [Paragraph_Translation_ID] INT IDENTITY(1,1) NOT NULL,
    [Paragraph_ID] INT NOT NULL,
    [Language_ID] INT NOT NULL,
	[Content_Type_ID] INT NOT NULL DEFAULT 1,
    [Paragraph_Translation] NVARCHAR(MAX) NULL,
	[Paragraph_Translation_Text_Only] NVARCHAR(MAX) NULL,
	[Translation_Quality] TINYINT NULL,
	[Translation_Quality_Feedback] NVARCHAR(MAX) NULL,
	[Active] BIT NOT NULL DEFAULT 1,
    [Created_Date] DATETIME NOT NULL DEFAULT SYSUTCDATETIME(),
    [Last_Modified] DATETIME NULL,
    CONSTRAINT PK_Articles_Paragraphs_Translated__Paragraph_Translation_ID PRIMARY KEY CLUSTERED ([Paragraph_Translation_ID] ASC)
);
GO

CREATE TABLE [dbo].[Articles_Paragraphs_Translated_Errors] (
    [Articles_Paragraphs_Translated_Errors_ID] INT IDENTITY(1,1) NOT NULL,
    [Paragraph_Translation_ID] INT NOT NULL,
	[Translation_Error_ID] INT NOT NULL,
    CONSTRAINT PK_Articles_Paragraphs_Translated_Errors__Articles_Paragraphs_Translated_Errors_ID PRIMARY KEY CLUSTERED ([Articles_Paragraphs_Translated_Errors_ID] ASC)
);
GO

CREATE TABLE dbo.Articles_Translations (
    Translation_ID              INT IDENTITY(1,1) PRIMARY KEY,
    Content_ID                  INT NOT NULL,
    Language_ID                 INT NOT NULL,
    Translated_Title            NVARCHAR(500) NULL,
    Paragraph_Count             INT NULL,
    Separator_Paragraph_Number  INT NULL,
    File_ID                     INT NULL,
    Created_Date                DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    Last_Modified               DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT FK_Articles_Translations_Content
        FOREIGN KEY (Content_ID) REFERENCES dbo.Articles_Contents(Content_ID),

    CONSTRAINT FK_Articles_Translations_Language
        FOREIGN KEY (Language_ID) REFERENCES dbo.Languages(Language_ID),

    CONSTRAINT FK_Articles_Translations_File
        FOREIGN KEY (File_ID) REFERENCES dbo.File_Store(File_ID)
);
GO

--
-- This table connects the Articles_Translations table with the Translation Error table because the Translated_Title is a translated element so therefore needs the same process as a paragraph
--
CREATE TABLE [dbo].[Articles_Translations_Errors] (
    [Articles_Translations_Errors_ID] INT IDENTITY(1,1) NOT NULL,
	[Translation_ID] INT NOT NULL,
	[Translation_Error_ID] INT NOT NULL,
    CONSTRAINT PK_Articles_Translations_Errors__Articles_Translations_Errors_ID PRIMARY KEY CLUSTERED ([Articles_Translations_Errors_ID] ASC)
);
GO

--
-- A Translation Error is not necessary an error, but the result from the paragraph translation process.  Therefore, a translation error could be just a successful translation.
--
CREATE TABLE [dbo].[Translation_Error] (
    [Translation_Error_ID] INT IDENTITY(1,1) NOT NULL,
    [Language_ID] INT NOT NULL,
    [Error_Type_ID] INT NOT NULL DEFAULT 1,
	[Service_Type_ID] INT NOT NULL DEFAULT 1,
	[Service_Model_ID] INT NOT NULL DEFAULT 1,
	[Translation_Error_Code] NVARCHAR(100) NULL,
	[Translation_Error_Text] NVARCHAR(MAX) NULL,
	[Retry_Attempts] TINYINT NOT NULL DEFAULT 0,
	[Active] BIT NOT NULL DEFAULT 1,
    [Created_Date] DATETIME NOT NULL DEFAULT SYSUTCDATETIME(),
    [Last_Modified] DATETIME NULL,
    CONSTRAINT PK_Translation_Error__Translation_Error_ID PRIMARY KEY CLUSTERED ([Translation_Error_ID] ASC)
);
GO

CREATE TABLE [dbo].[Translation_Cache] (
    [Translation_Cache_ID] INT IDENTITY(1,1) NOT NULL,
    [Paragraph_Hash] CHAR(32) NOT NULL, -- MD5 produces 128-bit hashes = 16 bytes = 32 hex characters
    [Language_ID] INT NOT NULL,
    [Content_Type_ID] INT NOT NULL DEFAULT 1,
    [Paragraph_Translation] NVARCHAR(MAX) NOT NULL,
    [Paragraph_Translation_Text_Only] NVARCHAR(MAX) NULL,
    [Translation_Quality] TINYINT NULL,
    [Translation_Quality_Feedback] NVARCHAR(MAX) NULL,
    [Engine_ID] INT NOT NULL DEFAULT 1,
    [Model_ID] INT NOT NULL DEFAULT 1,
    [Created_Date] DATETIME NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Translation_Cache__Translation_Cache_ID PRIMARY KEY CLUSTERED ([Translation_Cache_ID] ASC)
);
GO

CREATE TABLE Paragraph_Cleaning_Rules (
    Rule_ID INT IDENTITY(1,1) PRIMARY KEY,
    Rule_Name NVARCHAR(100) NOT NULL,
    Match_Type NVARCHAR(50) NOT NULL,        -- 'Contains' or 'Regex'
    Match_Value NVARCHAR(MAX) NOT NULL,
    Clean_Output NVARCHAR(MAX) NULL,       
    Text_Output NVARCHAR(MAX) NULL,        
    Content_Type_Name NVARCHAR(100) NULL,
    Transform_Type NVARCHAR(50) NULL,
    Active BIT NOT NULL DEFAULT 1,
    Priority INT NOT NULL DEFAULT 100,
    Allow_Chain BIT NOT NULL DEFAULT 0,
    Log_Only BIT NOT NULL DEFAULT 0
);
GO

INSERT INTO Paragraph_Cleaning_Rules (
    Rule_Name, Match_Type, Match_Value,
    Clean_Output, Text_Output, Content_Type_Name,
    Transform_Type, Active, Priority, Allow_Chain, Log_Only
)
VALUES
('Audio Download Link',         'Regex',    '<a[^>]+href\s*=\s*[''"][^''"]+\.mp3[''"]',              NULL, NULL, 'Header Audio',           NULL,         1, 100, 0, 0),
('Spacing Break',               'Regex',    '<p[^>]*>(&nbsp;|\\s)*</p>',                             NULL, NULL, 'Break',                  NULL,         1, 100, 0, 0),
('Indented Quotation (40px)',   'Regex',    'padding-left:\s*40px',                                   NULL, NULL, 'Indented Quotation',     'strippatag', 1, 100, 0, 0),
('Key Takeaways (H6)',          'Regex',    '^<h6>Key Takeaways</h6>$',                                'Key Takeaways', 'Key Takeaways', 'Key Takeaways', NULL, 1, 5, 0, 0),
('General H6 Title',            'Regex',    '<h6>.*?</h6>',                                            NULL, NULL, 'Title',                 'strippatag', 1, 99, 0, 0),
('Decode All HTML Entities',    'Regex',    '&#[0-9]+;',                                               NULL, NULL, NULL,                   'decodehtml', 1, 20, 1, 0),
('Sub Title (H6)',              'Regex',    '<h6>.*?</h6>',                                            NULL, NULL, 'Sub Title',             'strippatag', 1, 100, 0, 0),
('Default Paragraph – Promote to Content', 'Regex', '^<p.*?>.*?</p>$',                                 NULL, NULL, 'Content',               'strippatag', 1, 600, 0, 0),
('Strip LI Tags – For List Levels', 'Regex', '^<li>.*?</li>$',                                         NULL, NULL, NULL,                   'strippatag', 1, 300, 0, 0);
GO

CREATE TABLE Articles_Paragraphs_Clean_Log (
    Log_ID INT IDENTITY(1,1) PRIMARY KEY,
    Paragraph_ID INT NOT NULL,
    Rule_Name NVARCHAR(100) NOT NULL,
    Applied_At DATETIME NOT NULL DEFAULT SYSUTCDATETIME(),
    Raw_Snapshot NVARCHAR(MAX),
    Cleaned_Snapshot NVARCHAR(MAX),
    Text_Snapshot NVARCHAR(MAX),
    Notes NVARCHAR(MAX)
);
GO

CREATE TABLE [dbo].[Paragraph_Audio](
	[Audio_ID] [int] IDENTITY(1,1) NOT NULL,
	[Paragraph_ID] [int] NULL,
	[Paragraph_Translation_ID] [int] NULL,
	[Voice_ID] [int] NULL,
	[File_Name] [nvarchar](255) NULL,
	[File_Data] [varbinary](max) NULL,
	[Verified] [bit] NOT NULL DEFAULT 0,
	[Verified_Date] DATETIME2 NULL,
	[Verified_By] NVARCHAR(100) NULL,
	[Created_Date] DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(), 
PRIMARY KEY CLUSTERED 
(
	[Audio_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

-- =============================
-- RELATIONSHIPS
-- =============================

ALTER TABLE Paragraph_Audio
ADD CONSTRAINT FK_ParagraphAudio_Paragraph
    FOREIGN KEY (Paragraph_ID) REFERENCES Articles_Paragraphs(Paragraph_ID);
GO

ALTER TABLE Paragraph_Audio
ADD CONSTRAINT FK_ParagraphAudio_Translation
    FOREIGN KEY (Paragraph_Translation_ID) REFERENCES Articles_Paragraphs_Translated(Paragraph_Translation_ID);
GO

ALTER TABLE Paragraph_Audio
ADD CONSTRAINT CK_ParagraphAudio_OnlyOneFK
CHECK (
	(Paragraph_ID IS NOT NULL AND Paragraph_Translation_ID IS NULL)
	OR (Paragraph_ID IS NULL AND Paragraph_Translation_ID IS NOT NULL)
);
GO

CREATE INDEX IX_ParagraphAudio_Paragraph_ID
	ON Paragraph_Audio (Paragraph_ID)
	WHERE Paragraph_ID IS NOT NULL;
GO

CREATE INDEX IX_ParagraphAudio_Translation_ID
	ON Paragraph_Audio (Paragraph_Translation_ID)
	WHERE Paragraph_Translation_ID IS NOT NULL;
GO

ALTER TABLE [dbo].[Translation_Cache]
	ADD CONSTRAINT FK_Translation_Cache__Language_ID FOREIGN KEY ([Language_ID])
	REFERENCES [dbo].[Languages] ([Language_ID]);
GO

ALTER TABLE [dbo].[Translation_Cache]
	ADD CONSTRAINT FK_Translation_Cache__Content_Type_ID FOREIGN KEY ([Content_Type_ID])
	REFERENCES [dbo].[Types] ([Type_ID]);
GO

ALTER TABLE [dbo].[Translation_Cache]
ADD CONSTRAINT FK_Translation_Cache__Engine_ID FOREIGN KEY ([Engine_ID])
REFERENCES [dbo].[Types] ([Type_ID]);
GO

ALTER TABLE [dbo].[Translation_Cache]
ADD CONSTRAINT FK_Translation_Cache__Model_ID FOREIGN KEY ([Model_ID])
REFERENCES [dbo].[Types] ([Type_ID]);
GO

ALTER TABLE [dbo].[Articles_Translations_Errors]
ADD CONSTRAINT FK_Articles_Translations_Errors__Translation_ID FOREIGN KEY ([Translation_ID])
REFERENCES [dbo].[Articles_Translations] ([Translation_ID]);
GO

ALTER TABLE [dbo].[Articles_Translations_Errors]
ADD CONSTRAINT FK_Articles_Translations_Errors__Translation_Error_ID FOREIGN KEY ([Translation_Error_ID])
REFERENCES [dbo].[Translation_Error] ([Translation_Error_ID]);
GO

ALTER TABLE [dbo].[Articles_Paragraphs_Translated_Errors]
ADD CONSTRAINT FK_Articles_Paragraphs_Translated_Errors__Paragraph_Translation_ID FOREIGN KEY ([Paragraph_Translation_ID])
REFERENCES [dbo].[Articles_Paragraphs_Translated] ([Paragraph_Translation_ID]);
GO

ALTER TABLE [dbo].[Articles_Paragraphs_Translated_Errors]
ADD CONSTRAINT FK_Articles_Paragraphs_Translated_Errors__Translation_Error_ID FOREIGN KEY ([Translation_Error_ID])
REFERENCES [dbo].[Translation_Error] ([Translation_Error_ID]);
GO

ALTER TABLE [dbo].[Translation_Error]
ADD CONSTRAINT FK_Translation_Error__Language_ID FOREIGN KEY ([Language_ID])
REFERENCES [dbo].[Languages] ([Language_ID]);
GO

ALTER TABLE [dbo].[Translation_Error]
ADD CONSTRAINT FK_Translation_Error__Error_Type_ID FOREIGN KEY ([Error_Type_ID])
REFERENCES [dbo].[Types] ([Type_ID]);
GO

ALTER TABLE [dbo].[Translation_Error]
ADD CONSTRAINT FK_Translation_Error__Service_Type_ID FOREIGN KEY ([Service_Type_ID])
REFERENCES [dbo].[Types] ([Type_ID]);
GO

ALTER TABLE [dbo].[Translation_Error]
ADD CONSTRAINT FK_Translation_Error__Service_Model_ID FOREIGN KEY ([Service_Model_ID])
REFERENCES [dbo].[Types] ([Type_ID]);
GO

ALTER TABLE [dbo].[Articles_Contents]
ADD CONSTRAINT FK_Articles_Contents__Content_Type_ID FOREIGN KEY ([Content_Type_ID])
REFERENCES [dbo].[Types] ([Type_ID]);
GO

ALTER TABLE [dbo].[Articles_Contents]
ADD CONSTRAINT FK_Articles_Contents__Article_ID FOREIGN KEY ([Article_ID])
REFERENCES [dbo].[Articles] ([Article_ID]);
GO

ALTER TABLE [dbo].[Articles_Paragraphs]
ADD CONSTRAINT FK_Articles_Paragraphs__Translation_ID FOREIGN KEY ([Translation_ID])
REFERENCES [dbo].[Articles_Translations] ([Translation_ID]);
GO

ALTER TABLE [dbo].[Articles_Paragraphs]
ADD CONSTRAINT FK_Articles_Paragraphs__Content_Type_ID FOREIGN KEY ([Content_Type_ID])
REFERENCES [dbo].[Types] ([Type_ID]);
GO

ALTER TABLE [dbo].[Articles_Paragraphs_Translated]
ADD CONSTRAINT FK_Articles_Paragraphs_Translated__Paragraph_ID FOREIGN KEY ([Paragraph_ID])
REFERENCES [dbo].[Articles_Paragraphs] ([Paragraph_ID]);
GO

ALTER TABLE [dbo].[Articles_Paragraphs_Translated]
ADD CONSTRAINT FK_Articles_Paragraphs_Translated__Language_ID FOREIGN KEY ([Language_ID])
REFERENCES [dbo].[Languages] ([Language_ID]);
GO

ALTER TABLE [dbo].[Articles_Paragraphs_Translated]
ADD CONSTRAINT FK_Articles_Paragraphs_Translated__Content_Type_ID FOREIGN KEY ([Content_Type_ID])
REFERENCES [dbo].[Types] ([Type_ID]);
GO

-- =============================
-- TRIGGERS
-- =============================

CREATE TRIGGER trg_Translation_Error_LastModified ON [dbo].[Translation_Error]
AFTER UPDATE AS
BEGIN
    SET NOCOUNT ON;
    UPDATE t SET Last_Modified = SYSUTCDATETIME()
    FROM [dbo].[Translation_Error] t
    INNER JOIN inserted i ON t.Translation_Error_ID = i.Translation_Error_ID;
END;
GO

CREATE TRIGGER trg_Articles_LastModified ON [dbo].[Articles]
AFTER UPDATE AS
BEGIN
    SET NOCOUNT ON;
    UPDATE a SET Last_Modified = SYSUTCDATETIME()
    FROM [dbo].[Articles] a
    INNER JOIN inserted i ON a.Article_ID = i.Article_ID;
END;
GO

CREATE TRIGGER trg_Languages_LastModified ON [dbo].[Languages]
AFTER UPDATE AS
BEGIN
    SET NOCOUNT ON;
    UPDATE l SET Last_Modified = SYSUTCDATETIME()
    FROM [dbo].[Languages] l
    INNER JOIN inserted i ON l.Language_ID = i.Language_ID;
END;
GO

CREATE TRIGGER trg_ArticlesParagraphs_LastModified ON [dbo].[Articles_Paragraphs]
AFTER UPDATE AS
BEGIN
    SET NOCOUNT ON;
    UPDATE p SET Last_Modified = SYSUTCDATETIME()
    FROM [dbo].[Articles_Paragraphs] p
    INNER JOIN inserted i ON p.Paragraph_ID = i.Paragraph_ID;
END;
GO

CREATE TRIGGER trg_ArticlesParagraphsTranslated_LastModified ON [dbo].[Articles_Paragraphs_Translated]
AFTER UPDATE AS
BEGIN
    SET NOCOUNT ON;
    UPDATE pt SET Last_Modified = SYSUTCDATETIME()
    FROM [dbo].[Articles_Paragraphs_Translated] pt
    INNER JOIN inserted i ON pt.Paragraph_Translation_ID = i.Paragraph_Translation_ID;
END;
GO

CREATE TRIGGER trg_ArticlesTranslations_LastModified ON [dbo].[Articles_Translations]
AFTER UPDATE AS
BEGIN
    SET NOCOUNT ON;
    UPDATE t SET Last_Modified = SYSUTCDATETIME()
    FROM [dbo].[Articles_Translations] t
    INNER JOIN inserted i ON t.Translation_ID = i.Translation_ID;
END;
GO

CREATE TRIGGER trg_Types_LastModified ON [dbo].[Types]
AFTER UPDATE AS
BEGIN
    SET NOCOUNT ON;
    UPDATE t SET Last_Modified = SYSUTCDATETIME()
    FROM [dbo].[Types] t
    INNER JOIN inserted i ON t.[Type_ID] = i.[Type_ID];
END;
GO

CREATE TRIGGER trg_Articles_Contents_LastModified ON [dbo].[Articles_Contents]
AFTER UPDATE AS
BEGIN
    SET NOCOUNT ON;
    UPDATE t SET Last_Modified = SYSUTCDATETIME()
    FROM [dbo].[Articles_Contents] t
    INNER JOIN inserted i ON t.Content_ID = i.Content_ID;
END;
GO

-- =============================
-- Initial Data Import
-- =============================

-- Import Articles from LTDB into FFA.dbo.Articles
INSERT INTO dbo.Articles (
    Article_Name,
    Article_File_Name,
    Article_Date,
    Article_Image_Location,
    Article_Audio_Link,
    Article_Found,
    Last_Modified,
    Article_URL
)
SELECT
    Article_Name,
    Article_File_Name,
    Article_Date,
    Article_Image_Location,
    Article_Audio_Link,
    Article_Found,
    LastModified,
    Article_URL
FROM LTDB.dbo.Articles;
GO

-- Import Languages from LTDB into FFA.dbo.Languages
INSERT INTO dbo.Languages (
	Language_Name,
	Language_Abbreviation,
	Foreign_Name,
	Active
)
SELECT
	Language_Name,
	Language_Abbreviation,
	Foreign_Name,
	Active
FROM LTDB.dbo.Languages
ORDER BY Language_Name;
GO

CREATE VIEW view_Articles_Paragraphs_char_overview AS
WITH EntityMap AS (
    SELECT Html_Entity, CharValue, PlainChar FROM (
        SELECT '&#8220;' AS Html_Entity, NCHAR(8220) AS CharValue, '"' AS PlainChar UNION ALL
        SELECT '&#8221;', NCHAR(8221), '"' UNION ALL
        SELECT '&#8217;', NCHAR(8217), '''' UNION ALL
        SELECT '&#8230;', NCHAR(8230), '...' UNION ALL
        SELECT '&#8211;', NCHAR(8211), '-' UNION ALL
        SELECT '&#8216;', NCHAR(8216), '''' UNION ALL
        SELECT '&#8212;', NCHAR(8212), '-'
    ) AS x
),
Matches AS (
    SELECT Paragraph_ID,
           value AS RawToken
    FROM Articles_Paragraphs
    CROSS APPLY STRING_SPLIT(Paragraph_Raw, ' ')
    WHERE value LIKE '%&#[0-9]%'
),
Entities AS (
    SELECT
        SUBSTRING(RawToken, CHARINDEX('&#', RawToken), 
            CHARINDEX(';', RawToken + ';', CHARINDEX('&#', RawToken)) - CHARINDEX('&#', RawToken) + 1) AS Html_Entity
    FROM Matches
    WHERE CHARINDEX('&#', RawToken) > 0
),
HexCounted AS (
    SELECT Html_Entity, COUNT(*) AS HexCount
    FROM Entities
    GROUP BY Html_Entity
),
CharCounted AS (
    SELECT e.Html_Entity, SUM(LEN(p.Paragraph_Raw) - LEN(REPLACE(p.Paragraph_Raw, e.CharValue, ''))) AS CharCount
    FROM EntityMap e
    CROSS JOIN Articles_Paragraphs p
    GROUP BY e.Html_Entity
),
PlainCharCounted AS (
    SELECT e.Html_Entity, SUM(LEN(p.Paragraph_Raw) - LEN(REPLACE(p.Paragraph_Raw, e.PlainChar, ''))) AS PlainCharCount
    FROM EntityMap e
    CROSS JOIN Articles_Paragraphs p
    GROUP BY e.Html_Entity
)
SELECT 
    m.Html_Entity,
    ISNULL(h.HexCount, 0) AS HexCount,
    ISNULL(c.CharCount, 0) AS CharCount,
    ISNULL(p.PlainCharCount, 0) AS PlainCharCount
FROM EntityMap m
LEFT JOIN HexCounted h ON m.Html_Entity = h.Html_Entity
LEFT JOIN CharCounted c ON m.Html_Entity = c.Html_Entity
LEFT JOIN PlainCharCounted p ON m.Html_Entity = p.Html_Entity
GO

UPDATE Languages SET Text_Direction = 'RTL' WHERE Language_Name = 'Arabic';
UPDATE Languages SET Text_Direction = 'RTL' WHERE Language_Name = 'Hebrew';
UPDATE Languages SET Text_Direction = 'RTL' WHERE Language_Name = 'Pashto';
UPDATE Languages SET Text_Direction = 'RTL' WHERE Language_Name = 'Persian';
UPDATE Languages SET Text_Direction = 'RTL' WHERE Language_Name = 'Sindhi';
UPDATE Languages SET Text_Direction = 'RTL' WHERE Language_Name = 'Urdu';
UPDATE Languages SET Text_Direction = 'RTL' WHERE Language_Name = 'Uyghur';
GO

UPDATE Languages SET Locale_Code = 'en-US' WHERE Language_Name = 'English';
UPDATE Languages SET Locale_Code = 'af-ZA' WHERE Language_Name = 'Afrikaans';
UPDATE Languages SET Locale_Code = 'sq-AL' WHERE Language_Name = 'Albanian';
UPDATE Languages SET Locale_Code = 'am-ET' WHERE Language_Name = 'Amharic';
UPDATE Languages SET Locale_Code = 'ar-SA' WHERE Language_Name = 'Arabic';
UPDATE Languages SET Locale_Code = 'hy-AM' WHERE Language_Name = 'Armenian';
UPDATE Languages SET Locale_Code = 'az-AZ' WHERE Language_Name = 'Azerbaijani';
UPDATE Languages SET Locale_Code = 'eu-ES' WHERE Language_Name = 'Basque';
UPDATE Languages SET Locale_Code = 'be-BY' WHERE Language_Name = 'Belarusian';
UPDATE Languages SET Locale_Code = 'bn-IN' WHERE Language_Name = 'Bengali';
UPDATE Languages SET Locale_Code = 'bs-BA' WHERE Language_Name = 'Bosnian';
UPDATE Languages SET Locale_Code = 'bg-BG' WHERE Language_Name = 'Bulgarian';
UPDATE Languages SET Locale_Code = 'my-MM' WHERE Language_Name = 'Burmese';
UPDATE Languages SET Locale_Code = 'ca-ES' WHERE Language_Name = 'Catalan';
UPDATE Languages SET Locale_Code = 'kw-GB' WHERE Language_Name = 'Cornish';
UPDATE Languages SET Locale_Code = 'hr-HR' WHERE Language_Name = 'Croatian';
UPDATE Languages SET Locale_Code = 'cs-CZ' WHERE Language_Name = 'Czech';
UPDATE Languages SET Locale_Code = 'da-DK' WHERE Language_Name = 'Danish';
UPDATE Languages SET Locale_Code = 'nl-NL' WHERE Language_Name = 'Dutch';
UPDATE Languages SET Locale_Code = 'et-EE' WHERE Language_Name = 'Estonian';
UPDATE Languages SET Locale_Code = 'fo-FO' WHERE Language_Name = 'Faroese';
UPDATE Languages SET Locale_Code = 'fj-FJ' WHERE Language_Name = 'Fijian';
UPDATE Languages SET Locale_Code = 'fi-FI' WHERE Language_Name = 'Finnish';
UPDATE Languages SET Locale_Code = 'fr-FR' WHERE Language_Name = 'French';
UPDATE Languages SET Locale_Code = 'gl-ES' WHERE Language_Name = 'Galician';
UPDATE Languages SET Locale_Code = 'ka-GE' WHERE Language_Name = 'Georgian';
UPDATE Languages SET Locale_Code = 'de-DE' WHERE Language_Name = 'German';
UPDATE Languages SET Locale_Code = 'el-GR' WHERE Language_Name = 'Greek';
UPDATE Languages SET Locale_Code = 'ha-NG' WHERE Language_Name = 'Hausa';
UPDATE Languages SET Locale_Code = 'he-IL' WHERE Language_Name = 'Hebrew';
UPDATE Languages SET Locale_Code = 'hi-IN' WHERE Language_Name = 'Hindi';
UPDATE Languages SET Locale_Code = 'hu-HU' WHERE Language_Name = 'Hungarian';
UPDATE Languages SET Locale_Code = 'is-IS' WHERE Language_Name = 'Icelandic';
UPDATE Languages SET Locale_Code = 'id-ID' WHERE Language_Name = 'Indonesian';
UPDATE Languages SET Locale_Code = 'iu-CA' WHERE Language_Name = 'Inuktitut';
UPDATE Languages SET Locale_Code = 'ga-IE' WHERE Language_Name = 'Irish Gaelic';
UPDATE Languages SET Locale_Code = 'it-IT' WHERE Language_Name = 'Italian';
UPDATE Languages SET Locale_Code = 'ja-JP' WHERE Language_Name = 'Japanese';
UPDATE Languages SET Locale_Code = 'jv-ID' WHERE Language_Name = 'Javanese';
UPDATE Languages SET Locale_Code = 'kn-IN' WHERE Language_Name = 'Kannada';
UPDATE Languages SET Locale_Code = 'kk-KZ' WHERE Language_Name = 'Kazakh';
UPDATE Languages SET Locale_Code = 'km-KH' WHERE Language_Name = 'Khmer';
UPDATE Languages SET Locale_Code = 'ko-KR' WHERE Language_Name = 'Korean';
UPDATE Languages SET Locale_Code = 'ky-KG' WHERE Language_Name = 'Kyrgyz';
UPDATE Languages SET Locale_Code = 'lo-LA' WHERE Language_Name = 'Lao';
UPDATE Languages SET Locale_Code = 'lv-LV' WHERE Language_Name = 'Latvian';
UPDATE Languages SET Locale_Code = 'lt-LT' WHERE Language_Name = 'Lithuanian';
UPDATE Languages SET Locale_Code = 'lb-LU' WHERE Language_Name = 'Luxembourgish';
UPDATE Languages SET Locale_Code = 'mk-MK' WHERE Language_Name = 'Macedonian';
UPDATE Languages SET Locale_Code = 'mg-MG' WHERE Language_Name = 'Malagasy';
UPDATE Languages SET Locale_Code = 'ms-MY' WHERE Language_Name = 'Malay';
UPDATE Languages SET Locale_Code = 'mt-MT' WHERE Language_Name = 'Maltese';
UPDATE Languages SET Locale_Code = 'zh-CN' WHERE Language_Name = 'Mandarin Chinese';
UPDATE Languages SET Locale_Code = 'mi-NZ' WHERE Language_Name = 'Maori';
UPDATE Languages SET Locale_Code = 'mr-IN' WHERE Language_Name = 'Marathi';
UPDATE Languages SET Locale_Code = 'mn-MN' WHERE Language_Name = 'Mongolian';
UPDATE Languages SET Locale_Code = 'ne-NP' WHERE Language_Name = 'Nepali';
UPDATE Languages SET Locale_Code = 'no-NO' WHERE Language_Name = 'Norwegian';
UPDATE Languages SET Locale_Code = 'or-IN' WHERE Language_Name = 'Odia (Oriya)';
UPDATE Languages SET Locale_Code = 'ps-AF' WHERE Language_Name = 'Pashto';
UPDATE Languages SET Locale_Code = 'fa-IR' WHERE Language_Name = 'Persian';
UPDATE Languages SET Locale_Code = 'pl-PL' WHERE Language_Name = 'Polish';
UPDATE Languages SET Locale_Code = 'pt-PT' WHERE Language_Name = 'Portuguese';
UPDATE Languages SET Locale_Code = 'qu-PE' WHERE Language_Name = 'Quechua';
UPDATE Languages SET Locale_Code = 'ro-RO' WHERE Language_Name = 'Romanian';
UPDATE Languages SET Locale_Code = 'ru-RU' WHERE Language_Name = 'Russian';
UPDATE Languages SET Locale_Code = 'sa-IN' WHERE Language_Name = 'Sanskrit';
UPDATE Languages SET Locale_Code = 'gd-GB' WHERE Language_Name = 'Scottish Gaelic';
UPDATE Languages SET Locale_Code = 'sr-RS' WHERE Language_Name = 'Serbian';
UPDATE Languages SET Locale_Code = 'st-ZA' WHERE Language_Name = 'Sesotho';
UPDATE Languages SET Locale_Code = 'sd-PK' WHERE Language_Name = 'Sindhi';
UPDATE Languages SET Locale_Code = 'sk-SK' WHERE Language_Name = 'Slovak';
UPDATE Languages SET Locale_Code = 'sl-SI' WHERE Language_Name = 'Slovenian';
UPDATE Languages SET Locale_Code = 'so-SO' WHERE Language_Name = 'Somali';
UPDATE Languages SET Locale_Code = 'es-ES' WHERE Language_Name = 'Spanish';
UPDATE Languages SET Locale_Code = 'sw-KE' WHERE Language_Name = 'Swahili';
UPDATE Languages SET Locale_Code = 'sv-SE' WHERE Language_Name = 'Swedish';
UPDATE Languages SET Locale_Code = 'tl-PH' WHERE Language_Name = 'Tagalog';
UPDATE Languages SET Locale_Code = 'tg-TJ' WHERE Language_Name = 'Tajik';
UPDATE Languages SET Locale_Code = 'ta-IN' WHERE Language_Name = 'Tamil';
UPDATE Languages SET Locale_Code = 'tt-RU' WHERE Language_Name = 'Tatar';
UPDATE Languages SET Locale_Code = 'te-IN' WHERE Language_Name = 'Telugu';
UPDATE Languages SET Locale_Code = 'th-TH' WHERE Language_Name = 'Thai';
UPDATE Languages SET Locale_Code = 'tn-BW' WHERE Language_Name = 'Tswana';
UPDATE Languages SET Locale_Code = 'tr-TR' WHERE Language_Name = 'Turkish';
UPDATE Languages SET Locale_Code = 'uk-UA' WHERE Language_Name = 'Ukrainian';
UPDATE Languages SET Locale_Code = 'ur-PK' WHERE Language_Name = 'Urdu';
UPDATE Languages SET Locale_Code = 'ug-CN' WHERE Language_Name = 'Uyghur';
UPDATE Languages SET Locale_Code = 'uz-UZ' WHERE Language_Name = 'Uzbek';
UPDATE Languages SET Locale_Code = 'vi-VN' WHERE Language_Name = 'Vietnamese';
UPDATE Languages SET Locale_Code = 'cy-GB' WHERE Language_Name = 'Welsh';
UPDATE Languages SET Locale_Code = 'wuu-CN' WHERE Language_Name = 'Wu Chinese';
UPDATE Languages SET Locale_Code = 'xh-ZA' WHERE Language_Name = 'Xhosa';
UPDATE Languages SET Locale_Code = 'yo-NG' WHERE Language_Name = 'Yoruba';
UPDATE Languages SET Locale_Code = 'zu-ZA' WHERE Language_Name = 'Zulu';
GO

CREATE TRIGGER trg_Voices_LastModified ON dbo.Voices
AFTER UPDATE AS
BEGIN
    SET NOCOUNT ON;
    UPDATE v SET Last_Modified = SYSUTCDATETIME()
    FROM dbo.Voices v
    INNER JOIN inserted i ON v.Voice_ID = i.Voice_ID;
END;
GO

CREATE UNIQUE INDEX IX_Voices_Voice_Name ON dbo.Voices (Voice_Name);
GO

CREATE VIEW vw_Paragraph_Audio_Expanded AS
SELECT 
    pa.Audio_ID,
    pa.Paragraph_ID,
    pa.Paragraph_Translation_ID,
    v.Voice_Name,
    v.Engine_Name,
    v.Model_Name,
    pa.File_Name,
    pa.Verified,
    pa.Verified_Date,
    pa.Verified_By,
    pa.Created_Date
FROM Paragraph_Audio pa
LEFT JOIN Voices v ON pa.Voice_ID = v.Voice_ID;
GO

-- Remove binary columns
ALTER TABLE Paragraph_Audio
DROP COLUMN File_Data;
GO

ALTER TABLE Paragraph_Audio
DROP COLUMN File_Name;
GO

-- Add FK to File_Store
ALTER TABLE Paragraph_Audio
ADD File_ID INT NULL;
GO

ALTER TABLE Paragraph_Audio
ADD CONSTRAINT FK_ParagraphAudio_File_ID
FOREIGN KEY (File_ID) REFERENCES File_Store(File_ID);
GO

CREATE VIEW vw_Paragraph_Audio_With_File AS
SELECT
    pa.Audio_ID,
    pa.Paragraph_ID,
    pa.Paragraph_Translation_ID,
    pa.Voice_ID,
    v.Voice_Name,
    fs.File_Name,
    fs.File_Format,
    fs.File_Size_Bytes,
    pa.Verified,
    pa.Verified_Date,
    pa.Verified_By
FROM Paragraph_Audio pa
LEFT JOIN Voices v ON pa.Voice_ID = v.Voice_ID
LEFT JOIN File_Store fs ON pa.File_ID = fs.File_ID;
GO







-- OpenAI Voices
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'alloy', N'OpenAI', N'gpt-4', N'Versatile male voice for general narration', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'echo', N'OpenAI', N'gpt-4', N'Clear male voice for summaries and info delivery', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'fable', N'OpenAI', N'gpt-4', N'Storytelling voice with a warm tone', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'onyx', N'OpenAI', N'gpt-4', N'Deep male voice, great for serious tone', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'nova', N'OpenAI', N'gpt-4', N'Energetic female voice with high clarity', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'shimmer', N'OpenAI', N'gpt-4', N'Crisp female voice ideal for quotes or dialogue', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
GO
-- Azure voices
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'af-ZA-AdriNeural', N'Azure', N'Neural', N'Female voice for Afrikaans (South Africa)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'af-ZA-WillemNeural', N'Azure', N'Neural', N'Male voice for Afrikaans (South Africa)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'am-ET-MekdesNeural', N'Azure', N'Neural', N'Female voice for Amharic (Ethiopia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'am-ET-AmehaNeural', N'Azure', N'Neural', N'Male voice for Amharic (Ethiopia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ar-AE-FatimaNeural', N'Azure', N'Neural', N'Female voice for Arabic (United Arab Emirates)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ar-AE-HamdanNeural', N'Azure', N'Neural', N'Male voice for Arabic (United Arab Emirates)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ar-BH-LailaNeural', N'Azure', N'Neural', N'Female voice for Arabic (Bahrain)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ar-BH-AliNeural', N'Azure', N'Neural', N'Male voice for Arabic (Bahrain)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ar-DZ-AminaNeural', N'Azure', N'Neural', N'Female voice for Arabic (Algeria)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ar-DZ-IsmaelNeural', N'Azure', N'Neural', N'Male voice for Arabic (Algeria)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ar-EG-SalmaNeural', N'Azure', N'Neural', N'Female voice for Arabic (Egypt)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ar-EG-ShakirNeural', N'Azure', N'Neural', N'Male voice for Arabic (Egypt)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ar-IQ-RanaNeural', N'Azure', N'Neural', N'Female voice for Arabic (Iraq)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ar-IQ-BasselNeural', N'Azure', N'Neural', N'Male voice for Arabic (Iraq)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ar-JO-SanaNeural', N'Azure', N'Neural', N'Female voice for Arabic (Jordan)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ar-JO-TaimNeural', N'Azure', N'Neural', N'Male voice for Arabic (Jordan)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ar-KW-NouraNeural', N'Azure', N'Neural', N'Female voice for Arabic (Kuwait)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ar-KW-FahedNeural', N'Azure', N'Neural', N'Male voice for Arabic (Kuwait)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ar-LB-LaylaNeural', N'Azure', N'Neural', N'Female voice for Arabic (Lebanon)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ar-LB-RamiNeural', N'Azure', N'Neural', N'Male voice for Arabic (Lebanon)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ar-LY-ImanNeural', N'Azure', N'Neural', N'Female voice for Arabic (Libya)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ar-LY-OmarNeural', N'Azure', N'Neural', N'Male voice for Arabic (Libya)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ar-MA-MounaNeural', N'Azure', N'Neural', N'Female voice for Arabic (Morocco)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ar-MA-JamalNeural', N'Azure', N'Neural', N'Male voice for Arabic (Morocco)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ar-OM-AyshaNeural', N'Azure', N'Neural', N'Female voice for Arabic (Oman)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ar-OM-AbdullahNeural', N'Azure', N'Neural', N'Male voice for Arabic (Oman)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ar-QA-AmalNeural', N'Azure', N'Neural', N'Female voice for Arabic (Qatar)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ar-QA-MoazNeural', N'Azure', N'Neural', N'Male voice for Arabic (Qatar)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ar-SA-ZariyahNeural', N'Azure', N'Neural', N'Female voice for Arabic (Saudi Arabia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ar-SA-HamedNeural', N'Azure', N'Neural', N'Male voice for Arabic (Saudi Arabia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ar-SY-AmanyNeural', N'Azure', N'Neural', N'Female voice for Arabic (Syria)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ar-SY-LaithNeural', N'Azure', N'Neural', N'Male voice for Arabic (Syria)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ar-TN-ReemNeural', N'Azure', N'Neural', N'Female voice for Arabic (Tunisia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ar-TN-HediNeural', N'Azure', N'Neural', N'Male voice for Arabic (Tunisia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ar-YE-MaryamNeural', N'Azure', N'Neural', N'Female voice for Arabic (Yemen)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ar-YE-SalehNeural', N'Azure', N'Neural', N'Male voice for Arabic (Yemen)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'as-IN-YashicaNeural', N'Azure', N'Neural', N'Female voice for Assamese (India)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'as-IN-PriyomNeural', N'Azure', N'Neural', N'Male voice for Assamese (India)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'az-AZ-BanuNeural', N'Azure', N'Neural', N'Female voice for Azerbaijani (Latin, Azerbaijan)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'az-AZ-BabekNeural', N'Azure', N'Neural', N'Male voice for Azerbaijani (Latin, Azerbaijan)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'bg-BG-KalinaNeural', N'Azure', N'Neural', N'Female voice for Bulgarian (Bulgaria)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'bg-BG-BorislavNeural', N'Azure', N'Neural', N'Male voice for Bulgarian (Bulgaria)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'bn-BD-NabanitaNeural', N'Azure', N'Neural', N'Female voice for Bangla (Bangladesh)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'bn-BD-PradeepNeural', N'Azure', N'Neural', N'Male voice for Bangla (Bangladesh)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'bn-IN-TanishaaNeural', N'Azure', N'Neural', N'Female voice for Bengali (India)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'bn-IN-BashkarNeural', N'Azure', N'Neural', N'Male voice for Bengali (India)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'bs-BA-VesnaNeural', N'Azure', N'Neural', N'Female voice for Bosnian (Bosnia and Herzegovina)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'bs-BA-GoranNeural', N'Azure', N'Neural', N'Male voice for Bosnian (Bosnia and Herzegovina)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ca-ES-JoanaNeural', N'Azure', N'Neural', N'Female voice for Catalan', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ca-ES-EnricNeural', N'Azure', N'Neural', N'Male voice for Catalan', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ca-ES-AlbaNeural', N'Azure', N'Neural', N'Female voice for Catalan', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'cs-CZ-VlastaNeural', N'Azure', N'Neural', N'Female voice for Czech (Czechia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'cs-CZ-AntoninNeural', N'Azure', N'Neural', N'Male voice for Czech (Czechia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'cy-GB-NiaNeural', N'Azure', N'Neural', N'Female voice for Welsh (United Kingdom)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'cy-GB-AledNeural', N'Azure', N'Neural', N'Male voice for Welsh (United Kingdom)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'da-DK-ChristelNeural', N'Azure', N'Neural', N'Female voice for Danish (Denmark)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'da-DK-JeppeNeural', N'Azure', N'Neural', N'Male voice for Danish (Denmark)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'de-AT-IngridNeural', N'Azure', N'Neural', N'Female voice for German (Austria)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'de-AT-JonasNeural', N'Azure', N'Neural', N'Male voice for German (Austria)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'de-CH-LeniNeural', N'Azure', N'Neural', N'Female voice for German (Switzerland)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'de-CH-JanNeural', N'Azure', N'Neural', N'Male voice for German (Switzerland)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'de-DE-KatjaNeural', N'Azure', N'Neural', N'Female voice for German (Germany)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'de-DE-ConradNeural', N'Azure', N'Neural', N'Male voice for German (Germany)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'de-DE-SeraphinaMultilingualNeural', N'Azure', N'Neural', N'Female voice for German (Germany)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'de-DE-FlorianMultilingualNeural', N'Azure', N'Neural', N'Male voice for German (Germany)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'de-DE-AmalaNeural', N'Azure', N'Neural', N'Female voice for German (Germany)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'de-DE-BerndNeural', N'Azure', N'Neural', N'Male voice for German (Germany)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'de-DE-ChristophNeural', N'Azure', N'Neural', N'Male voice for German (Germany)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'de-DE-ElkeNeural', N'Azure', N'Neural', N'Female voice for German (Germany)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'de-DE-GiselaNeural', N'Azure', N'Neural', N'Female voice for German (Germany)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'de-DE-KasperNeural', N'Azure', N'Neural', N'Male voice for German (Germany)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'de-DE-KillianNeural', N'Azure', N'Neural', N'Male voice for German (Germany)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'de-DE-KlarissaNeural', N'Azure', N'Neural', N'Female voice for German (Germany)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'de-DE-KlausNeural', N'Azure', N'Neural', N'Male voice for German (Germany)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'de-DE-LouisaNeural', N'Azure', N'Neural', N'Female voice for German (Germany)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'de-DE-MajaNeural', N'Azure', N'Neural', N'Female voice for German (Germany)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'de-DE-RalfNeural', N'Azure', N'Neural', N'Male voice for German (Germany)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'de-DE-TanjaNeural', N'Azure', N'Neural', N'Female voice for German (Germany)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'el-GR-AthinaNeural', N'Azure', N'Neural', N'Female voice for Greek (Greece)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'el-GR-NestorasNeural', N'Azure', N'Neural', N'Male voice for Greek (Greece)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-AU-NatashaNeural', N'Azure', N'Neural', N'Female voice for English (Australia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-AU-WilliamNeural', N'Azure', N'Neural', N'Male voice for English (Australia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-AU-AnnetteNeural', N'Azure', N'Neural', N'Female voice for English (Australia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-AU-CarlyNeural', N'Azure', N'Neural', N'Female voice for English (Australia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-AU-DarrenNeural', N'Azure', N'Neural', N'Male voice for English (Australia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-AU-DuncanNeural', N'Azure', N'Neural', N'Male voice for English (Australia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-AU-ElsieNeural', N'Azure', N'Neural', N'Female voice for English (Australia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-AU-FreyaNeural', N'Azure', N'Neural', N'Female voice for English (Australia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-AU-JoanneNeural', N'Azure', N'Neural', N'Female voice for English (Australia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-AU-KenNeural', N'Azure', N'Neural', N'Male voice for English (Australia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-AU-KimNeural', N'Azure', N'Neural', N'Female voice for English (Australia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-AU-NeilNeural', N'Azure', N'Neural', N'Male voice for English (Australia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-AU-TimNeural', N'Azure', N'Neural', N'Male voice for English (Australia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-AU-TinaNeural', N'Azure', N'Neural', N'Female voice for English (Australia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-CA-ClaraNeural', N'Azure', N'Neural', N'Female voice for English (Canada)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-CA-LiamNeural', N'Azure', N'Neural', N'Male voice for English (Canada)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-GB-SoniaNeural', N'Azure', N'Neural', N'Female voice for English (United Kingdom)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-GB-RyanNeural', N'Azure', N'Neural', N'Male voice for English (United Kingdom)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-GB-LibbyNeural', N'Azure', N'Neural', N'Female voice for English (United Kingdom)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-GB-AdaMultilingualNeural', N'Azure', N'Neural', N'Female voice for English (United Kingdom)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-GB-OllieMultilingualNeural', N'Azure', N'Neural', N'Male voice for English (United Kingdom)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-GB-AbbiNeural', N'Azure', N'Neural', N'Female voice for English (United Kingdom)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-GB-AlfieNeural', N'Azure', N'Neural', N'Male voice for English (United Kingdom)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-GB-BellaNeural', N'Azure', N'Neural', N'Female voice for English (United Kingdom)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-GB-ElliotNeural', N'Azure', N'Neural', N'Male voice for English (United Kingdom)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-GB-EthanNeural', N'Azure', N'Neural', N'Male voice for English (United Kingdom)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-GB-HollieNeural', N'Azure', N'Neural', N'Female voice for English (United Kingdom)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-GB-MaisieNeural', N'Azure', N'Neural', N'Female voice for English (United Kingdom)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-GB-NoahNeural', N'Azure', N'Neural', N'Male voice for English (United Kingdom)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-GB-OliverNeural', N'Azure', N'Neural', N'Male voice for English (United Kingdom)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-GB-OliviaNeural', N'Azure', N'Neural', N'Female voice for English (United Kingdom)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-GB-ThomasNeural', N'Azure', N'Neural', N'Male voice for English (United Kingdom)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-GB-MiaNeural', N'Azure', N'Neural', N'Female voice for English (United Kingdom)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-HK-YanNeural', N'Azure', N'Neural', N'Female voice for English (Hong Kong SAR)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-HK-SamNeural', N'Azure', N'Neural', N'Male voice for English (Hong Kong SAR)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-IE-EmilyNeural', N'Azure', N'Neural', N'Female voice for English (Ireland)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-IE-ConnorNeural', N'Azure', N'Neural', N'Male voice for English (Ireland)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-IN-AaravNeural', N'Azure', N'Neural', N'Male voice for English (India)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-IN-AashiNeural', N'Azure', N'Neural', N'Female voice for English (India)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-IN-AartiNeural', N'Azure', N'Neural', N'Female voice for English (India)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-IN-ArjunNeural', N'Azure', N'Neural', N'Male voice for English (India)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-IN-AnanyaNeural', N'Azure', N'Neural', N'Female voice for English (India)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-IN-KavyaNeural', N'Azure', N'Neural', N'Female voice for English (India)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-IN-KunalNeural', N'Azure', N'Neural', N'Male voice for English (India)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-IN-NeerjaNeural', N'Azure', N'Neural', N'Female voice for English (India)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-IN-PrabhatNeural', N'Azure', N'Neural', N'Male voice for English (India)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-IN-RehaanNeural', N'Azure', N'Neural', N'Male voice for English (India)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-KE-AsiliaNeural', N'Azure', N'Neural', N'Female voice for English (Kenya)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-KE-ChilembaNeural', N'Azure', N'Neural', N'Male voice for English (Kenya)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-NG-EzinneNeural', N'Azure', N'Neural', N'Female voice for English (Nigeria)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-NG-AbeoNeural', N'Azure', N'Neural', N'Male voice for English (Nigeria)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-NZ-MollyNeural', N'Azure', N'Neural', N'Female voice for English (New Zealand)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-NZ-MitchellNeural', N'Azure', N'Neural', N'Male voice for English (New Zealand)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-PH-RosaNeural', N'Azure', N'Neural', N'Female voice for English (Philippines)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-PH-JamesNeural', N'Azure', N'Neural', N'Male voice for English (Philippines)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-SG-LunaNeural', N'Azure', N'Neural', N'Female voice for English (Singapore)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-SG-WayneNeural', N'Azure', N'Neural', N'Male voice for English (Singapore)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-TZ-ImaniNeural', N'Azure', N'Neural', N'Female voice for English (Tanzania)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-TZ-ElimuNeural', N'Azure', N'Neural', N'Male voice for English (Tanzania)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-US-AvaMultilingualNeural', N'Azure', N'Neural', N'Female voice for English (United States)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-US-AndrewMultilingualNeural', N'Azure', N'Neural', N'Male voice for English (United States)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-US-EmmaMultilingualNeural', N'Azure', N'Neural', N'Female voice for English (United States)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-US-AlloyTurboMultilingualNeural', N'Azure', N'Neural', N'Male voice for English (United States)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-US-EchoTurboMultilingualNeural', N'Azure', N'Neural', N'Male voice for English (United States)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-US-FableTurboMultilingualNeural', N'Azure', N'Neural', N'Neutral voice for English (United States)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-US-OnyxTurboMultilingualNeural', N'Azure', N'Neural', N'Male voice for English (United States)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-US-NovaTurboMultilingualNeural', N'Azure', N'Neural', N'Female voice for English (United States)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-US-ShimmerTurboMultilingualNeural', N'Azure', N'Neural', N'Female voice for English (United States)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-US-BrianMultilingualNeural', N'Azure', N'Neural', N'Male voice for English (United States)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-US-AvaNeural', N'Azure', N'Neural', N'Female voice for English (United States)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-US-AndrewNeural', N'Azure', N'Neural', N'Male voice for English (United States)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-US-EmmaNeural', N'Azure', N'Neural', N'Female voice for English (United States)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-US-BrianNeural', N'Azure', N'Neural', N'Male voice for English (United States)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-US-JennyNeural', N'Azure', N'Neural', N'Female voice for English (United States)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-US-GuyNeural', N'Azure', N'Neural', N'Male voice for English (United States)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-US-AriaNeural', N'Azure', N'Neural', N'Female voice for English (United States)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-US-DavisNeural', N'Azure', N'Neural', N'Male voice for English (United States)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-US-JaneNeural', N'Azure', N'Neural', N'Female voice for English (United States)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-US-JasonNeural', N'Azure', N'Neural', N'Male voice for English (United States)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-US-KaiNeural', N'Azure', N'Neural', N'Male voice for English (United States)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-US-LunaNeural', N'Azure', N'Neural', N'Female voice for English (United States)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-US-SaraNeural', N'Azure', N'Neural', N'Female voice for English (United States)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-US-TonyNeural', N'Azure', N'Neural', N'Male voice for English (United States)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-US-NancyNeural', N'Azure', N'Neural', N'Female voice for English (United States)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-US-CoraMultilingualNeural', N'Azure', N'Neural', N'Female voice for English (United States)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-US-ChristopherMultilingualNeural', N'Azure', N'Neural', N'Male voice for English (United States)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-US-BrandonMultilingualNeural', N'Azure', N'Neural', N'Male voice for English (United States)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-US-AmberNeural', N'Azure', N'Neural', N'Female voice for English (United States)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-US-AnaNeural', N'Azure', N'Neural', N'Female voice for English (United States)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-US-AshleyNeural', N'Azure', N'Neural', N'Female voice for English (United States)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-US-BrandonNeural', N'Azure', N'Neural', N'Male voice for English (United States)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-US-ChristopherNeural', N'Azure', N'Neural', N'Male voice for English (United States)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-US-CoraNeural', N'Azure', N'Neural', N'Female voice for English (United States)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-US-ElizabethNeural', N'Azure', N'Neural', N'Female voice for English (United States)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-US-EricNeural', N'Azure', N'Neural', N'Male voice for English (United States)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-US-JacobNeural', N'Azure', N'Neural', N'Male voice for English (United States)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-US-JennyMultilingualNeural', N'Azure', N'Neural', N'Female voice for English (United States)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-US-MichelleNeural', N'Azure', N'Neural', N'Female voice for English (United States)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-US-MonicaNeural', N'Azure', N'Neural', N'Female voice for English (United States)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-US-RogerNeural', N'Azure', N'Neural', N'Male voice for English (United States)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-US-RyanMultilingualNeural', N'Azure', N'Neural', N'Male voice for English (United States)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-US-SteffanNeural', N'Azure', N'Neural', N'Male voice for English (United States)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-ZA-LeahNeural', N'Azure', N'Neural', N'Female voice for English (South Africa)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'en-ZA-LukeNeural', N'Azure', N'Neural', N'Male voice for English (South Africa)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-AR-ElenaNeural', N'Azure', N'Neural', N'Female voice for Spanish (Argentina)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-AR-TomasNeural', N'Azure', N'Neural', N'Male voice for Spanish (Argentina)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-BO-SofiaNeural', N'Azure', N'Neural', N'Female voice for Spanish (Bolivia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-BO-MarceloNeural', N'Azure', N'Neural', N'Male voice for Spanish (Bolivia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-CL-CatalinaNeural', N'Azure', N'Neural', N'Female voice for Spanish (Chile)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-CL-LorenzoNeural', N'Azure', N'Neural', N'Male voice for Spanish (Chile)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-CO-SalomeNeural', N'Azure', N'Neural', N'Female voice for Spanish (Colombia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-CO-GonzaloNeural', N'Azure', N'Neural', N'Male voice for Spanish (Colombia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-CR-MariaNeural', N'Azure', N'Neural', N'Female voice for Spanish (Costa Rica)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-CR-JuanNeural', N'Azure', N'Neural', N'Male voice for Spanish (Costa Rica)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-CU-BelkysNeural', N'Azure', N'Neural', N'Female voice for Spanish (Cuba)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-CU-ManuelNeural', N'Azure', N'Neural', N'Male voice for Spanish (Cuba)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-DO-RamonaNeural', N'Azure', N'Neural', N'Female voice for Spanish (Dominican Republic)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-DO-EmilioNeural', N'Azure', N'Neural', N'Male voice for Spanish (Dominican Republic)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-EC-AndreaNeural', N'Azure', N'Neural', N'Female voice for Spanish (Ecuador)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-EC-LuisNeural', N'Azure', N'Neural', N'Male voice for Spanish (Ecuador)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-ES-ElviraNeural', N'Azure', N'Neural', N'Female voice for Spanish (Spain)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-ES-AlvaroNeural', N'Azure', N'Neural', N'Male voice for Spanish (Spain)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-ES-ArabellaMultilingualNeural', N'Azure', N'Neural', N'Female voice for Spanish (Spain)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-ES-IsidoraMultilingualNeural', N'Azure', N'Neural', N'Female voice for Spanish (Spain)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-ES-TristanMultilingualNeural', N'Azure', N'Neural', N'Male voice for Spanish (Spain)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-ES-XimenaMultilingualNeural', N'Azure', N'Neural', N'Female voice for Spanish (Spain)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-ES-AbrilNeural', N'Azure', N'Neural', N'Female voice for Spanish (Spain)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-ES-ArnauNeural', N'Azure', N'Neural', N'Male voice for Spanish (Spain)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-ES-DarioNeural', N'Azure', N'Neural', N'Male voice for Spanish (Spain)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-ES-EliasNeural', N'Azure', N'Neural', N'Male voice for Spanish (Spain)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-ES-EstrellaNeural', N'Azure', N'Neural', N'Female voice for Spanish (Spain)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-ES-IreneNeural', N'Azure', N'Neural', N'Female voice for Spanish (Spain)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-ES-LaiaNeural', N'Azure', N'Neural', N'Female voice for Spanish (Spain)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-ES-LiaNeural', N'Azure', N'Neural', N'Female voice for Spanish (Spain)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-ES-NilNeural', N'Azure', N'Neural', N'Male voice for Spanish (Spain)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-ES-SaulNeural', N'Azure', N'Neural', N'Male voice for Spanish (Spain)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-ES-TeoNeural', N'Azure', N'Neural', N'Male voice for Spanish (Spain)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-ES-TrianaNeural', N'Azure', N'Neural', N'Female voice for Spanish (Spain)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-ES-VeraNeural', N'Azure', N'Neural', N'Female voice for Spanish (Spain)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-ES-XimenaNeural', N'Azure', N'Neural', N'Female voice for Spanish (Spain)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-GQ-TeresaNeural', N'Azure', N'Neural', N'Female voice for Spanish (Equatorial Guinea)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-GQ-JavierNeural', N'Azure', N'Neural', N'Male voice for Spanish (Equatorial Guinea)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-GT-MartaNeural', N'Azure', N'Neural', N'Female voice for Spanish (Guatemala)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-GT-AndresNeural', N'Azure', N'Neural', N'Male voice for Spanish (Guatemala)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-HN-KarlaNeural', N'Azure', N'Neural', N'Female voice for Spanish (Honduras)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-HN-CarlosNeural', N'Azure', N'Neural', N'Male voice for Spanish (Honduras)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-MX-DaliaNeural', N'Azure', N'Neural', N'Female voice for Spanish (Mexico)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-MX-JorgeNeural', N'Azure', N'Neural', N'Male voice for Spanish (Mexico)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-MX-BeatrizNeural', N'Azure', N'Neural', N'Female voice for Spanish (Mexico)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-MX-CandelaNeural', N'Azure', N'Neural', N'Female voice for Spanish (Mexico)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-MX-CarlotaNeural', N'Azure', N'Neural', N'Female voice for Spanish (Mexico)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-MX-CecilioNeural', N'Azure', N'Neural', N'Male voice for Spanish (Mexico)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-MX-GerardoNeural', N'Azure', N'Neural', N'Male voice for Spanish (Mexico)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-MX-LarissaNeural', N'Azure', N'Neural', N'Female voice for Spanish (Mexico)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-MX-LibertoNeural', N'Azure', N'Neural', N'Male voice for Spanish (Mexico)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-MX-LucianoNeural', N'Azure', N'Neural', N'Male voice for Spanish (Mexico)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-MX-MarinaNeural', N'Azure', N'Neural', N'Female voice for Spanish (Mexico)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-MX-NuriaNeural', N'Azure', N'Neural', N'Female voice for Spanish (Mexico)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-MX-PelayoNeural', N'Azure', N'Neural', N'Male voice for Spanish (Mexico)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-MX-RenataNeural', N'Azure', N'Neural', N'Female voice for Spanish (Mexico)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-MX-YagoNeural', N'Azure', N'Neural', N'Male voice for Spanish (Mexico)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-NI-YolandaNeural', N'Azure', N'Neural', N'Female voice for Spanish (Nicaragua)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-NI-FedericoNeural', N'Azure', N'Neural', N'Male voice for Spanish (Nicaragua)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-PA-MargaritaNeural', N'Azure', N'Neural', N'Female voice for Spanish (Panama)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-PA-RobertoNeural', N'Azure', N'Neural', N'Male voice for Spanish (Panama)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-PE-CamilaNeural', N'Azure', N'Neural', N'Female voice for Spanish (Peru)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-PE-AlexNeural', N'Azure', N'Neural', N'Male voice for Spanish (Peru)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-PR-KarinaNeural', N'Azure', N'Neural', N'Female voice for Spanish (Puerto Rico)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-PR-VictorNeural', N'Azure', N'Neural', N'Male voice for Spanish (Puerto Rico)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-PY-TaniaNeural', N'Azure', N'Neural', N'Female voice for Spanish (Paraguay)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-PY-MarioNeural', N'Azure', N'Neural', N'Male voice for Spanish (Paraguay)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-SV-LorenaNeural', N'Azure', N'Neural', N'Female voice for Spanish (El Salvador)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-SV-RodrigoNeural', N'Azure', N'Neural', N'Male voice for Spanish (El Salvador)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-US-PalomaNeural', N'Azure', N'Neural', N'Female voice for Spanish (United States)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-US-AlonsoNeural', N'Azure', N'Neural', N'Male voice for Spanish (United States)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-UY-ValentinaNeural', N'Azure', N'Neural', N'Female voice for Spanish (Uruguay)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-UY-MateoNeural', N'Azure', N'Neural', N'Male voice for Spanish (Uruguay)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-VE-PaolaNeural', N'Azure', N'Neural', N'Female voice for Spanish (Venezuela)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'es-VE-SebastianNeural', N'Azure', N'Neural', N'Male voice for Spanish (Venezuela)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'et-EE-AnuNeural', N'Azure', N'Neural', N'Female voice for Estonian (Estonia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'et-EE-KertNeural', N'Azure', N'Neural', N'Male voice for Estonian (Estonia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'eu-ES-AinhoaNeural', N'Azure', N'Neural', N'Female voice for Basque', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'eu-ES-AnderNeural', N'Azure', N'Neural', N'Male voice for Basque', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'fa-IR-DilaraNeural', N'Azure', N'Neural', N'Female voice for Persian (Iran)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'fa-IR-FaridNeural', N'Azure', N'Neural', N'Male voice for Persian (Iran)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'fi-FI-SelmaNeural', N'Azure', N'Neural', N'Female voice for Finnish (Finland)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'fi-FI-HarriNeural', N'Azure', N'Neural', N'Male voice for Finnish (Finland)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'fi-FI-NooraNeural', N'Azure', N'Neural', N'Female voice for Finnish (Finland)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'fil-PH-BlessicaNeural', N'Azure', N'Neural', N'Female voice for Filipino (Philippines)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'fil-PH-AngeloNeural', N'Azure', N'Neural', N'Male voice for Filipino (Philippines)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'fr-BE-CharlineNeural', N'Azure', N'Neural', N'Female voice for French (Belgium)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'fr-BE-GerardNeural', N'Azure', N'Neural', N'Male voice for French (Belgium)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'fr-CA-SylvieNeural', N'Azure', N'Neural', N'Female voice for French (Canada)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'fr-CA-JeanNeural', N'Azure', N'Neural', N'Male voice for French (Canada)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'fr-CA-AntoineNeural', N'Azure', N'Neural', N'Male voice for French (Canada)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'fr-CA-ThierryNeural', N'Azure', N'Neural', N'Male voice for French (Canada)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'fr-CH-ArianeNeural', N'Azure', N'Neural', N'Female voice for French (Switzerland)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'fr-CH-FabriceNeural', N'Azure', N'Neural', N'Male voice for French (Switzerland)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'fr-FR-DeniseNeural', N'Azure', N'Neural', N'Female voice for French (France)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'fr-FR-HenriNeural', N'Azure', N'Neural', N'Male voice for French (France)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'fr-FR-VivienneMultilingualNeural', N'Azure', N'Neural', N'Female voice for French (France)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'fr-FR-RemyMultilingualNeural', N'Azure', N'Neural', N'Male voice for French (France)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'fr-FR-LucienMultilingualNeural', N'Azure', N'Neural', N'Male voice for French (France)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'fr-FR-AlainNeural', N'Azure', N'Neural', N'Male voice for French (France)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'fr-FR-BrigitteNeural', N'Azure', N'Neural', N'Female voice for French (France)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'fr-FR-CelesteNeural', N'Azure', N'Neural', N'Female voice for French (France)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'fr-FR-ClaudeNeural', N'Azure', N'Neural', N'Male voice for French (France)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'fr-FR-CoralieNeural', N'Azure', N'Neural', N'Female voice for French (France)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'fr-FR-EloiseNeural', N'Azure', N'Neural', N'Female voice for French (France)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'fr-FR-JacquelineNeural', N'Azure', N'Neural', N'Female voice for French (France)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'fr-FR-JeromeNeural', N'Azure', N'Neural', N'Male voice for French (France)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'fr-FR-JosephineNeural', N'Azure', N'Neural', N'Female voice for French (France)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'fr-FR-MauriceNeural', N'Azure', N'Neural', N'Male voice for French (France)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'fr-FR-YvesNeural', N'Azure', N'Neural', N'Male voice for French (France)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'fr-FR-YvetteNeural', N'Azure', N'Neural', N'Female voice for French (France)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ga-IE-OrlaNeural', N'Azure', N'Neural', N'Female voice for Irish (Ireland)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ga-IE-ColmNeural', N'Azure', N'Neural', N'Male voice for Irish (Ireland)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'gl-ES-SabelaNeural', N'Azure', N'Neural', N'Female voice for Galician', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'gl-ES-RoiNeural', N'Azure', N'Neural', N'Male voice for Galician', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'gu-IN-DhwaniNeural', N'Azure', N'Neural', N'Female voice for Gujarati (India)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'gu-IN-NiranjanNeural', N'Azure', N'Neural', N'Male voice for Gujarati (India)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'he-IL-HilaNeural', N'Azure', N'Neural', N'Female voice for Hebrew (Israel)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'he-IL-AvriNeural', N'Azure', N'Neural', N'Male voice for Hebrew (Israel)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'hi-IN-AaravNeural', N'Azure', N'Neural', N'Male voice for Hindi (India)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'hi-IN-AnanyaNeural', N'Azure', N'Neural', N'Female voice for Hindi (India)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'hi-IN-AartiNeural', N'Azure', N'Neural', N'Female voice for Hindi (India)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'hi-IN-ArjunNeural', N'Azure', N'Neural', N'Male voice for Hindi (India)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'hi-IN-KavyaNeural', N'Azure', N'Neural', N'Female voice for Hindi (India)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'hi-IN-KunalNeural', N'Azure', N'Neural', N'Male voice for Hindi (India)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'hi-IN-RehaanNeural', N'Azure', N'Neural', N'Male voice for Hindi (India)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'hi-IN-SwaraNeural', N'Azure', N'Neural', N'Female voice for Hindi (India)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'hi-IN-MadhurNeural', N'Azure', N'Neural', N'Male voice for Hindi (India)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'hr-HR-GabrijelaNeural', N'Azure', N'Neural', N'Female voice for Croatian (Croatia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'hr-HR-SreckoNeural', N'Azure', N'Neural', N'Male voice for Croatian (Croatia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'hu-HU-NoemiNeural', N'Azure', N'Neural', N'Female voice for Hungarian (Hungary)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'hu-HU-TamasNeural', N'Azure', N'Neural', N'Male voice for Hungarian (Hungary)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'hy-AM-AnahitNeural', N'Azure', N'Neural', N'Female voice for Armenian (Armenia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'hy-AM-HaykNeural', N'Azure', N'Neural', N'Male voice for Armenian (Armenia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'id-ID-GadisNeural', N'Azure', N'Neural', N'Female voice for Indonesian (Indonesia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'id-ID-ArdiNeural', N'Azure', N'Neural', N'Male voice for Indonesian (Indonesia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'is-IS-GudrunNeural', N'Azure', N'Neural', N'Female voice for Icelandic (Iceland)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'is-IS-GunnarNeural', N'Azure', N'Neural', N'Male voice for Icelandic (Iceland)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'it-IT-ElsaNeural', N'Azure', N'Neural', N'Female voice for Italian (Italy)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'it-IT-IsabellaNeural', N'Azure', N'Neural', N'Female voice for Italian (Italy)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'it-IT-DiegoNeural', N'Azure', N'Neural', N'Male voice for Italian (Italy)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'it-IT-AlessioMultilingualNeural', N'Azure', N'Neural', N'Male voice for Italian (Italy)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'it-IT-IsabellaMultilingualNeural', N'Azure', N'Neural', N'Female voice for Italian (Italy)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'it-IT-GiuseppeMultilingualNeural', N'Azure', N'Neural', N'Male voice for Italian (Italy)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'it-IT-MarcelloMultilingualNeural', N'Azure', N'Neural', N'Male voice for Italian (Italy)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'it-IT-BenignoNeural', N'Azure', N'Neural', N'Male voice for Italian (Italy)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'it-IT-CalimeroNeural', N'Azure', N'Neural', N'Male voice for Italian (Italy)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'it-IT-CataldoNeural', N'Azure', N'Neural', N'Male voice for Italian (Italy)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'it-IT-FabiolaNeural', N'Azure', N'Neural', N'Female voice for Italian (Italy)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'it-IT-FiammaNeural', N'Azure', N'Neural', N'Female voice for Italian (Italy)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'it-IT-GianniNeural', N'Azure', N'Neural', N'Male voice for Italian (Italy)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'it-IT-GiuseppeNeural', N'Azure', N'Neural', N'Male voice for Italian (Italy)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'it-IT-ImeldaNeural', N'Azure', N'Neural', N'Female voice for Italian (Italy)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'it-IT-IrmaNeural', N'Azure', N'Neural', N'Female voice for Italian (Italy)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'it-IT-LisandroNeural', N'Azure', N'Neural', N'Male voice for Italian (Italy)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'it-IT-PalmiraNeural', N'Azure', N'Neural', N'Female voice for Italian (Italy)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'it-IT-PierinaNeural', N'Azure', N'Neural', N'Female voice for Italian (Italy)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'it-IT-RinaldoNeural', N'Azure', N'Neural', N'Male voice for Italian (Italy)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'iu-Cans-CA-SiqiniqNeural', N'Azure', N'Neural', N'Female voice for Inuktitut (Syllabics, Canada)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'iu-Cans-CA-TaqqiqNeural', N'Azure', N'Neural', N'Male voice for Inuktitut (Syllabics, Canada)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'iu-Latn-CA-SiqiniqNeural', N'Azure', N'Neural', N'Female voice for Inuktitut (Latin, Canada)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'iu-Latn-CA-TaqqiqNeural', N'Azure', N'Neural', N'Male voice for Inuktitut (Latin, Canada)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ja-JP-NanamiNeural', N'Azure', N'Neural', N'Female voice for Japanese (Japan)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ja-JP-KeitaNeural', N'Azure', N'Neural', N'Male voice for Japanese (Japan)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ja-JP-AoiNeural', N'Azure', N'Neural', N'Female voice for Japanese (Japan)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ja-JP-DaichiNeural', N'Azure', N'Neural', N'Male voice for Japanese (Japan)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ja-JP-MayuNeural', N'Azure', N'Neural', N'Female voice for Japanese (Japan)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ja-JP-NaokiNeural', N'Azure', N'Neural', N'Male voice for Japanese (Japan)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ja-JP-ShioriNeural', N'Azure', N'Neural', N'Female voice for Japanese (Japan)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'jv-ID-SitiNeural', N'Azure', N'Neural', N'Female voice for Javanese (Latin, Indonesia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'jv-ID-DimasNeural', N'Azure', N'Neural', N'Male voice for Javanese (Latin, Indonesia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ka-GE-EkaNeural', N'Azure', N'Neural', N'Female voice for Georgian (Georgia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ka-GE-GiorgiNeural', N'Azure', N'Neural', N'Male voice for Georgian (Georgia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'kk-KZ-AigulNeural', N'Azure', N'Neural', N'Female voice for Kazakh (Kazakhstan)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'kk-KZ-DauletNeural', N'Azure', N'Neural', N'Male voice for Kazakh (Kazakhstan)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'km-KH-SreymomNeural', N'Azure', N'Neural', N'Female voice for Khmer (Cambodia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'km-KH-PisethNeural', N'Azure', N'Neural', N'Male voice for Khmer (Cambodia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'kn-IN-SapnaNeural', N'Azure', N'Neural', N'Female voice for Kannada (India)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'kn-IN-GaganNeural', N'Azure', N'Neural', N'Male voice for Kannada (India)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ko-KR-SunHiNeural', N'Azure', N'Neural', N'Female voice for Korean (Korea)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ko-KR-InJoonNeural', N'Azure', N'Neural', N'Male voice for Korean (Korea)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ko-KR-HyunsuMultilingualNeural', N'Azure', N'Neural', N'Male voice for Korean (Korea)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ko-KR-BongJinNeural', N'Azure', N'Neural', N'Male voice for Korean (Korea)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ko-KR-GookMinNeural', N'Azure', N'Neural', N'Male voice for Korean (Korea)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ko-KR-HyunsuNeural', N'Azure', N'Neural', N'Male voice for Korean (Korea)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ko-KR-JiMinNeural', N'Azure', N'Neural', N'Female voice for Korean (Korea)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ko-KR-SeoHyeonNeural', N'Azure', N'Neural', N'Female voice for Korean (Korea)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ko-KR-SoonBokNeural', N'Azure', N'Neural', N'Female voice for Korean (Korea)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ko-KR-YuJinNeural', N'Azure', N'Neural', N'Female voice for Korean (Korea)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'lo-LA-KeomanyNeural', N'Azure', N'Neural', N'Female voice for Lao (Laos)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'lo-LA-ChanthavongNeural', N'Azure', N'Neural', N'Male voice for Lao (Laos)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'lt-LT-OnaNeural', N'Azure', N'Neural', N'Female voice for Lithuanian (Lithuania)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'lt-LT-LeonasNeural', N'Azure', N'Neural', N'Male voice for Lithuanian (Lithuania)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'lv-LV-EveritaNeural', N'Azure', N'Neural', N'Female voice for Latvian (Latvia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'lv-LV-NilsNeural', N'Azure', N'Neural', N'Male voice for Latvian (Latvia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'mk-MK-MarijaNeural', N'Azure', N'Neural', N'Female voice for Macedonian (North Macedonia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'mk-MK-AleksandarNeural', N'Azure', N'Neural', N'Male voice for Macedonian (North Macedonia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ml-IN-SobhanaNeural', N'Azure', N'Neural', N'Female voice for Malayalam (India)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ml-IN-MidhunNeural', N'Azure', N'Neural', N'Male voice for Malayalam (India)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'mn-MN-YesuiNeural', N'Azure', N'Neural', N'Female voice for Mongolian (Mongolia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'mn-MN-BataaNeural', N'Azure', N'Neural', N'Male voice for Mongolian (Mongolia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'mr-IN-AarohiNeural', N'Azure', N'Neural', N'Female voice for Marathi (India)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'mr-IN-ManoharNeural', N'Azure', N'Neural', N'Male voice for Marathi (India)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ms-MY-YasminNeural', N'Azure', N'Neural', N'Female voice for Malay (Malaysia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ms-MY-OsmanNeural', N'Azure', N'Neural', N'Male voice for Malay (Malaysia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'mt-MT-GraceNeural', N'Azure', N'Neural', N'Female voice for Maltese (Malta)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'mt-MT-JosephNeural', N'Azure', N'Neural', N'Male voice for Maltese (Malta)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'my-MM-NilarNeural', N'Azure', N'Neural', N'Female voice for Burmese (Myanmar)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'my-MM-ThihaNeural', N'Azure', N'Neural', N'Male voice for Burmese (Myanmar)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'nb-NO-PernilleNeural', N'Azure', N'Neural', N'Female voice for Norwegian Bokmål (Norway)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'nb-NO-FinnNeural', N'Azure', N'Neural', N'Male voice for Norwegian Bokmål (Norway)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'nb-NO-IselinNeural', N'Azure', N'Neural', N'Female voice for Norwegian Bokmål (Norway)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ne-NP-HemkalaNeural', N'Azure', N'Neural', N'Female voice for Nepali (Nepal)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ne-NP-SagarNeural', N'Azure', N'Neural', N'Male voice for Nepali (Nepal)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'nl-BE-DenaNeural', N'Azure', N'Neural', N'Female voice for Dutch (Belgium)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'nl-BE-ArnaudNeural', N'Azure', N'Neural', N'Male voice for Dutch (Belgium)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'nl-NL-FennaNeural', N'Azure', N'Neural', N'Female voice for Dutch (Netherlands)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'nl-NL-MaartenNeural', N'Azure', N'Neural', N'Male voice for Dutch (Netherlands)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'nl-NL-ColetteNeural', N'Azure', N'Neural', N'Female voice for Dutch (Netherlands)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'or-IN-SubhasiniNeural', N'Azure', N'Neural', N'Female voice for Odia (India)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'or-IN-SukantNeural', N'Azure', N'Neural', N'Male voice for Odia (India)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'pa-IN-OjasNeural', N'Azure', N'Neural', N'Male voice for Punjabi (India)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'pa-IN-VaaniNeural', N'Azure', N'Neural', N'Female voice for Punjabi (India)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'pl-PL-AgnieszkaNeural', N'Azure', N'Neural', N'Female voice for Polish (Poland)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'pl-PL-MarekNeural', N'Azure', N'Neural', N'Male voice for Polish (Poland)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'pl-PL-ZofiaNeural', N'Azure', N'Neural', N'Female voice for Polish (Poland)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ps-AF-LatifaNeural', N'Azure', N'Neural', N'Female voice for Pashto (Afghanistan)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ps-AF-GulNawazNeural', N'Azure', N'Neural', N'Male voice for Pashto (Afghanistan)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'pt-BR-FranciscaNeural', N'Azure', N'Neural', N'Female voice for Portuguese (Brazil)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'pt-BR-AntonioNeural', N'Azure', N'Neural', N'Male voice for Portuguese (Brazil)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'pt-BR-MacerioMultilingualNeural', N'Azure', N'Neural', N'Male voice for Portuguese (Brazil)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'pt-BR-ThalitaMultilingualNeural', N'Azure', N'Neural', N'Female voice for Portuguese (Brazil)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'pt-BR-BrendaNeural', N'Azure', N'Neural', N'Female voice for Portuguese (Brazil)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'pt-BR-DonatoNeural', N'Azure', N'Neural', N'Male voice for Portuguese (Brazil)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'pt-BR-ElzaNeural', N'Azure', N'Neural', N'Female voice for Portuguese (Brazil)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'pt-BR-FabioNeural', N'Azure', N'Neural', N'Male voice for Portuguese (Brazil)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'pt-BR-GiovannaNeural', N'Azure', N'Neural', N'Female voice for Portuguese (Brazil)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'pt-BR-HumbertoNeural', N'Azure', N'Neural', N'Male voice for Portuguese (Brazil)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'pt-BR-JulioNeural', N'Azure', N'Neural', N'Male voice for Portuguese (Brazil)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'pt-BR-LeilaNeural', N'Azure', N'Neural', N'Female voice for Portuguese (Brazil)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'pt-BR-LeticiaNeural', N'Azure', N'Neural', N'Female voice for Portuguese (Brazil)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'pt-BR-ManuelaNeural', N'Azure', N'Neural', N'Female voice for Portuguese (Brazil)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'pt-BR-NicolauNeural', N'Azure', N'Neural', N'Male voice for Portuguese (Brazil)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'pt-BR-ThalitaNeural', N'Azure', N'Neural', N'Female voice for Portuguese (Brazil)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'pt-BR-ValerioNeural', N'Azure', N'Neural', N'Male voice for Portuguese (Brazil)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'pt-BR-YaraNeural', N'Azure', N'Neural', N'Female voice for Portuguese (Brazil)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'pt-PT-RaquelNeural', N'Azure', N'Neural', N'Female voice for Portuguese (Portugal)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'pt-PT-DuarteNeural', N'Azure', N'Neural', N'Male voice for Portuguese (Portugal)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'pt-PT-FernandaNeural', N'Azure', N'Neural', N'Female voice for Portuguese (Portugal)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ro-RO-AlinaNeural', N'Azure', N'Neural', N'Female voice for Romanian (Romania)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ro-RO-EmilNeural', N'Azure', N'Neural', N'Male voice for Romanian (Romania)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ru-RU-SvetlanaNeural', N'Azure', N'Neural', N'Female voice for Russian (Russia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ru-RU-DmitryNeural', N'Azure', N'Neural', N'Male voice for Russian (Russia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ru-RU-DariyaNeural', N'Azure', N'Neural', N'Female voice for Russian (Russia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'si-LK-ThiliniNeural', N'Azure', N'Neural', N'Female voice for Sinhala (Sri Lanka)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'si-LK-SameeraNeural', N'Azure', N'Neural', N'Male voice for Sinhala (Sri Lanka)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'sk-SK-ViktoriaNeural', N'Azure', N'Neural', N'Female voice for Slovak (Slovakia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'sk-SK-LukasNeural', N'Azure', N'Neural', N'Male voice for Slovak (Slovakia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'sl-SI-PetraNeural', N'Azure', N'Neural', N'Female voice for Slovenian (Slovenia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'sl-SI-RokNeural', N'Azure', N'Neural', N'Male voice for Slovenian (Slovenia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'so-SO-UbaxNeural', N'Azure', N'Neural', N'Female voice for Somali (Somalia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'so-SO-MuuseNeural', N'Azure', N'Neural', N'Male voice for Somali (Somalia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'sq-AL-AnilaNeural', N'Azure', N'Neural', N'Female voice for Albanian (Albania)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'sq-AL-IlirNeural', N'Azure', N'Neural', N'Male voice for Albanian (Albania)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'sr-Latn-RS-NicholasNeural', N'Azure', N'Neural', N'Male voice for Serbian (Latin, Serbia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'sr-Latn-RS-SophieNeural', N'Azure', N'Neural', N'Female voice for Serbian (Latin, Serbia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'sr-RS-SophieNeural', N'Azure', N'Neural', N'Female voice for Serbian (Cyrillic, Serbia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'sr-RS-NicholasNeural', N'Azure', N'Neural', N'Male voice for Serbian (Cyrillic, Serbia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'su-ID-TutiNeural', N'Azure', N'Neural', N'Female voice for Sundanese (Indonesia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'su-ID-JajangNeural', N'Azure', N'Neural', N'Male voice for Sundanese (Indonesia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'sv-SE-SofieNeural', N'Azure', N'Neural', N'Female voice for Swedish (Sweden)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'sv-SE-MattiasNeural', N'Azure', N'Neural', N'Male voice for Swedish (Sweden)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'sv-SE-HilleviNeural', N'Azure', N'Neural', N'Female voice for Swedish (Sweden)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'sw-KE-ZuriNeural', N'Azure', N'Neural', N'Female voice for Swahili (Kenya)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'sw-KE-RafikiNeural', N'Azure', N'Neural', N'Male voice for Swahili (Kenya)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'sw-TZ-RehemaNeural', N'Azure', N'Neural', N'Female voice for Swahili (Tanzania)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'sw-TZ-DaudiNeural', N'Azure', N'Neural', N'Male voice for Swahili (Tanzania)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ta-IN-PallaviNeural', N'Azure', N'Neural', N'Female voice for Tamil (India)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ta-IN-ValluvarNeural', N'Azure', N'Neural', N'Male voice for Tamil (India)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ta-LK-SaranyaNeural', N'Azure', N'Neural', N'Female voice for Tamil (Sri Lanka)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ta-LK-KumarNeural', N'Azure', N'Neural', N'Male voice for Tamil (Sri Lanka)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ta-MY-KaniNeural', N'Azure', N'Neural', N'Female voice for Tamil (Malaysia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ta-MY-SuryaNeural', N'Azure', N'Neural', N'Male voice for Tamil (Malaysia)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ta-SG-VenbaNeural', N'Azure', N'Neural', N'Female voice for Tamil (Singapore)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ta-SG-AnbuNeural', N'Azure', N'Neural', N'Male voice for Tamil (Singapore)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'te-IN-ShrutiNeural', N'Azure', N'Neural', N'Female voice for Telugu (India)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'te-IN-MohanNeural', N'Azure', N'Neural', N'Male voice for Telugu (India)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'th-TH-PremwadeeNeural', N'Azure', N'Neural', N'Female voice for Thai (Thailand)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'th-TH-NiwatNeural', N'Azure', N'Neural', N'Male voice for Thai (Thailand)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'th-TH-AcharaNeural', N'Azure', N'Neural', N'Female voice for Thai (Thailand)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'tr-TR-EmelNeural', N'Azure', N'Neural', N'Female voice for Turkish (Türkiye)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'tr-TR-AhmetNeural', N'Azure', N'Neural', N'Male voice for Turkish (Türkiye)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'uk-UA-PolinaNeural', N'Azure', N'Neural', N'Female voice for Ukrainian (Ukraine)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'uk-UA-OstapNeural', N'Azure', N'Neural', N'Male voice for Ukrainian (Ukraine)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ur-IN-GulNeural', N'Azure', N'Neural', N'Female voice for Urdu (India)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ur-IN-SalmanNeural', N'Azure', N'Neural', N'Male voice for Urdu (India)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ur-PK-UzmaNeural', N'Azure', N'Neural', N'Female voice for Urdu (Pakistan)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'ur-PK-AsadNeural', N'Azure', N'Neural', N'Male voice for Urdu (Pakistan)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'uz-UZ-MadinaNeural', N'Azure', N'Neural', N'Female voice for Uzbek (Latin, Uzbekistan)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'uz-UZ-SardorNeural', N'Azure', N'Neural', N'Male voice for Uzbek (Latin, Uzbekistan)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'vi-VN-HoaiMyNeural', N'Azure', N'Neural', N'Female voice for Vietnamese (Vietnam)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'vi-VN-NamMinhNeural', N'Azure', N'Neural', N'Male voice for Vietnamese (Vietnam)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'wuu-CN-XiaotongNeural', N'Azure', N'Neural', N'Female voice for Chinese (Wu, Simplified)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'wuu-CN-YunzheNeural', N'Azure', N'Neural', N'Male voice for Chinese (Wu, Simplified)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'yue-CN-XiaoMinNeural', N'Azure', N'Neural', N'Female voice for Chinese (Cantonese, Simplified)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'yue-CN-YunSongNeural', N'Azure', N'Neural', N'Male voice for Chinese (Cantonese, Simplified)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'zh-CN-XiaoxiaoNeural', N'Azure', N'Neural', N'Female voice for Chinese (Mandarin, Simplified)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'zh-CN-YunxiNeural', N'Azure', N'Neural', N'Male voice for Chinese (Mandarin, Simplified)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'zh-CN-YunjianNeural', N'Azure', N'Neural', N'Male voice for Chinese (Mandarin, Simplified)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'zh-CN-XiaoyiNeural', N'Azure', N'Neural', N'Female voice for Chinese (Mandarin, Simplified)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'zh-CN-YunyangNeural', N'Azure', N'Neural', N'Male voice for Chinese (Mandarin, Simplified)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'zh-CN-XiaochenNeural', N'Azure', N'Neural', N'Female voice for Chinese (Mandarin, Simplified)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'zh-CN-XiaochenMultilingualNeural', N'Azure', N'Neural', N'Female voice for Chinese (Mandarin, Simplified)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'zh-CN-XiaohanNeural', N'Azure', N'Neural', N'Female voice for Chinese (Mandarin, Simplified)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'zh-CN-XiaomengNeural', N'Azure', N'Neural', N'Female voice for Chinese (Mandarin, Simplified)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'zh-CN-XiaomoNeural', N'Azure', N'Neural', N'Female voice for Chinese (Mandarin, Simplified)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'zh-CN-XiaoqiuNeural', N'Azure', N'Neural', N'Female voice for Chinese (Mandarin, Simplified)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'zh-CN-XiaorouNeural', N'Azure', N'Neural', N'Female voice for Chinese (Mandarin, Simplified)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'zh-CN-XiaoruiNeural', N'Azure', N'Neural', N'Female voice for Chinese (Mandarin, Simplified)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'zh-CN-XiaoshuangNeural', N'Azure', N'Neural', N'Female voice for Chinese (Mandarin, Simplified)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'zh-CN-XiaoxiaoDialectsNeural', N'Azure', N'Neural', N'Female voice for Chinese (Mandarin, Simplified)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'zh-CN-XiaoxiaoMultilingualNeural', N'Azure', N'Neural', N'Female voice for Chinese (Mandarin, Simplified)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'zh-CN-XiaoyanNeural', N'Azure', N'Neural', N'Female voice for Chinese (Mandarin, Simplified)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'zh-CN-XiaoyouNeural', N'Azure', N'Neural', N'Female voice for Chinese (Mandarin, Simplified)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'zh-CN-XiaoyuMultilingualNeural', N'Azure', N'Neural', N'Female voice for Chinese (Mandarin, Simplified)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'zh-CN-XiaozhenNeural', N'Azure', N'Neural', N'Female voice for Chinese (Mandarin, Simplified)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'zh-CN-YunfengNeural', N'Azure', N'Neural', N'Male voice for Chinese (Mandarin, Simplified)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'zh-CN-YunhaoNeural', N'Azure', N'Neural', N'Male voice for Chinese (Mandarin, Simplified)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'zh-CN-YunjieNeural', N'Azure', N'Neural', N'Male voice for Chinese (Mandarin, Simplified)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'zh-CN-YunxiaNeural', N'Azure', N'Neural', N'Male voice for Chinese (Mandarin, Simplified)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'zh-CN-YunyeNeural', N'Azure', N'Neural', N'Male voice for Chinese (Mandarin, Simplified)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'zh-CN-YunyiMultilingualNeural', N'Azure', N'Neural', N'Male voice for Chinese (Mandarin, Simplified)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'zh-CN-YunzeNeural', N'Azure', N'Neural', N'Male voice for Chinese (Mandarin, Simplified)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'zh-CN-henan-YundengNeural', N'Azure', N'Neural', N'Male voice for Chinese (Zhongyuan Mandarin Henan, Simplified)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'zh-CN-liaoning-XiaobeiNeural', N'Azure', N'Neural', N'Female voice for Chinese (Northeastern Mandarin, Simplified)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'zh-CN-shaanxi-XiaoniNeural', N'Azure', N'Neural', N'Female voice for Chinese (Zhongyuan Mandarin Shaanxi, Simplified)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'zh-CN-shandong-YunxiangNeural', N'Azure', N'Neural', N'Male voice for Chinese (Jilu Mandarin, Simplified)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'zh-CN-sichuan-YunxiNeural', N'Azure', N'Neural', N'Male voice for Chinese (Southwestern Mandarin, Simplified)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'zh-HK-HiuMaanNeural', N'Azure', N'Neural', N'Female voice for Chinese (Cantonese, Traditional)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'zh-HK-WanLungNeural', N'Azure', N'Neural', N'Male voice for Chinese (Cantonese, Traditional)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'zh-HK-HiuGaaiNeural', N'Azure', N'Neural', N'Female voice for Chinese (Cantonese, Traditional)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'zh-TW-HsiaoChenNeural', N'Azure', N'Neural', N'Female voice for Chinese (Taiwanese Mandarin, Traditional)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'zh-TW-YunJheNeural', N'Azure', N'Neural', N'Male voice for Chinese (Taiwanese Mandarin, Traditional)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'zh-TW-HsiaoYuNeural', N'Azure', N'Neural', N'Female voice for Chinese (Taiwanese Mandarin, Traditional)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'zu-ZA-ThandoNeural', N'Azure', N'Neural', N'Female voice for Zulu (South Africa)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
INSERT INTO FFA.dbo.Voices (Voice_Name, Engine_Name, Model_Name, Notes, Active, Created_Date, Last_Modified)
VALUES (N'zu-ZA-ThembaNeural', N'Azure', N'Neural', N'Male voice for Zulu (South Africa)', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
GO

CREATE VIEW vw_Invalid_Paragraph_Audio_Voices AS
SELECT pa.Audio_ID, pa.Voice_ID
FROM Paragraph_Audio pa
LEFT JOIN Voices v ON pa.Voice_ID = v.Voice_ID
WHERE pa.Voice_ID IS NOT NULL AND v.Voice_ID IS NULL;
GO

CREATE TRIGGER trg_ParagraphAudio_LastModified
ON dbo.Paragraph_Audio
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE pa
    SET Verified_Date = SYSUTCDATETIME()
    FROM dbo.Paragraph_Audio pa
    INNER JOIN inserted i ON pa.Audio_ID = i.Audio_ID
    WHERE i.Verified = 1 AND pa.Verified_Date IS NULL;
END;
GO

-- Trigger to update Verified_Date on verification of audio
CREATE TRIGGER trg_ParagraphAudio_VerifiedDate
ON dbo.Paragraph_Audio
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE t
    SET Verified_Date = SYSUTCDATETIME()
    FROM dbo.Paragraph_Audio t
    INNER JOIN inserted i ON t.Audio_ID = i.Audio_ID
    WHERE i.Verified = 1 AND t.Verified_Date IS NULL;
END;
GO

CREATE VIEW vw_Paragraph_Translation_Status AS
SELECT 
    ap.Paragraph_ID,
    ap.Translation_ID,
    at.Language_ID,
    l.Language_Name,
    apt.Paragraph_Translation_ID,
    CASE WHEN apt.Paragraph_Translation IS NOT NULL THEN 1 ELSE 0 END AS Is_Translated
FROM Articles_Paragraphs ap
JOIN Articles_Translations at ON ap.Translation_ID = at.Translation_ID
JOIN Languages l ON at.Language_ID = l.Language_ID
LEFT JOIN Articles_Paragraphs_Translated apt ON ap.Paragraph_ID = apt.Paragraph_ID AND apt.Language_ID = at.Language_ID;
GO

IF EXISTS (
    SELECT * FROM sys.extended_properties 
    WHERE major_id = OBJECT_ID('dbo.Articles') 
      AND name = 'MS_Description' AND minor_id = 0
)
BEGIN
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Articles';
END;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for Articles.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Articles';
GO

BEGIN TRY
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Articles',
        @level2type = N'COLUMN', @level2name = N'Article_Date';
END TRY
BEGIN CATCH
END CATCH;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for column Article_Date in Articles.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Articles',
  @level2type = N'COLUMN', @level2name = N'Article_Date';
GO

BEGIN TRY
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Articles',
        @level2type = N'COLUMN', @level2name = N'Article_Found';
END TRY
BEGIN CATCH
END CATCH;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for column Article_Found in Articles.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Articles',
  @level2type = N'COLUMN', @level2name = N'Article_Found';
GO

BEGIN TRY
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Articles',
        @level2type = N'COLUMN', @level2name = N'WordPress_ID';
END TRY
BEGIN CATCH
END CATCH;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for column WordPress_ID in Articles.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Articles',
  @level2type = N'COLUMN', @level2name = N'WordPress_ID';
GO

BEGIN TRY
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Articles',
        @level2type = N'COLUMN', @level2name = N'WordPress_Last_Modified';
END TRY
BEGIN CATCH
END CATCH;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for column WordPress_Last_Modified in Articles.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Articles',
  @level2type = N'COLUMN', @level2name = N'WordPress_Last_Modified';
GO

BEGIN TRY
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Articles',
        @level2type = N'COLUMN', @level2name = N'Active';
END TRY
BEGIN CATCH
END CATCH;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for column Active in Articles.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Articles',
  @level2type = N'COLUMN', @level2name = N'Active';
GO

BEGIN TRY
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Articles',
        @level2type = N'COLUMN', @level2name = N'Last_Modified';
END TRY
BEGIN CATCH
END CATCH;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for column Last_Modified in Articles.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Articles',
  @level2type = N'COLUMN', @level2name = N'Last_Modified';
GO

IF EXISTS (
    SELECT * FROM sys.extended_properties 
    WHERE major_id = OBJECT_ID('dbo.Articles_Contents') 
      AND name = 'MS_Description' AND minor_id = 0
)
BEGIN
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Articles_Contents';
END;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for Articles_Contents.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Articles_Contents';
GO

BEGIN TRY
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Articles_Contents',
        @level2type = N'COLUMN', @level2name = N'Article_ID';
END TRY
BEGIN CATCH
END CATCH;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for column Article_ID in Articles_Contents.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Articles_Contents',
  @level2type = N'COLUMN', @level2name = N'Article_ID';
GO

BEGIN TRY
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Articles_Contents',
        @level2type = N'COLUMN', @level2name = N'Content_Type_ID';
END TRY
BEGIN CATCH
END CATCH;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for column Content_Type_ID in Articles_Contents.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Articles_Contents',
  @level2type = N'COLUMN', @level2name = N'Content_Type_ID';
GO

BEGIN TRY
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Articles_Contents',
        @level2type = N'COLUMN', @level2name = N'WordPress_Last_Modified';
END TRY
BEGIN CATCH
END CATCH;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for column WordPress_Last_Modified in Articles_Contents.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Articles_Contents',
  @level2type = N'COLUMN', @level2name = N'WordPress_Last_Modified';
GO

BEGIN TRY
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Articles_Contents',
        @level2type = N'COLUMN', @level2name = N'Active';
END TRY
BEGIN CATCH
END CATCH;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for column Active in Articles_Contents.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Articles_Contents',
  @level2type = N'COLUMN', @level2name = N'Active';
GO

BEGIN TRY
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Articles_Contents',
        @level2type = N'COLUMN', @level2name = N'Last_Modified';
END TRY
BEGIN CATCH
END CATCH;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for column Last_Modified in Articles_Contents.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Articles_Contents',
  @level2type = N'COLUMN', @level2name = N'Last_Modified';
GO

IF EXISTS (
    SELECT * FROM sys.extended_properties 
    WHERE major_id = OBJECT_ID('dbo.Types') 
      AND name = 'MS_Description' AND minor_id = 0
)
BEGIN
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Types';
END;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for Types.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Types';
GO

BEGIN TRY
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Types',
        @level2type = N'COLUMN', @level2name = N'Active';
END TRY
BEGIN CATCH
END CATCH;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for column Active in Types.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Types',
  @level2type = N'COLUMN', @level2name = N'Active';
GO

BEGIN TRY
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Types',
        @level2type = N'COLUMN', @level2name = N'Last_Modified';
END TRY
BEGIN CATCH
END CATCH;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for column Last_Modified in Types.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Types',
  @level2type = N'COLUMN', @level2name = N'Last_Modified';
GO

IF EXISTS (
    SELECT * FROM sys.extended_properties 
    WHERE major_id = OBJECT_ID('dbo.Languages') 
      AND name = 'MS_Description' AND minor_id = 0
)
BEGIN
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Languages';
END;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for Languages.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Languages';
GO

BEGIN TRY
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Languages',
        @level2type = N'COLUMN', @level2name = N'Translation_Priority';
END TRY
BEGIN CATCH
END CATCH;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for column Translation_Priority in Languages.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Languages',
  @level2type = N'COLUMN', @level2name = N'Translation_Priority';
GO

BEGIN TRY
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Languages',
        @level2type = N'COLUMN', @level2name = N'Create_MP3';
END TRY
BEGIN CATCH
END CATCH;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for column Create_MP3 in Languages.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Languages',
  @level2type = N'COLUMN', @level2name = N'Create_MP3';
GO

BEGIN TRY
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Languages',
        @level2type = N'COLUMN', @level2name = N'Active';
END TRY
BEGIN CATCH
END CATCH;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for column Active in Languages.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Languages',
  @level2type = N'COLUMN', @level2name = N'Active';
GO

BEGIN TRY
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Languages',
        @level2type = N'COLUMN', @level2name = N'Last_Modified';
END TRY
BEGIN CATCH
END CATCH;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for column Last_Modified in Languages.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Languages',
  @level2type = N'COLUMN', @level2name = N'Last_Modified';
GO

IF EXISTS (
    SELECT * FROM sys.extended_properties 
    WHERE major_id = OBJECT_ID('dbo.Articles_Paragraphs') 
      AND name = 'MS_Description' AND minor_id = 0
)
BEGIN
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Articles_Paragraphs';
END;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for Articles_Paragraphs.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Articles_Paragraphs';
GO

BEGIN TRY
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Articles_Paragraphs',
        @level2type = N'COLUMN', @level2name = N'Translation_ID';
END TRY
BEGIN CATCH
END CATCH;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for column Translation_ID in Articles_Paragraphs.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Articles_Paragraphs',
  @level2type = N'COLUMN', @level2name = N'Translation_ID';
GO

BEGIN TRY
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Articles_Paragraphs',
        @level2type = N'COLUMN', @level2name = N'Paragraph_Number';
END TRY
BEGIN CATCH
END CATCH;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for column Paragraph_Number in Articles_Paragraphs.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Articles_Paragraphs',
  @level2type = N'COLUMN', @level2name = N'Paragraph_Number';
GO

BEGIN TRY
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Articles_Paragraphs',
        @level2type = N'COLUMN', @level2name = N'Content_Type_ID';
END TRY
BEGIN CATCH
END CATCH;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for column Content_Type_ID in Articles_Paragraphs.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Articles_Paragraphs',
  @level2type = N'COLUMN', @level2name = N'Content_Type_ID';
GO

BEGIN TRY
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Articles_Paragraphs',
        @level2type = N'COLUMN', @level2name = N'Active';
END TRY
BEGIN CATCH
END CATCH;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for column Active in Articles_Paragraphs.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Articles_Paragraphs',
  @level2type = N'COLUMN', @level2name = N'Active';
GO

BEGIN TRY
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Articles_Paragraphs',
        @level2type = N'COLUMN', @level2name = N'Last_Modified';
END TRY
BEGIN CATCH
END CATCH;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for column Last_Modified in Articles_Paragraphs.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Articles_Paragraphs',
  @level2type = N'COLUMN', @level2name = N'Last_Modified';
GO

IF EXISTS (
    SELECT * FROM sys.extended_properties 
    WHERE major_id = OBJECT_ID('dbo.Articles_Paragraphs_Translated') 
      AND name = 'MS_Description' AND minor_id = 0
)
BEGIN
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Articles_Paragraphs_Translated';
END;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for Articles_Paragraphs_Translated.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Articles_Paragraphs_Translated';
GO

BEGIN TRY
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Articles_Paragraphs_Translated',
        @level2type = N'COLUMN', @level2name = N'Paragraph_ID';
END TRY
BEGIN CATCH
END CATCH;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for column Paragraph_ID in Articles_Paragraphs_Translated.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Articles_Paragraphs_Translated',
  @level2type = N'COLUMN', @level2name = N'Paragraph_ID';
GO

BEGIN TRY
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Articles_Paragraphs_Translated',
        @level2type = N'COLUMN', @level2name = N'Language_ID';
END TRY
BEGIN CATCH
END CATCH;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for column Language_ID in Articles_Paragraphs_Translated.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Articles_Paragraphs_Translated',
  @level2type = N'COLUMN', @level2name = N'Language_ID';
GO

BEGIN TRY
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Articles_Paragraphs_Translated',
        @level2type = N'COLUMN', @level2name = N'Content_Type_ID';
END TRY
BEGIN CATCH
END CATCH;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for column Content_Type_ID in Articles_Paragraphs_Translated.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Articles_Paragraphs_Translated',
  @level2type = N'COLUMN', @level2name = N'Content_Type_ID';
GO

BEGIN TRY
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Articles_Paragraphs_Translated',
        @level2type = N'COLUMN', @level2name = N'Translation_Quality';
END TRY
BEGIN CATCH
END CATCH;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for column Translation_Quality in Articles_Paragraphs_Translated.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Articles_Paragraphs_Translated',
  @level2type = N'COLUMN', @level2name = N'Translation_Quality';
GO

BEGIN TRY
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Articles_Paragraphs_Translated',
        @level2type = N'COLUMN', @level2name = N'Active';
END TRY
BEGIN CATCH
END CATCH;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for column Active in Articles_Paragraphs_Translated.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Articles_Paragraphs_Translated',
  @level2type = N'COLUMN', @level2name = N'Active';
GO

BEGIN TRY
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Articles_Paragraphs_Translated',
        @level2type = N'COLUMN', @level2name = N'Last_Modified';
END TRY
BEGIN CATCH
END CATCH;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for column Last_Modified in Articles_Paragraphs_Translated.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Articles_Paragraphs_Translated',
  @level2type = N'COLUMN', @level2name = N'Last_Modified';
GO

IF EXISTS (
    SELECT * FROM sys.extended_properties 
    WHERE major_id = OBJECT_ID('dbo.Articles_Paragraphs_Translated_Errors') 
      AND name = 'MS_Description' AND minor_id = 0
)
BEGIN
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Articles_Paragraphs_Translated_Errors';
END;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for Articles_Paragraphs_Translated_Errors.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Articles_Paragraphs_Translated_Errors';
GO

BEGIN TRY
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Articles_Paragraphs_Translated_Errors',
        @level2type = N'COLUMN', @level2name = N'Paragraph_Translation_ID';
END TRY
BEGIN CATCH
END CATCH;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for column Paragraph_Translation_ID in Articles_Paragraphs_Translated_Errors.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Articles_Paragraphs_Translated_Errors',
  @level2type = N'COLUMN', @level2name = N'Paragraph_Translation_ID';
GO

BEGIN TRY
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Articles_Paragraphs_Translated_Errors',
        @level2type = N'COLUMN', @level2name = N'Translation_Error_ID';
END TRY
BEGIN CATCH
END CATCH;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for column Translation_Error_ID in Articles_Paragraphs_Translated_Errors.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Articles_Paragraphs_Translated_Errors',
  @level2type = N'COLUMN', @level2name = N'Translation_Error_ID';
GO

IF EXISTS (
    SELECT * FROM sys.extended_properties 
    WHERE major_id = OBJECT_ID('dbo.Articles_Translations_Errors') 
      AND name = 'MS_Description' AND minor_id = 0
)
BEGIN
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Articles_Translations_Errors';
END;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for Articles_Translations_Errors.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Articles_Translations_Errors';
GO

BEGIN TRY
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Articles_Translations_Errors',
        @level2type = N'COLUMN', @level2name = N'Translation_ID';
END TRY
BEGIN CATCH
END CATCH;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for column Translation_ID in Articles_Translations_Errors.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Articles_Translations_Errors',
  @level2type = N'COLUMN', @level2name = N'Translation_ID';
GO

BEGIN TRY
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Articles_Translations_Errors',
        @level2type = N'COLUMN', @level2name = N'Translation_Error_ID';
END TRY
BEGIN CATCH
END CATCH;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for column Translation_Error_ID in Articles_Translations_Errors.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Articles_Translations_Errors',
  @level2type = N'COLUMN', @level2name = N'Translation_Error_ID';
GO

IF EXISTS (
    SELECT * FROM sys.extended_properties 
    WHERE major_id = OBJECT_ID('dbo.Translation_Error') 
      AND name = 'MS_Description' AND minor_id = 0
)
BEGIN
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Translation_Error';
END;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for Translation_Error.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Translation_Error';
GO

BEGIN TRY
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Translation_Error',
        @level2type = N'COLUMN', @level2name = N'Language_ID';
END TRY
BEGIN CATCH
END CATCH;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for column Language_ID in Translation_Error.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Translation_Error',
  @level2type = N'COLUMN', @level2name = N'Language_ID';
GO

BEGIN TRY
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Translation_Error',
        @level2type = N'COLUMN', @level2name = N'Error_Type_ID';
END TRY
BEGIN CATCH
END CATCH;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for column Error_Type_ID in Translation_Error.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Translation_Error',
  @level2type = N'COLUMN', @level2name = N'Error_Type_ID';
GO

BEGIN TRY
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Translation_Error',
        @level2type = N'COLUMN', @level2name = N'Service_Type_ID';
END TRY
BEGIN CATCH
END CATCH;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for column Service_Type_ID in Translation_Error.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Translation_Error',
  @level2type = N'COLUMN', @level2name = N'Service_Type_ID';
GO

BEGIN TRY
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Translation_Error',
        @level2type = N'COLUMN', @level2name = N'Service_Model_ID';
END TRY
BEGIN CATCH
END CATCH;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for column Service_Model_ID in Translation_Error.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Translation_Error',
  @level2type = N'COLUMN', @level2name = N'Service_Model_ID';
GO

BEGIN TRY
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Translation_Error',
        @level2type = N'COLUMN', @level2name = N'Retry_Attempts';
END TRY
BEGIN CATCH
END CATCH;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for column Retry_Attempts in Translation_Error.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Translation_Error',
  @level2type = N'COLUMN', @level2name = N'Retry_Attempts';
GO

BEGIN TRY
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Translation_Error',
        @level2type = N'COLUMN', @level2name = N'Active';
END TRY
BEGIN CATCH
END CATCH;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for column Active in Translation_Error.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Translation_Error',
  @level2type = N'COLUMN', @level2name = N'Active';
GO

BEGIN TRY
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Translation_Error',
        @level2type = N'COLUMN', @level2name = N'Last_Modified';
END TRY
BEGIN CATCH
END CATCH;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for column Last_Modified in Translation_Error.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Translation_Error',
  @level2type = N'COLUMN', @level2name = N'Last_Modified';
GO

IF EXISTS (
    SELECT * FROM sys.extended_properties 
    WHERE major_id = OBJECT_ID('dbo.Translation_Cache') 
      AND name = 'MS_Description' AND minor_id = 0
)
BEGIN
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Translation_Cache';
END;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for Translation_Cache.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Translation_Cache';
GO

BEGIN TRY
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Translation_Cache',
        @level2type = N'COLUMN', @level2name = N'Language_ID';
END TRY
BEGIN CATCH
END CATCH;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for column Language_ID in Translation_Cache.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Translation_Cache',
  @level2type = N'COLUMN', @level2name = N'Language_ID';
GO

BEGIN TRY
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Translation_Cache',
        @level2type = N'COLUMN', @level2name = N'Content_Type_ID';
END TRY
BEGIN CATCH
END CATCH;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for column Content_Type_ID in Translation_Cache.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Translation_Cache',
  @level2type = N'COLUMN', @level2name = N'Content_Type_ID';
GO

BEGIN TRY
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Translation_Cache',
        @level2type = N'COLUMN', @level2name = N'Translation_Quality';
END TRY
BEGIN CATCH
END CATCH;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for column Translation_Quality in Translation_Cache.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Translation_Cache',
  @level2type = N'COLUMN', @level2name = N'Translation_Quality';
GO

BEGIN TRY
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Translation_Cache',
        @level2type = N'COLUMN', @level2name = N'Engine_ID';
END TRY
BEGIN CATCH
END CATCH;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for column Engine_ID in Translation_Cache.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Translation_Cache',
  @level2type = N'COLUMN', @level2name = N'Engine_ID';
GO

BEGIN TRY
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Translation_Cache',
        @level2type = N'COLUMN', @level2name = N'Model_ID';
END TRY
BEGIN CATCH
END CATCH;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for column Model_ID in Translation_Cache.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Translation_Cache',
  @level2type = N'COLUMN', @level2name = N'Model_ID';
GO

IF EXISTS (
    SELECT * FROM sys.extended_properties 
    WHERE major_id = OBJECT_ID('dbo.Paragraph_Audio') 
      AND name = 'MS_Description' AND minor_id = 0
)
BEGIN
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Paragraph_Audio';
END;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for Paragraph_Audio.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Paragraph_Audio';
GO

BEGIN TRY
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Paragraph_Audio',
        @level2type = N'COLUMN', @level2name = N'Paragraph_ID';
END TRY
BEGIN CATCH
END CATCH;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for column Paragraph_ID in Paragraph_Audio.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Paragraph_Audio',
  @level2type = N'COLUMN', @level2name = N'Paragraph_ID';
GO

BEGIN TRY
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Paragraph_Audio',
        @level2type = N'COLUMN', @level2name = N'Paragraph_Translation_ID';
END TRY
BEGIN CATCH
END CATCH;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for column Paragraph_Translation_ID in Paragraph_Audio.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Paragraph_Audio',
  @level2type = N'COLUMN', @level2name = N'Paragraph_Translation_ID';
GO

BEGIN TRY
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Paragraph_Audio',
        @level2type = N'COLUMN', @level2name = N'Voice_ID';
END TRY
BEGIN CATCH
END CATCH;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for column Voice_ID in Paragraph_Audio.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Paragraph_Audio',
  @level2type = N'COLUMN', @level2name = N'Voice_ID';
GO

BEGIN TRY
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Paragraph_Audio',
        @level2type = N'COLUMN', @level2name = N'Verified';
END TRY
BEGIN CATCH
END CATCH;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for column Verified in Paragraph_Audio.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Paragraph_Audio',
  @level2type = N'COLUMN', @level2name = N'Verified';
GO

BEGIN TRY
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Paragraph_Audio',
        @level2type = N'COLUMN', @level2name = N'Verified_Date';
END TRY
BEGIN CATCH
END CATCH;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for column Verified_Date in Paragraph_Audio.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Paragraph_Audio',
  @level2type = N'COLUMN', @level2name = N'Verified_Date';
GO

BEGIN TRY
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Paragraph_Audio',
        @level2type = N'COLUMN', @level2name = N'Audio_ID';
END TRY
BEGIN CATCH
END CATCH;
GO

EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = N'Description for column Audio_ID in Paragraph_Audio.',
  @level0type = N'SCHEMA', @level0name = N'dbo',
  @level1type = N'TABLE', @level1name = N'Paragraph_Audio',
  @level2type = N'COLUMN', @level2name = N'Audio_ID';
GO

BEGIN TRY
    EXEC sys.sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE', @level1name = N'Paragraph_Audio',
        @level2type = N'COLUMN', @level2name = N'ADD';
END TRY
BEGIN CATCH
END CATCH;
GO

CREATE TABLE Voice_Roles (
    Role_Name NVARCHAR(50) PRIMARY KEY,     -- e.g., 'Header'
    Voice_ID INT FOREIGN KEY REFERENCES Voices(Voice_ID)
);
GO

INSERT INTO FFA.dbo.Voice_Roles (Role_Name, Voice_ID)
SELECT N'Header', Voice_ID FROM FFA.dbo.Voices WHERE Voice_Name = N'en-US-JennyNeural';
GO
INSERT INTO FFA.dbo.Voice_Roles (Role_Name, Voice_ID)
SELECT N'Content', Voice_ID FROM FFA.dbo.Voices WHERE Voice_Name = N'en-US-BrandonNeural';
GO
INSERT INTO FFA.dbo.Voice_Roles (Role_Name, Voice_ID)
SELECT N'Scripture', Voice_ID FROM FFA.dbo.Voices WHERE Voice_Name = N'en-GB-RyanNeural';
GO
INSERT INTO FFA.dbo.Voice_Roles (Role_Name, Voice_ID)
SELECT N'EllenWhite', Voice_ID FROM FFA.dbo.Voices WHERE Voice_Name = N'en-US-NovaTurboMultilingualNeural';
GO
INSERT INTO FFA.dbo.Voice_Roles (Role_Name, Voice_ID)
SELECT N'MaleQuote', Voice_ID FROM FFA.dbo.Voices WHERE Voice_Name = N'en-US-GuyNeural';
GO
INSERT INTO FFA.dbo.Voice_Roles (Role_Name, Voice_ID)
SELECT N'ForeignDefault', Voice_ID FROM FFA.dbo.Voices WHERE Voice_Name = N'en-US-BrandonNeural';
GO


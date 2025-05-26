USE [master];
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = N'API')
BEGIN
    ALTER DATABASE [API] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [API];
END
GO

CREATE DATABASE [API];
GO

USE [API];
GO

-- 🔹 File Store Table
CREATE TABLE dbo.File_Store (
    [File_ID]            INT IDENTITY(1,1) PRIMARY KEY,
    File_Hash            VARCHAR(64) NOT NULL UNIQUE,          -- SHA-256
    [File_Name]          NVARCHAR(255) NOT NULL,
    [File_Size_Bytes]    INT NULL,
    [File_Format]        NVARCHAR(10) NOT NULL DEFAULT 'mp3',
    File_Binary          VARBINARY(MAX) NOT NULL,
    Created_Date         DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    Last_Modified        DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

-- 🔹 Canonical Paragraph Metadata
CREATE TABLE dbo.Paragraph_Content (
    Paragraph_Content_ID INT IDENTITY(1,1) PRIMARY KEY,
    Paragraph_Hash       VARCHAR(64) NOT NULL UNIQUE,          -- SHA-256
    Paragraph_Raw        NVARCHAR(MAX) NOT NULL,
    Article_ID           INT NOT NULL,
    Paragraph_Number     INT NOT NULL,
    Locale_Code          NVARCHAR(10) NOT NULL,
    Content_Type_Name    NVARCHAR(50) NOT NULL,
    Created_Date         DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    Last_Modified        DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

-- 🔹 MP3 Generation Audit Table
CREATE TABLE dbo.Paragraph_MP3_Audit (
    Audit_ID             INT IDENTITY(1,1) PRIMARY KEY,
    Paragraph_Content_ID INT NOT NULL FOREIGN KEY REFERENCES dbo.Paragraph_Content(Paragraph_Content_ID),
    Voice_ID			 INT NULL,
    [File_ID]            INT NOT NULL FOREIGN KEY REFERENCES dbo.File_Store([File_ID]),
    Created_Date         DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    Last_Modified        DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

-- 🔹 Voice Override Map Table
CREATE TABLE dbo.Paragraph_Voice_Overrides (
    Override_ID          INT IDENTITY(1,1) PRIMARY KEY,
    Paragraph_Content_ID INT NOT NULL FOREIGN KEY REFERENCES dbo.Paragraph_Content(Paragraph_Content_ID),
    Voice_ID		     INT NULL,
    Modified_Note        NVARCHAR(255) NULL,
    Modified_Date        DATETIME2 NULL,
    Created_Date         DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

-- 🔹 Trigger to update Modified_Date
CREATE TRIGGER trg_Update_LastModified_Paragraph_Voice_Overrides
ON dbo.Paragraph_Voice_Overrides
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE o
    SET Modified_Date = SYSUTCDATETIME()
    FROM dbo.Paragraph_Voice_Overrides o
    INNER JOIN inserted i ON o.Override_ID = i.Override_ID;
END;
GO

-- 🔹 Indexes for Performance
CREATE UNIQUE INDEX UX_Overrides_Key ON dbo.Paragraph_Voice_Overrides (Paragraph_Content_ID);
CREATE NONCLUSTERED INDEX IX_MP3Audit_Paragraph ON dbo.Paragraph_MP3_Audit (Paragraph_Content_ID);
GO

CREATE TABLE dbo.ChatGPT_Cache (
    ChatGPT_Cache_ID INT IDENTITY(1,1) PRIMARY KEY,
    Prompt NVARCHAR(MAX) NOT NULL,
    Response NVARCHAR(MAX) NULL,
    Created_Date DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    Last_Modified DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

CREATE TRIGGER trg_Update_LastModified_File_Store
ON dbo.File_Store
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE t
    SET Last_Modified = SYSUTCDATETIME()
    FROM dbo.File_Store t
    INNER JOIN inserted i ON t.File_ID = i.File_ID;
END;
GO

CREATE TRIGGER trg_Update_LastModified_Paragraph_Content
ON dbo.Paragraph_Content
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE t
    SET Last_Modified = SYSUTCDATETIME()
    FROM dbo.Paragraph_Content t
    INNER JOIN inserted i ON t.Paragraph_Content_ID = i.Paragraph_Content_ID;
END;
GO

CREATE TRIGGER trg_Update_LastModified_Paragraph_MP3_Audit
ON dbo.Paragraph_MP3_Audit
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE t
    SET Last_Modified = SYSUTCDATETIME()
    FROM dbo.Paragraph_MP3_Audit t
    INNER JOIN inserted i ON t.Audit_ID = i.Audit_ID;
END;
GO

CREATE TRIGGER trg_Update_LastModified_ChatGPT_Cache
ON dbo.ChatGPT_Cache
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE t
    SET Last_Modified = SYSUTCDATETIME()
    FROM dbo.ChatGPT_Cache t
    INNER JOIN inserted i ON t.ChatGPT_Cache_ID = i.ChatGPT_Cache_ID;
END;
GO

CREATE TABLE dbo.Paragraph_MP3_Errors (
    Error_ID INT IDENTITY(1,1) PRIMARY KEY,
    Paragraph_Content_ID INT NOT NULL FOREIGN KEY REFERENCES dbo.Paragraph_Content(Paragraph_Content_ID),
    Voice_ID INT NULL,
    Error_Message NVARCHAR(1000) NOT NULL,
    Error_Source NVARCHAR(100),  -- e.g., 'Azure', 'ChatGPT', 'FileIO'
    Retry_Count INT NOT NULL DEFAULT 0,
    Created_Date DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    Last_Modified DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

-- Filter by article + language
CREATE NONCLUSTERED INDEX IX_ParagraphContent_ArticleLang ON dbo.Paragraph_Content (Article_ID, Locale_Code);
-- MP3 audit filtering by file
CREATE NONCLUSTERED INDEX IX_MP3Audit_File ON dbo.Paragraph_MP3_Audit (File_ID);
-- Voice override filtering by voice ID
CREATE NONCLUSTERED INDEX IX_Overrides_Voice ON dbo.Paragraph_Voice_Overrides (Voice_ID);
GO

CREATE TABLE dbo.Paragraph_Translation_Grades (
    Grade_ID INT IDENTITY(1,1) PRIMARY KEY,
    Paragraph_Content_ID INT NOT NULL,
    Locale_Code NVARCHAR(10) NOT NULL,
    Grade_Score INT NOT NULL, -- 0 = not graded, 1–100
    Grade_Comment NVARCHAR(255),
    Graded_By NVARCHAR(50), -- 'ChatGPT', 'Admin'
    Created_Date DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    Last_Modified DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

CREATE TABLE dbo.Translated_Paragraph_MP3_Audit (
    Audit_ID INT IDENTITY(1,1) PRIMARY KEY,
    Article_ID INT NOT NULL,
    Paragraph_Number INT NOT NULL,
    Locale_Code NVARCHAR(10) NOT NULL,
    Voice_ID INT NULL,  -- Loose link to FFA.dbo.Voices
    File_ID INT NOT NULL FOREIGN KEY REFERENCES dbo.File_Store(File_ID),
    Created_Date DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    Last_Modified DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

CREATE VIEW dbo.Voices AS
SELECT * FROM FFA.dbo.Voices;
GO

CREATE VIEW dbo.Languages AS
SELECT * FROM FFA.dbo.Languages;
GO

CREATE VIEW dbo.Types AS
SELECT * FROM FFA.dbo.Types;
GO

CREATE VIEW dbo.Invalid_Paragraph_Voices AS
SELECT o.Override_ID, o.Voice_ID
FROM dbo.Paragraph_Voice_Overrides o
LEFT JOIN dbo.Voices v ON o.Voice_ID = v.Voice_ID
WHERE o.Voice_ID IS NOT NULL AND v.Voice_ID IS NULL;
GO

CREATE VIEW dbo.Invalid_MP3_File_Refs AS
SELECT a.Audit_ID, a.File_ID
FROM dbo.Paragraph_MP3_Audit a
LEFT JOIN dbo.File_Store f ON a.File_ID = f.File_ID
WHERE f.File_ID IS NULL
UNION
SELECT t.Audit_ID, t.File_ID
FROM dbo.Translated_Paragraph_MP3_Audit t
LEFT JOIN dbo.File_Store f ON t.File_ID = f.File_ID
WHERE f.File_ID IS NULL;
GO

CREATE VIEW dbo.Orphan_Paragraph_Content AS
SELECT p.*
FROM dbo.Paragraph_Content p
LEFT JOIN dbo.Paragraph_MP3_Audit a ON p.Paragraph_Content_ID = a.Paragraph_Content_ID
LEFT JOIN dbo.Paragraph_Voice_Overrides o ON p.Paragraph_Content_ID = o.Paragraph_Content_ID
LEFT JOIN dbo.Paragraph_MP3_Errors e ON p.Paragraph_Content_ID = e.Paragraph_Content_ID
LEFT JOIN dbo.Paragraph_Translation_Grades g ON p.Paragraph_Content_ID = g.Paragraph_Content_ID
WHERE a.Paragraph_Content_ID IS NULL
  AND o.Paragraph_Content_ID IS NULL
  AND e.Paragraph_Content_ID IS NULL
  AND g.Paragraph_Content_ID IS NULL;
GO

CREATE UNIQUE NONCLUSTERED INDEX IX_ParagraphContent_Hash ON dbo.Paragraph_Content (Paragraph_Hash);
GO

CREATE VIEW dbo.Translation_MP3_Progress AS
SELECT
    pc.Article_ID,
    pc.Locale_Code,
    COUNT(DISTINCT pc.Paragraph_Content_ID) AS Total_Paragraphs,
    COUNT(DISTINCT a.Paragraph_Content_ID) AS MP3_Generated,
    COUNT(DISTINCT e.Paragraph_Content_ID) AS MP3_Errors,
    CAST(100.0 * COUNT(DISTINCT a.Paragraph_Content_ID) / NULLIF(COUNT(DISTINCT pc.Paragraph_Content_ID), 0) AS DECIMAL(5,2)) AS Completion_Percent
FROM dbo.Paragraph_Content pc
LEFT JOIN dbo.Paragraph_MP3_Audit a ON pc.Paragraph_Content_ID = a.Paragraph_Content_ID
LEFT JOIN dbo.Paragraph_MP3_Errors e ON pc.Paragraph_Content_ID = e.Paragraph_Content_ID
GROUP BY pc.Article_ID, pc.Locale_Code;
GO

-- 🔹 File_Store Table
EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = 'Stores binary MP3 or other output files with metadata and deduplication hash.',
  @level0type = N'SCHEMA', @level0name = 'dbo',
  @level1type = N'TABLE', @level1name = 'File_Store';
GO

-- 🔹 Paragraph_Content Table
EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = 'Represents the canonical English paragraphs tied to an article and paragraph number. Supports translation and audio generation.',
  @level0type = N'SCHEMA', @level0name = 'dbo',
  @level1type = N'TABLE', @level1name = 'Paragraph_Content';
GO

-- 🔹 Paragraph_MP3_Audit Table
EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = 'Tracks MP3 fragments created for Paragraph_Content rows. Each record links to a File_Store row.',
  @level0type = N'SCHEMA', @level0name = 'dbo',
  @level1type = N'TABLE', @level1name = 'Paragraph_MP3_Audit';
GO

-- 🔹 Voice_ID in Paragraph_MP3_Audit
EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = 'Soft foreign key to FFA.dbo.Voices.Voice_ID. Indicates which voice was used to generate this paragraph MP3.',
  @level0type = N'SCHEMA', @level0name = 'dbo',
  @level1type = N'TABLE',  @level1name = 'Paragraph_MP3_Audit',
  @level2type = N'COLUMN', @level2name = 'Voice_ID';
GO

-- 🔹 Paragraph_Voice_Overrides Table
EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = 'Allows overriding the default voice for a given paragraph prior to MP3 generation.',
  @level0type = N'SCHEMA', @level0name = 'dbo',
  @level1type = N'TABLE', @level1name = 'Paragraph_Voice_Overrides';
GO

-- 🔹 Paragraph_MP3_Errors Table
EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = 'Stores retryable or permanent error logs from MP3 generation processes.',
  @level0type = N'SCHEMA', @level0name = 'dbo',
  @level1type = N'TABLE', @level1name = 'Paragraph_MP3_Errors';
GO

-- 🔹 Translated_Paragraph_MP3_Audit Table
EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = 'Tracks MP3 fragments for translated (non-English) paragraphs by Article_ID and Locale_Code.',
  @level0type = N'SCHEMA', @level0name = 'dbo',
  @level1type = N'TABLE', @level1name = 'Translated_Paragraph_MP3_Audit';
GO

-- 🔹 Paragraph_Translation_Grades Table
EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = 'Stores AI-generated translation quality scores and notes per paragraph and locale.',
  @level0type = N'SCHEMA', @level0name = 'dbo',
  @level1type = N'TABLE', @level1name = 'Paragraph_Translation_Grades';
GO

-- 🔹 ChatGPT_Cache Table
EXEC sys.sp_addextendedproperty
  @name = N'MS_Description',
  @value = 'Caches prompt/response pairs from ChatGPT or other models to avoid redundant API calls.',
  @level0type = N'SCHEMA', @level0name = 'dbo',
  @level1type = N'TABLE', @level1name = 'ChatGPT_Cache';
GO

CREATE VIEW dbo.Valid_Voice_Lookup AS
SELECT Voice_ID, Voice_Name, Engine_Name, Model_Name FROM FFA.dbo.Voices;
GO

-- Trigger: Last_Modified on Paragraph_Translation_Grades
CREATE TRIGGER trg_Paragraph_Translation_Grades_LastModified
ON dbo.Paragraph_Translation_Grades
AFTER UPDATE AS
BEGIN
    SET NOCOUNT ON;
    UPDATE t SET Last_Modified = SYSUTCDATETIME()
    FROM dbo.Paragraph_Translation_Grades t
    INNER JOIN inserted i ON t.Grade_ID = i.Grade_ID;
END;
GO

-- Trigger: Last_Modified on Translated_Paragraph_MP3_Audit
CREATE TRIGGER trg_Translated_Paragraph_MP3_Audit_LastModified
ON dbo.Translated_Paragraph_MP3_Audit
AFTER UPDATE AS
BEGIN
    SET NOCOUNT ON;
    UPDATE t SET Last_Modified = SYSUTCDATETIME()
    FROM dbo.Translated_Paragraph_MP3_Audit t
    INNER JOIN inserted i ON t.Audit_ID = i.Audit_ID;
END;
GO

CREATE NONCLUSTERED INDEX IX_Translated_MP3_File ON dbo.Translated_Paragraph_MP3_Audit (File_ID);
GO

CREATE VIEW vw_Duplicate_File_Hashes AS
	SELECT File_Hash, COUNT(*) AS HashCount
	FROM dbo.File_Store
	GROUP BY File_Hash
	HAVING COUNT(*) > 1;
GO

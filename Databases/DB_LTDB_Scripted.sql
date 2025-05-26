USE [master]
GO
CREATE DATABASE [LTDB]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'LTDB', FILENAME = N'D:\SQL\Data\LTDB.mdf' , SIZE = 599936KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'LTDB_log', FILENAME = N'D:\SQL\Data\LTDB_log.ldf' , SIZE = 3976KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
ALTER DATABASE [LTDB] SET COMPATIBILITY_LEVEL = 150
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [LTDB].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [LTDB] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [LTDB] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [LTDB] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [LTDB] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [LTDB] SET ARITHABORT OFF 
GO
ALTER DATABASE [LTDB] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [LTDB] SET AUTO_SHRINK ON 
GO
ALTER DATABASE [LTDB] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [LTDB] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [LTDB] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [LTDB] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [LTDB] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [LTDB] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [LTDB] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [LTDB] SET  DISABLE_BROKER 
GO
ALTER DATABASE [LTDB] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [LTDB] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [LTDB] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [LTDB] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [LTDB] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [LTDB] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [LTDB] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [LTDB] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [LTDB] SET  MULTI_USER 
GO
ALTER DATABASE [LTDB] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [LTDB] SET DB_CHAINING OFF 
GO
ALTER DATABASE [LTDB] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [LTDB] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [LTDB] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [LTDB] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'LTDB', N'ON'
GO
ALTER DATABASE [LTDB] SET QUERY_STORE = OFF
GO
USE [LTDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Articles_Foreign_Versions](
	[Article_Foreign_Version_ID] [int] IDENTITY(1,1) NOT NULL,
	[Article_Unique_ID] [int] NOT NULL,
	[Language_ID] [int] NOT NULL,
	[Article_Name] [nvarchar](500) NULL,
	[Article_File_Name] [nvarchar](150) NOT NULL,
	[Article_Audio_Link] [nvarchar](150) NULL,
	[Article_Paragraph_Count] [int] NULL,
	[LastModified] [datetime] NULL,
 CONSTRAINT [PK_Articles_Foreign_Versions] PRIMARY KEY CLUSTERED 
(
	[Article_Foreign_Version_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Articles](
	[Article_Unique_ID] [int] IDENTITY(1,1) NOT NULL,
	[Article_Name] [nvarchar](500) NULL,
	[Article_File_Name] [nvarchar](150) NULL,
	[Article_Date] [date] NULL,
	[Article_Image_Location] [nvarchar](150) NULL,
	[Article_Audio_Link] [nvarchar](150) NULL,
	[Article_Found] [bit] NOT NULL,
	[Article_Paragraph_Count] [int] NOT NULL,
	[LastModified] [datetime] NULL,
	[Article_URL] [nvarchar](150) NULL,
 CONSTRAINT [PK_Articles] PRIMARY KEY NONCLUSTERED 
(
	[Article_Unique_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [IX__Articles__Article_Unique_ID] ON [dbo].[Articles]
(
	[Article_Unique_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Languages](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Language_Name] [nvarchar](255) NOT NULL,
	[Language_Abbreviation] [nvarchar](3) NOT NULL,
	[Foreign_Name] [nvarchar](255) NULL,
	[Active] [bit] NOT NULL,
	[LastModified] [datetime] NULL,
 CONSTRAINT [PK_Languages] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view
	[dbo].[view_CodeBuilderData]
as
select
	a.Article_Unique_ID
	,afv.Article_Foreign_Version_ID
	,a.Article_Name
	,a.Article_File_Name as English_File_Name
	,CASE
        WHEN l.Language_Name = 'Wu Chinese' THEN 'Chinese (Wu)'
        WHEN l.Language_Name = 'Mandarin Chinese' THEN 'Chinese (Mandarin)'
        ELSE l.Language_Name 
    END AS [Language]
	,l.Language_Abbreviation as Abbreviation
	,l.Foreign_Name
	,afv.Article_File_Name as Foreign_File_Name
	--,afv.*
	--,a.*
	--,l.*
from
	Articles_Foreign_Versions afv,
	Articles a,
	Languages l
where
	afv.Article_Unique_ID = a.Article_Unique_ID
	and afv.Language_ID = l.ID
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[view_en_Categories_with_Article_PDFs] AS
SELECT 
	LEFT(REPLACE(Article_File_Name, 'R:\Shared\Website Archives\articles\', ''), CHARINDEX('\', REPLACE(Article_File_Name, 'R:\Shared\Website Archives\articles\', '')) - 1) AS Category,
	Article_Date,
	REPLACE(Article_File_Name, '.txt', '.pdf') AS PDF_File_Name
FROM [LTDB].[dbo].[Articles]
WHERE Article_Found = 1 AND LEFT(REPLACE(Article_File_Name, 'R:\Shared\Website Archives\articles\', ''), CHARINDEX('\', REPLACE(Article_File_Name, 'R:\Shared\Website Archives\articles\', '')) - 1) NOT IN ('the_spirit_of_prophecy', 'prophetic_keys')
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Translations](
	[Translation_ID] [int] IDENTITY(1,1) NOT NULL,
	[Article_Unique_ID] [int] NOT NULL,
	[Paragraph_Number] [int] NOT NULL,
	[Language_Abbreviation] [nvarchar](3) NOT NULL,
	[English_Text] [nvarchar](max) NOT NULL,
	[Foreign_Text] [nvarchar](max) NOT NULL,
	[Date_Time] [datetime] NOT NULL,
	[Translation_Error] [bit] NOT NULL,
	[Translation_Failure] [bit] NULL,
	[Translation_Failure_Reason] [nvarchar](max) NULL,
	[Translation_Failure_Level] [smallint] NULL,
 CONSTRAINT [PK_Translations] PRIMARY KEY CLUSTERED 
(
	[Translation_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[view_Translations_Errors] AS
SELECT 
    [Translation_ID],
    T.Article_Unique_ID,
    A.Article_File_Name,
    [Paragraph_Number],
    T.Language_Abbreviation,
    L.Language_Name,
    [English_Text],
    [Foreign_Text],
    [Date_Time],
    [Translation_Error],
    'DEL "' + 
    LEFT(A.Article_File_Name, LEN(A.Article_File_Name) - CHARINDEX('.', REVERSE(A.Article_File_Name))) + 
    '_' + T.Language_Abbreviation + '.*"' AS FileName_With_Lang
FROM 
    [LTDB].[dbo].[Translations] T
    JOIN Languages L ON T.Language_Abbreviation = L.Language_Abbreviation
    JOIN Articles A ON T.Article_Unique_ID = A.Article_Unique_ID
WHERE
    (
        T.Foreign_Text LIKE '! ERROR%' OR
        T.Foreign_Text LIKE 'I''m sorry%' OR
        T.Foreign_Text LIKE 'Sorry%' OR
        T.Foreign_Text LIKE 'Pardon%' OR
		T.Foreign_Text LIKE 'Since%' OR
        -- Translations of "I'm sorry" / "Sorry"
        T.Foreign_Text LIKE 'Lo siento%' OR			-- Spanish
        T.Foreign_Text LIKE 'माफ़ कीजिए%' OR         -- Hindi
        T.Foreign_Text LIKE 'آسف%' OR               -- Arabic
        T.Foreign_Text LIKE 'Ek is jammer%' OR      -- Afrikaans
        T.Foreign_Text LIKE 'Desculpa%' OR          -- Portuguese
        T.Foreign_Text LIKE 'Извините%' OR          -- Russian
        T.Foreign_Text LIKE 'Maaf%' OR              -- Indonesian / Malay
        T.Foreign_Text LIKE 'Es tut mir leid%' OR   -- German
        T.Foreign_Text LIKE 'Je suis désolé%' OR    -- French
        T.Foreign_Text LIKE 'Mi dispiace%' OR       -- Italian
        T.Foreign_Text LIKE 'ごめんなさい%' OR           -- Japanese
        T.Foreign_Text LIKE 'Xin lỗi%' OR               -- Vietnamese
        T.Foreign_Text LIKE 'Üzgünüm%' OR               -- Turkish
        T.Foreign_Text LIKE '죄송합니다%' OR             -- Korean
        T.Foreign_Text LIKE 'ขอโทษ%' OR                 -- Thai
        T.Foreign_Text LIKE 'Omlouvám se%' OR           -- Czech
        T.Foreign_Text LIKE 'Paumanhin%' OR             -- Tagalog
        T.Foreign_Text LIKE '对不起%' OR                 -- Mandarin Chinese
        T.Foreign_Text LIKE 'Îmi pare rău%' OR          -- Romanian
        T.Foreign_Text LIKE 'Undskyld%' OR              -- Danish
        T.Foreign_Text LIKE 'Het spijt me%' OR          -- Dutch
        T.Foreign_Text LIKE 'Sajnálom%' OR              -- Hungarian
        T.Foreign_Text LIKE 'متأسفم%' OR                -- Persian
        T.Foreign_Text LIKE 'Mae’n ddrwg gennyf%' OR    -- Welsh
        T.Foreign_Text LIKE 'Ներողություն%' OR           -- Armenian
        T.Foreign_Text LIKE 'Bağışlayın%' OR            -- Azerbaijani
        T.Foreign_Text LIKE 'Прабачце%' OR              -- Belarusian
        T.Foreign_Text LIKE 'Žao mi je%' OR             -- Bosnian / Croatian
        T.Foreign_Text LIKE 'Съжалявам%' OR             -- Bulgarian
        T.Foreign_Text LIKE 'Ho sento%' OR              -- Catalan
        T.Foreign_Text LIKE 'Vabandust%' OR             -- Estonian
        T.Foreign_Text LIKE 'Anteeksi%' OR              -- Finnish
        T.Foreign_Text LIKE 'Sinto muito%' OR           -- Galician / Portuguese
        T.Foreign_Text LIKE 'Λυπάμαι%' OR               -- Greek
        T.Foreign_Text LIKE 'סליחה%' OR                 -- Hebrew
        T.Foreign_Text LIKE 'Piedod%' OR                -- Latvian
        T.Foreign_Text LIKE 'Fyrirgefðu%' OR            -- Icelandic
        T.Foreign_Text LIKE 'ಕ್ಷಮಿಸಿ%' OR                 -- Kannada
        T.Foreign_Text LIKE 'Кешіріңіз%' OR             -- Kazakh
        T.Foreign_Text LIKE 'Atsiprašau%' OR            -- Lithuanian
        T.Foreign_Text LIKE 'Извини%' OR                -- Macedonian / Serbian
        T.Foreign_Text LIKE 'माफ करा%' OR               -- Marathi
        T.Foreign_Text LIKE 'Aroha mai%' OR             -- Maori
        T.Foreign_Text LIKE 'माफ गर्नुहोस्%' OR             -- Nepali
        T.Foreign_Text LIKE 'Beklager%' OR              -- Norwegian
        T.Foreign_Text LIKE 'Przepraszam%' OR           -- Polish
        T.Foreign_Text LIKE 'Ospravedlňujem sa%' OR     -- Slovak
        T.Foreign_Text LIKE 'Oprosti%' OR               -- Slovenian
        T.Foreign_Text LIKE 'Samahani%' OR              -- Swahili
        T.Foreign_Text LIKE 'Förlåt%' OR                -- Swedish
        T.Foreign_Text LIKE 'மன்னிக்கவும்%' OR         -- Tamil
        T.Foreign_Text LIKE 'Вибачте%' OR               -- Ukrainian
        T.Foreign_Text LIKE 'معاف کرنا%' OR             -- Urdu
        T.Foreign_Text LIKE 'క్షమించండి%' OR             -- Telugu
        T.Foreign_Text LIKE 'Më fal%' OR                -- Albanian
        T.Foreign_Text LIKE 'ይቅርታ%' OR                 -- Amharic
        T.Foreign_Text LIKE 'দুঃখিত%' OR                 -- Bengali
        T.Foreign_Text LIKE 'Barkatu%' OR               -- Basque
        T.Foreign_Text LIKE 'တောင်းပန်ပါတယ်%' OR          -- Burmese
        T.Foreign_Text LIKE 'Digowgh%' OR               -- Cornish
        T.Foreign_Text LIKE 'Fyrirgef mí%' OR           -- Faroese
        T.Foreign_Text LIKE 'Vosoti%' OR                -- Fijian
        T.Foreign_Text LIKE 'ბოდიში%' OR                -- Georgian
        T.Foreign_Text LIKE 'Yi hakuri%' OR             -- Hausa
        T.Foreign_Text LIKE 'Ulaakut%' OR               -- Inuktitut
        T.Foreign_Text LIKE 'Tá brón orm%' OR           -- Irish Gaelic
        T.Foreign_Text LIKE 'Nuwun sewu%' OR            -- Javanese
        T.Foreign_Text LIKE 'សូមអភ័យទោស%' OR           -- Khmer
        T.Foreign_Text LIKE 'Кечиресиз%' OR             -- Kyrgyz
        T.Foreign_Text LIKE 'ຂໍອະໄພ%' OR                 -- Lao
        T.Foreign_Text LIKE 'Ech bedauere%' OR          -- Luxembourgish
        T.Foreign_Text LIKE 'Azafady%' OR               -- Malagasy
        T.Foreign_Text LIKE 'Skużani%' OR               -- Maltese
        T.Foreign_Text LIKE 'Уучлаарай%' OR             -- Mongolian
        T.Foreign_Text LIKE 'ମୁଁ ଦୁଃଖିତ%' OR                -- Odia (Oriya)
        T.Foreign_Text LIKE 'بخښنه غواړم%' OR           -- Pashto
        T.Foreign_Text LIKE 'Pampachaykuway%' OR        -- Quechua
        T.Foreign_Text LIKE 'क्षमास्वस्वरं%' OR               -- Sanskrit
        T.Foreign_Text LIKE 'Tha mi duilich%' OR        -- Scottish Gaelic
        T.Foreign_Text LIKE 'Ke kopa tshwarelo%' OR     -- Sesotho
        T.Foreign_Text LIKE 'معاف ڪجو%' OR              -- Sindhi
        T.Foreign_Text LIKE 'Waan ka xumahay%' OR       -- Somali
        T.Foreign_Text LIKE 'Маъзур%' OR                -- Tajik
        T.Foreign_Text LIKE 'Гафу итегез%' OR           -- Tatar
        T.Foreign_Text LIKE 'Itshwarelo%' OR            -- Tswana
        T.Foreign_Text LIKE 'Kechiring%' OR             -- Uzbek
        T.Foreign_Text LIKE 'بخشایش%' OR                -- Uyghur
        T.Foreign_Text LIKE 'Ndicela uxolo%' OR         -- Xhosa
        T.Foreign_Text LIKE 'Mo banujẹ%' OR             -- Yoruba
        T.Foreign_Text LIKE 'Ngiyaxolisa%'              -- Zulu
    )
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[view_Articles] AS
SELECT
	a.Article_Unique_ID
	,af.Article_Foreign_Version_ID AS Foreign_Article_Unique_ID
	,a.Article_Date
	,a.Article_Name
	,l.Language_Name
	,af.Article_Name AS Foreign_Article_Name
	,a.Article_File_Name
	,af.Article_File_Name AS Foreign_Article_File_Name
	,a.Article_Image_Location
	,a.Article_Audio_Link
	,af.Article_Audio_Link AS Foreign_Article_Audio_Link
	,a.Article_Paragraph_Count
	,af.Article_Paragraph_Count AS Foreign_Article_Paragraph_Count
FROM
	Articles_Foreign_Versions af
	,Articles a
	,Languages l
WHERE
	af.Article_Unique_ID = a.Article_Unique_ID
	AND af.Language_ID = l.ID
	AND a.Article_Found = 1
GO
ALTER TABLE [dbo].[Articles] ADD  CONSTRAINT [DF_Articles_Article_Found]  DEFAULT ((0)) FOR [Article_Found]
GO
ALTER TABLE [dbo].[Articles] ADD  CONSTRAINT [DF_Articles_Article_Paragraph_Count]  DEFAULT ((0)) FOR [Article_Paragraph_Count]
GO
ALTER TABLE [dbo].[Languages] ADD  CONSTRAINT [DF_Languages_Active]  DEFAULT ((0)) FOR [Active]
GO
ALTER TABLE [dbo].[Translations] ADD  CONSTRAINT [DF_Translations_Date_Time]  DEFAULT (getdate()) FOR [Date_Time]
GO
ALTER TABLE [dbo].[Translations] ADD  CONSTRAINT [DF_Translations_Translation_Error]  DEFAULT ((0)) FOR [Translation_Error]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_Backup] as
	-- Define the backup path where you want to save the backup file
	DECLARE @BackupPath NVARCHAR(255)
	SET @BackupPath = 'D:\SQL\Backup\' 
	-- Generate a dynamic backup file name using the current date and time
	DECLARE @BackupFileName NVARCHAR(255)
	SET @BackupFileName = @BackupPath + 'LTDB_' + REPLACE(CONVERT(NVARCHAR(20), GETDATE(), 120), ':', '') + '.BAK'
	-- Perform a full database backup to the generated file name
	BACKUP DATABASE LTDB TO DISK = @BackupFileName
	-- Generate a dynamic backup file name using the current date and time
	DECLARE @BackupFileName2 NVARCHAR(255)
	SET @BackupFileName2 = @BackupPath + 'FFA_' + REPLACE(CONVERT(NVARCHAR(20), GETDATE(), 120), ':', '') + '.BAK'
	-- Perform a full database backup to the generated file name
	BACKUP DATABASE FFA TO DISK = @BackupFileName2
	-- Generate a dynamic backup file name using the current date and time
	DECLARE @BackupFileName3 NVARCHAR(255)
	SET @BackupFileName3 = @BackupPath + 'API_' + REPLACE(CONVERT(NVARCHAR(20), GETDATE(), 120), ':', '') + '.BAK'
	-- Perform a full database backup to the generated file name
	BACKUP DATABASE API TO DISK = @BackupFileName3
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_Cleanup_Duplicate_Translations] AS
	WITH RankedTranslations AS (
		SELECT 
			*,
			ROW_NUMBER() OVER (
				PARTITION BY Article_Unique_ID, Paragraph_Number, Language_Abbreviation
				ORDER BY Date_Time DESC
			) AS RowRank
		FROM dbo.Translations
	)
	DELETE FROM RankedTranslations
	WHERE RowRank > 1
GO
USE [master]
GO
ALTER DATABASE [LTDB] SET  READ_WRITE 
GO

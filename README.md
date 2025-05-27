# FFAWMT
**FFA Website Management Tool**  
A Windows Forms-based C# automation suite for managing English and multilingual article content from WordPress, powered by Microsoft Azure, OpenAI, and SQL Server.

---

## 📌 Overview

The FFAWMT application automates the ingestion, translation, formatting, audio narration, and export of articles from the FFA WordPress site. It is designed for internal use, providing accurate multilingual outputs using a paragraph-level translation and voice synthesis pipeline.

Key Goals:
- Keep multilingual versions of articles in sync with the English source
- Preserve formatting and paragraph breaks throughout all transformations
- Generate accurate TTS voiceovers using dynamic voice profiles
- Produce HTML, PDF, MP3, DOCX, and TXT files for publishing
- Maintain completely data pipeline and log in SQL for later reproduction
- Document long-term future plan
- 

---

## 🧱 Project Structure

```
FFAWMT/
├── AppConfig.cs                       # Loads config/secrets from ffa.json
├── MainForm.cs                        # Windows Forms UI and button handlers
├── Program.cs                         # Entry point
├── Constants.cs                       # All global constants and defaults
├── ParagraphImporter.cs               # Extracts, inserts, and updates paragraph data
├── Mp3Generator.cs                    # Generates MP3 fragments and merges them
├── TTSManager.cs                      # Interfaces with Azure/OpenAI TTS services
├── WordPressAPI.cs                    # Pulls article metadata and content from WordPress
├── ParagraphCleaner.cs                # Classifies paragraph types, cleans HTML
├── HTMLParser.cs                      # Handles inner HTML formatting
├── Databases/                         # SQL schema build scripts
├── README.md                          # Project documentation
```

---

## ⚙️ System Requirements

- Windows OS
- .NET 8 SDK
- Visual Studio 2022 or later
- Microsoft SQL Server 2019 or newer
- Github
- Internet access for API calls
- File share access for logging and output
- 

---

## 🔐 Configuration

Required configuration file:

```
R:\Shared\AppPasswords\ffa.json
```

Example:

```json
{
  "AzureTTSKey": "your-azure-key",
  "AzureRegion": "centralus",
  "SqlConnectionString": "Server=Name,1433;Database=FFA;User Id=sa;Password=...;",
  "OpenAIKey": "sk-...",
  "WordPressURL": "https://website.org/",
  "WordPressAPIBaseURL": "https://website.org/wp-json/wp/v2/posts?status=publish&per_page=100&page=",
  "WordPressAPICategoryURL": "https://website.org/wp-json/wp/v2/categories/",
  "AppLogPath": "R:\\Shared\\AppLog\\",
  "AppMP3FragmentsPath": "R:\\Shared\\Website Archives\\fragments\\",
  "ChatGPTEndpoint": "https://api.openai.com/v1/chat/completions",
  "ChatGPTModel": "gpt-4o"
}
```

---

## 🧭 Menu Options (Console or UI Buttons)

This application was a console application first.  This section will be merged into a feature list later.

| Option | Description | Status |
|--------|------------------------------------------|-------------------|
| 1 | Download WordPress metadata into SQL			| TESTED			|
| 2 | Breakout article paragraphs from stored HTML	| TESTED			|
| C | Clean paragraph records and apply types		| TESTED			|
| 3 | Run Menu Items 1, 2, C						| TESTED			|
| 4 | Generate MP3s (English)						| TODO TESTING MORE	|
| 6 | Translate paragraphs							| NOT WORKING		|
| 7 | Generate MP3s (Foreign)						| NOT WORKING		|
| 9 | Rebuild language `[ShortCode]` JavaScript		| NOT WORKING		|
| X | Exit application								| TESTED			|

---

## 🧠 Core Concepts

### Article Normalization
- Articles are imported from WordPress using a JSON API.
- They are stored in `Articles`, `Articles_Contents`, and `Articles_Translations`.

### Paragraph Processing
- HTML is split into paragraphs using tag-based parsing.
- Each paragraph is stored as raw, cleaned (HTML), and text-only.
- Each line is classified as quote, content, break, header, etc.

### Paragraph Translation
- Translations are run one-by-one by paragraph.
- Azure is used first, then ChatGPT (if retry threshold reached).
- Failures are logged and retried later.
- Each paragraph’s translation includes metadata: engine, model, language, timestamp.

### Voice Generation (MP3s)
- Paragraphs are assigned voices based on:
  - Article version (1 or 2)
  - Paragraph type (e.g., “bible” → British male, “quote” → 1800s woman)
  - Article category
- Voice matches for these rules are stored in `Constants.cs`
- Fragments are saved to: `fragment_{Paragraph_ID}.mp3`
- Fragments are merged into full article MP3s: `article_{Article_ID}.mp3`

---

## 📦 Output Files

- HTML (translated templates)
- TXT / DOCX (cleaned and unformatted versions)
- PDF (rendered from site preview or screenshot)
- MP3 (voiceover, one per article and paragraph)
- JS `[ShortCode]` dropdown config for translated links

All logs are stored under:
```
log_dir\FFA_yyyy-MM-dd_HHmmss.txt
```

---

## 🔁 Retry & Failover Strategy

- Each translation/MP3 operation has a retry limit (default: 3)
- On failure:
  - Translation: Switch from Azure to ChatGPT
  - TTS: Try backup voice or engine
- Errors are logged and linked to specific paragraph IDs in `Articles_Paragraphs_Translated_Errors`
- 

---

## 🎯 Design Principles

- Multi-machine concurrency is supported
- No duplicate translations unless article is updated
- All actions logged in real-time and persisted to disk
- Database schema enforces referential integrity
- Paragraph-level granularity for precise translation/versioning
- MP3 fragments allow for fine-tuned narration updates
- 

---

## 🎯 Overall Problems/Comments For Future Consideration

- When you run Menu option 1, 2, C it is different than just running the 3 which is suppose to do the same.  Consider this.
- Verify that updates to articles are only processed once
- Begin to verify coupled MP3 generated files
- 

---

## 📈 Future Enhancement Plan

- Complete MP3 English testing
- Translate paragraphs feature
- Voice generation for translated paragraphs (Option 7)
- Grading and scoring translation accuracy using AI (ChatGPT verifier)
- UI interface for reviewing and fixing bad translations
- Side-by-side paragraph viewer with language switching
- CLI support: `FFA.exe 1` (for use in Task Scheduler or scripts)
- Advanced translation engine comparison tools
- Language Translation:
	- Bible verse override logic for false-positives
- File-System Sync & Validation:
	- File-to-SQL integrity sync (like LanguageFiles)
	- Auto-deletion of SQL entries when files are removed
	- Line-length validation
	- Known error phrase detection in outputs
- HTML Output:
	- Archive folder structure under /series/lang/...
	- Dynamic population of metadata in HTML (e.g., image, audio)
- MP3 Transcription:
	- Whisper transcription of MP3s (batch/single)
- Evaluation Tools:
	- AI-based translation meaning matching
	- Error phrase scoring
	- Bible verse detection as confirmation
- User Interface Options:
	- MP3 batch from .txt
	- MP3 transcription
	- File anomaly scans
	- Article URL fetch/convert
	- Runtime timeout adjustment
- 
- Historical Book MP3 Creator:
	- Features
		- This is a Windows desktop application designed for archiving, processing, and narrating historical scanned documents. Built for ultra-wide screens and long-term reproducibility, the tool offers structured, operator-driven control over each step of the workflow.
	- Book Management
		- Add scanned PDF books to a searchable, categorized library
		- Store full binary PDF and derived data in SQL Server
		- Prevent duplicate ingestion using SHA-256 hashing
		- View books grouped by user-defined categories
		- 
	- Page Viewing & Editing
		- Ultra-wide, single-form layout with three-panel view:
			- Thumbnail navigation
			- Full-page image viewer
			- Text, voice, and control panel
			- 
		- Support for:
			- Image rotation (90° clockwise)
			- Manual cropping to remove scanner borders or unwanted areas
			- Splitting dual-page scans into two separate pages
			- Dynamic page numbering (with support for negative numbers and renumbering on-the-fly)
			- 
	- OCR Zone Management
		- Default full-page zone or custom drawn rectangular zones
		- Multiple zones per page ordered by drawing sequence
		- Reset and redraw zones at any time
		- Visual overlay with color-coded zone states
		- 
	- OCR & Text Editing
		- Manual “Process Page” or “Process Entire Book” triggers OCR using Tesseract
		- Editable per-zone OCR output with inline feedback
		- Reprocessing a zone will overwrite any previous edits
		- 
	- Voice Assignment & Narration
		- Global default voice setting (Azure or ChatGPT)
		- Per-zone and per-insertion voice overrides
		- Insert custom narration blocks:
			- Before pages
			- After pages
			- Between zones
		- Inline MP3 preview of any zone or narration
		- 
	- Audio Fragment Generation
		- Generate MP3 fragments per zone or insertion
		- Store fragment metadata, hash, and voice selection in the database
		- Reuse unchanged fragments automatically
		- 
	- Final Output Compilation
		- Compile all finalized zones and insertions into a single MP3 per book
		- Output file saved as `Compiled/article_{BookID}.mp3`
		- Optional silence trimming and volume normalization
		- 
	- Batch Actions Panel
		- Process All Pages (OCR unprocessed pages)
		- Reprocess Current Page (overwrite edited text)
		- Regenerate MP3s (only if changed)
		- Reprocess All Pages (force overwrite and audio regeneration)
		- Compile Book Audio (final stitching of all content)
		- 
	- Visual Feedback
		- Status icons and color overlays for:
			- Unprocessed
			- Excluded
			- Needs Review
			- Finalized
			- Custom voice
			- Edited text
			- 
	- Summary
		- This feature is designed for precise, repeatable processing of historical scanned documents into narrated audio — with complete control at each stage.
- 


---

## 📄 License

Developed for internal use.
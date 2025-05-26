# FFAWMT
**FFA Website Management Tool**  
A Windows Forms application for managing and automating multilingual content on the FFA WordPress website.

---

## 📌 Overview

FFAWMT is a C# Windows Forms application designed to:
- Sync published articles from WordPress into a local SQL Server database
- Parse and classify article HTML into structured paragraphs
- Automatically translate content into 95+ languages using Microsoft Azure and/or ChatGPT
- Generate MP3 voiceovers of English and translated paragraphs
- Export files for website integration (HTML, PDF, DOCX, MP3, TXT)
- Manage QA, error logging, and voice selection based on paragraph type and article version
- 

---

## 🧱 Project Structure

```
FFAWMT/
│
├── Databases/                # Database build scripts
├── MainForm.cs               # Windows Forms UI with console emulator
├── AppConfig.cs              # Loads secrets from ffa.json
├── Constants.cs              # Global config and defaults
├── Program.cs                # Entry point, loads MainForm
└── README.md                 # This file
```

---

## ⚙️ Requirements

- **.NET 8 SDK**
- **Visual Studio 2022 or later**
- **SQL Server 2019+**
- Valid credentials for:
  - Microsoft Azure TTS / Translate
  - OpenAI ChatGPT API

---

## 🔐 Configuration

This file location is hard-coded in the code.

Create a JSON file at:

```
R:\Shared\AppPasswords\ffa.json
```

Example content:

```json
{
  "AzureTTSKey": "your-azure-key",
  "AzureRegion": "eastus",
  "SqlConnectionString": "Server=Name,1433;Database=FFA;User Id=sa;Password=yourpass;",
  "OpenAIKey": "your-openai-key",
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

## 🚀 Features

### Menu Actions:
- **[1] Sync WordPress Metadata**  
  Pull latest posts from the WordPress API into SQL

- **[2] Import Article Paragraphs**  
  Convert HTML content into tagged paragraph records

- **[C] Clean Paragraphs**  
  Apply rule-based classification and cleanup

- **[3] Full Reset (1 → 2 → Clean)**  
  Combines steps above in order

- **[4] Create MP3s (English)**  
  Text-to-speech generation with multi-voice handling

---

## 🛠 Developer Notes

- Paragraphs are tagged with type IDs and audio roles
- Failover logic uses Azure first, then ChatGPT, with retry policies
- Voice selection is content-aware and version-dependent
- 

---

## 🧪 Future Features

- Language Translations
- Translated MP3 generation
- Translation QA and quality grading
- PDF and HTML file output for each language
- 

---

## 🧾 License

Internal project for FFA website content generation automation.

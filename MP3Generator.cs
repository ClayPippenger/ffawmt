using System;
using System.Collections.Generic;
using Microsoft.Data.SqlClient;
using System.IO;
using System.Linq;

namespace FFAWMT.Services
{
    public static class Mp3Generator
    {
        public class ParagraphWorkItem
        {
            public int ParagraphID { get; set; }
            public int TranslationID { get; set; }
            public int LanguageID { get; set; }
            public int ParagraphNumber { get; set; }
            public int ContentTypeID { get; set; }
            public string ParagraphRaw { get; set; }
            public string ParagraphClean { get; set; }
            public string ParagraphText { get; set; }
            public int? SeparatorParagraphNumber { get; set; }
            public int? ParagraphCount { get; set; }
            public string WordPressCategory { get; set; }
            public int ArticleID { get; set; }
            public string ArticleName { get; set; }
        }

        public static void Run()
        {
            Logger.Log("[MP3] Starting paragraph queue loader...");

            var items = new List<ParagraphWorkItem>();

            using var connection = new SqlConnection(AppConfig.Current.SqlConnectionString);
            connection.Open();

            var sql = @"
                SELECT
                    p.Paragraph_ID,
                    p.Translation_ID,
                    1 AS Language_ID,
                    p.Paragraph_Number,
                    p.Content_Type_ID,
                    p.Paragraph_Raw,
                    p.Paragraph_Clean,
                    p.Paragraph_Text,
                    t.Separator_Paragraph_Number,
                    t.Paragraph_Count,
                    a.WordPress_Category,
                    a.Article_ID,
                    a.Article_Name
                FROM Articles_Paragraphs p
                JOIN Articles_Translations t ON p.Translation_ID = t.Translation_ID
                JOIN Articles_Contents c ON t.Content_ID = c.Content_ID
                JOIN Articles a ON c.Article_ID = a.Article_ID
                LEFT JOIN Paragraph_Audio pa ON p.Paragraph_ID = pa.Paragraph_ID
                WHERE pa.File_ID IS NULL
                  AND p.Paragraph_Text IS NOT NULL
                  AND LTRIM(RTRIM(p.Paragraph_Text)) <> ''";

            using var cmd = new SqlCommand(sql, connection);
            using var reader = cmd.ExecuteReader();

            while (reader.Read())
            {
                items.Add(new ParagraphWorkItem
                {
                    ParagraphID = reader.GetInt32(0),
                    TranslationID = reader.GetInt32(1),
                    LanguageID = reader.GetInt32(2),
                    ParagraphNumber = reader.GetInt32(3),
                    ContentTypeID = reader.GetInt32(4),
                    ParagraphRaw = reader.IsDBNull(5) ? null : reader.GetString(5),
                    ParagraphClean = reader.IsDBNull(6) ? null : reader.GetString(6),
                    ParagraphText = reader.IsDBNull(7) ? null : reader.GetString(7),
                    SeparatorParagraphNumber = reader.IsDBNull(8) ? null : reader.GetInt32(8),
                    ParagraphCount = reader.IsDBNull(9) ? null : reader.GetInt32(9),
                    WordPressCategory = reader.IsDBNull(10) ? null : reader.GetString(10),
                    ArticleID = reader.GetInt32(11),
                    ArticleName = reader.IsDBNull(12) ? null : reader.GetString(12)
                });
            }
            reader.Close();

            Logger.Log($"[MP3] Queue loaded: {items.Count} paragraph(s) pending audio.");

            var byArticle = items.GroupBy(i => i.ArticleID).OrderBy(g => g.First().ArticleName);
            int articleCount = 0;

            foreach (var group in byArticle)
            {
                var first = group.First();
                Logger.Log($"[MP3] Article_ID: { first.ArticleID} | Name: { first.ArticleName}");

                var sorted = group.OrderBy(i => i.ParagraphNumber).ToList();
                var mergedFiles = new List<string>();

                foreach (var item in sorted)
                {
                    string cleanText = item.ParagraphText ?? item.ParagraphClean ?? item.ParagraphRaw ?? "";
                    var voice = VoiceSelector.GetVoice(item);
                    if (voice == null)
                    {
                        Logger.Log($"⚠️  Voice not found for Paragraph_ID {item.ParagraphID}. Skipping.");
                        continue;
                    }

                    Logger.Log($"🎧 Generating MP3 for Paragraph_ID {item.ParagraphID} | Role: {voice.RoleName}");

                    int? fileId = TTSManager.GenerateAndStoreMp3(connection, item.ParagraphID, cleanText, voice.VoiceId, voice.RoleName);
                    if (fileId == null)
                    {
                        Logger.Log($"❌ Failed to create MP3 for Paragraph_ID {item.ParagraphID}");
                        continue;
                    }

                    var audioCmd = new SqlCommand(@"
                        INSERT INTO FFA.dbo.Paragraph_Audio (Paragraph_ID, Paragraph_Translation_ID, File_ID, Voice_ID)
                        VALUES (@PID, NULL, @FID, @VID);", connection);
                    audioCmd.Parameters.AddWithValue("@PID", item.ParagraphID);
                    audioCmd.Parameters.AddWithValue("@FID", fileId.Value);
                    audioCmd.Parameters.AddWithValue("@VID", voice.VoiceId);
                    audioCmd.ExecuteNonQuery();

                    Logger.Log($"✅ MP3 linked for Paragraph_ID {item.ParagraphID} as File_ID {fileId.Value}");

                    string fragPath = $@"{AppConfig.Current.AppMP3FragmentsPath}fragment_{item.ParagraphID}.mp3";
                    if (File.Exists(fragPath))
                        mergedFiles.Add(fragPath);
                }

                if (mergedFiles.Count > 0)
                {
                    string mergedPath = $@"{AppConfig.Current.AppMP3FragmentsPath}article_{first.ArticleID}.mp3";
                    using var output = File.Create(mergedPath);
                    foreach (var path in mergedFiles)
                    {
                        byte[] bytes = File.ReadAllBytes(path);
                        output.Write(bytes, 0, bytes.Length);
                    }
                    Logger.Log($"📦 Merged article MP3 saved: {mergedPath}");

                    foreach (var path in mergedFiles)
                    {
                        try
                        {
                            File.Delete(path);
                            Logger.Log($"🧹 Deleted fragment: {path}");
                        }
                        catch (Exception ex)
                        {
                            Logger.Log($"[CLEANUP ERROR] Could not delete {path}: {ex.Message}");
                        }
                    }
                }

                articleCount++;
                if (articleCount % 20 == 0)
                {
                    Logger.Log($"[BATCH PAUSE] Completed { articleCount} articles...");
                }
            }

            Logger.Log("[MP3] All done.");
        }
    }
}

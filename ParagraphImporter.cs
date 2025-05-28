using System;
using System.Collections.Generic;
using Microsoft.Data.SqlClient;
using System.Linq;
using System.Text.RegularExpressions;
using HtmlAgilityPack;

namespace FFAWMT.Services
{
    public static class ParagraphImporter
    {
        private static readonly Dictionary<string, string> CharacterReplacements = new()
        {
            { "&#8220;", "\"" },
            { "&#8221;", "\"" },
            { "&#8217;", "'"  },
            { "&#8230;", "..." },
            { "&#8211;", "-"  },
            { "&#8216;", "'"  },
            { "&#8212;", "-"  }
        };

        //public static void Run()
        //{
        //    Logger.Log("[Action] Starting paragraph import process...");
        //    int totalImported = 0;

        //    using (var connection = new SqlConnection(AppConfig.Current.SqlConnectionString))
        //    {
        //        connection.Open();

        //        var selectCmd = new SqlCommand(@"
        //            SELECT c.Content_ID, c.Post_Content
        //            FROM Articles_Contents c
        //            WHERE NOT EXISTS (
        //                SELECT 1 FROM Articles_Paragraphs p
        //                JOIN Articles_Translations t ON p.Translation_ID = t.Translation_ID
        //                WHERE t.Content_ID = c.Content_ID
        //            )", connection);

        //        var itemsToImport = new List<(int ContentID, string Html)>();

        //        using (var reader = selectCmd.ExecuteReader())
        //        {
        //            while (reader.Read())
        //            {
        //                int contentId = reader.GetInt32(0);
        //                string html = reader.IsDBNull(1) ? string.Empty : reader.GetString(1);
        //                itemsToImport.Add((contentId, html));
        //            }
        //        }

        //        foreach (var item in itemsToImport)
        //        {
        //            int contentId = item.ContentID;
        //            string html = item.Html;

        //            var paragraphs = ExtractParagraphs(html);
        //            Logger.Log($"Found {paragraphs.Count} paragraphs for Content_ID {contentId}...");

        //            var insertTranslation = new SqlCommand(@"
        //                INSERT INTO Articles_Translations (Content_ID, Language_ID)
        //                OUTPUT INSERTED.Translation_ID
        //                VALUES (@ContentID, 1)", connection);
        //            insertTranslation.Parameters.AddWithValue("@ContentID", contentId);

        //            int translationId = (int)insertTranslation.ExecuteScalar();

        //            int paragraphNumber = 1;

        //            foreach (var para in paragraphs)
        //            {
        //                string trimmedText = para.TextOnly.Trim();
        //                int typeId = para.TypeID;

        //                if (Regex.IsMatch(trimmedText, "^[\"\'‘’“”]"))
        //                    typeId = GetTypeIdByName("Quote");

        //                try
        //                {
        //                    var insertParagraph = new SqlCommand(@"
        //                        INSERT INTO Articles_Paragraphs
        //                        (Translation_ID, Paragraph_Number, Content_Type_ID, Paragraph_Raw)
        //                        VALUES (@TID, @Num, @TypeID, @Raw)", connection);

        //                    insertParagraph.Parameters.AddWithValue("@TID", translationId);
        //                    insertParagraph.Parameters.AddWithValue("@Num", paragraphNumber++);
        //                    insertParagraph.Parameters.AddWithValue("@TypeID", typeId);
        //                    insertParagraph.Parameters.AddWithValue("@Raw", para.Raw);

        //                    insertParagraph.ExecuteNonQuery();
        //                }
        //                catch (Exception ex)
        //                {
        //                    Logger.Log($"❌ Insert failed at Content_ID {contentId}, Paragraph {paragraphNumber - 1}");
        //                    Logger.Log($"TypeID: {typeId}, Text: {trimmedText.Substring(0, Math.Min(100, trimmedText.Length))}");
        //                    Logger.Log("Error: " + ex.Message);
        //                }
        //            }

        //            totalImported++;
        //        }
        //        //UpdateSeparatorLines(connection);
        //        //UpdateParagraphCounts(connection);
        //        //UpdateTranslatedTitles(connection);
        //    }
        //    Logger.Log($"Paragraph import complete. {totalImported} article(s) processed.");
        //}

        public static List<int> ImportAll()
        {
            var updatedArticleIds = new List<int>();

            var articlesToProcess = GetArticlesToProcess(); // You already have this

            foreach (var article in articlesToProcess)
            {
                if (string.IsNullOrWhiteSpace(article.Post_Content))
                {
                    Logger.Log($"⚠️ Article_ID {article.Id} has empty content. Skipping.");
                    continue;
                }

                int newContentId = ImportArticle(article.Id, article.Post_Content);

                if (newContentId > 0)
                {
                    updatedArticleIds.Add(article.Id);
                }
            }

            return updatedArticleIds;
        }

        private static List<Article> GetArticlesToProcess()
        {
            var articles = new List<Article>();

            using var connection = new SqlConnection(AppConfig.Current.SqlConnectionString);
            connection.Open();

            var command = new SqlCommand(@"
                SELECT 
                    a.Article_ID,
                    t.Translated_Title,
                    c.Post_Content
                FROM Articles a
                JOIN Articles_Contents c ON a.Article_ID = c.Article_ID
                JOIN Articles_Translations t ON t.Content_ID = c.Content_ID
                ", connection);

            using var reader = command.ExecuteReader();
            while (reader.Read())
            {
                articles.Add(new Article
                {
                    Id = reader.GetInt32(0),
                    Title = reader.IsDBNull(1) ? "" : reader.GetString(1),
                    Post_Content = reader.IsDBNull(2) ? "" : reader.GetString(2)
                });
            }

            return articles;
        }

        public static int ImportArticle(int articleId, string postContentHtml)
        {
            using var connection = new SqlConnection(AppConfig.Current.SqlConnectionString);
            connection.Open();

            Logger.Log($"📥 Importing Article_ID {articleId}");

            // 1. Insert new Articles_Contents
            var insertContentCmd = new SqlCommand(@"
        INSERT INTO Articles_Contents (Article_ID, Post_Content, Created_Date)
        OUTPUT INSERTED.Content_ID
        VALUES (@ArticleID, @Content, GETDATE())", connection);

            insertContentCmd.Parameters.AddWithValue("@ArticleID", articleId);
            insertContentCmd.Parameters.AddWithValue("@Content", postContentHtml);
            int contentId = Convert.ToInt32(insertContentCmd.ExecuteScalar());

            Logger.Log($"📄 Inserted new content record: Content_ID = {contentId}");


            Logger.Log("🧩 Inserting English paragraphs for new content...");

            var paragraphs = ExtractParagraphs(postContentHtml);

            var insertEnglishTranslation = new SqlCommand(@"
    INSERT INTO Articles_Translations (Content_ID, Language_ID)
    OUTPUT INSERTED.Translation_ID
    VALUES (@ContentID, 1)", connection);
            insertEnglishTranslation.Parameters.AddWithValue("@ContentID", contentId);
            int translationId = (int)insertEnglishTranslation.ExecuteScalar();

            int paragraphNumber = 1;
            foreach (var para in paragraphs)
            {
                string trimmedText = para.TextOnly.Trim();
                int typeId = para.TypeID;

                if (Regex.IsMatch(trimmedText, "^[\"\'‘’“”]"))
                    typeId = GetTypeIdByName("Quote");

                var insertParagraph = new SqlCommand(@"
        INSERT INTO Articles_Paragraphs
        (Translation_ID, Paragraph_Number, Content_Type_ID, Paragraph_Raw)
        VALUES (@TID, @Num, @TypeID, @Raw)", connection);

                insertParagraph.Parameters.AddWithValue("@TID", translationId);
                insertParagraph.Parameters.AddWithValue("@Num", paragraphNumber++);
                insertParagraph.Parameters.AddWithValue("@TypeID", typeId);
                insertParagraph.Parameters.AddWithValue("@Raw", para.Raw);

                insertParagraph.ExecuteNonQuery();
            }

            Logger.Log("📄 Inserted English paragraphs for new content...");


            // 2. Load all active languages
            var languages = new List<int>();
            var getLanguagesCmd = new SqlCommand("SELECT Language_ID FROM Languages WHERE Active = 1 AND Language_ID IN (1)", connection); // TODO Modify to allow <> English
            using (var reader = getLanguagesCmd.ExecuteReader())
            {
                while (reader.Read())
                    languages.Add(reader.GetInt32(0));
            }

            // 3. Insert translations for all languages (for this content)
            int insertedCount = 0;
            foreach (int languageId in languages)
            {
                // Check if translation already exists for this Content_ID + Language_ID
                var checkCmd = new SqlCommand(@"
            SELECT COUNT(*) FROM Articles_Translations
            WHERE Content_ID = @ContentID AND Language_ID = @LangID", connection);

                checkCmd.Parameters.AddWithValue("@ContentID", contentId);
                checkCmd.Parameters.AddWithValue("@LangID", languageId);
                int existing = Convert.ToInt32(checkCmd.ExecuteScalar());

                if (existing == 0)
                {
                    var insertTranslationCmd = new SqlCommand(@"
                INSERT INTO Articles_Translations (Content_ID, Language_ID)
                VALUES (@ContentID, @LangID)", connection);

                    insertTranslationCmd.Parameters.AddWithValue("@ContentID", contentId);
                    insertTranslationCmd.Parameters.AddWithValue("@LangID", languageId);
                    insertTranslationCmd.ExecuteNonQuery();
                    insertedCount++;
                }
            }

            Logger.Log($"🌐 {insertedCount} translation records created for Content_ID {contentId}.");

            return contentId;
        }

        private class Article
        {
            public int Id { get; set; }
            public string Title { get; set; }
            public string Post_Content { get; set; } // Add this to support re-import
        }

        public static int UpdateEnglishTitlesInArticlesTranslations()
        {
            //Logger.Log("Updating English titles in Articles_Translations...");

            using (var connection = new SqlConnection(AppConfig.Current.SqlConnectionString))
            {
                connection.Open();
                var command = new SqlCommand(@"
                    UPDATE t
                    SET Translated_Title = a.Article_Name
                    FROM Articles_Translations t
                    JOIN Articles_Contents c ON t.Content_ID = c.Content_ID
                    JOIN Articles a ON c.Article_ID = a.Article_ID
                    WHERE t.Language_ID = 1 AND (t.Translated_Title IS NULL OR t.Translated_Title = '');", connection);
                int rows = command.ExecuteNonQuery();

                Logger.Log($"Updated {rows} English titles in Articles_Translations...");

                return rows;
            }
        }

        public static int UpdateEnglishParagraphCountsInArticlesTranslations()
        {
            using (var connection = new SqlConnection(AppConfig.Current.SqlConnectionString))
            {
                connection.Open();
                int totalUpdated = 0;

                // Update article translation paragraph counts
                Logger.Log("Updating paragraph counts for article translations...");
                var cmd1 = new SqlCommand(@"
                    UPDATE t
                    SET Paragraph_Count = p.ParaCount
                    FROM Articles_Translations t
                    JOIN (
                        SELECT p.Translation_ID, COUNT(*) AS ParaCount
                        FROM Articles_Paragraphs p
                        JOIN Articles_Translations t2 ON p.Translation_ID = t2.Translation_ID
                        WHERE t2.Language_ID = 1
                        GROUP BY p.Translation_ID
                    ) p ON t.Translation_ID = p.Translation_ID
                    WHERE t.Language_ID = 1 AND ISNULL(t.Paragraph_Count, -1) <> p.ParaCount;", connection);

                int updatedTranslations = cmd1.ExecuteNonQuery();
                Logger.Log($"✔️ Updated paragraph counts for {updatedTranslations} English translations.");
                totalUpdated += updatedTranslations;

                Logger.Log($"Updated {totalUpdated} English paragraph counts in Articles_Translations...");

                return totalUpdated;
            }
        }

        public static int UpdateCleanAndTextForSeparatorLines()
        {
            //Logger.Log("Updating Paragraph_Clean and Paragraph_Text for Separator Lines in Articles_Paragraphs.");

            using (var connection = new SqlConnection(AppConfig.Current.SqlConnectionString))
            {
                connection.Open();
                var command = new SqlCommand(@"
                    UPDATE p
                    SET 
                        p.Paragraph_Clean = '',
                        p.Paragraph_Text = '',
                        p.Content_Type_ID = t.Type_ID
                    FROM Articles_Paragraphs p
                    JOIN Types t ON t.Type_Name = 'Separator'
                    WHERE 
                        LTRIM(RTRIM(p.Paragraph_Raw)) LIKE '%~~~%' 
                        AND p.Paragraph_Clean IS NULL 
                        AND p.Paragraph_Text IS NULL;", connection);

                int rows = command.ExecuteNonQuery();

                Logger.Log($"Updated {rows} Paragraph_Clean and Paragraph_Text for Separator Lines in Articles_Paragraphs.");

                return rows;
            }
        }

        public static int UpdateEnglishSeparatorParagraphNumber()
        {
            //Logger.Log("Updating English separator paragraph number positions (~~~)...");

            using (var connection1 = new SqlConnection(AppConfig.Current.SqlConnectionString))
            {
                connection1.Open();
                var command1 = new SqlCommand(@"
                    UPDATE t
                    SET Separator_Paragraph_Number = m.Separator_Paragraph_Number
                    FROM Articles_Translations t
                    JOIN (
                        SELECT
                            p.Translation_ID,
                            MIN(p.Paragraph_Number) AS Separator_Paragraph_Number
                        FROM Articles_Paragraphs p
                        JOIN Articles_Translations t2 ON p.Translation_ID = t2.Translation_ID
                        WHERE t2.Language_ID = 1
                          AND LTRIM(RTRIM(p.Paragraph_Raw)) LIKE '%~~~%'
                        GROUP BY p.Translation_ID
                    ) m ON t.Translation_ID = m.Translation_ID
                    WHERE t.Language_ID = 1 AND t.Separator_Paragraph_Number IS NULL;", connection1);

                int rows = command1.ExecuteNonQuery();

                Logger.Log($"Updated {rows} English separator paragraph number positions (~~~).");

                return rows;
            }
        }

        private static List<ParagraphBlock> ExtractParagraphs(string html)
        {
            var list = new List<ParagraphBlock>();
            var doc = new HtmlDocument();
            doc.LoadHtml(html);

            var allNodes = doc.DocumentNode.Descendants()
                .Where(n => n.Name is "li" or "p" or "h1" or "h2" or "h3" or "h4" or "h5" or "h6" or "blockquote" ||
                            (n.Name == "div" && n.GetAttributeValue("style", "").Contains("padding-left")) ||
                            (n.Name == "span" && n.GetAttributeValue("style", "").Contains("padding-left")))
                .Where(n => n.NodeType == HtmlNodeType.Element)
                .ToList();

            foreach (var node in allNodes)
            {
                if (node.Name is "script" or "form" or "audio") continue;

                string raw = node.OuterHtml.Trim();
                string textOnly = Regex.Replace(node.InnerText.Trim(), "\\s+", " ");
                if (string.IsNullOrWhiteSpace(textOnly) && !raw.Contains("&nbsp;")) continue;

                int typeId = 1;
                if (node.Name == "li")
                {
                    int level = Math.Min(node.Ancestors("li").Count() + 1, 7);
                    string typeName = $"List Item Level {level}";
                    typeId = GetTypeIdByName(typeName);

                    var cloned = node.Clone();
                    foreach (var nested in cloned.SelectNodes("./ul|./ol") ?? Enumerable.Empty<HtmlNode>())
                        nested.Remove();
                    raw = cloned.OuterHtml.Trim().Replace("\r", "").Replace("\n", "");
                    textOnly = Regex.Replace(cloned.InnerText.Trim(), "\\s+", " ");
                }
                else if (Regex.IsMatch(raw, "padding-left:\\s*(\\d+)px", RegexOptions.IgnoreCase))
                {
                    typeId = GetTypeIdByName("Content Indented");
                }
                else if (string.IsNullOrWhiteSpace(textOnly) && raw.Contains("&nbsp;"))
                {
                    typeId = GetTypeIdByName("Break");
                }

                string cleaned = SanitizeHtmlForTranslation(node);

                list.Add(new ParagraphBlock
                {
                    Raw = raw,
                    Cleaned = cleaned,
                    TextOnly = textOnly,
                    TypeID = typeId
                });
            }

            return list;
        }

        private static string SanitizeHtmlForTranslation(HtmlNode node)
        {
            var html = node.OuterHtml;
            html = html.Replace("&nbsp;", " ");
            html = System.Net.WebUtility.HtmlDecode(html);
            html = html.Replace(" ", "&nbsp;");
            return html.Trim();
        }

        private static int GetTypeIdByName(string typeName)
        {
            using var connection = new SqlConnection(AppConfig.Current.SqlConnectionString);
            connection.Open();
            var cmd = new SqlCommand("SELECT Type_ID FROM Types WHERE Type_Name = @Name", connection);
            cmd.Parameters.AddWithValue("@Name", typeName);
            var result = cmd.ExecuteScalar();
            return result != null ? Convert.ToInt32(result) : 1;
        }

        private class ParagraphBlock
        {
            public string Raw { get; set; }
            public string Cleaned { get; set; }
            public string TextOnly { get; set; }
            public int TypeID { get; set; }
        }
    }
}

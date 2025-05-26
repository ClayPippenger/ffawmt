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

        private static string NormalizeSmartCharacters(string html)
        {
            string result = html;
            foreach (var pair in CharacterReplacements)
            {
                result = result.Replace(pair.Key, pair.Value);
                result = result.Replace(System.Net.WebUtility.HtmlDecode(pair.Key), pair.Value);
            }
            return result;
        }

        public static void Run()
        {
            Console.WriteLine("Starting paragraph import process...");
            int totalImported = 0;

            using (var connection = new SqlConnection(AppConfig.Current.SqlConnectionString))
            {
                connection.Open();

                var selectCmd = new SqlCommand(@"
                    SELECT c.Content_ID, c.Post_Content
                    FROM Articles_Contents c
                    WHERE NOT EXISTS (
                        SELECT 1 FROM Articles_Paragraphs p
                        JOIN Articles_Translations t ON p.Translation_ID = t.Translation_ID
                        WHERE t.Content_ID = c.Content_ID
                    )", connection);

                var itemsToImport = new List<(int ContentID, string Html)>();

                using (var reader = selectCmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        int contentId = reader.GetInt32(0);
                        string html = reader.IsDBNull(1) ? string.Empty : reader.GetString(1);
                        itemsToImport.Add((contentId, html));
                    }
                }

                foreach (var item in itemsToImport)
                {
                    int contentId = item.ContentID;
                    string html = item.Html;

                    var paragraphs = ExtractParagraphs(html);
                    Console.WriteLine($"Found {paragraphs.Count} paragraphs for Content_ID {contentId}...");

                    var insertTranslation = new SqlCommand(@"
                        INSERT INTO Articles_Translations (Content_ID, Language_ID)
                        OUTPUT INSERTED.Translation_ID
                        VALUES (@ContentID, 1)", connection);
                    insertTranslation.Parameters.AddWithValue("@ContentID", contentId);

                    int translationId = (int)insertTranslation.ExecuteScalar();

                    int paragraphNumber = 1;

                    foreach (var para in paragraphs)
                    {
                        string trimmedText = para.TextOnly.Trim();
                        int typeId = para.TypeID;

                        if (Regex.IsMatch(trimmedText, "^[\"\'‘’“”]"))
                            typeId = GetTypeIdByName("Quote");

                        try
                        {
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
                        catch (Exception ex)
                        {
                            Console.WriteLine($"❌ Insert failed at Content_ID {contentId}, Paragraph {paragraphNumber - 1}");
                            Console.WriteLine($"TypeID: {typeId}, Text: {trimmedText.Substring(0, Math.Min(100, trimmedText.Length))}");
                            Console.WriteLine("Error: " + ex.Message);
                        }
                    }

                    totalImported++;
                }
                UpdateSeparatorLines(connection);
                UpdateParagraphCounts(connection);
                UpdateTranslatedTitles(connection);
            }
            Console.WriteLine($"Paragraph import complete. {totalImported} article(s) processed.");
        }

        private static void UpdateTranslatedTitles(SqlConnection connection)
        {
            Console.WriteLine("Updating translated titles...");

            var cmd = new SqlCommand(@"
                UPDATE t
                SET Translated_Title = a.Article_Name
                FROM Articles_Translations t
                JOIN Articles_Contents c ON t.Content_ID = c.Content_ID
                JOIN Articles a ON c.Article_ID = a.Article_ID
                WHERE t.Language_ID = 1
                  AND (t.Translated_Title IS NULL OR t.Translated_Title = '');
                ", connection);

            int updated = cmd.ExecuteNonQuery();
            Console.WriteLine($"✔️ Updated translated titles for {updated} English translations.");
        }

        private static void UpdateParagraphCounts(SqlConnection connection)
        {
            Console.WriteLine("Updating paragraph counts...");

            var cmd = new SqlCommand(@"
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
                WHERE t.Language_ID = 1;
                ", connection);

            int updated = cmd.ExecuteNonQuery();
            Console.WriteLine($"✔️ Updated paragraph counts for {updated} English translations.");
        }

        private static void UpdateSeparatorLines(SqlConnection connection)
        {
            Console.WriteLine("Updating separator paragraph numbers (~~~)...");

            // First, get all Translation_IDs for English articles
            var cmd = new SqlCommand(@"
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
                WHERE t.Language_ID = 1;
                ", connection);

            int updated = cmd.ExecuteNonQuery();
            Console.WriteLine($"✔️ Updated separator lines for {updated} English translations.");
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

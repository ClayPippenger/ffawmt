using System;
using System.Collections.Generic;
using Microsoft.Data.SqlClient;
using System.Linq;
using System.Text.RegularExpressions;
using HtmlAgilityPack;

namespace FFAWMT.Services
{
    public static class ParagraphCleaner
    {
        private static readonly Dictionary<string, Func<string, string>> TransformMap = new()
        {
            ["strippatag"] = StripOuterPTagPreservingInnerHtml,
            ["striphtml"] = html => Regex.Replace(html, "<.*?>", "").Trim(),
            ["decodehtml"] = html => System.Net.WebUtility.HtmlDecode(html),
            ["trim"] = html => html.Trim(),
            ["lowercase"] = html => html.ToLowerInvariant(),
            ["striptags_ul_li"] = StripUlLiTags,
            ["stripblockquoteptag"] = StripBlockquotePTag,
            ["removepunctuation"] = html => Regex.Replace(html, @"[^\w\s]", "").Trim(),
        };

        private static string StripBlockquotePTag(string html)
        {
            if (string.IsNullOrWhiteSpace(html)) return html;

            var doc = new HtmlDocument();
            doc.LoadHtml(html);

            var blockquote = doc.DocumentNode.SelectSingleNode("//blockquote");
            if (blockquote == null)
                return html;

            var innerHtmlParts = new List<string>();

            foreach (var child in blockquote.ChildNodes)
            {
                if (child.NodeType == HtmlNodeType.Element && (child.Name == "p" || child.Name == "div" || child.Name == "span"))
                {
                    innerHtmlParts.Add(child.InnerHtml.Trim());
                }
                else if (child.NodeType == HtmlNodeType.Text)
                {
                    innerHtmlParts.Add(child.InnerText.Trim());
                }
            }

            return string.Join(" ", innerHtmlParts.Where(x => !string.IsNullOrWhiteSpace(x)));
        }


        private static string StripUlLiTags(string html)
        {
            if (string.IsNullOrWhiteSpace(html)) return html;

            var doc = new HtmlDocument();
            doc.LoadHtml(html);

            // Unwrap all <ul> and <li> tags, flatten content
            var textParts = new List<string>();

            void ExtractText(HtmlNode node)
            {
                if (node.Name == "li" || node.Name == "ul")
                {
                    foreach (var child in node.ChildNodes)
                        ExtractText(child);
                }
                else if (node.NodeType == HtmlNodeType.Text || node.Name == "span" || node.Name == "b" || node.Name == "i" || node.Name == "em" || node.Name == "strong")
                {
                    textParts.Add(node.InnerText.Trim());
                }
                else
                {
                    textParts.Add(node.InnerText.Trim());
                }
            }

            foreach (var node in doc.DocumentNode.ChildNodes)
                ExtractText(node);

            return string.Join(" ", textParts.Where(x => !string.IsNullOrWhiteSpace(x)));
        }

        public static void Run()
        {
            Console.WriteLine("Starting paragraph clean and text extraction process...");

            using var connection = new SqlConnection(AppConfig.Current.SqlConnectionString);
            connection.Open();

            var rules = LoadRules(); // sorted by Priority

            var selectCmd = new SqlCommand(@"
        SELECT Paragraph_ID, Paragraph_Raw 
        FROM Articles_Paragraphs 
        WHERE Paragraph_Clean IS NULL OR Paragraph_Text IS NULL", connection);

            var paragraphToTranslationMap = new Dictionary<int, int>();
            var paragraphToTypeId = new Dictionary<int, int>();

            using (var preloadTypesCmd = new SqlCommand("SELECT Paragraph_ID, Content_Type_ID FROM Articles_Paragraphs", connection))
            using (var preloadTypeReader = preloadTypesCmd.ExecuteReader())
            {
                while (preloadTypeReader.Read())
                {
                    int pid = preloadTypeReader.GetInt32(0);
                    int typeId = preloadTypeReader.GetInt32(1);
                    paragraphToTypeId[pid] = typeId;
                }
            }

            using var reader = selectCmd.ExecuteReader();
            var updates = new List<(int ParagraphID, string Raw, string Cleaned, string TextOnly, int? TypeID)>();
            var firstH6Seen = new HashSet<int>(); // For Rule: General H6 Title

            while (reader.Read())
            {
                int id = reader.GetInt32(0);
                string raw = reader.IsDBNull(1) ? string.Empty : reader.GetString(1);
                int currentTypeId = paragraphToTypeId.TryGetValue(id, out var knownType) ? knownType : 1;

                string cleaned = raw;
                var htmlDoc = new HtmlDocument();
                htmlDoc.LoadHtml(raw);
                var node = htmlDoc.DocumentNode;
                string defaultCleaned = SanitizeHtmlForTranslation(node);
                string textOnly = Regex.Replace(node.InnerText.Trim(), @"\s+", " ");

                int? typeId = null;

                foreach (var rule in rules)
                {
                    bool matched = rule.MatchType == "Contains"
                        ? raw.Contains(rule.MatchValue, StringComparison.OrdinalIgnoreCase)
                        : Regex.IsMatch(raw, rule.MatchValue, RegexOptions.IgnoreCase);

                    if (!matched) continue;

                    if (rule.RuleName == "General H6 Title" || rule.RuleName == "Sub Title (H6)")
                    {
                        int tid = paragraphToTranslationMap.TryGetValue(id, out var tempTid) ? tempTid : 0;

                        if (rule.RuleName == "General H6 Title")
                        {
                            if (firstH6Seen.Contains(tid)) continue;
                            firstH6Seen.Add(tid);
                        }
                        else if (rule.RuleName == "Sub Title (H6)")
                        {
                            if (!firstH6Seen.Contains(tid)) continue;
                        }
                    }

                    if (!string.IsNullOrWhiteSpace(rule.ContentTypeName) && typeId == null)
                        typeId = EnsureTypeExists(rule.ContentTypeName);

                    if (rule.CleanOutput != null)
                        cleaned = rule.CleanOutput == string.Empty ? "" : rule.CleanOutput;

                    if (rule.TextOutput != null)
                        textOnly = rule.TextOutput == string.Empty ? "" : rule.TextOutput;

                    if (!string.IsNullOrWhiteSpace(rule.TransformType))
                    {
                        if (typeId == null || currentTypeId == 1)
                        {
                            var transformKey = rule.TransformType.Trim().ToLower();
                            if (TransformMap.TryGetValue(transformKey, out var transformFunc))
                            {
                                cleaned = transformFunc.Invoke(cleaned);
                                textOnly = transformFunc.Invoke(textOnly);
                            }
                        }
                    }

                    // no break; rules are chained
                }

                updates.Add((id, raw, cleaned, textOnly, typeId));
            }
            reader.Close();

            foreach (var (id, raw, cleaned, textOnly, typeId) in updates)
            {
                var updateCmd = new SqlCommand(@"
            UPDATE Articles_Paragraphs
            SET Paragraph_Clean = @Cleaned,
                Paragraph_Text = @TextOnly" +
                        (typeId.HasValue ? ", Content_Type_ID = @TypeID" : "") +
                    " WHERE Paragraph_ID = @ID", connection);

                updateCmd.Parameters.AddWithValue("@Cleaned", cleaned);
                updateCmd.Parameters.AddWithValue("@TextOnly", textOnly);
                updateCmd.Parameters.AddWithValue("@ID", id);
                if (typeId.HasValue)
                    updateCmd.Parameters.AddWithValue("@TypeID", typeId.Value);

                updateCmd.ExecuteNonQuery();
            }

            Console.WriteLine("Paragraph cleaning complete.");
        }

        private static int GetExistingTypeId(int paragraphId, SqlConnection conn)
        {
            using var cmd = new SqlCommand("SELECT Content_Type_ID FROM Articles_Paragraphs WHERE Paragraph_ID = @ID", conn);
            cmd.Parameters.AddWithValue("@ID", paragraphId);
            var result = cmd.ExecuteScalar();
            return result != null ? Convert.ToInt32(result) : 1; // assume 1 = default if null
        }

        private static string SanitizeHtmlForTranslation(HtmlNode node)
        {
            var html = node.OuterHtml;
            html = html.Replace("&nbsp;", " ");
            html = System.Net.WebUtility.HtmlDecode(html);
            html = html.Replace(" ", "&nbsp;");
            return html.Trim();
        }

        private static string StripOuterPTagPreservingInnerHtml(string html)
        {
            if (string.IsNullOrWhiteSpace(html)) return html;

            var doc = new HtmlDocument();
            doc.LoadHtml(html);

            var node = doc.DocumentNode.FirstChild;
            if (node == null) return html;

            // These are the tags you want to strip the outer wrapper from
            var allowedTags = new[] { "p", "h6", "li" };

            return allowedTags.Contains(node.Name.ToLower())
                ? node.InnerHtml.Trim()
                : html;
        }

        private static int EnsureTypeExists(string typeName)
        {
            using var conn = new SqlConnection(AppConfig.Current.SqlConnectionString);
            conn.Open();

            var selectCmd = new SqlCommand("SELECT Type_ID FROM Types WHERE Type_Name = @Name", conn);
            selectCmd.Parameters.AddWithValue("@Name", typeName);
            var result = selectCmd.ExecuteScalar();
            if (result != null) return Convert.ToInt32(result);

            var insertCmd = new SqlCommand("INSERT INTO Types (Type_Name, Active) OUTPUT INSERTED.Type_ID VALUES (@Name, 1)", conn);
            insertCmd.Parameters.AddWithValue("@Name", typeName);
            return Convert.ToInt32(insertCmd.ExecuteScalar());
        }

        private static List<CleaningRule> LoadRules()
        {
            var rules = new List<CleaningRule>();
            using var connection = new SqlConnection(AppConfig.Current.SqlConnectionString);
            connection.Open();
            using var cmd = new SqlCommand(@"
                SELECT Rule_Name, Match_Type, Match_Value,
                       Clean_Output, Text_Output, Content_Type_Name,
                       Transform_Type, Priority, Allow_Chain, Log_Only
                FROM Paragraph_Cleaning_Rules
                WHERE Active = 1
                ORDER BY Priority, Rule_ID", connection);

            using var reader = cmd.ExecuteReader();
            while (reader.Read())
            {
                rules.Add(new CleaningRule
                {
                    RuleName = reader.GetString(0),
                    MatchType = reader.GetString(1),
                    MatchValue = reader.GetString(2),
                    CleanOutput = reader.IsDBNull(3) ? null : reader.GetString(3),
                    TextOutput = reader.IsDBNull(4) ? null : reader.GetString(4),
                    ContentTypeName = reader.IsDBNull(5) ? null : reader.GetString(5),
                    TransformType = reader.IsDBNull(6) ? null : reader.GetString(6),
                    Priority = reader.GetInt32(7),
                    AllowChain = reader.GetBoolean(8),
                    LogOnly = reader.GetBoolean(9)
                });
            }
            return rules;
        }

        private class CleaningRule
        {
            public string RuleName { get; set; }
            public string MatchType { get; set; }
            public string MatchValue { get; set; }
            public string CleanOutput { get; set; }
            public string TextOutput { get; set; }
            public string ContentTypeName { get; set; }
            public string TransformType { get; set; }
            public int Priority { get; set; }
            public bool AllowChain { get; set; }
            public bool LogOnly { get; set; }
        }
    }
}

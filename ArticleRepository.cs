using System;
using Microsoft.Data.SqlClient;
using System.Linq;
using FFAWMT.Models;

namespace FFAWMT.Data
{
    public static class ArticleRepository
    {
        private static string ConnectionString => AppConfig.Current.SqlConnectionString;

        public static void ProcessPost(WordPressPost post, string category)
        {
            string slug = post.slug.Trim('/');
            bool matchFound = false;

            using (var connection = new SqlConnection(ConnectionString))
            {
                connection.Open();

                var findCmd = new SqlCommand(@"
                    SELECT Article_ID, WordPress_Last_Modified, Article_URL
                    FROM Articles
                    WHERE Article_URL IS NOT NULL", connection);

                using (var reader = findCmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        int articleId = reader.GetInt32(0);
                        DateTime? existingModified = reader.IsDBNull(1) ? null : reader.GetDateTime(1);
                        string articleUrl = reader.IsDBNull(2) ? null : reader.GetString(2);

                        string dbSlug = articleUrl?.Trim('/').Split('/').LastOrDefault();

                        if (dbSlug != null && dbSlug.Equals(slug, StringComparison.OrdinalIgnoreCase))
                        {
                            matchFound = true;
                            reader.Close();

                            if (!existingModified.HasValue || post.modified > existingModified.Value)
                            {
                                var updateCmd = new SqlCommand(@"
                                    UPDATE Articles
                                    SET WordPress_ID = @WordPressID,
                                        WordPress_Slug = @Slug,
                                        WordPress_Last_Modified = @Modified,
                                        WordPress_Category = @Category
                                    WHERE Article_ID = @ArticleID", connection);

                                updateCmd.Parameters.AddWithValue("@WordPressID", post.id);
                                updateCmd.Parameters.AddWithValue("@Slug", slug);
                                updateCmd.Parameters.AddWithValue("@Modified", post.modified);
                                updateCmd.Parameters.AddWithValue("@Category", category);
                                updateCmd.Parameters.AddWithValue("@ArticleID", articleId);

                                updateCmd.ExecuteNonQuery();
                                Console.WriteLine($"Updated article: {slug}");


                                // Ensure Type 'WordPress' exists and get its ID
                                int contentTypeId;

                                var getTypeCmd = new SqlCommand("SELECT Type_ID FROM Types WHERE Type_Name = @TypeName", connection);
                                getTypeCmd.Parameters.AddWithValue("@TypeName", "WordPress");

                                var result = getTypeCmd.ExecuteScalar();
                                if (result != null)
                                {
                                    contentTypeId = (int)result;
                                }
                                else
                                {
                                    // Insert new Type record
                                    var insertTypeCmd = new SqlCommand("INSERT INTO Types (Type_Name) OUTPUT INSERTED.Type_ID VALUES (@TypeName)", connection);
                                    insertTypeCmd.Parameters.AddWithValue("@TypeName", "WordPress");
                                    contentTypeId = (int)insertTypeCmd.ExecuteScalar();
                                }

                                // Insert new content
                                var insertCmd = new SqlCommand(@"
                                    INSERT INTO Articles_Contents (Article_ID, Content_Type_ID, Post_Content, WordPress_Last_Modified)
                                    VALUES (@ArticleID, @ContentTypeID, @PostContent, @Modified)", connection);

                                insertCmd.Parameters.AddWithValue("@ArticleID", articleId);
                                insertCmd.Parameters.AddWithValue("@ContentTypeID", contentTypeId);
                                insertCmd.Parameters.AddWithValue("@PostContent", post.content?.rendered ?? "");
                                insertCmd.Parameters.AddWithValue("@Modified", post.modified);

                                insertCmd.ExecuteNonQuery();
                                Console.WriteLine($"Updated article contents: {slug}");

                            }
                            else
                            {
                                Console.WriteLine($"No update needed for: {slug}");
                            }

                            break;
                        }
                    }

                    if (!matchFound)
                    {
                        reader.Close();

                        string articleUrl = $"{AppConfig.Current.WordPressURL}{slug}/";
                        string articleName = System.Globalization.CultureInfo.CurrentCulture.TextInfo.ToTitleCase(slug.Replace("-", " "));

                        var insertCmd = new SqlCommand(@"
                            INSERT INTO Articles (WordPress_ID, WordPress_Slug, WordPress_Last_Modified, WordPress_Category, Article_Name, Article_URL)
                            VALUES (@WordPressID, @Slug, @Modified, @Category, @ArticleName, @ArticleURL)", connection);

                        insertCmd.Parameters.AddWithValue("@WordPressID", post.id);
                        insertCmd.Parameters.AddWithValue("@Slug", slug);
                        insertCmd.Parameters.AddWithValue("@Modified", post.modified);
                        insertCmd.Parameters.AddWithValue("@Category", category);
                        insertCmd.Parameters.AddWithValue("@ArticleName", articleName);
                        insertCmd.Parameters.AddWithValue("@ArticleURL", articleUrl);

                        insertCmd.ExecuteNonQuery();
                        Console.WriteLine($"Inserted new article: {slug}");
                    }
                }
            }
        }
    }
}
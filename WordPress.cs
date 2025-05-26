using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text.Json;
using System.Threading.Tasks;
using System.Threading;
using FFAWMT.Models;
using FFAWMT.Data;

namespace FFAWMT.Services
{
    public static class WordPressAPIManager
    {
        private static readonly HttpClient client = new HttpClient();

        public static async Task SyncWordPressMetadataAsync()
        {
            Console.WriteLine("Starting WordPress metadata sync...");

            int page = 1;
            int totalProcessed = 0;
            var categoryCache = new Dictionary<int, string>();

            while (true)
            {
                var url = AppConfig.Current.WordPressAPIBaseURL + page;
                try
                {
                    var response = await client.GetAsync(url);
                    if (!response.IsSuccessStatusCode)
                    {
                        Console.WriteLine($"Failed to fetch posts (HTTP {response.StatusCode})");
                        break;
                    }

                    var json = await response.Content.ReadAsStringAsync();
                    var posts = JsonSerializer.Deserialize<List<WordPressPost>>(json);
                    if (posts == null || posts.Count == 0)
                        break;

                    foreach (var post in posts)
                    {
                        if (totalProcessed >= 1000) break;

                        string category = "";
                        if (post.categories != null && post.categories.Count > 0)
                        {
                            int catId = post.categories[0];
                            if (!categoryCache.TryGetValue(catId, out category))
                            {
                                await Task.Delay(100);
                                var catResp = await client.GetAsync(AppConfig.Current.WordPressAPICategoryURL + catId);
                                if (catResp.IsSuccessStatusCode)
                                {
                                    var catJson = await catResp.Content.ReadAsStringAsync();
                                    var catObj = JsonSerializer.Deserialize<WordPressCategory>(catJson);
                                    category = catObj?.name ?? "Unknown";
                                    categoryCache[catId] = category;
                                }
                                else
                                {
                                    Console.WriteLine($"Failed to fetch category {catId}");
                                }
                            }
                        }

                        ArticleRepository.ProcessPost(post, category);
                        totalProcessed++;
                        Thread.Sleep(100); // polite delay
                    }

                    if (totalProcessed >= 1000) break;
                    page++;
                }
                catch (Exception ex)
                {
                    Console.WriteLine("Error during sync: " + ex.Message);
                    break;
                }
            }

            Console.WriteLine("WordPress metadata sync complete.");
        }
    }
}

namespace FFAWMT.Models
{
    public class WordPressContent
    {
        public string rendered { get; set; }
    }

    public class WordPressPost
    {
        public int id { get; set; }
        public string slug { get; set; }
        public DateTime modified { get; set; }
        public List<int> categories { get; set; }
        public WordPressContent content { get; set; }
    }
    public class WordPressCategory
    {
        public int id { get; set; }
        public string name { get; set; }
    }
}

using System;
using Microsoft.Data.SqlClient;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

namespace FFAWMT.Services
{
    public static class ChatGPTClient
    {
        public static async Task<string> AskString(string prompt)
        {
            // First try cache
            string cached = GetCachedResponse(prompt);
            if (cached != null)
                return cached;

            using var client = new HttpClient();
            client.DefaultRequestHeaders.Add("Authorization", $"Bearer {AppConfig.Current.OpenAIKey}");

            var payload = new
            {
                model = AppConfig.Current.ChatGPTModel,
                messages = new[]
                {
            new { role = "user", content = prompt }
        },
                temperature = 0.2
            };

            var content = new StringContent(JsonSerializer.Serialize(payload), Encoding.UTF8, "application/json");

            var response = await client.PostAsync(AppConfig.Current.ChatGPTEndpoint, content);

            var json = await response.Content.ReadAsStringAsync();

            using var doc = JsonDocument.Parse(json);
            var reply = doc.RootElement
                .GetProperty("choices")[0]
                .GetProperty("message")
                .GetProperty("content")
                .GetString()
                ?.Trim();

            CacheResponse(prompt, reply);
            return reply;
        }

        public static async Task<bool> AskBoolean(string prompt)
        {
            var reply = await AskString(prompt);
            return reply?.Trim().StartsWith("yes", StringComparison.OrdinalIgnoreCase) == true;
        }

        private static string GetCachedResponse(string prompt)
        {
            using var conn = new SqlConnection(AppConfig.Current.SqlConnectionString);
            conn.Open();

            var cmd = new SqlCommand(@"
        SELECT Response
        FROM API.dbo.ChatGPT_Cache
        WHERE Prompt = @Prompt", conn);

            cmd.Parameters.AddWithValue("@Prompt", prompt);

            var result = cmd.ExecuteScalar();
            return result == DBNull.Value ? null : result as string;
        }

        private static void CacheResponse(string prompt, string response)
        {
            using var conn = new SqlConnection(AppConfig.Current.SqlConnectionString);
            conn.Open();

            var cmd = new SqlCommand(@"
        MERGE API.dbo.ChatGPT_Cache AS target
        USING (SELECT @Prompt AS Prompt) AS source
        ON target.Prompt = source.Prompt
        WHEN MATCHED THEN
            UPDATE SET Response = @Response, Last_Modified = SYSUTCDATETIME()
        WHEN NOT MATCHED THEN
            INSERT (Prompt, Response) VALUES (@Prompt, @Response);", conn);

            cmd.Parameters.AddWithValue("@Prompt", prompt);
            cmd.Parameters.AddWithValue("@Response", (object?)response ?? DBNull.Value);
            cmd.ExecuteNonQuery();
        }

    }
}

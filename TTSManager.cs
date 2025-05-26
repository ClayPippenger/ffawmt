
using System;
using Microsoft.Data.SqlClient;
using System.IO;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;

namespace FFAWMT.Services
{
    public static class TTSManager
    {
        public static byte[] GetAudioFromAzure(string text, string voiceName)
        {
            try
            {
                var region = AppConfig.Current.AzureRegion;
                var key = AppConfig.Current.AzureTTSKey;
                var endpoint = $"https://{region}.tts.speech.microsoft.com/cognitiveservices/v1";

                string ssml = $@"
                    <speak version='1.0' xml:lang='en-US'>
                      <voice name='{voiceName}'>{System.Security.SecurityElement.Escape(text)}</voice>
                    </speak>";

                using var client = new HttpClient();
                client.DefaultRequestHeaders.Add("Ocp-Apim-Subscription-Key", key);
                client.DefaultRequestHeaders.Add("X-Microsoft-OutputFormat", "audio-16khz-32kbitrate-mono-mp3");
                client.DefaultRequestHeaders.UserAgent.ParseAdd("FFA-Translation/1.0");

                var content = new StringContent(ssml, Encoding.UTF8, "application/ssml+xml");
                var response = client.PostAsync(endpoint, content).Result;

                if (!response.IsSuccessStatusCode)
                {
                    Console.WriteLine($"[AZURE ERROR] {response.StatusCode} - {response.ReasonPhrase}");
                    return null;
                }

                return response.Content.ReadAsByteArrayAsync().Result;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[AZURE EXCEPTION] {ex.Message}");
                return null;
            }
        }

        public static byte[] GetAudioFromOpenAI(string text, string voiceName)
        {
            try
            {
                var apiKey = AppConfig.Current.OpenAIKey;
                var endpoint = "https://api.openai.com/v1/audio/speech";

                using var client = new HttpClient();
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", apiKey);

                var payload = new
                {
                    model = "tts-1",
                    voice = voiceName,
                    input = text,
                    response_format = "mp3"
                };

                var json = JsonSerializer.Serialize(payload);
                var content = new StringContent(json, Encoding.UTF8, "application/json");
                var response = client.PostAsync(endpoint, content).Result;

                if (!response.IsSuccessStatusCode)
                {
                    Console.WriteLine($"[OPENAI ERROR] {response.StatusCode} - {response.ReasonPhrase}");
                    return null;
                }

                return response.Content.ReadAsByteArrayAsync().Result;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[OPENAI EXCEPTION] {ex.Message}");
                return null;
            }
        }

        public static int? GenerateAndStoreMp3(SqlConnection connection, int paragraphId, string text, int voiceId, string roleName)
        {
            try
            {
                string normalizedText = (text ?? "").Trim();
                string fileHash = ComputeTextHash(normalizedText);

                Console.WriteLine($"[TTS CHECK] Paragraph_ID: { paragraphId}, Role: { roleName}                ");
                Console.WriteLine($"[TEXT HASH] {fileHash}");
                Console.WriteLine($"[TEXT LEN] {normalizedText.Length} characters");

                // Check API File_Store for existing hash
                var checkApi = new SqlCommand("SELECT File_ID FROM API.dbo.File_Store WHERE File_Hash = @Hash", connection);
                checkApi.Parameters.AddWithValue("@Hash", fileHash);
                var existingApi = checkApi.ExecuteScalar();
                int fileIdApi;

                if (existingApi != null)
                {
                    fileIdApi = (int)existingApi;
                    Console.WriteLine($"[API] ✅ File reuse: File_ID {fileIdApi}");
                }
                else
                {
                    // Look up voice
                    var voiceCmd = new SqlCommand("SELECT Voice_Name, Engine_Name FROM FFA.dbo.Voices WHERE Voice_ID = @ID", connection);
                    voiceCmd.Parameters.AddWithValue("@ID", voiceId);
                    using var reader = voiceCmd.ExecuteReader();
                    if (!reader.Read()) return null;

                    string voiceName = reader.GetString(0);
                    string engineName = reader.GetString(1);
                    reader.Close();

                    Console.WriteLine($"[TTS] Generating MP3 for Paragraph_ID {paragraphId} | Engine: {engineName} | Voice: {voiceName}");

                    byte[] audioBytes = engineName switch
                    {
                        "Azure" => GetAudioFromAzure(normalizedText, voiceName),
                        "OpenAI" => GetAudioFromOpenAI(normalizedText, voiceName),
                        _ => throw new Exception("Unknown engine: " + engineName)
                    };

                    if (audioBytes == null || audioBytes.Length == 0)
                    {
                        Console.WriteLine($"[TTS ERROR] ❌ Audio generation failed.");
                        return null;
                    }

                    var insertApi = new SqlCommand(@"
                        INSERT INTO API.dbo.File_Store (File_Hash, File_Name, File_Size_Bytes, File_Format, File_Binary, Created_Date)
                        OUTPUT INSERTED.File_ID
                        VALUES (@Hash, @Name, @Size, 'mp3', @Binary, SYSUTCDATETIME())", connection);
                    insertApi.Parameters.AddWithValue("@Hash", fileHash);
                    insertApi.Parameters.AddWithValue("@Name", $"Paragraph_{paragraphId}_{roleName}.mp3");
                    insertApi.Parameters.AddWithValue("@Size", audioBytes.Length);
                    insertApi.Parameters.AddWithValue("@Binary", audioBytes);
                    fileIdApi = (int)insertApi.ExecuteScalar();

                    string diskPath = $@"R:\Shared\Website Archives\fragments\fragment_{paragraphId}.mp3";
                    File.WriteAllBytes(diskPath, audioBytes);
                    Console.WriteLine($"[DISK] 💾 Saved fragment to {diskPath}");
                }

                // Sync to FFA
                var checkFfa = new SqlCommand("SELECT File_ID FROM FFA.dbo.File_Store WHERE File_Hash = @Hash", connection);
                checkFfa.Parameters.AddWithValue("@Hash", fileHash);
                var existingFfa = checkFfa.ExecuteScalar();
                int fileIdFfa;

                if (existingFfa != null)
                {
                    fileIdFfa = (int)existingFfa;
                    Console.WriteLine($"[FFA] ✅ File already exists: File_ID {fileIdFfa}");
                }
                else
                {
                    var getBinary = new SqlCommand("SELECT File_Binary FROM API.dbo.File_Store WHERE File_ID = @ID", connection);
                    getBinary.Parameters.AddWithValue("@ID", fileIdApi);
                    var fileData = getBinary.ExecuteScalar() as byte[];

                    var insertFfa = new SqlCommand(@"
                        INSERT INTO FFA.dbo.File_Store (File_Hash, File_Name, File_Size_Bytes, File_Format, File_Binary, Created_Date)
                        OUTPUT INSERTED.File_ID
                        VALUES (@Hash, @Name, @Size, 'mp3', @Binary, SYSUTCDATETIME())", connection);
                    insertFfa.Parameters.AddWithValue("@Hash", fileHash);
                    insertFfa.Parameters.AddWithValue("@Name", $"Paragraph_{paragraphId}_{roleName}.mp3");
                    insertFfa.Parameters.AddWithValue("@Size", fileData.Length);
                    insertFfa.Parameters.AddWithValue("@Binary", fileData);
                    fileIdFfa = (int)insertFfa.ExecuteScalar();
                    Console.WriteLine($"[FFA] ✅ File inserted: File_ID {fileIdFfa}");
                }

                return fileIdFfa;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[TTSManager ERROR] {ex.Message}");
                return null;
            }
        }

        private static string ComputeTextHash(string input)
        {
            if (string.IsNullOrWhiteSpace(input)) return null;
            using var sha256 = SHA256.Create();
            var bytes = Encoding.UTF8.GetBytes(input.Trim());
            return BitConverter.ToString(sha256.ComputeHash(bytes)).Replace("-", "").ToLowerInvariant();
        }
    }
}

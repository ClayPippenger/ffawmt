using System;
using System.IO;
using System.Text.Json;

namespace FFAWMT
{
    public class AppConfig
    {
        public string AzureTTSKey { get; set; }
        public string AzureRegion { get; set; }
        public string OpenAIKey { get; set; }
        public string SqlConnectionString { get; set; }
        public string WordPressURL { get; set; }
        public string ChatGPTModel { get; set; }
        public string ChatGPTEndpoint { get; set; }
        public string AppLogPath { get; set; }
        public string AppMP3FragmentsPath { get; set; }
        public string WordPressAPIBaseURL { get; set; }
        public string WordPressAPICategoryURL { get; set; }

        public static AppConfig Current { get; private set; }

        // TODO = Hardcoded path
        public static void Load(string configPath = @"R:\Shared\AppPasswords\ffa.json")
        {
            try
            {
                var json = File.ReadAllText(configPath);
                Current = JsonSerializer.Deserialize<AppConfig>(json);
                if (Current == null)
                    throw new Exception("Configuration deserialized as null.");
            }
            catch (Exception ex)
            {
                Console.WriteLine("Failed to load configuration:");
                Console.WriteLine(ex.Message);
                Environment.Exit(1); // hard exit on config load failure
            }
        }
    }
}

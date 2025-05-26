namespace FFAWMT
{
    public static class Constants
    {
        // Retry & Timeout Settings
        public const int MaxTranslationRetries = 3;
        public const int MaxVoiceRetries = 3;
        public const int RetryDelayMilliseconds = 3000;

        // Application Flags
        public const bool EnableChatGPTFailover = true;

        // Voice Assignments (defaults)
        public const string VoiceEnglishMain = "en-US-AndrewNeural";
        public const string VoiceEnglishFemale = "en-US-EmmaMultilingualNeural";
        public const string VoiceBible = "en-AU-DuncanNeural";
        public const string VoiceSummary = "en-US-AndrewMultilingualNeural";

        // Console Formatting
        public const string AppTitle = "FFA Website Management Tool (FFAWMT)";
    }
}

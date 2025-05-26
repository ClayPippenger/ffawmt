
using System;
using Microsoft.Data.SqlClient;
using static FFAWMT.Services.Mp3Generator;

namespace FFAWMT.Services
{
    public class VoiceSelection
    {
        public int VoiceId { get; set; }
        public string RoleName { get; set; }
    }

    public static class VoiceSelector
    {
        public static VoiceSelection GetVoice(ParagraphWorkItem item)
        {
            string typeName = TryGetContentTypeName(item.ContentTypeID);
            string cleanText = HtmlCleaner.StripHtml(item.ParagraphClean)?.TrimStart() ?? "";

            // Determine voice role
            string role = VoiceManager.DetermineVoiceRole(new Paragraph
            {
                Content_Type_Name = typeName,
                Paragraph_Text = cleanText
            });

            try
            {
                int voiceId = VoiceManager.GetVoiceIdByRole(role);

                return new VoiceSelection
                {
                    VoiceId = voiceId,
                    RoleName = role
                };
            }
            catch (Exception ex)
            {
                Console.WriteLine($"CRITICAL ERROR: Voice role '{role}' not found in Voice_Roles table.");
                return null;
            }
        }

        private static string TryGetContentTypeName(int contentTypeId)
        {
            using var conn = new SqlConnection(AppConfig.Current.SqlConnectionString);
            conn.Open();

            var cmd = new SqlCommand("SELECT TOP 1 Type_Name FROM Types WHERE Type_ID = @ID", conn);
            cmd.Parameters.AddWithValue("@ID", contentTypeId);

            var result = cmd.ExecuteScalar();
            return result == DBNull.Value ? null : result as string;
        }
    }
}


using System;
using Microsoft.Data.SqlClient;
using FFAWMT;

namespace FFAWMT.Services
{
    public static class VoiceManager
    {
        public static int GetVoiceIdByRole(string roleName)
        {
            using (var conn = new SqlConnection(AppConfig.Current.SqlConnectionString))
            {
                conn.Open();
                var cmd = new SqlCommand(@"
                    SELECT Voice_ID 
                    FROM Voice_Roles 
                    WHERE Role_Name = @RoleName", conn);
                cmd.Parameters.AddWithValue("@RoleName", roleName);

                var result = cmd.ExecuteScalar();
                if (result == null)
                    throw new Exception($"Voice role '{roleName}' not found in Voice_Roles table.");

                return (int)result;
            }
        }

        public static string DetermineVoiceRole(Paragraph paragraph)
        {
            if (paragraph == null) return "Content";

            var type = paragraph.Content_Type_Name?.Trim() ?? "";
            var text = paragraph.Paragraph_Text ?? "";

            if (type == "Break" || type == "Separator")
                return "Header";

            if (type == "Indented Quotation" && text.Contains("Ellen White", StringComparison.OrdinalIgnoreCase))
                return "EllenWhite";

            if (type == "Indented Quotation" || text.Contains("William Miller") || text.Contains("Arthur White"))
                return "MaleQuote";

            if (text.StartsWith("“") && text.EndsWith("”")) // simple quote test
                return "Scripture";

            return "Content";
        }
    }

    public class Paragraph
    {
        public string Content_Type_Name { get; set; }
        public string Paragraph_Text { get; set; }
    }
}

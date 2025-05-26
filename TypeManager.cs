using System;
using Microsoft.Data.SqlClient;

namespace FFAWMT.Services
{
    public static class TypeManager
    {
        private static string ConnectionString => AppConfig.Current.SqlConnectionString;

        public static void AddType(string typeName)
        {
            using var connection = new SqlConnection(ConnectionString);
            connection.Open();

            var cmd = new SqlCommand(
                "INSERT INTO Types (Type_Name) VALUES (@TypeName)", connection);
            cmd.Parameters.AddWithValue("@TypeName", typeName);

            int rows = cmd.ExecuteNonQuery();
            Logger.Log(rows > 0
                ? $"✅ Added type: {typeName}"
                : $"❌ Failed to add type.");
        }

        public static void UpdateType(int typeId, string newName = null, bool? active = null)
        {
            using var connection = new SqlConnection(ConnectionString);
            connection.Open();

            var updateSql = "UPDATE Types SET ";
            if (newName != null) updateSql += "Type_Name = @Name";
            if (newName != null && active.HasValue) updateSql += ", ";
            if (active.HasValue) updateSql += "Active = @Active";
            updateSql += " WHERE Type_ID = @TypeID";

            var cmd = new SqlCommand(updateSql, connection);
            cmd.Parameters.AddWithValue("@TypeID", typeId);
            if (newName != null) cmd.Parameters.AddWithValue("@Name", newName);
            if (active.HasValue) cmd.Parameters.AddWithValue("@Active", active.Value);

            int rows = cmd.ExecuteNonQuery();
            Logger.Log(rows > 0
                ? $"✅ Updated type ID {typeId}"
                : $"❌ No changes made for type ID {typeId}");
        }
    }
}

using System;
using System.Configuration;
using System.Data;
using System.Collections.Generic;
using MySqlConnector;

namespace AttendanceApp.Utils
{
    public static class DBHelper
    {
        public static string GetCompanyDBConnection()
        {
            return ConfigurationManager.ConnectionStrings["CompanyDB"].ConnectionString;
        }

        public static string GetAttendanceDBConnection()
        {
            return ConfigurationManager.ConnectionStrings["AttendanceDB"].ConnectionString;
        }

        private static T RunWithRetry<T>(Func<T> operation, int maxRetries = 3, int delayMs = 500)
        {
            int attempts = 0;
            while (true)
            {
                try
                {
                    attempts++;
                    return operation();
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine(string.Format("Database operation failed. Attempt {0} of {1}. Error: {2}", attempts, maxRetries, ex.Message));
                    if (attempts >= maxRetries)
                    {
                        throw;
                    }
                    // Wait before retrying (exponential backoff)
                    System.Threading.Thread.Sleep(delayMs * attempts);
                }
            }
        }

        private static MySqlParameter[] CloneParameters(MySqlParameter[] parameters)
        {
            if (parameters == null) return null;
            MySqlParameter[] cloned = new MySqlParameter[parameters.Length];
            for (int i = 0; i < parameters.Length; i++)
            {
                cloned[i] = new MySqlParameter(parameters[i].ParameterName, parameters[i].Value)
                {
                    DbType = parameters[i].DbType,
                    Direction = parameters[i].Direction,
                    IsNullable = parameters[i].IsNullable,
                    Size = parameters[i].Size,
                    SourceColumn = parameters[i].SourceColumn,
                    SourceVersion = parameters[i].SourceVersion
                };
            }
            return cloned;
        }

        public static DataTable ExecuteQuery(string connectionString, string query, params MySqlParameter[] parameters)
        {
            return RunWithRetry(() =>
            {
                DataTable dt = new DataTable();
                using (MySqlConnection conn = new MySqlConnection(connectionString))
                {
                    using (MySqlCommand cmd = new MySqlCommand(query, conn))
                    {
                        if (parameters != null)
                        {
                            cmd.Parameters.AddRange(CloneParameters(parameters));
                        }
                        using (MySqlDataAdapter sda = new MySqlDataAdapter(cmd))
                        {
                            sda.Fill(dt);
                        }
                    }
                }
                return dt;
            });
        }

        public static int ExecuteNonQuery(string connectionString, string query, params MySqlParameter[] parameters)
        {
            return RunWithRetry(() =>
            {
                int rowsAffected = 0;
                using (MySqlConnection conn = new MySqlConnection(connectionString))
                {
                    using (MySqlCommand cmd = new MySqlCommand(query, conn))
                    {
                        if (parameters != null)
                        {
                            cmd.Parameters.AddRange(CloneParameters(parameters));
                        }
                        conn.Open();
                        rowsAffected = cmd.ExecuteNonQuery();
                    }
                }
                return rowsAffected;
            });
        }

        public static object ExecuteScalar(string connectionString, string query, params MySqlParameter[] parameters)
        {
            return RunWithRetry(() =>
            {
                object result = null;
                using (MySqlConnection conn = new MySqlConnection(connectionString))
                {
                    using (MySqlCommand cmd = new MySqlCommand(query, conn))
                    {
                        if (parameters != null)
                        {
                            cmd.Parameters.AddRange(CloneParameters(parameters));
                        }
                        conn.Open();
                        result = cmd.ExecuteScalar();
                    }
                }
                return result;
            });
        }
    }
}

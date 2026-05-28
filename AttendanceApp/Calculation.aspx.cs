using System;
using System.Collections.Generic;
using System.Data;
using System.Web.Script.Serialization;
using System.Web.Services;
using AttendanceApp.Utils;
using MySqlConnector;

namespace AttendanceApp
{
    public partial class Calculation : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!User.Identity.IsAuthenticated)
            {
                Response.Redirect("Login.aspx");
            }
            
            int role = Convert.ToInt32(Session["Role"] ?? 0);
            if (role != 1)
            {
                Response.Write("<h2 style='color:red;text-align:center;margin-top:50px;'>Only Admin Can Access</h2>");
                Response.End();
            }
        }

        [WebMethod]
        public static string GetCalculationData(int year, int month, string category, string division, float wage)
        {
            // 1. Get all category wages for the given year & month
            Dictionary<string, float> wageDict = new Dictionary<string, float>();
            string wQ = "SELECT Category, WageRate FROM CalculationWages WHERE Year=@Y AND Month=@M";
            DataTable dtWages = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), wQ,
                new MySqlParameter("@Y", year), new MySqlParameter("@M", month));
            foreach (DataRow dr in dtWages.Rows)
            {
                wageDict[dr["Category"].ToString()] = Convert.ToSingle(dr["WageRate"]);
            }

            // Fallback for single category if wage is 0
            if (wage == 0 && category != "All" && wageDict.ContainsKey(category))
            {
                wage = wageDict[category];
            }

            // 2. Get Employees in category and division
            string eQ = "SELECT ID, Name, Department, Category, JoinDate, ResignDate FROM Employees WHERE Status='Active'";
            List<MySqlParameter> pList = new List<MySqlParameter>();
            if (category != "All")
            {
                eQ += " AND Category=@C";
                pList.Add(new MySqlParameter("@C", category));
            }
            if (division != "All")
            {
                eQ += " AND Department=@Div";
                pList.Add(new MySqlParameter("@Div", division));
            }
            DataTable dtEmp = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), eQ, pList.ToArray());

            // 3. Get Absences and Sunday Holidays
            string aQ = @"SELECT EmpID, 
                          SUM(CASE WHEN StatusValue = 0 AND (LeaveType = 'Unpaid' OR LeaveType = 'Paired Unpaid' OR LeaveType = '' OR LeaveType IS NULL) AND DAYOFWEEK(STR_TO_DATE(CONCAT(Year, '-', Month + 1, '-', Day), '%Y-%c-%e')) != 7 THEN 1 ELSE 0 END) as UnpaidLeaves,
                          SUM(CASE WHEN StatusValue = 0 AND DAYOFWEEK(STR_TO_DATE(CONCAT(Year, '-', Month + 1, '-', Day), '%Y-%c-%e')) = 7 THEN 1 ELSE 0 END) as SatCuts,
                          SUM(CASE WHEN StatusValue = 0.5 THEN 1 ELSE 0 END) as HalfDays,
                          SUM(CASE WHEN IsHoliday = 1 AND DAYOFWEEK(STR_TO_DATE(CONCAT(Year, '-', Month + 1, '-', Day), '%Y-%c-%e')) = 1 THEN 1 ELSE 0 END) as SundayHolidays
                          FROM Attendance 
                          WHERE Year=@Y AND Month=@M GROUP BY EmpID";
            DataTable dtAtt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), aQ,
                new MySqlParameter("@Y", year), new MySqlParameter("@M", month));
            
            Dictionary<string, float> absenceDict = new Dictionary<string, float>();
            Dictionary<string, int> sunHolidayDict = new Dictionary<string, int>();
            foreach(DataRow dr in dtAtt.Rows)
            {
                float unpaid = dr["UnpaidLeaves"] == DBNull.Value ? 0 : Convert.ToSingle(dr["UnpaidLeaves"]);
                float satCut = dr["SatCuts"] == DBNull.Value ? 0 : Convert.ToSingle(dr["SatCuts"]);
                float halfDays = dr["HalfDays"] == DBNull.Value ? 0 : Convert.ToSingle(dr["HalfDays"]);
                int sunHols = dr["SundayHolidays"] == DBNull.Value ? 0 : Convert.ToInt32(dr["SundayHolidays"]);
                
                absenceDict[dr["EmpID"].ToString()] = unpaid + satCut + (halfDays * 0.5f);
                sunHolidayDict[dr["EmpID"].ToString()] = sunHols;
            }

            // 4. Get Overrides
            string oQ = "SELECT EmpID, FinalDays FROM CalculationOverrides WHERE Year=@Y AND Month=@M";
            List<MySqlParameter> oParams = new List<MySqlParameter> {
                new MySqlParameter("@Y", year),
                new MySqlParameter("@M", month)
            };
            if (category != "All")
            {
                oQ += " AND Category=@C";
                oParams.Add(new MySqlParameter("@C", category));
            }
            DataTable dtOver = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), oQ, oParams.ToArray());
            Dictionary<string, float> overDict = new Dictionary<string, float>();
            foreach(DataRow dr in dtOver.Rows)
            {
                overDict[dr["EmpID"].ToString()] = Convert.ToSingle(dr["FinalDays"]);
            }

            // Get Global Adjustment
            float globalAdj = 0;
            string gq = "SELECT StatusValue FROM Attendance WHERE Year=@Y AND Month=@M AND EmpID='GLOBAL' AND Day=0 LIMIT 1";
            object gRes = DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), gq,
                new MySqlParameter("@Y", year), new MySqlParameter("@M", month));
            if (gRes != null && gRes != DBNull.Value)
            {
                globalAdj = Convert.ToSingle(gRes);
            }

            int daysInMonth = DateTime.DaysInMonth(year, month + 1);
            List<object> list = new List<object>();
            foreach(DataRow dr in dtEmp.Rows)
            {
                string id = dr["ID"].ToString();
                string empCat = dr["Category"].ToString();
                
                DateTime? joinDate = dr["JoinDate"] != DBNull.Value ? Convert.ToDateTime(dr["JoinDate"]) : (DateTime?)null;
                DateTime? resignDate = dr["ResignDate"] != DBNull.Value ? Convert.ToDateTime(dr["ResignDate"]) : (DateTime?)null;
                
                int workingDays = 0;
                for (int d = 1; d <= daysInMonth; d++)
                {
                    DateTime currDate = new DateTime(year, month + 1, d);
                    if (currDate.DayOfWeek == DayOfWeek.Sunday) continue;
                    if (joinDate.HasValue && currDate < joinDate.Value.Date) continue;
                    if (resignDate.HasValue && currDate > resignDate.Value.Date) continue;
                    workingDays++;
                }

                int sunHols = sunHolidayDict.ContainsKey(id) ? sunHolidayDict[id] : 0;
                workingDays += sunHols;

                float abs = absenceDict.ContainsKey(id) ? absenceDict[id] : 0;
                float present = workingDays - abs + globalAdj;
                
                float final = overDict.ContainsKey(id) ? overDict[id] : present;
                
                // Determine employee's specific wage rate
                float empWage = wage > 0 ? wage : (wageDict.ContainsKey(empCat) ? wageDict[empCat] : 0f);
                
                list.Add(new {
                    ID = id,
                    Name = dr["Name"].ToString(),
                    Department = dr["Department"].ToString(),
                    Present = present,
                    Final = final,
                    Amount = final * empWage,
                    WageRate = empWage
                });
            }

            return new JavaScriptSerializer().Serialize(list);
        }

        [WebMethod]
        public static string SaveWage(int year, int month, string category, float wage)
        {
            string q = @"INSERT INTO CalculationWages (Year, Month, Category, WageRate) 
                         VALUES (@Y, @M, @C, @W) ON DUPLICATE KEY UPDATE WageRate=@W";
            DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), q,
                new MySqlParameter("@Y", year), new MySqlParameter("@M", month),
                new MySqlParameter("@C", category), new MySqlParameter("@W", wage));
            return "{\"status\":\"success\"}";
        }

        [WebMethod]
        public static string SaveOverride(int year, int month, string category, string empId, float finalDays)
        {
            if (category == "All")
            {
                string qCat = "SELECT Category FROM Employees WHERE ID=@ID";
                object res = DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), qCat, new MySqlParameter("@ID", empId));
                if (res != null && res != DBNull.Value)
                {
                    category = res.ToString();
                }
            }
            string q = @"INSERT INTO CalculationOverrides (Year, Month, Category, EmpID, FinalDays) 
                         VALUES (@Y, @M, @C, @ID, @F) ON DUPLICATE KEY UPDATE FinalDays=@F";
            DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), q,
                new MySqlParameter("@Y", year), new MySqlParameter("@M", month),
                new MySqlParameter("@C", category), new MySqlParameter("@ID", empId),
                new MySqlParameter("@F", finalDays));
            return "{\"status\":\"success\"}";
        }

        [WebMethod]
        public static string GetCategories()
        {
            string query = "SELECT Name FROM Categories ORDER BY Name ASC";
            DataTable dt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), query);
            List<string> list = new List<string>();
            foreach (DataRow dr in dt.Rows)
            {
                list.Add(dr["Name"].ToString());
            }
            return new JavaScriptSerializer().Serialize(list);
        }

        [WebMethod]
        public static string GetDivisions()
        {
            string query = "SELECT Name FROM Divisions ORDER BY Name ASC";
            DataTable dt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), query);
            List<string> list = new List<string>();
            foreach (DataRow dr in dt.Rows)
            {
                list.Add(dr["Name"].ToString());
            }
            return new JavaScriptSerializer().Serialize(list);
        }
    }
}

using System;
using System.Data;
using System.Web;
using System.Web.Security;
using AttendanceApp.Utils;
using MySqlConnector;
namespace AttendanceApp
{
    public partial class Login : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (User.Identity.IsAuthenticated)
                {
                    Response.Redirect("Dashboard.aspx");
                }
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            string username = txtUsername.Text.Trim();
            string password = txtPassword.Text.Trim();

            if (string.IsNullOrEmpty(username))
            {
                ShowError("Username is required.");
                return;
            }

            string pcno = null;

            try
            {
                pcno = ADHelper.AuthenticateAndGetPCNO(username, password);
            }
            catch (Exception ex)
            {
                ShowError("AD Error: " + ex.Message);
                return;
            }

            if (string.IsNullOrEmpty(pcno))
            {
                ShowError("Invalid credentials or user not found in AD.");
                return;
            }

            // Fetch Role from AttendanceDB
            int role = 0;
            try
            {
                string queryRole = "SELECT Role FROM AppUsers WHERE PCNO = @PCNO LIMIT 1";
                object res = DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), queryRole, new MySqlParameter("@PCNO", pcno));
                if (res == null || res == DBNull.Value)
                {
                    ShowError("Access denied. You are not authorized to log in. Please contact an administrator.");
                    return;
                }
                role = Convert.ToInt32(res);

                if (role == 2)
                {
                    ShowError("Access denied. Your administrator access has been revoked. Please contact a system administrator.");
                    return;
                }
                if (role == 3)
                {
                    ShowError("Access denied. Your regular user access has been revoked. Please contact a system administrator.");
                    return;
                }
            }
            catch (Exception ex)
            {
                ShowError("Database Connection Error: Could not connect to Attendance Database. Please verify database services are running. " + ex.Message);
                return;
            }

            // Load allowed divisions for regular user
            System.Collections.Generic.List<string> allowedDivisions = new System.Collections.Generic.List<string>();
            if (role != 1)
            {
                try
                {
                    string queryDivs = "SELECT DivisionName FROM UserDivisions WHERE PCNO = @PCNO";
                    DataTable dtDivs = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), queryDivs, new MySqlParameter("@PCNO", pcno));
                    foreach (DataRow row in dtDivs.Rows)
                    {
                        allowedDivisions.Add(row["DivisionName"].ToString());
                    }
                    
                    if (allowedDivisions.Count == 0)
                    {
                        ShowError("Login Error: No allowed divisions assigned. Please contact an administrator.");
                        return;
                    }
                }
                catch (Exception ex)
                {
                    ShowError("Database Connection Error: Could not retrieve division permissions. " + ex.Message);
                    return;
                }
            }

            // Fetch Division from CompanyDB
            string division = "";
            string name = "User";
            string designation = "";
            try
            {
                string queryDiv = "SELECT NAME, DESIGNATION, DIVNAME FROM hrdata.empdetails WHERE PCNO = @PCNO LIMIT 1";
                DataTable dt = DBHelper.ExecuteQuery(DBHelper.GetCompanyDBConnection(), queryDiv, new MySqlParameter("@PCNO", pcno));
                if (dt.Rows.Count > 0)
                {
                    name = dt.Rows[0]["NAME"].ToString();
                    designation = dt.Rows[0]["DESIGNATION"].ToString();
                    division = dt.Rows[0]["DIVNAME"].ToString();
                }
                else
                {
                    if (role == 1)
                    {
                        name = "Admin";
                        designation = "System Administrator";
                        division = "D-ADMIN";
                    }
                    else
                    {
                        ShowError("Login Error: Employee details not found in database.");
                        return;
                    }
                }
            }
            catch (Exception ex)
            {
                ShowError("Database Connection Error: Could not connect to Employee Database. Please verify database services are running. " + ex.Message);
                return;
            }

            // Store in Session
            Session["PCNO"] = pcno;
            Session["Role"] = role; // 1 for Admin, 0 for User
            Session["Name"] = name;
            Session["Designation"] = designation;
            Session["AllowedDivisions"] = allowedDivisions;

            if (role == 1)
            {
                string divPrefix = division;
                if (division.Contains("/"))
                {
                    divPrefix = division.Split('/')[0].Trim();
                }
                Session["Division"] = divPrefix;
            }
            else
            {
                Session["Division"] = allowedDivisions[0];
            }

            if (role == 1)
            {
                try
                {
                    string updateNameQuery = @"
                        INSERT INTO AppUsers (PCNO, Name, Role) 
                        VALUES (@PCNO, @Name, 1)
                        ON DUPLICATE KEY UPDATE Name = @Name, Role = 1";
                    DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), updateNameQuery,
                        new MySqlParameter("@PCNO", pcno),
                        new MySqlParameter("@Name", name));
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine("Error updating admin name on login: " + ex.Message);
                }
            }

            FormsAuthentication.SetAuthCookie(pcno, false);
            Response.Redirect("Dashboard.aspx");
        }

        private void ShowError(string message)
        {
            lblError.Text = message;
            lblError.Visible = true;
        }
    }
}

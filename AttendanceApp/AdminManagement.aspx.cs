using System;
using System.Data;
using MySqlConnector;
using AttendanceApp.Utils;

namespace AttendanceApp
{
    public partial class AdminManagement : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!User.Identity.IsAuthenticated)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            int role = Convert.ToInt32(Session["Role"] ?? 0);
            if (role != 1)
            {
                Response.Redirect("Dashboard.aspx");
                return;
            }

            // Ensure the Name column exists in AppUsers table
            EnsureNameColumnExists();
            EnsureUserDivisionsTableExists();

            if (!IsPostBack)
            {
                hfActiveTab.Value = "NonAdmins";
                PopulateUserDivisions();
                BindAdminGrid();
            }
        }

        protected void btnTabAdmins_Click(object sender, EventArgs e)
        {
            hfActiveTab.Value = "Admins";
            BindAdminGrid();
        }

        protected void btnTabNonAdmins_Click(object sender, EventArgs e)
        {
            hfActiveTab.Value = "NonAdmins";
            BindAdminGrid();
        }

        public int GetAdminCount()
        {
            try
            {
                string q = "SELECT COUNT(*) FROM AppUsers WHERE Role = 1 OR Role = 2";
                object res = DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), q);
                return res != null ? Convert.ToInt32(res) : 0;
            }
            catch { return 0; }
        }

        public int GetNonAdminCount()
        {
            try
            {
                string q = "SELECT COUNT(*) FROM AppUsers WHERE Role = 0 OR Role = 3";
                object res = DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), q);
                return res != null ? Convert.ToInt32(res) : 0;
            }
            catch { return 0; }
        }

        protected void btnAddAdmin_Click(object sender, EventArgs e)
        {
            string pcno = txtAdminPCNO.Text.Trim();
            string name = txtAdminName.Text.Trim();

            if (string.IsNullOrEmpty(pcno) || string.IsNullOrEmpty(name))
            {
                ShowAdminMessage("PCNO and Name are required.", false);
                return;
            }

            try
            {
                // 1. Insert/Update in CompanyDB (hrdata.empdetails) so details are available on AD login
                string queryEmp = @"
                    INSERT INTO empdetails (PCNO, NAME, DESIGNATION, DIVNAME) 
                    VALUES (@PCNO, @Name, 'Administrator', 'AD-Admin')
                    ON DUPLICATE KEY UPDATE NAME=@Name";
                
                MySqlParameter[] paramsEmp = new MySqlParameter[] {
                    new MySqlParameter("@PCNO", pcno),
                    new MySqlParameter("@Name", name)
                };
                DBHelper.ExecuteNonQuery(DBHelper.GetCompanyDBConnection(), queryEmp, paramsEmp);

                // 2. Insert/Update in AttendanceDB (AppUsers)
                string queryUser = @"
                    INSERT INTO AppUsers (PCNO, Name, Role) 
                    VALUES (@PCNO, @Name, 1)
                    ON DUPLICATE KEY UPDATE Name = @Name, Role = 1";
                
                MySqlParameter[] paramsUser = new MySqlParameter[] {
                    new MySqlParameter("@PCNO", pcno),
                    new MySqlParameter("@Name", name)
                };
                DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), queryUser, paramsUser);

                ShowAdminMessage($"Admin user '{name}' (PCNO: {pcno}) has been successfully created/updated.", true);
                
                // Clear fields
                txtAdminPCNO.Text = "";
                txtAdminName.Text = "";

                // Rebind the admin grid
                BindAdminGrid();
            }
            catch (Exception ex)
            {
                ShowAdminMessage("Error: " + ex.Message, false);
            }
        }

        protected void gvAdminUsers_RowCommand(object sender, System.Web.UI.WebControls.GridViewCommandEventArgs e)
        {
            if (e.CommandName == "RevokeAdmin")
            {
                string targetPcno = e.CommandArgument.ToString();
                string currentPcno = Session["PCNO"] != null ? Session["PCNO"].ToString() : "";

                if (targetPcno == currentPcno)
                {
                    ShowGridMessage("You cannot revoke your own administrator access.", false);
                    return;
                }

                try
                {
                    // Query the user's current role to determine if they are an Admin or a Regular User
                    string queryRole = "SELECT Role FROM AppUsers WHERE PCNO = @PCNO LIMIT 1";
                    object resRole = DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), queryRole, new MySqlParameter("@PCNO", targetPcno));
                    int currentRole = resRole != null ? Convert.ToInt32(resRole) : 0;
                    
                    int targetRevokedRole = (currentRole == 1) ? 2 : 3;

                    // Downgrade the user's role in AppUsers (does not delete details)
                    string query = "UPDATE AppUsers SET Role = @TargetRole WHERE PCNO = @PCNO";
                    MySqlParameter[] mysqlParams = new MySqlParameter[] {
                        new MySqlParameter("@TargetRole", targetRevokedRole),
                        new MySqlParameter("@PCNO", targetPcno)
                    };
                    DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), query, mysqlParams);

                    string accessType = (targetRevokedRole == 2) ? "Administrator" : "Regular user";
                    ShowGridMessage($"{accessType} access for PCNO {targetPcno} has been successfully revoked.", true);
                    BindAdminGrid();
                }
                catch (Exception ex)
                {
                    ShowGridMessage("Error revoking access: " + ex.Message, false);
                }
            }
            else if (e.CommandName == "GrantAdmin")
            {
                string targetPcno = e.CommandArgument.ToString();
                try
                {
                    // Query the user's current role to determine if they are a revoked Admin or a revoked User
                    string queryRole = "SELECT Role FROM AppUsers WHERE PCNO = @PCNO LIMIT 1";
                    object resRole = DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), queryRole, new MySqlParameter("@PCNO", targetPcno));
                    int currentRole = resRole != null ? Convert.ToInt32(resRole) : 0;

                    int targetGrantedRole = (currentRole == 2) ? 1 : 0;

                    // Upgrade the user's role in AppUsers
                    string query = "UPDATE AppUsers SET Role = @TargetRole WHERE PCNO = @PCNO";
                    MySqlParameter[] mysqlParams = new MySqlParameter[] {
                        new MySqlParameter("@TargetRole", targetGrantedRole),
                        new MySqlParameter("@PCNO", targetPcno)
                    };
                    DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), query, mysqlParams);

                    string accessType = (targetGrantedRole == 1) ? "Administrator" : "Regular user";
                    ShowGridMessage($"{accessType} access for PCNO {targetPcno} has been successfully granted.", true);
                    BindAdminGrid();
                }
                catch (Exception ex)
                {
                    ShowGridMessage("Error granting access: " + ex.Message, false);
                }
            }
            else if (e.CommandName == "DeleteUser")
            {
                string targetPcno = e.CommandArgument.ToString();
                try
                {
                    // Permanently delete the user from AppUsers
                    string query = "DELETE FROM AppUsers WHERE PCNO = @PCNO";
                    MySqlParameter[] mysqlParams = new MySqlParameter[] {
                        new MySqlParameter("@PCNO", targetPcno)
                    };
                    DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), query, mysqlParams);

                    // Delete division mapping
                    string deleteDivs = "DELETE FROM UserDivisions WHERE PCNO = @PCNO";
                    DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), deleteDivs, new MySqlParameter("@PCNO", targetPcno));

                    ShowGridMessage($"User with PCNO {targetPcno} has been permanently deleted from the registry.", true);
                    BindAdminGrid();
                }
                catch (Exception ex)
                {
                    ShowGridMessage("Error deleting user: " + ex.Message, false);
                }
            }
            else if (e.CommandName == "EditUserDivs")
            {
                string targetPcno = e.CommandArgument.ToString();
                try
                {
                    // Fetch user details
                    string queryUser = "SELECT PCNO, Name FROM AppUsers WHERE PCNO = @PCNO";
                    DataTable dtUser = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), queryUser, new MySqlParameter("@PCNO", targetPcno));
                    if (dtUser.Rows.Count > 0)
                    {
                        txtUserPCNO.Text = dtUser.Rows[0]["PCNO"].ToString();
                        txtUserPCNO.ReadOnly = true; // Don't let them change PCNO during edit
                        txtUserName.Text = dtUser.Rows[0]["Name"].ToString();
                        
                        // Clear selection
                        foreach (System.Web.UI.WebControls.ListItem item in cblUserDivisions.Items)
                        {
                            item.Selected = false;
                        }
                        
                        // Fetch assigned divisions
                        string queryDivs = "SELECT DivisionName FROM UserDivisions WHERE PCNO = @PCNO";
                        DataTable dtDivs = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), queryDivs, new MySqlParameter("@PCNO", targetPcno));
                        foreach (DataRow row in dtDivs.Rows)
                        {
                            string divName = row["DivisionName"].ToString();
                            System.Web.UI.WebControls.ListItem item = cblUserDivisions.Items.FindByValue(divName);
                            if (item != null)
                            {
                                item.Selected = true;
                            }
                        }
                        
                        btnAddUser.Text = "Update Regular User";
                        btnCancelUserEdit.Visible = true;
                        
                        // Set the form title and styling
                        userFormTitle.InnerHtml = "<i class=\"fas fa-user-edit mr-2\"></i> Edit Regular User";
                        userFormHeader.Style["background"] = "linear-gradient(135deg, #4f46e5 0%, #3730a3 100%)";

                        ShowAdminMessage($"Editing details for user '{txtUserName.Text}'.", true);
                    }
                }
                catch (Exception ex)
                {
                    ShowGridMessage("Error loading user details: " + ex.Message, false);
                }
            }
        }

        private void BindAdminGrid()
        {
            try
            {
                lblGridMessage.Visible = false;
                string activeTab = string.IsNullOrEmpty(hfActiveTab.Value) ? "NonAdmins" : hfActiveTab.Value;

                // Toggle visibility of the forms based on tab
                phAdminForm.Visible = (activeTab == "Admins");
                phUserForm.Visible = (activeTab == "NonAdmins");

                string query = "";
                if (activeTab == "NonAdmins")
                {
                    query = @"SELECT u.PCNO, u.Name, u.Role, GROUP_CONCAT(ud.DivisionName ORDER BY ud.DivisionName ASC SEPARATOR ', ') as AllowedDivisions 
                              FROM AppUsers u 
                              LEFT JOIN UserDivisions ud ON u.PCNO = ud.PCNO 
                              WHERE u.Role = 0 OR u.Role = 3 
                              GROUP BY u.PCNO, u.Name, u.Role 
                              ORDER BY u.Name ASC";
                }
                else
                {
                    query = "SELECT PCNO, Name, Role, NULL as AllowedDivisions FROM AppUsers WHERE Role = 1 OR Role = 2 ORDER BY Name ASC";
                }

                DataTable dt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), query);
                gvAdminUsers.DataSource = dt;
                gvAdminUsers.DataBind();

                if (activeTab == "NonAdmins")
                {
                    btnTabNonAdmins.CssClass = "nav-link active";
                    btnTabAdmins.CssClass = "nav-link";
                }
                else
                {
                    btnTabNonAdmins.CssClass = "nav-link";
                    btnTabAdmins.CssClass = "nav-link active";
                }
            }
            catch (Exception ex)
            {
                ShowGridMessage("Error loading administrators: " + ex.Message, false);
            }
        }

        private void EnsureNameColumnExists()
        {
            try
            {
                string checkQuery = @"
                    SELECT COUNT(*) 
                    FROM INFORMATION_SCHEMA.COLUMNS 
                    WHERE TABLE_SCHEMA = 'AttendanceDB' 
                      AND TABLE_NAME = 'AppUsers' 
                      AND COLUMN_NAME = 'Name'";
                
                object count = DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), checkQuery);
                if (count != null && Convert.ToInt32(count) == 0)
                {
                    string alterQuery = "ALTER TABLE AppUsers ADD COLUMN Name VARCHAR(100)";
                    DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), alterQuery);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error verifying Name column in AppUsers: " + ex.Message);
            }
        }

        private void ShowAdminMessage(string msg, bool success, string showModalId = null)
        {
            string type = success ? "success" : "error";
            string cleanMessage = msg.Replace("'", "\\'").Replace("\r", "").Replace("\n", " ");
            string script = string.Format("showToast('{0}', '{1}');", cleanMessage, type);
            if (!string.IsNullOrEmpty(showModalId))
            {
                script += string.Format(" var modalEl = document.getElementById('{0}'); if (modalEl) {{ var modal = bootstrap.Modal.getInstance(modalEl) || new bootstrap.Modal(modalEl); modal.show(); }}", showModalId);
                if (showModalId == "userModal" && txtUserPCNO.ReadOnly)
                {
                    script += " var label = document.getElementById('userModalLabel'); if (label) label.innerHTML = '<i class=\"fas fa-user mr-2\"></i> Edit Regular User';";
                }
            }
            ClientScript.RegisterStartupScript(this.GetType(), "toast_" + Guid.NewGuid().ToString("N"), script, true);
        }

        private void ShowGridMessage(string msg, bool success)
        {
            string type = success ? "success" : "error";
            string cleanMessage = msg.Replace("'", "\\'").Replace("\r", "").Replace("\n", " ");
            string script = string.Format("showToast('{0}', '{1}');", cleanMessage, type);
            ClientScript.RegisterStartupScript(this.GetType(), "toast_" + Guid.NewGuid().ToString("N"), script, true);
        }

        private void EnsureUserDivisionsTableExists()
        {
            try
            {
                string createTableQuery = @"
                    CREATE TABLE IF NOT EXISTS UserDivisions (
                        PCNO VARCHAR(50),
                        DivisionName VARCHAR(100),
                        PRIMARY KEY (PCNO, DivisionName)
                    )";
                DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), createTableQuery);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error creating UserDivisions table: " + ex.Message);
            }
        }

        private void PopulateUserDivisions()
        {
            try
            {
                cblUserDivisions.Items.Clear();
                string query = "SELECT Name FROM Divisions ORDER BY Name ASC";
                DataTable dt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), query);
                foreach (DataRow row in dt.Rows)
                {
                    cblUserDivisions.Items.Add(new System.Web.UI.WebControls.ListItem(row["Name"].ToString(), row["Name"].ToString()));
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error populating divisions checkbox list: " + ex.Message);
            }
        }

        protected void btnCancelUserEdit_Click(object sender, EventArgs e)
        {
            txtUserPCNO.Text = "";
            txtUserPCNO.ReadOnly = false;
            txtUserName.Text = "";
            foreach (System.Web.UI.WebControls.ListItem item in cblUserDivisions.Items)
            {
                item.Selected = false;
            }
            btnAddUser.Text = "Save Regular User";
            btnCancelUserEdit.Visible = false;

            // Reset form title and styling
            userFormTitle.InnerHtml = "<i class=\"fas fa-user mr-2\"></i> Add Regular User";
            userFormHeader.Style["background"] = "linear-gradient(135deg, #0f172a 0%, #1e293b 100%)";
        }

        protected void btnAddUser_Click(object sender, EventArgs e)
        {
            string pcno = txtUserPCNO.Text.Trim();
            string name = txtUserName.Text.Trim();
            
            if (string.IsNullOrEmpty(pcno) || string.IsNullOrEmpty(name))
            {
                ShowAdminMessage("PCNO and Name are required.", false);
                return;
            }
            
            // Get selected divisions
            System.Collections.Generic.List<string> selectedDivs = new System.Collections.Generic.List<string>();
            foreach (System.Web.UI.WebControls.ListItem item in cblUserDivisions.Items)
            {
                if (item.Selected)
                {
                    selectedDivs.Add(item.Value);
                }
            }
            
            if (selectedDivs.Count == 0)
            {
                ShowAdminMessage("Please select at least one division for the user.", false);
                return;
            }
            
            try
            {
                // 1. Insert/Update in CompanyDB (hrdata.empdetails)
                string queryEmp = @"
                    INSERT INTO empdetails (PCNO, NAME, DESIGNATION, DIVNAME) 
                    VALUES (@PCNO, @Name, 'Regular User', 'D-USER')
                    ON DUPLICATE KEY UPDATE NAME=@Name";
                
                MySqlParameter[] paramsEmp = new MySqlParameter[] {
                    new MySqlParameter("@PCNO", pcno),
                    new MySqlParameter("@Name", name)
                };
                DBHelper.ExecuteNonQuery(DBHelper.GetCompanyDBConnection(), queryEmp, paramsEmp);

                // 2. Insert/Update in AttendanceDB (AppUsers) as Role = 0 (Regular User)
                string queryUser = @"
                    INSERT INTO AppUsers (PCNO, Name, Role) 
                    VALUES (@PCNO, @Name, 0)
                    ON DUPLICATE KEY UPDATE Name = @Name, Role = 0";
                
                MySqlParameter[] paramsUser = new MySqlParameter[] {
                    new MySqlParameter("@PCNO", pcno),
                    new MySqlParameter("@Name", name)
                };
                DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), queryUser, paramsUser);

                // 3. Clear existing divisions for this user and insert new ones
                string deleteDivs = "DELETE FROM UserDivisions WHERE PCNO = @PCNO";
                DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), deleteDivs, new MySqlParameter("@PCNO", pcno));

                string insertDiv = "INSERT INTO UserDivisions (PCNO, DivisionName) VALUES (@PCNO, @Div)";
                foreach (string div in selectedDivs)
                {
                    DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), insertDiv, 
                        new MySqlParameter("@PCNO", pcno),
                        new MySqlParameter("@Div", div));
                }

                ShowAdminMessage($"Regular user '{name}' (PCNO: {pcno}) has been successfully saved/updated.", true);
                
                // Clear fields
                txtUserPCNO.Text = "";
                txtUserName.Text = "";
                txtUserPCNO.ReadOnly = false;
                btnAddUser.Text = "Save Regular User";
                btnCancelUserEdit.Visible = false;
                foreach (System.Web.UI.WebControls.ListItem item in cblUserDivisions.Items)
                {
                    item.Selected = false;
                }

                // Reset form title and styling
                userFormTitle.InnerHtml = "<i class=\"fas fa-user mr-2\"></i> Add Regular User";
                userFormHeader.Style["background"] = "linear-gradient(135deg, #0f172a 0%, #1e293b 100%)";

                // Rebind grids
                BindAdminGrid();
            }
            catch (Exception ex)
            {
                ShowAdminMessage("Error saving regular user: " + ex.Message, false);
            }
        }
    }
}

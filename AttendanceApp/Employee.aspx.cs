using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Web.UI.WebControls;
using AttendanceApp.Utils;
using MySqlConnector;

namespace AttendanceApp
{
    public partial class Employee : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!User.Identity.IsAuthenticated)
            {
                Response.Redirect("Login.aspx");
            }

            // Only admin can access employee master in the original logic
            int role = Convert.ToInt32(Session["Role"] ?? 0);
            if (role != 1)
            {
                Response.Write("<h2 style='color:red;text-align:center;margin-top:50px;'>Only Admin Can Access</h2>");
                Response.End();
            }

            if (!IsPostBack)
            {
                PopulateDropdowns();
                BindGrid();
            }
        }

        private void PopulateDropdowns()
        {
            try
            {
                // Populate Divisions
                string divQuery = "SELECT Name FROM Divisions ORDER BY Name ASC";
                DataTable dtDiv = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), divQuery);
                ddlDept.DataSource = dtDiv;
                ddlDept.DataTextField = "Name";
                ddlDept.DataValueField = "Name";
                ddlDept.DataBind();

                // Populate Categories
                string catQuery = "SELECT Name FROM Categories ORDER BY Name ASC";
                DataTable dtCat = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), catQuery);
                
                // For manual entry category
                ddlCat.DataSource = dtCat;
                ddlCat.DataTextField = "Name";
                ddlCat.DataValueField = "Name";
                ddlCat.DataBind();

                // For import category
                ddlImportCat.DataSource = dtCat;
                ddlImportCat.DataTextField = "Name";
                ddlImportCat.DataValueField = "Name";
                ddlImportCat.DataBind();

                // For search filter (preserve "All" at index 0 and clear existing dynamic items)
                string selectedFilter = ddlFilter.SelectedValue;
                ddlFilter.Items.Clear();
                ddlFilter.Items.Add(new ListItem("All", "All"));
                foreach (DataRow row in dtCat.Rows)
                {
                    ddlFilter.Items.Add(new ListItem(row["Name"].ToString(), row["Name"].ToString()));
                }
                
                // Try restoring selection if it still exists
                if (ddlFilter.Items.FindByValue(selectedFilter) != null)
                {
                    ddlFilter.SelectedValue = selectedFilter;
                }

                // For search division filter (preserve "All" at index 0 and clear existing dynamic items)
                string selectedDivFilter = ddlFilterDiv.SelectedValue;
                ddlFilterDiv.Items.Clear();
                ddlFilterDiv.Items.Add(new ListItem("All", "All"));
                foreach (DataRow row in dtDiv.Rows)
                {
                    ddlFilterDiv.Items.Add(new ListItem(row["Name"].ToString(), row["Name"].ToString()));
                }
                
                // Try restoring selection if it still exists
                if (ddlFilterDiv.Items.FindByValue(selectedDivFilter) != null)
                {
                    ddlFilterDiv.SelectedValue = selectedDivFilter;
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error populating dropdowns: " + ex.Message, false);
            }
        }

        private void BindGrid()
        {
            string filter = ddlFilter.SelectedValue;
            string divFilter = ddlFilterDiv.SelectedValue;
            string search = txtSearch.Text.Trim();
            string tabStatus = string.IsNullOrEmpty(hfActiveTab.Value) ? "Active" : hfActiveTab.Value;

            string query = "SELECT ID, Name, Department, Category, JoinDate, LeaveBalance, Status FROM Employees WHERE Status = @Status";
            
            if (filter != "All")
            {
                query += " AND Category = @Category";
            }
            if (divFilter != "All")
            {
                query += " AND Department = @Department";
            }
            if (!string.IsNullOrEmpty(search))
            {
                query += " AND (ID LIKE @Search OR Name LIKE @Search)";
            }
            
            query += " ORDER BY Department ASC, Name ASC";
            
            List<MySqlParameter> pList = new List<MySqlParameter>();
            pList.Add(new MySqlParameter("@Status", tabStatus));
            if (filter != "All") pList.Add(new MySqlParameter("@Category", filter));
            if (divFilter != "All") pList.Add(new MySqlParameter("@Department", divFilter));
            if (!string.IsNullOrEmpty(search)) pList.Add(new MySqlParameter("@Search", "%" + search + "%"));

            DataTable dt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), query, pList.ToArray());
            
            gvEmployees.DataSource = dt;
            gvEmployees.DataBind();

            // Set active states on the tab LinkButtons
            if (tabStatus == "Resigned")
            {
                btnTabActive.CssClass = "nav-link";
                btnTabResigned.CssClass = "nav-link active";
            }
            else
            {
                btnTabActive.CssClass = "nav-link active";
                btnTabResigned.CssClass = "nav-link";
            }
        }

        protected void btnAddEmployee_Click(object sender, EventArgs e)
        {
            try
            {
                string id = txtEmpID.Text.Trim();
                string name = txtEmpName.Text.Trim();
                string dept = ddlDept.SelectedValue;
                string cat = ddlCat.SelectedValue;
                string joinDate = txtJoinDate.Text;
                float l;
                float leave = float.TryParse(txtLeaveBalance.Text, out l) ? l : 0;
                string oldId = hfEditOldID.Value;

                if (string.IsNullOrEmpty(id) || string.IsNullOrEmpty(name))
                {
                    ShowMessage("ID and Name are required", false, "employeeModal");
                    return;
                }

                if (string.IsNullOrEmpty(oldId))
                {
                    // INSERT MODE
                    string qCheck = "SELECT COUNT(*) FROM Employees WHERE ID = @ID";
                    int count = Convert.ToInt32(DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), qCheck, new MySqlParameter("@ID", id)));
                    if (count > 0)
                    {
                        ShowMessage("Employee ID already exists.", false, "employeeModal");
                        return;
                    }

                    string query = "INSERT INTO Employees (ID, Name, Department, Category, JoinDate, LeaveBalance, Status) VALUES (@ID, @Name, @Dept, @Cat, @JoinDate, @Leave, 'Active')";
                    MySqlParameter[] p = new MySqlParameter[] {
                        new MySqlParameter("@ID", id),
                        new MySqlParameter("@Name", name),
                        new MySqlParameter("@Dept", dept),
                        new MySqlParameter("@Cat", cat),
                        new MySqlParameter("@JoinDate", string.IsNullOrEmpty(joinDate) ? (object)DBNull.Value : DateTime.Parse(joinDate)),
                        new MySqlParameter("@Leave", leave)
                    };
                    DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), query, p);
                    ShowMessage("Employee added successfully.", true);
                }
                else
                {
                    // UPDATE MODE
                    if (id != oldId)
                    {
                        string qCheck = "SELECT COUNT(*) FROM Employees WHERE ID = @ID";
                        int count = Convert.ToInt32(DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), qCheck, new MySqlParameter("@ID", id)));
                        if (count > 0)
                        {
                            ShowMessage("New Employee ID is already present.", false, "employeeModal");
                            return;
                        }
                    }

                    string updateQuery = "UPDATE Employees SET ID = @ID, Name = @Name, Department = @Dept, Category = @Cat, JoinDate = @JoinDate, LeaveBalance = @Leave WHERE ID = @OldID";
                    MySqlParameter[] pUpdate = new MySqlParameter[] {
                        new MySqlParameter("@ID", id),
                        new MySqlParameter("@Name", name),
                        new MySqlParameter("@Dept", dept),
                        new MySqlParameter("@Cat", cat),
                        new MySqlParameter("@JoinDate", string.IsNullOrEmpty(joinDate) ? (object)DBNull.Value : DateTime.Parse(joinDate)),
                        new MySqlParameter("@Leave", leave),
                        new MySqlParameter("@OldID", oldId)
                    };
                    DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), updateQuery, pUpdate);

                    if (id != oldId)
                    {
                        // Cascade update Attendance records
                        string updateAtt = "UPDATE Attendance SET EmpID = @NewID WHERE EmpID = @OldID";
                        DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), updateAtt, new MySqlParameter("@NewID", id), new MySqlParameter("@OldID", oldId));
                    }
                    
                    ShowMessage("Employee updated successfully.", true);
                }

                ResetForm();
                BindGrid();
            }
            catch(Exception ex)
            {
                ShowMessage("Error: " + ex.Message, false, "employeeModal");
            }
        }

        protected void btnImport_Click(object sender, EventArgs e)
        {
            if (fileCSV.HasFile)
            {
                try
                {
                    string cat = ddlImportCat.SelectedValue;
                    using (StreamReader sr = new StreamReader(fileCSV.PostedFile.InputStream))
                    {
                        string line = sr.ReadLine(); // header
                        while ((line = sr.ReadLine()) != null)
                        {
                            string[] v = line.Split(',');
                            if (v.Length >= 2 && !string.IsNullOrWhiteSpace(v[0]) && !string.IsNullOrWhiteSpace(v[1]))
                            {
                                string id = v[0].Trim();
                                string name = v[1].Trim();
                                string dept = v.Length > 2 ? v[2].Trim() : "GENERAL";
                                string joinDate = v.Length > 3 ? v[3].Trim() : "";
                                float l;
                                float leave = v.Length > 4 && float.TryParse(v[4], out l) ? l : 0;

                                // Auto-register new division if not exists in db
                                if (!string.IsNullOrEmpty(dept))
                                {
                                    string checkDiv = "SELECT COUNT(*) FROM Divisions WHERE Name = @Name";
                                    int divCount = Convert.ToInt32(DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), checkDiv, new MySqlParameter("@Name", dept)));
                                    if (divCount == 0)
                                    {
                                        string insertDiv = "INSERT INTO Divisions (Name) VALUES (@Name)";
                                        DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), insertDiv, new MySqlParameter("@Name", dept));
                                    }
                                }

                                // check if exists
                                string qCheck = "SELECT COUNT(*) FROM Employees WHERE ID = @ID";
                                int count = Convert.ToInt32(DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), qCheck, new MySqlParameter("@ID", id)));
                                if (count == 0)
                                {
                                    string query = "INSERT INTO Employees (ID, Name, Department, Category, JoinDate, LeaveBalance, Status) VALUES (@ID, @Name, @Dept, @Cat, @JoinDate, @Leave, 'Active')";
                                    MySqlParameter[] p = new MySqlParameter[] {
                                        new MySqlParameter("@ID", id),
                                        new MySqlParameter("@Name", name),
                                        new MySqlParameter("@Dept", dept),
                                        new MySqlParameter("@Cat", cat),
                                        new MySqlParameter("@JoinDate", string.IsNullOrEmpty(joinDate) ? (object)DBNull.Value : DateTime.Parse(joinDate)),
                                        new MySqlParameter("@Leave", leave)
                                    };
                                    DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), query, p);
                                }
                            }
                        }
                    }
                    PopulateDropdowns(); // Refresh dropdown lists with any new divisions from import
                    BindGrid();
                    ShowMessage("Import successful.", true);
                }
                catch(Exception ex)
                {
                    ShowMessage("Import Error: " + ex.Message, false, "importModal");
                }
            }
        }

        protected void btnTabActive_Click(object sender, EventArgs e)
        {
            hfActiveTab.Value = "Active";
            BindGrid();
        }

        protected void btnTabResigned_Click(object sender, EventArgs e)
        {
            hfActiveTab.Value = "Resigned";
            BindGrid();
        }

        protected string GetActiveCount()
        {
            try
            {
                string query = "SELECT COUNT(*) FROM Employees WHERE Status = 'Active'";
                object result = DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), query);
                return result != null ? result.ToString() : "0";
            }
            catch
            {
                return "0";
            }
        }

        protected string GetResignedCount()
        {
            try
            {
                string query = "SELECT COUNT(*) FROM Employees WHERE Status = 'Resigned'";
                object result = DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), query);
                return result != null ? result.ToString() : "0";
            }
            catch
            {
                return "0";
            }
        }

        protected void ddlFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            BindGrid();
        }

        protected void ddlFilterDiv_SelectedIndexChanged(object sender, EventArgs e)
        {
            BindGrid();
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            BindGrid();
        }

        protected void btnCancelEdit_Click(object sender, EventArgs e)
        {
            ResetForm();
            ShowMessage("Edit cancelled.", true);
        }

        private void ResetForm()
        {
            txtEmpID.Text = "";
            txtEmpName.Text = "";
            txtLeaveBalance.Text = "";
            txtJoinDate.Text = "";
            hfEditOldID.Value = "";
            btnAddEmployee.Text = "Add Employee";
            btnCancelEdit.Visible = false;
        }

        protected void gvEmployees_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            // Empty handler to allow GridView to fire RowCommand without error for CommandName="Delete" if used.
            // Actual delete logic will be in RowCommand.
        }

        protected void gvEmployees_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                HiddenField hfStatus = (HiddenField)e.Row.FindControl("hfStatus");
                DropDownList ddlStatus = (DropDownList)e.Row.FindControl("ddlStatus");
                
                if (hfStatus != null && ddlStatus != null)
                {
                    ddlStatus.SelectedValue = hfStatus.Value;
                    if (hfStatus.Value == "Resigned")
                    {
                        e.Row.CssClass = "resigned-row strike";
                    }
                }
            }
        }

        protected void ddlStatus_SelectedIndexChanged(object sender, EventArgs e)
        {
            DropDownList ddl = (DropDownList)sender;
            GridViewRow row = (GridViewRow)ddl.NamingContainer;
            HiddenField hfEmpID = (HiddenField)row.FindControl("hfEmpID");
            HiddenField hfResignDate = (HiddenField)row.FindControl("hfResignDate");

            string id = hfEmpID.Value;
            string status = ddl.SelectedValue;

            string resignDateQuery = status == "Resigned" ? ", ResignDate = @Date" : ", ResignDate = NULL";
            object dbDate = DBNull.Value;
            if (status == "Resigned")
            {
                DateTime dt;
                if (DateTime.TryParse(hfResignDate.Value, out dt))
                {
                    dbDate = dt;
                }
                else
                {
                    dbDate = DateTime.Now; // Fallback if JS fails or invalid date
                }
            }

            MySqlParameter pDate = new MySqlParameter("@Date", dbDate);

            string query = "UPDATE Employees SET Status = @Status " + resignDateQuery + " WHERE ID = @ID";
            MySqlParameter[] p = new MySqlParameter[] {
                new MySqlParameter("@Status", status),
                new MySqlParameter("@ID", id),
                pDate
            };

            DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), query, p);
            BindGrid();
        }

        protected void gvEmployees_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "EditEmp")
            {
                string id = e.CommandArgument.ToString();
                string query = "SELECT * FROM Employees WHERE ID = @ID";
                DataTable dt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), query, new MySqlParameter("@ID", id));
                if (dt.Rows.Count > 0)
                {
                    DataRow dr = dt.Rows[0];
                    hfEditOldID.Value = dr["ID"].ToString();
                    txtEmpID.Text = dr["ID"].ToString();
                    txtEmpName.Text = dr["Name"].ToString();
                    string deptValue = dr["Department"].ToString();
                    if (ddlDept.Items.FindByValue(deptValue) != null)
                    {
                        ddlDept.SelectedValue = deptValue;
                    }
                    else
                    {
                        ddlDept.Items.Add(new ListItem(deptValue, deptValue));
                        ddlDept.SelectedValue = deptValue;
                    }

                    string catValue = dr["Category"].ToString();
                    if (ddlCat.Items.FindByValue(catValue) != null)
                    {
                        ddlCat.SelectedValue = catValue;
                    }
                    else
                    {
                        ddlCat.Items.Add(new ListItem(catValue, catValue));
                        ddlCat.SelectedValue = catValue;
                    }

                    txtJoinDate.Text = dr["JoinDate"] != DBNull.Value ? Convert.ToDateTime(dr["JoinDate"]).ToString("yyyy-MM-dd") : "";
                    txtLeaveBalance.Text = dr["LeaveBalance"].ToString();
                    
                    btnAddEmployee.Text = "Update Employee";
                    btnCancelEdit.Visible = true;
                    ShowMessage("Editing employee " + txtEmpName.Text, true, "employeeModal");
                }
            }
            else if (e.CommandName == "DeleteEmp")
            {
                string id = e.CommandArgument.ToString();
                try
                {
                    string delAtt = "DELETE FROM Attendance WHERE EmpID = @ID";
                    DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), delAtt, new MySqlParameter("@ID", id));
                    
                    string delEmp = "DELETE FROM Employees WHERE ID = @ID";
                    DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), delEmp, new MySqlParameter("@ID", id));
                    
                    BindGrid();
                    ShowMessage("Employee and their attendance history completely deleted.", true);
                }
                catch (Exception ex)
                {
                    ShowMessage("Error deleting employee: " + ex.Message, false);
                }
            }
        }

        private void ShowMessage(string msg, bool success)
        {
            ShowMessage(msg, success, null);
        }

        private void ShowMessage(string msg, bool success, string showModalId)
        {
            lblMessage.Text = msg;
            lblMessage.Visible = false;

            string cleanMessage = msg.Replace("'", "\\'").Replace("\r", "").Replace("\n", " ");
            string toastType = success ? "success" : "error";
            string script = string.Format("showToast('{0}', '{1}');", cleanMessage, toastType);

            if (!string.IsNullOrEmpty(showModalId))
            {
                script += string.Format(" var modalEl = document.getElementById('{0}'); if (modalEl) {{ var modal = bootstrap.Modal.getInstance(modalEl) || new bootstrap.Modal(modalEl); modal.show(); }}", showModalId);
                if (showModalId == "employeeModal" && !string.IsNullOrEmpty(hfEditOldID.Value))
                {
                    script += " var label = document.getElementById('employeeModalLabel'); if (label) label.textContent = 'Edit Employee Details';";
                }
            }

            ClientScript.RegisterStartupScript(this.GetType(), "toast_" + Guid.NewGuid().ToString("N"), script, true);
        }
    }
}

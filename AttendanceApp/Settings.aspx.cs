using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using AttendanceApp.Utils;
using MySqlConnector;

namespace AttendanceApp
{
    public partial class Settings : System.Web.UI.Page
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

            if (!IsPostBack)
            {
                BindDivisions();
                BindCategories();
            }
        }

        private void ShowToast(string message, string type)
        {
            string cleanMessage = message.Replace("'", "\\'").Replace("\r", "").Replace("\n", " ");
            string script = string.Format("showToast('{0}', '{1}');", cleanMessage, type);
            ClientScript.RegisterStartupScript(this.GetType(), "toast_" + Guid.NewGuid().ToString("N"), script, true);
        }

        #region Division Management

        private void BindDivisions()
        {
            try
            {
                string query = "SELECT Id, Name FROM Divisions ORDER BY Name ASC";
                DataTable dt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), query);
                gvDivisions.DataSource = dt;
                gvDivisions.DataBind();
            }
            catch (Exception ex)
            {
                ShowToast("Error loading divisions: " + ex.Message, "error");
            }
        }

        protected void btnAddDiv_Click(object sender, EventArgs e)
        {
            string divName = txtNewDivName.Text.Trim();
            if (string.IsNullOrEmpty(divName))
            {
                ShowToast("Division name cannot be empty.", "warning");
                return;
            }

            try
            {
                string checkQuery = "SELECT COUNT(*) FROM Divisions WHERE Name = @Name";
                int count = Convert.ToInt32(DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), checkQuery, new MySqlParameter("@Name", divName)));
                if (count > 0)
                {
                    ShowToast("Division '" + divName + "' already exists.", "warning");
                    return;
                }

                string insertQuery = "INSERT INTO Divisions (Name) VALUES (@Name)";
                DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), insertQuery, new MySqlParameter("@Name", divName));
                txtNewDivName.Text = "";
                BindDivisions();
                ShowToast("Division '" + divName + "' added successfully.", "success");
            }
            catch (Exception ex)
            {
                ShowToast("Error adding division: " + ex.Message, "error");
            }
        }

        protected void gvDivisions_RowEditing(object sender, GridViewEditEventArgs e)
        {
            gvDivisions.EditIndex = e.NewEditIndex;
            BindDivisions();
        }

        protected void gvDivisions_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            gvDivisions.EditIndex = -1;
            BindDivisions();
        }

        protected void gvDivisions_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {
            int id = Convert.ToInt32(gvDivisions.DataKeys[e.RowIndex].Value);
            TextBox txtName = (TextBox)gvDivisions.Rows[e.RowIndex].FindControl("txtDivName");
            string newName = txtName != null ? txtName.Text.Trim() : "";

            if (string.IsNullOrEmpty(newName))
            {
                ShowToast("Division name cannot be empty.", "warning");
                return;
            }

            try
            {
                // Get old name first
                string getOldNameQuery = "SELECT Name FROM Divisions WHERE Id = @Id";
                string oldName = DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), getOldNameQuery, new MySqlParameter("@Id", id))?.ToString();

                if (string.IsNullOrEmpty(oldName))
                {
                    ShowToast("Error: Division not found.", "error");
                    return;
                }

                if (oldName.Equals(newName, StringComparison.OrdinalIgnoreCase))
                {
                    gvDivisions.EditIndex = -1;
                    BindDivisions();
                    return;
                }

                // Check for uniqueness
                string checkQuery = "SELECT COUNT(*) FROM Divisions WHERE Name = @Name AND Id != @Id";
                int count = Convert.ToInt32(DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), checkQuery, 
                    new MySqlParameter("@Name", newName),
                    new MySqlParameter("@Id", id)));
                if (count > 0)
                {
                    ShowToast("Division name '" + newName + "' is already in use.", "warning");
                    return;
                }

                // Update Divisions table
                string updateQuery = "UPDATE Divisions SET Name = @Name WHERE Id = @Id";
                DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), updateQuery, 
                    new MySqlParameter("@Name", newName),
                    new MySqlParameter("@Id", id));

                // Cascade update Employees table
                string cascadeQuery = "UPDATE Employees SET Department = @NewName WHERE Department = @OldName";
                DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), cascadeQuery, 
                    new MySqlParameter("@NewName", newName),
                    new MySqlParameter("@OldName", oldName));

                gvDivisions.EditIndex = -1;
                BindDivisions();
                ShowToast("Division updated to '" + newName + "' successfully.", "success");
            }
            catch (Exception ex)
            {
                ShowToast("Error updating division: " + ex.Message, "error");
            }
        }

        protected void gvDivisions_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            int id = Convert.ToInt32(gvDivisions.DataKeys[e.RowIndex].Value);

            try
            {
                // Get name first
                string getNameQuery = "SELECT Name FROM Divisions WHERE Id = @Id";
                string name = DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), getNameQuery, new MySqlParameter("@Id", id))?.ToString();

                if (string.IsNullOrEmpty(name))
                {
                    ShowToast("Error: Division not found.", "error");
                    return;
                }

                // Verify if division is assigned to any employees
                string countEmpQuery = "SELECT COUNT(*) FROM Employees WHERE Department = @Dept";
                int count = Convert.ToInt32(DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), countEmpQuery, new MySqlParameter("@Dept", name)));
                
                if (count > 0)
                {
                    ShowToast("Cannot delete: assigned to " + count + " employee(s).", "warning");
                    return;
                }

                // Delete
                string deleteQuery = "DELETE FROM Divisions WHERE Id = @Id";
                DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), deleteQuery, new MySqlParameter("@Id", id));

                BindDivisions();
                ShowToast("Division '" + name + "' deleted successfully.", "success");
            }
            catch (Exception ex)
            {
                ShowToast("Error deleting division: " + ex.Message, "error");
            }
        }

        #endregion

        #region Category Management

        private void BindCategories()
        {
            try
            {
                string query = "SELECT Id, Name FROM Categories ORDER BY Name ASC";
                DataTable dt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), query);
                gvCategories.DataSource = dt;
                gvCategories.DataBind();
            }
            catch (Exception ex)
            {
                ShowToast("Error loading categories: " + ex.Message, "error");
            }
        }

        protected void btnAddCat_Click(object sender, EventArgs e)
        {
            string catName = txtNewCatName.Text.Trim();
            if (string.IsNullOrEmpty(catName))
            {
                ShowToast("Category name cannot be empty.", "warning");
                return;
            }

            try
            {
                string checkQuery = "SELECT COUNT(*) FROM Categories WHERE Name = @Name";
                int count = Convert.ToInt32(DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), checkQuery, new MySqlParameter("@Name", catName)));
                if (count > 0)
                {
                    ShowToast("Category '" + catName + "' already exists.", "warning");
                    return;
                }

                string insertQuery = "INSERT INTO Categories (Name) VALUES (@Name)";
                DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), insertQuery, new MySqlParameter("@Name", catName));
                txtNewCatName.Text = "";
                BindCategories();
                ShowToast("Category '" + catName + "' added successfully.", "success");
            }
            catch (Exception ex)
            {
                ShowToast("Error adding category: " + ex.Message, "error");
            }
        }

        protected void gvCategories_RowEditing(object sender, GridViewEditEventArgs e)
        {
            gvCategories.EditIndex = e.NewEditIndex;
            BindCategories();
        }

        protected void gvCategories_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            gvCategories.EditIndex = -1;
            BindCategories();
        }

        protected void gvCategories_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {
            int id = Convert.ToInt32(gvCategories.DataKeys[e.RowIndex].Value);
            TextBox txtName = (TextBox)gvCategories.Rows[e.RowIndex].FindControl("txtCatName");
            string newName = txtName != null ? txtName.Text.Trim() : "";

            if (string.IsNullOrEmpty(newName))
            {
                ShowToast("Category name cannot be empty.", "warning");
                return;
            }

            try
            {
                // Get old name first
                string getOldNameQuery = "SELECT Name FROM Categories WHERE Id = @Id";
                string oldName = DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), getOldNameQuery, new MySqlParameter("@Id", id))?.ToString();

                if (string.IsNullOrEmpty(oldName))
                {
                    ShowToast("Error: Category not found.", "error");
                    return;
                }

                if (oldName.Equals(newName, StringComparison.OrdinalIgnoreCase))
                {
                    gvCategories.EditIndex = -1;
                    BindCategories();
                    return;
                }

                // Check for uniqueness
                string checkQuery = "SELECT COUNT(*) FROM Categories WHERE Name = @Name AND Id != @Id";
                int count = Convert.ToInt32(DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), checkQuery, 
                    new MySqlParameter("@Name", newName),
                    new MySqlParameter("@Id", id)));
                if (count > 0)
                {
                    ShowToast("Category name '" + newName + "' is already in use.", "warning");
                    return;
                }

                // Update Categories table
                string updateQuery = "UPDATE Categories SET Name = @Name WHERE Id = @Id";
                DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), updateQuery, 
                    new MySqlParameter("@Name", newName),
                    new MySqlParameter("@Id", id));

                // Cascade update Employees table
                string cascadeQuery = "UPDATE Employees SET Category = @NewName WHERE Category = @OldName";
                DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), cascadeQuery, 
                    new MySqlParameter("@NewName", newName),
                    new MySqlParameter("@OldName", oldName));

                // Cascade update CalculationWages table
                string cascadeWages = "UPDATE CalculationWages SET Category = @NewName WHERE Category = @OldName";
                DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), cascadeWages, 
                    new MySqlParameter("@NewName", newName),
                    new MySqlParameter("@OldName", oldName));

                // Cascade update CalculationOverrides table
                string cascadeOverrides = "UPDATE CalculationOverrides SET Category = @NewName WHERE Category = @OldName";
                DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), cascadeOverrides, 
                    new MySqlParameter("@NewName", newName),
                    new MySqlParameter("@OldName", oldName));

                gvCategories.EditIndex = -1;
                BindCategories();
                ShowToast("Category updated to '" + newName + "' successfully.", "success");
            }
            catch (Exception ex)
            {
                ShowToast("Error updating category: " + ex.Message, "error");
            }
        }

        protected void gvCategories_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            int id = Convert.ToInt32(gvCategories.DataKeys[e.RowIndex].Value);

            try
            {
                // Get name first
                string getNameQuery = "SELECT Name FROM Categories WHERE Id = @Id";
                string name = DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), getNameQuery, new MySqlParameter("@Id", id))?.ToString();

                if (string.IsNullOrEmpty(name))
                {
                    ShowToast("Error: Category not found.", "error");
                    return;
                }

                // Verify if category is assigned to any employees
                string countEmpQuery = "SELECT COUNT(*) FROM Employees WHERE Category = @Cat";
                int count = Convert.ToInt32(DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), countEmpQuery, new MySqlParameter("@Cat", name)));
                
                if (count > 0)
                {
                    ShowToast("Cannot delete: assigned to " + count + " employee(s).", "warning");
                    return;
                }

                // Verify if category has wages configured
                string countWagesQuery = "SELECT COUNT(*) FROM CalculationWages WHERE Category = @Cat";
                int countWages = Convert.ToInt32(DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), countWagesQuery, new MySqlParameter("@Cat", name)));

                if (countWages > 0)
                {
                    ShowToast("Cannot delete: category has wage records.", "warning");
                    return;
                }

                // Delete
                string deleteQuery = "DELETE FROM Categories WHERE Id = @Id";
                DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), deleteQuery, new MySqlParameter("@Id", id));

                BindCategories();
                ShowToast("Category '" + name + "' deleted successfully.", "success");
            }
            catch (Exception ex)
            {
                ShowToast("Error deleting category: " + ex.Message, "error");
            }
        }

        #endregion
    }
}

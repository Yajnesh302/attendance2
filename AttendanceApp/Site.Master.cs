using System;
using System.Web.Security;

namespace AttendanceApp
{
    public partial class SiteMaster : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["PCNO"] == null && Page.User.Identity.IsAuthenticated)
            {
                // Session was lost (e.g., app rebuild) but auth cookie remains. Force logout.
                FormsAuthentication.SignOut();
                Response.Redirect("Login.aspx");
                return;
            }

            int role = Convert.ToInt32(Session["Role"] ?? 0);
            if (role == 1)
            {
                lblUserName.InnerText = "Administrator";
                myfw.Attributes["class"] = "fas fa-user-shield text-success";
                phEmployeeMaster.Visible = true;
                phCalculation.Visible = true;
            }
            else
            {
                lblUserName.InnerText = "User";
                myfw.Attributes["class"] = "fas fa-user";
                phEmployeeMaster.Visible = false;
                phCalculation.Visible = false;
            }

            // Toggle sidebar and top nav visibility based on the page
            string currentPage = System.IO.Path.GetFileName(Request.Url.AbsolutePath);
            if (currentPage.Equals("Dashboard.aspx", StringComparison.OrdinalIgnoreCase) || 
                currentPage.Equals("Dashboard", StringComparison.OrdinalIgnoreCase))
            {
                phSidebar.Visible = true;
                phTopNav.Visible = false;
            }
            else
            {
                phSidebar.Visible = false;
                phTopNav.Visible = true;
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            FormsAuthentication.SignOut();
            Response.Redirect("Login.aspx");
        }
    }
}

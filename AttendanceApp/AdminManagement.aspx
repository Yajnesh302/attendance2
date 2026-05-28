<%@ Page Title="Admin Management" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AdminManagement.aspx.cs" Inherits="AttendanceApp.AdminManagement" EnableEventValidation="false" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Admin Management
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .admin-container {
            margin-top: 10px;
        }
        
        /* Custom styled Confirm Dialog Modal for Revoking Admin */
        #revokeConfirmModal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100vw;
            height: 100vh;
            background: rgba(15, 23, 42, 0.4);
            backdrop-filter: blur(8px);
            -webkit-backdrop-filter: blur(8px);
            z-index: 100000;
            align-items: center;
            justify-content: center;
            opacity: 0;
            transition: opacity 0.3s cubic-bezier(0.16, 1, 0.3, 1);
        }
        
        .confirm-modal-box {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 16px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25), inset 0 0 0 1px rgba(255, 255, 255, 0.6);
            width: 480px;
            max-width: 90%;
            transform: scale(0.92);
            transition: transform 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
            overflow: hidden;
            font-family: 'Segoe UI', system-ui, sans-serif;
            border: 1px solid rgba(226, 232, 240, 0.8);
        }
        
        .confirm-modal-header {
            background: #f8fafc;
            padding: 20px 24px;
            border-bottom: 1px solid #e2e8f0;
            display: flex;
            align-items: center;
            gap: 14px;
        }
        
        .confirm-modal-icon-container {
            background: #fee2e2;
            color: #dc2626;
            width: 42px;
            height: 42px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 4px 6px -1px rgba(220, 38, 38, 0.1);
        }
        
        .confirm-modal-title {
            font-size: 1.25rem;
            font-weight: 700;
            color: #0f172a;
            letter-spacing: -0.01em;
        }
        
        .confirm-modal-body {
            padding: 24px;
            font-size: 1rem;
            line-height: 1.6;
            color: #334155;
        }
        
        .confirm-modal-footer {
            background: #f8fafc;
            padding: 16px 24px;
            border-top: 1px solid #e2e8f0;
            display: flex;
            justify-content: flex-end;
            gap: 10px;
        }
        
        .btn-modal-action {
            padding: 10px 18px;
            font-size: 0.88rem;
            font-weight: 600;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
            border: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
        }
        
        .btn-modal-cancel {
            border: 1px solid #cbd5e1;
            background: white;
            color: #475569;
        }
        .btn-modal-cancel:hover {
            background: #f1f5f9;
            color: #1e293b;
            border-color: #94a3b8;
        }
        
        .btn-modal-revoke {
            background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
            color: white;
            box-shadow: 0 4px 12px rgba(239, 68, 68, 0.25);
        }
        .btn-modal-revoke:hover {
            box-shadow: 0 6px 16px rgba(239, 68, 68, 0.35);
            transform: translateY(-1px);
            color: white !important;
        }

        /* Custom Tabs Styling */
        .nav-tabs .nav-link {
            border: 1px solid transparent;
            color: #64748b !important;
            font-size: 0.9rem;
            transition: all 0.2s ease;
            padding: 10px 20px;
        }
        .nav-tabs .nav-link:hover {
            color: #4f46e5 !important;
            border-color: #f1f5f9 #f1f5f9 transparent;
            background-color: #fafbfc;
        }
        .nav-tabs .nav-link.active {
            border-color: #e2e8f0 #e2e8f0 #fff !important;
            background-color: #fff !important;
            color: #4f46e5 !important;
            font-weight: 700 !important;
            box-shadow: 0 -2px 6px rgba(0,0,0,0.02);
        }
        
        /* Division checklist custom styles */
        .division-checklist ul {
            list-style-type: none;
            padding-left: 0;
            margin-bottom: 0;
        }
        .division-checklist li {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 6px 12px;
            border-radius: 6px;
            transition: background-color 0.15s ease;
        }
        .division-checklist li:hover {
            background-color: #f1f5f9;
        }
        .division-checklist input[type="checkbox"] {
            width: 18px;
            height: 18px;
            cursor: pointer;
            accent-color: #4f46e5;
            margin-top: 0;
        }
        .division-checklist label {
            margin-bottom: 0;
            cursor: pointer;
            font-weight: 600;
            color: #334155;
            font-size: 0.9rem;
            user-select: none;
        }
        
        /* Readonly textbox style for editing mode */
        .form-control[readonly] {
            background-color: #f1f5f9 !important;
            color: #64748b !important;
            cursor: not-allowed;
            border-color: #cbd5e1 !important;
        }
    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="m-0 text-dark font-weight-bold">Admin Management</h2>
    </div>
    <hr class="mb-4" />
    
    <asp:HiddenField ID="hfActiveTab" runat="server" Value="NonAdmins" />
    
    <div class="row admin-container">
        <!-- Grid Registry and Forms side-by-side -->
        <div class="col-12 mb-4">
            <div class="card shadow-sm border-0 rounded-lg">
                <div class="card-header py-3 text-white d-flex justify-content-between align-items-center" style="background: linear-gradient(180deg,#4f46e5 10%,#3730a3 100%);">
                    <h5 class="m-0 font-weight-bold"><i class="fas fa-users-cog mr-2"></i> User Access Control Registry</h5>
                </div>
                <div class="card-body p-4 bg-white text-dark">
                    <!-- TABS NAVIGATION -->
                    <ul class="nav nav-tabs mb-4" id="adminTabs" role="tablist" style="border-bottom: 1px solid #e2e8f0;">
                        <li class="nav-item">
                            <asp:LinkButton ID="btnTabNonAdmins" runat="server" OnClick="btnTabNonAdmins_Click"
                                            CssClass="nav-link active"
                                            style="font-weight: 600; border-radius: 8px 8px 0 0; margin-right: 4px;">
                                Regular Users <span class="badge bg-secondary text-white ml-1" style="font-size: 0.75rem; padding: 3px 8px;"><%= GetNonAdminCount() %></span>
                            </asp:LinkButton>
                        </li>
                        <li class="nav-item">
                            <asp:LinkButton ID="btnTabAdmins" runat="server" OnClick="btnTabAdmins_Click"
                                            CssClass="nav-link"
                                            style="font-weight: 600; border-radius: 8px 8px 0 0; margin-right: 4px;">
                                System Administrators <span class="badge bg-success text-white ml-1" style="font-size: 0.75rem; padding: 3px 8px;"><%= GetAdminCount() %></span>
                            </asp:LinkButton>
                        </li>
                    </ul>

                    <asp:Label ID="lblGridMessage" runat="server" Visible="false" CssClass="alert d-block mb-3" role="alert"></asp:Label>
                    
                    <div class="row">
                        <!-- Left column: User Registry Grid -->
                        <div class="col-lg-7 col-xl-8 mb-4">
                            <div class="table-responsive bg-white rounded shadow-sm border" style="border-radius: 12px; overflow: hidden;">
                                <asp:GridView ID="gvAdminUsers" runat="server" AutoGenerateColumns="False" 
                                              CssClass="table table-hover align-middle mb-0" 
                                              DataKeyNames="PCNO" OnRowCommand="gvAdminUsers_RowCommand" GridLines="None">
                                    <Columns>
                                        <asp:BoundField DataField="PCNO" HeaderText="PCNO" HeaderStyle-CssClass="bg-light text-gray-800 font-weight-bold py-3 px-3 border-bottom" ItemStyle-CssClass="align-middle font-weight-bold py-3 px-3" />
                                        <asp:BoundField DataField="Name" HeaderText="Name" HeaderStyle-CssClass="bg-light text-gray-800 font-weight-bold py-3 px-3 border-bottom" ItemStyle-CssClass="align-middle py-3 px-3" NullDisplayText="N/A" />
                                        <asp:TemplateField HeaderText="Status / Access" HeaderStyle-CssClass="bg-light text-gray-800 font-weight-bold py-3 px-3 border-bottom" ItemStyle-CssClass="align-middle py-3 px-3">
                                            <ItemTemplate>
                                                <%# hfActiveTab.Value == "Admins" ? 
                                                    (Convert.ToInt32(Eval("Role")) == 1 ? "<span class='badge bg-success text-white px-2 py-1' style='font-size:0.75rem;'><i class='fas fa-check-circle mr-1'></i>Active Admin</span>" : "<span class='badge bg-danger text-white px-2 py-1' style='font-size:0.75rem;'><i class='fas fa-times-circle mr-1'></i>Access Revoked</span>") : 
                                                    (Convert.ToInt32(Eval("Role")) == 3 ? "<span class='badge bg-danger text-white px-2 py-1' style='font-size:0.75rem;'><i class='fas fa-times-circle mr-1'></i>Access Revoked</span>" :
                                                     (Eval("AllowedDivisions") == DBNull.Value || string.IsNullOrEmpty(Eval("AllowedDivisions").ToString()) ? "<span class='text-muted' style='font-size:0.85rem; font-style:italic;'>None</span>" : "<span class='font-weight-bold text-dark' style='font-size:0.88rem;'>" + Eval("AllowedDivisions") + "</span>")) %>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Actions" HeaderStyle-CssClass="bg-light text-gray-800 font-weight-bold text-center py-3 px-3 border-bottom" ItemStyle-CssClass="text-center align-middle py-3 px-3">
                                            <ItemTemplate>
                                                <!-- Revoke Button (Visible if active tab is Admins and Role == 1, or active tab is NonAdmins and Role == 0) -->
                                                <asp:LinkButton ID="lnkRevoke" runat="server" CommandName="RevokeAdmin" 
                                                                CommandArgument='<%# Eval("PCNO") %>' 
                                                                CssClass="btn btn-danger btn-sm font-weight-bold text-white px-3 py-1"
                                                                OnClientClick='<%# "return confirmRevoke(this, \"" + Eval("Name") + "\", \"" + Eval("PCNO") + "\");" %>'
                                                                Visible='<%# (hfActiveTab.Value == "Admins" && Convert.ToInt32(Eval("Role")) == 1) || (hfActiveTab.Value == "NonAdmins" && Convert.ToInt32(Eval("Role")) == 0) %>'
                                                                style="border-radius: 4px; box-shadow: 0 2px 4px rgba(220,38,38,0.15);">
                                                    <i class="fas fa-user-minus mr-1"></i> Revoke
                                                </asp:LinkButton>
                                                <!-- Grant Button (Visible if active tab is Admins and Role == 2, or active tab is NonAdmins and Role == 3) -->
                                                <asp:LinkButton ID="lnkGrant" runat="server" CommandName="GrantAdmin" 
                                                                CommandArgument='<%# Eval("PCNO") %>' 
                                                                CssClass="btn btn-success btn-sm font-weight-bold text-white px-3 py-1"
                                                                Visible='<%# (hfActiveTab.Value == "Admins" && Convert.ToInt32(Eval("Role")) == 2) || (hfActiveTab.Value == "NonAdmins" && Convert.ToInt32(Eval("Role")) == 3) %>'
                                                                style="border-radius: 4px; box-shadow: 0 2px 4px rgba(16,185,129,0.15);">
                                                    <i class="fas fa-user-plus mr-1"></i> Grant
                                                </asp:LinkButton>
                                                <!-- Edit Divisions Button (Visible if active tab is NonAdmins and Role == 0) -->
                                                <asp:LinkButton ID="lnkEdit" runat="server" CommandName="EditUserDivs" 
                                                                CommandArgument='<%# Eval("PCNO") %>' 
                                                                CssClass="btn btn-primary btn-sm font-weight-bold text-white px-3 py-1 ml-2"
                                                                Visible='<%# hfActiveTab.Value == "NonAdmins" && Convert.ToInt32(Eval("Role")) == 0 %>'
                                                                style="border-radius: 4px; background-color: #3b82f6; border-color: #3b82f6; box-shadow: 0 2px 4px rgba(59,130,246,0.15);">
                                                    <i class="fas fa-edit mr-1"></i> Edit
                                                </asp:LinkButton>
                                                <!-- Delete Button (Visible if active tab is Admins and Role == 2, or active tab is NonAdmins and Role == 3) -->
                                                <asp:LinkButton ID="lnkDelete" runat="server" CommandName="DeleteUser" 
                                                                CommandArgument='<%# Eval("PCNO") %>' 
                                                                CssClass="btn btn-danger btn-sm font-weight-bold text-white px-3 py-1 ml-2"
                                                                OnClientClick='<%# "return confirmDelete(this, \"" + Eval("Name") + "\", \"" + Eval("PCNO") + "\");" %>'
                                                                Visible='<%# (hfActiveTab.Value == "Admins" && Convert.ToInt32(Eval("Role")) == 2) || (hfActiveTab.Value == "NonAdmins" && Convert.ToInt32(Eval("Role")) == 3) %>'
                                                                style="border-radius: 4px; box-shadow: 0 2px 4px rgba(220,38,38,0.15);">
                                                    <i class="fas fa-trash-alt mr-1"></i> Delete
                                                </asp:LinkButton>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                    <EmptyDataTemplate>
                                        <div class="text-center p-4 text-muted">
                                            No records found in this category.
                                        </div>
                                    </EmptyDataTemplate>
                                </asp:GridView>
                            </div>
                        </div>

                        <!-- Right Column: Add/Edit Forms -->
                        <div class="col-lg-5 col-xl-4 mb-4">
                            <!-- Add Admin User Form -->
                            <asp:PlaceHolder ID="phAdminForm" runat="server">
                                <div class="card shadow-sm border rounded-lg">
                                    <div class="card-header py-3 text-white" style="background: linear-gradient(135deg, #4f46e5 0%, #3730a3 100%); border-radius: 8px 8px 0 0;">
                                        <h6 class="m-0 font-weight-bold"><i class="fas fa-user-shield mr-2"></i> Add New Admin User</h6>
                                    </div>
                                    <div class="card-body p-4 bg-light text-dark">
                                        <div class="form-group mb-3">
                                            <label class="form-label font-weight-bold text-gray-800" style="font-size: 0.9rem;">PCNO (Employee ID):</label>
                                            <asp:TextBox ID="txtAdminPCNO" runat="server" CssClass="form-control" placeholder="e.g. 1004" style="border-radius: 6px; padding: 10px;"></asp:TextBox>
                                        </div>
                                        <div class="form-group mb-4">
                                            <label class="form-label font-weight-bold text-gray-800" style="font-size: 0.9rem;">Full Name:</label>
                                            <asp:TextBox ID="txtAdminName" runat="server" CssClass="form-control" placeholder="e.g. Alice Smith" style="border-radius: 6px; padding: 10px;"></asp:TextBox>
                                        </div>
                                        <div>
                                            <asp:Button ID="btnAddAdmin" runat="server" Text="Create Admin User" CssClass="btn btn-primary btn-block font-weight-bold py-2 shadow-sm" OnClick="btnAddAdmin_Click" style="background: linear-gradient(135deg, #4f46e5 0%, #3730a3 100%); border: none; border-radius: 6px; font-size: 0.95rem;" />
                                        </div>
                                    </div>
                                </div>
                            </asp:PlaceHolder>

                            <!-- Add/Update Regular User Form -->
                            <asp:PlaceHolder ID="phUserForm" runat="server">
                                <div class="card shadow-sm border rounded-lg">
                                    <div ID="userFormHeader" runat="server" class="card-header py-3 text-white" style="background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%); border-radius: 8px 8px 0 0;">
                                        <h6 ID="userFormTitle" runat="server" class="m-0 font-weight-bold"><i class="fas fa-user mr-2"></i> Add Regular User</h6>
                                    </div>
                                    <div class="card-body p-4 bg-light text-dark">
                                        <div class="form-group mb-3">
                                            <label class="form-label font-weight-bold text-gray-800" style="font-size: 0.9rem;">PCNO (Employee ID):</label>
                                            <asp:TextBox ID="txtUserPCNO" runat="server" CssClass="form-control" placeholder="e.g. 1005" style="border-radius: 6px; padding: 10px;"></asp:TextBox>
                                        </div>
                                        <div class="form-group mb-3">
                                            <label class="form-label font-weight-bold text-gray-800" style="font-size: 0.9rem;">Full Name:</label>
                                            <asp:TextBox ID="txtUserName" runat="server" CssClass="form-control" placeholder="e.g. Bob Jones" style="border-radius: 6px; padding: 10px;"></asp:TextBox>
                                        </div>
                                        <div class="form-group mb-4">
                                            <label class="form-label font-weight-bold text-gray-800" style="font-size: 0.9rem;">Allowed Divisions (Access Control):</label>
                                            <div class="border rounded p-3 division-checklist" style="max-height: 220px; overflow-y: auto; background-color: #f8fafc; border-color: #cbd5e1; border-radius: 6px;">
                                                <asp:CheckBoxList ID="cblUserDivisions" runat="server" CssClass="w-100" RepeatLayout="UnorderedList">
                                                </asp:CheckBoxList>
                                            </div>
                                        </div>
                                        <div class="d-flex align-items-center">
                                            <asp:Button ID="btnCancelUserEdit" runat="server" Text="Cancel" CssClass="btn btn-secondary font-weight-bold py-2 mr-2" OnClick="btnCancelUserEdit_Click" Visible="false" style="border-radius: 6px; flex: 1; font-size: 0.95rem;" />
                                            <asp:Button ID="btnAddUser" runat="server" Text="Save Regular User" CssClass="btn btn-primary font-weight-bold py-2" OnClick="btnAddUser_Click" style="background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%); border: none; border-radius: 6px; flex: 2; font-size: 0.95rem;" />
                                        </div>
                                    </div>
                                </div>
                            </asp:PlaceHolder>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Custom Revoke Confirm Modal -->
    <div id="revokeConfirmModal">
        <div class="confirm-modal-box">
            <div class="confirm-modal-header" style="background: #fef2f2; border-bottom: 1px solid #fee2e2;">
                <div class="confirm-modal-icon-container">
                    <i class="fas fa-user-shield"></i>
                </div>
                <span class="confirm-modal-title">Revoke Admin Access</span>
            </div>
            <div class="confirm-modal-body">
                <span id="revokeConfirmPrompt">Are you sure you want to revoke administrator access for</span> <strong id="revokeAdminName" class="text-dark"></strong> (PCNO: <span id="revokeAdminPcno" class="text-secondary"></span>)?
                <div id="revokeConfirmDesc" style="margin-top: 12px; font-size: 0.88rem; color: #64748b; line-height: 1.5;">
                    This user will no longer be able to access the admin management, configurations, or calculation tools. Their details will be kept in the registry for future promotions.
                </div>
            </div>
            <div class="confirm-modal-footer">
                <button id="btnRevokeModalCancel" type="button" class="btn-modal-action btn-modal-cancel">Cancel</button>
                <button id="btnRevokeModalConfirm" type="button" class="btn-modal-action btn-modal-revoke">Revoke Access</button>
            </div>
        </div>
    </div>

    <!-- Custom Delete Confirm Modal -->
    <div id="deleteConfirmModal" style="display: none; position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; background: rgba(15, 23, 42, 0.4); backdrop-filter: blur(8px); -webkit-backdrop-filter: blur(8px); z-index: 100000; align-items: center; justify-content: center; opacity: 0; transition: opacity 0.3s cubic-bezier(0.16, 1, 0.3, 1);">
        <div class="confirm-modal-box">
            <div class="confirm-modal-header" style="background: #fef2f2; border-bottom: 1px solid #fee2e2;">
                <div class="confirm-modal-icon-container" style="background: #fee2e2; color: #dc2626;">
                    <i class="fas fa-trash-alt"></i>
                </div>
                <span class="confirm-modal-title">Delete User from Registry</span>
            </div>
            <div class="confirm-modal-body">
                Are you sure you want to permanently delete <strong id="deleteAdminName" class="text-dark"></strong> (PCNO: <span id="deleteAdminPcno" class="text-secondary"></span>) from the registry?
                <div style="margin-top: 12px; font-size: 0.88rem; color: #64748b; line-height: 1.5;">
                    This will completely remove their record from the administrative database table (`AppUsers`). They will no longer appear in the Non-Admins registry.
                </div>
            </div>
            <div class="confirm-modal-footer">
                <button id="btnDeleteModalCancel" type="button" class="btn-modal-action btn-modal-cancel">Cancel</button>
                <button id="btnDeleteModalConfirm" type="button" class="btn-modal-action btn-modal-revoke">Delete</button>
            </div>
        </div>
    </div>

    <script>
        let targetCommand = null;

        function confirmRevoke(element, name, pcno) {
            const modal = document.getElementById("revokeConfirmModal");
            const adminNameSpan = document.getElementById("revokeAdminName");
            const adminPcnoSpan = document.getElementById("revokeAdminPcno");
            const btnConfirm = document.getElementById("btnRevokeModalConfirm");
            const btnCancel = document.getElementById("btnRevokeModalCancel");

            if (!modal || !adminNameSpan || !adminPcnoSpan) return true;

            adminNameSpan.textContent = name;
            adminPcnoSpan.textContent = pcno;

            // Customize modal text dynamically based on the active tab
            const activeTab = document.getElementById('<%= hfActiveTab.ClientID %>').value;
            const titleSpan = modal.querySelector(".confirm-modal-title");
            const promptSpan = document.getElementById("revokeConfirmPrompt");
            const descDiv = document.getElementById("revokeConfirmDesc");
            const icon = modal.querySelector(".confirm-modal-icon-container i");

            if (activeTab === "Admins") {
                if (titleSpan) titleSpan.textContent = "Revoke Admin Access";
                if (promptSpan) promptSpan.textContent = "Are you sure you want to revoke administrator access for";
                if (descDiv) descDiv.textContent = "This user will no longer be able to access the admin management, configurations, or calculation tools. Their details will be kept in the registry for future promotions.";
                if (icon) icon.className = "fas fa-user-shield";
            } else {
                if (titleSpan) titleSpan.textContent = "Revoke User Access";
                if (promptSpan) promptSpan.textContent = "Are you sure you want to revoke regular user access for";
                if (descDiv) descDiv.textContent = "This user will no longer be able to access the attendance or ledger views. Their details and division mappings will be preserved in the registry.";
                if (icon) icon.className = "fas fa-user-minus";
            }
            
            // Save the postback script/href to execute if confirmed
            const originalHref = element.getAttribute("href");
            targetCommand = () => {
                if (originalHref.startsWith("javascript:")) {
                    // Eval the postback script
                    eval(originalHref.substring(11));
                } else {
                    // Navigate or click
                    window.location.href = originalHref;
                }
            };

            // Show modal
            modal.style.display = "flex";
            modal.offsetHeight; // trigger reflow
            modal.style.opacity = "1";
            modal.querySelector(".confirm-modal-box").style.transform = "scale(1)";

            btnCancel.onclick = () => {
                closeRevokeModal();
            };

            btnConfirm.onclick = () => {
                closeRevokeModal();
                if (targetCommand) targetCommand();
            };

            function closeRevokeModal() {
                modal.style.opacity = "0";
                modal.querySelector(".confirm-modal-box").style.transform = "scale(0.92)";
                setTimeout(() => {
                    modal.style.display = "none";
                }, 250);
            }

            return false; // Prevent immediate postback
        }

        function confirmDelete(element, name, pcno) {
            const modal = document.getElementById("deleteConfirmModal");
            const adminNameSpan = document.getElementById("deleteAdminName");
            const adminPcnoSpan = document.getElementById("deleteAdminPcno");
            const btnConfirm = document.getElementById("btnDeleteModalConfirm");
            const btnCancel = document.getElementById("btnDeleteModalCancel");

            if (!modal || !adminNameSpan || !adminPcnoSpan) return true;

            adminNameSpan.textContent = name;
            adminPcnoSpan.textContent = pcno;
            
            // Save the postback script/href to execute if confirmed
            const originalHref = element.getAttribute("href");
            targetCommand = () => {
                if (originalHref.startsWith("javascript:")) {
                    // Eval the postback script
                    eval(originalHref.substring(11));
                } else {
                    // Navigate or click
                    window.location.href = originalHref;
                }
            };

            // Show modal
            modal.style.display = "flex";
            modal.offsetHeight; // trigger reflow
            modal.style.opacity = "1";
            modal.querySelector(".confirm-modal-box").style.transform = "scale(1)";

            btnCancel.onclick = () => {
                closeDeleteModal();
            };

            btnConfirm.onclick = () => {
                closeDeleteModal();
                if (targetCommand) targetCommand();
            };

            function closeDeleteModal() {
                modal.style.opacity = "0";
                modal.querySelector(".confirm-modal-box").style.transform = "scale(0.92)";
                setTimeout(() => {
                    modal.style.display = "none";
                }, 250);
            }

            return false; // Prevent immediate postback
        }
    </script>
</asp:Content>

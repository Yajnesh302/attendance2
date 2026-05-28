<%@ Page Title="Settings" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Settings.aspx.cs" Inherits="AttendanceApp.Settings" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Settings & Configurations
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .settings-container {
            margin-top: 10px;
        }
        .card-header-gradient {
            background: linear-gradient(180deg, #4f46e5 10%, #3730a3 100%);
        }
        .table-custom-settings th {
            background-color: #f8fafc;
            color: #334155;
            font-weight: 700;
            border-bottom: 2px solid #e2e8f0;
            padding: 12px 16px;
        }
        .table-custom-settings td {
            color: #0f172a;
            vertical-align: middle !important;
            padding: 12px 16px;
        }
        .action-column {
            width: 180px;
            text-align: center;
        }
        .list-group-item-action {
            cursor: pointer;
            transition: all 0.2s ease;
            color: #334155;
        }
        .list-group-item-action:hover {
            background-color: #f1f5f9;
            color: #4f46e5;
            padding-left: 24px;
        }
        .list-group-item-action.active {
            padding-left: 24px;
        }
    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <h2>Settings & Configurations</h2>
    <hr />
    
    <asp:HiddenField ID="hfActiveTab" runat="server" ClientIDMode="Static" Value="divisions" />

    <div class="row settings-container">
        <!-- Sidebar Menu Column -->
        <div class="col-md-3 mb-4">
            <div class="card shadow-sm border-0 rounded-lg">
                <div class="card-header py-3 text-white card-header-gradient">
                    <h6 class="m-0 font-weight-bold"><i class="fas fa-sliders-h mr-2"></i> Settings Menu</h6>
                </div>
                <div class="list-group list-group-flush" id="settings-menu">
                    <a href="javascript:void(0);" onclick="switchTab('divisions')" id="tab-divisions" class="list-group-item list-group-item-action font-weight-bold py-3">
                        <i class="fas fa-building mr-2"></i> Divisions
                    </a>
                    <a href="javascript:void(0);" onclick="switchTab('categories')" id="tab-categories" class="list-group-item list-group-item-action font-weight-bold py-3">
                        <i class="fas fa-tags mr-2"></i> Categories
                    </a>
                </div>
            </div>
        </div>

        <!-- Settings Content Column -->
        <div class="col-md-9 mb-4">
            <!-- Division Management Panel -->
            <div id="panel-divisions" class="card shadow-sm border-0 rounded-lg" style="display:none;">
                <div class="card-header py-3 text-white card-header-gradient">
                    <h5 class="m-0 font-weight-bold"><i class="fas fa-building mr-2"></i> Division Management</h5>
                </div>
                <div class="card-body p-4 bg-white text-dark">
                    <!-- Add Division Form -->
                    <div class="input-group mb-4">
                        <asp:TextBox ID="txtNewDivName" runat="server" CssClass="form-control" placeholder="New Division Name (e.g. D-SALES)" MaxLength="100"></asp:TextBox>
                        <div class="input-group-append">
                            <asp:Button ID="btnAddDiv" runat="server" Text="Add Division" CssClass="btn btn-primary px-4" OnClick="btnAddDiv_Click" style="background-color: #4f46e5; border-color: #4f46e5;" />
                        </div>
                    </div>

                    <!-- Division GridView -->
                    <div class="table-responsive">
                        <asp:GridView ID="gvDivisions" runat="server" AutoGenerateColumns="False" 
                                      CssClass="table table-bordered table-hover table-custom-settings mb-0" 
                                      DataKeyNames="Id" 
                                      OnRowEditing="gvDivisions_RowEditing" 
                                      OnRowCancelingEdit="gvDivisions_RowCancelingEdit" 
                                      OnRowUpdating="gvDivisions_RowUpdating" 
                                      OnRowDeleting="gvDivisions_RowDeleting" 
                                      GridLines="None">
                            <Columns>
                                <asp:TemplateField HeaderText="Division Name">
                                    <ItemTemplate>
                                        <asp:Label ID="lblDivName" runat="server" Text='<%# Eval("Name") %>' Font-Bold="true"></asp:Label>
                                    </ItemTemplate>
                                    <EditItemTemplate>
                                        <asp:TextBox ID="txtDivName" runat="server" Text='<%# Bind("Name") %>' CssClass="form-control form-control-sm" MaxLength="100"></asp:TextBox>
                                    </EditItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Actions" ItemStyle-CssClass="action-column">
                                    <ItemTemplate>
                                        <div class="d-flex justify-content-center gap-2">
                                            <asp:LinkButton ID="btnEdit" runat="server" CommandName="Edit" CssClass="btn btn-sm btn-outline-primary py-1 px-2" ToolTip="Edit Division">
                                                <i class="fas fa-edit"></i> Edit
                                            </asp:LinkButton>
                                            <asp:LinkButton ID="btnDelete" runat="server" CommandName="Delete" CssClass="btn btn-sm btn-outline-danger py-1 px-2" ToolTip="Delete Division" 
                                                            OnClientClick='<%# "return confirmDelete(this, \"" + Eval("Name") + "\", \"division\");" %>'>
                                                <i class="fas fa-trash"></i> Delete
                                            </asp:LinkButton>
                                        </div>
                                    </ItemTemplate>
                                    <EditItemTemplate>
                                        <div class="d-flex justify-content-center gap-2">
                                            <asp:LinkButton ID="btnUpdate" runat="server" CommandName="Update" CssClass="btn btn-sm btn-success py-1 px-2" ToolTip="Save Changes">
                                                <i class="fas fa-check"></i> Save
                                            </asp:LinkButton>
                                            <asp:LinkButton ID="btnCancel" runat="server" CommandName="Cancel" CssClass="btn btn-sm btn-secondary py-1 px-2" ToolTip="Cancel Edit">
                                                <i class="fas fa-times"></i> Cancel
                                            </asp:LinkButton>
                                        </div>
                                    </EditItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                            <EmptyDataTemplate>
                                <div class="text-center p-3 text-muted">
                                    No divisions configured.
                                </div>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
            </div>

            <!-- Category Management Panel -->
            <div id="panel-categories" class="card shadow-sm border-0 rounded-lg" style="display:none;">
                <div class="card-header py-3 text-white card-header-gradient">
                    <h5 class="m-0 font-weight-bold"><i class="fas fa-tags mr-2"></i> Category Management</h5>
                </div>
                <div class="card-body p-4 bg-white text-dark">
                    <!-- Add Category Form -->
                    <div class="input-group mb-4">
                        <asp:TextBox ID="txtNewCatName" runat="server" CssClass="form-control" placeholder="New Category Name (e.g. Executive)" MaxLength="100"></asp:TextBox>
                        <div class="input-group-append">
                            <asp:Button ID="btnAddCat" runat="server" Text="Add Category" CssClass="btn btn-primary px-4" OnClick="btnAddCat_Click" style="background-color: #4f46e5; border-color: #4f46e5;" />
                        </div>
                    </div>

                    <!-- Category GridView -->
                    <div class="table-responsive">
                        <asp:GridView ID="gvCategories" runat="server" AutoGenerateColumns="False" 
                                      CssClass="table table-bordered table-hover table-custom-settings mb-0" 
                                      DataKeyNames="Id" 
                                      OnRowEditing="gvCategories_RowEditing" 
                                      OnRowCancelingEdit="gvCategories_RowCancelingEdit" 
                                      OnRowUpdating="gvCategories_RowUpdating" 
                                      OnRowDeleting="gvCategories_RowDeleting" 
                                      GridLines="None">
                            <Columns>
                                <asp:TemplateField HeaderText="Category Name">
                                    <ItemTemplate>
                                        <asp:Label ID="lblCatName" runat="server" Text='<%# Eval("Name") %>' Font-Bold="true"></asp:Label>
                                    </ItemTemplate>
                                    <EditItemTemplate>
                                        <asp:TextBox ID="txtCatName" runat="server" Text='<%# Bind("Name") %>' CssClass="form-control form-control-sm" MaxLength="100"></asp:TextBox>
                                    </EditItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Actions" ItemStyle-CssClass="action-column">
                                    <ItemTemplate>
                                        <div class="d-flex justify-content-center gap-2">
                                            <asp:LinkButton ID="btnEdit" runat="server" CommandName="Edit" CssClass="btn btn-sm btn-outline-primary py-1 px-2" ToolTip="Edit Category">
                                                <i class="fas fa-edit"></i> Edit
                                            </asp:LinkButton>
                                            <asp:LinkButton ID="btnDelete" runat="server" CommandName="Delete" CssClass="btn btn-sm btn-outline-danger py-1 px-2" ToolTip="Delete Category" 
                                                            OnClientClick='<%# "return confirmDelete(this, \"" + Eval("Name") + "\", \"category\");" %>'>
                                                <i class="fas fa-trash"></i> Delete
                                            </asp:LinkButton>
                                        </div>
                                    </ItemTemplate>
                                    <EditItemTemplate>
                                        <div class="d-flex justify-content-center gap-2">
                                            <asp:LinkButton ID="btnUpdate" runat="server" CommandName="Update" CssClass="btn btn-sm btn-success py-1 px-2" ToolTip="Save Changes">
                                                <i class="fas fa-check"></i> Save
                                            </asp:LinkButton>
                                            <asp:LinkButton ID="btnCancel" runat="server" CommandName="Cancel" CssClass="btn btn-sm btn-secondary py-1 px-2" ToolTip="Cancel Edit">
                                                <i class="fas fa-times"></i> Cancel
                                            </asp:LinkButton>
                                        </div>
                                    </EditItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                            <EmptyDataTemplate>
                                <div class="text-center p-3 text-muted">
                                    No categories configured.
                                </div>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        let deleteTarget = null;
        function confirmDelete(sender, name, type) {
            if (deleteTarget === sender) {
                deleteTarget = null;
                return true; // Allow postback
            }
            
            Swal.fire({
                title: 'Delete Confirmation',
                text: `Are you sure you want to delete the ${type} '${name}'? This action cannot be undone.`,
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#ef4444',
                cancelButtonColor: '#64748b',
                confirmButtonText: 'Yes, delete it!',
                cancelButtonText: 'Cancel',
                customClass: {
                    popup: 'shadow-lg rounded-lg border-0 bg-white text-dark',
                    title: 'font-weight-bold text-dark',
                    confirmButton: 'btn btn-danger font-weight-bold px-4 py-2',
                    cancelButton: 'btn btn-secondary font-weight-bold px-4 py-2 ml-2'
                },
                buttonsStyling: false
            }).then((result) => {
                if (result.isConfirmed) {
                    deleteTarget = sender;
                    sender.click(); // Re-trigger the click event
                }
            });
            
            return false; // Block immediate postback
        }

        function switchTab(tabName) {
            // Update hidden field value
            const hf = document.getElementById('hfActiveTab');
            if (hf) hf.value = tabName;
            
            // Remove active classes from all menu items
            document.querySelectorAll('#settings-menu a').forEach(el => {
                el.classList.remove('active', 'text-white');
                el.style.backgroundColor = '';
                
                const icon = el.querySelector('i');
                if (icon) {
                    // Reset colors of icons
                    if (el.id === 'tab-divisions') {
                        icon.className = 'fas fa-building mr-2 text-primary';
                    } else if (el.id === 'tab-categories') {
                        icon.className = 'fas fa-tags mr-2 text-success';
                    }
                }
            });
            
            // Hide all panels
            const panelDiv = document.getElementById('panel-divisions');
            const panelCat = document.getElementById('panel-categories');
            if (panelDiv) panelDiv.style.display = 'none';
            if (panelCat) panelCat.style.display = 'none';
            
            // Show selected panel & make menu item active
            if (tabName === 'divisions') {
                if (panelDiv) panelDiv.style.display = 'block';
                const menuEl = document.getElementById('tab-divisions');
                if (menuEl) {
                    menuEl.classList.add('active', 'text-white');
                    menuEl.style.backgroundColor = '#4f46e5';
                    const icon = menuEl.querySelector('i');
                    if (icon) icon.className = 'fas fa-building mr-2 text-white';
                }
            } else if (tabName === 'categories') {
                if (panelCat) panelCat.style.display = 'block';
                const menuEl = document.getElementById('tab-categories');
                if (menuEl) {
                    menuEl.classList.add('active', 'text-white');
                    menuEl.style.backgroundColor = '#4f46e5';
                    const icon = menuEl.querySelector('i');
                    if (icon) icon.className = 'fas fa-tags mr-2 text-white';
                }
            }
        }
        
        // Initialize on page load
        document.addEventListener('DOMContentLoaded', function() {
            const hf = document.getElementById('hfActiveTab');
            const activeTab = (hf && hf.value) ? hf.value : 'divisions';
            switchTab(activeTab);
        });

        // Handle page reloads / postbacks (ASP.NET WebForms specific)
        if (typeof window.Sys !== 'undefined' && typeof window.Sys.WebForms !== 'undefined') {
            var prm = Sys.WebForms.PageRequestManager.getInstance();
            prm.add_endRequest(function() {
                const hf = document.getElementById('hfActiveTab');
                const activeTab = (hf && hf.value) ? hf.value : 'divisions';
                switchTab(activeTab);
            });
        }
    </script>
</asp:Content>

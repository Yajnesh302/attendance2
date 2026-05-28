<%@ Page Title="Employee Master" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Employee.aspx.cs" Inherits="AttendanceApp.Employee" EnableEventValidation="false" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Employee Master
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .panel {
            background: white;
            padding: 20px;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.05);
            margin-bottom: 20px;
            border: 1px solid #f1f5f9;
        }
        
        /* Modern Table Styling */
        .table-custom {
            border-collapse: separate !important;
            border-spacing: 0 !important;
            width: 100% !important;
            border: 1px solid #e2e8f0 !important; /* Outer table border */
            border-radius: 12px !important;
            overflow: hidden !important;
        }
        .table-custom th {
            background-color: #f8fafc !important; /* Soft slate gray */
            color: #475569 !important; /* Slate color */
            font-size: 0.8rem !important;
            text-transform: uppercase !important;
            letter-spacing: 0.06em !important;
            font-weight: 700 !important;
            padding: 14px 20px !important;
            border-top: none !important;
            border-bottom: 2px solid #e2e8f0 !important;
            border-left: none !important;
            border-right: 1px solid #e2e8f0 !important; /* Clean vertical line in header */
            vertical-align: middle !important;
        }
        .table-custom th:last-child {
            border-right: none !important;
        }
        .table-custom td {
            padding: 14px 20px !important;
            color: #334155 !important; /* Charcoal slate */
            font-size: 0.92rem !important;
            font-weight: 500 !important;
            border-bottom: 1px solid #e2e8f0 !important; /* Horizontal separating lines */
            border-left: none !important;
            border-right: 1px solid #f1f5f9 !important; /* Soft vertical separating lines */
            vertical-align: middle !important;
        }
        .table-custom td:last-child {
            border-right: none !important;
        }
        .table-custom tr:last-child td {
            border-bottom: none !important; /* Remove bottom border on the last row */
        }
        .table-custom tr {
            transition: background-color 0.2s ease;
        }
        .table-custom tr:hover {
            background-color: #eef2ff !important; /* Distinct light indigo hover */
        }
        .table-custom tr:nth-child(even) {
            background-color: #fbfcfd;
        }
        
        /* Modern Pill Badge for Dropdown */
        .status-badge {
            border-radius: 50px !important;
            font-size: 0.78rem !important;
            font-weight: 700 !important;
            padding: 2px 24px 2px 10px !important; /* Right padding for custom Bootstrap select arrow */
            width: 110px !important;
            height: 28px !important;
            line-height: 1.2 !important;
            cursor: pointer !important;
            border: 1px solid transparent !important;
            display: inline-block !important;
            box-shadow: 0 1px 2px rgba(0,0,0,0.05);
            transition: all 0.15s ease;
        }
        
        /* Active Status Color Accent */
        select.status-badge {
            background-color: #ecfdf5 !important; /* Light green */
            color: #047857 !important; /* Dark green */
            border-color: #a7f3d0 !important;
        }
        select.status-badge:focus {
            box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.15) !important;
            border-color: #34d399 !important;
        }

        /* Resigned Status Color Accent */
        .resigned-row select.status-badge {
            background-color: #fef2f2 !important; /* Light red */
            color: #b91c1c !important; /* Dark red */
            border-color: #fecaca !important;
        }
        .resigned-row select.status-badge:focus {
            box-shadow: 0 0 0 3px rgba(239, 68, 68, 0.15) !important;
            border-color: #f87171 !important;
        }

        /* Resigned Row Muted Effect (Selective strike-through) */
        .resigned-row {
            background-color: #fbfcfd !important;
            opacity: 0.8;
        }
        .resigned-row td {
            color: #94a3b8 !important; /* Muted gray text */
        }
        .resigned-row td:nth-child(2), /* ID */
        .resigned-row td:nth-child(3), /* Name */
        .resigned-row td:nth-child(4), /* Department */
        .resigned-row td:nth-child(5), /* Category */
        .resigned-row td:nth-child(6), /* Join Date */
        .resigned-row td:nth-child(7)  /* Leave Balance */ {
            text-decoration: line-through !important;
            text-decoration-color: #cbd5e1 !important;
        }
        
        /* Modern Buttons in Table */
        .table-custom .btn-outline-primary {
            border-color: #e2e8f0;
            color: #4f46e5;
            background-color: #f8fafc;
            border-radius: 6px;
            font-weight: 600;
            padding: 5px 12px;
            font-size: 0.8rem;
            transition: all 0.2s ease;
        }
        .table-custom .btn-outline-primary:hover {
            background-color: #4f46e5;
            border-color: #4f46e5;
            color: white;
            transform: translateY(-1.5px);
            box-shadow: 0 4px 10px rgba(79, 70, 229, 0.15);
        }
        .table-custom .btn-outline-danger {
            border-color: #e2e8f0;
            color: #dc2626;
            background-color: #f8fafc;
            border-radius: 6px;
            font-weight: 600;
            padding: 5px 12px;
            font-size: 0.8rem;
            transition: all 0.2s ease;
        }
        .table-custom .btn-outline-danger:hover {
            background-color: #dc2626;
            border-color: #dc2626;
            color: white;
            transform: translateY(-1.5px);
            box-shadow: 0 4px 10px rgba(220, 38, 38, 0.15);
        }

        .animate-hover {
            transition: all 0.2s ease;
        }
        .animate-hover:hover {
            transform: translateY(-1.5px);
            box-shadow: 0 4px 12px rgba(79, 70, 229, 0.2) !important;
        }
        
        
        /* Custom Tabs Styling */
        .nav-tabs .nav-link {
            border: 1px solid transparent;
            color: #64748b !important; /* Muted slate */
            font-size: 0.9rem;
            transition: all 0.2s ease;
            padding: 10px 20px;
        }
        .nav-tabs .nav-link:hover {
            color: #4f46e5 !important; /* Brand color */
            border-color: #f1f5f9 #f1f5f9 transparent;
            background-color: #fafbfc;
        }
        .nav-tabs .nav-link.active {
            border-color: #e2e8f0 #e2e8f0 #fff !important; /* Match table border */
            background-color: #fff !important;
            color: #4f46e5 !important;
            font-weight: 700 !important;
            box-shadow: 0 -2px 6px rgba(0,0,0,0.02);
        }
        
        /* Modal Custom styles */
        .modal-content {
            border-radius: 14px;
            border: none;
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
        }
        .modal-header {
            border-top-left-radius: 14px;
            border-top-right-radius: 14px;
            background: linear-gradient(135deg, #4f46e5 0%, #3730a3 100%);
        }
        
        /* Fix Bootstrap modal backdrop z-index bug */
        .modal {
            background: rgba(0, 0, 0, 0.55);
        }
        .modal-backdrop {
            display: none !important;
        }
    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="mb-0 text-dark font-weight-bold">Employee Master</h2>
        <div>
            <button type="button" class="btn btn-primary shadow-sm mr-2 animate-hover" data-bs-toggle="modal" data-bs-target="#employeeModal" onclick="clearForm();">
                <i class="fas fa-user-plus mr-1"></i> Add Employee
            </button>
            <button type="button" class="btn btn-outline-primary shadow-sm animate-hover" data-bs-toggle="modal" data-bs-target="#importModal">
                <i class="fas fa-file-import mr-1"></i> Import CSV
            </button>
        </div>
    </div>
    
    <asp:Label ID="lblMessage" runat="server" CssClass="alert d-block d-none" Visible="false"></asp:Label>

    <!-- MAIN PANEL: full width -->
    <div class="panel mb-3 d-flex align-items-center justify-content-between flex-wrap">
        <div class="d-flex align-items-center mb-2 mb-sm-0 flex-wrap">
            <h5 class="mb-0 mr-2 text-dark font-weight-bold" style="font-size: 0.95rem;">Filter Category:</h5>
            <asp:DropDownList ID="ddlFilter" runat="server" CssClass="form-select w-auto mr-4 mb-2 mb-sm-0 shadow-sm" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_SelectedIndexChanged">
            </asp:DropDownList>
            
            <h5 class="mb-0 mr-2 text-dark font-weight-bold" style="font-size: 0.95rem;">Filter Division:</h5>
            <asp:DropDownList ID="ddlFilterDiv" runat="server" CssClass="form-select w-auto mb-2 mb-sm-0 shadow-sm" AutoPostBack="true" OnSelectedIndexChanged="ddlFilterDiv_SelectedIndexChanged">
            </asp:DropDownList>
        </div>
        <div class="d-flex align-items-center">
            <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control mr-2 shadow-sm" placeholder="Search ID or Name..." onkeyup="filterEmployees()"></asp:TextBox>
            <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn btn-outline-primary shadow-sm" OnClick="btnSearch_Click" />
        </div>
    </div>

    <!-- TABS NAVIGATION -->
    <asp:HiddenField ID="hfActiveTab" runat="server" Value="Active" />
    <ul class="nav nav-tabs mb-0 border-bottom-0" id="employeeTabs" role="tablist" style="padding-left: 4px;">
        <li class="nav-item">
            <asp:LinkButton ID="btnTabActive" runat="server" CssClass="nav-link active" OnClick="btnTabActive_Click" style="font-weight: 600; border-radius: 8px 8px 0 0; margin-right: 4px;">
                Active <span class="badge bg-success text-white ml-1" style="font-size: 0.75rem; padding: 3px 8px;"><%= GetActiveCount() %></span>
            </asp:LinkButton>
        </li>
        <li class="nav-item">
            <asp:LinkButton ID="btnTabResigned" runat="server" CssClass="nav-link" OnClick="btnTabResigned_Click" style="font-weight: 600; border-radius: 8px 8px 0 0; margin-right: 4px;">
                Resigned <span class="badge bg-secondary text-white ml-1" style="font-size: 0.75rem; padding: 3px 8px;"><%= GetResignedCount() %></span>
            </asp:LinkButton>
        </li>
    </ul>

    <div class="table-responsive bg-white rounded-lg shadow-sm border" style="border-radius: 12px; overflow: hidden; border-top-left-radius: 0px !important;">
        <asp:GridView ID="gvEmployees" runat="server" AutoGenerateColumns="False" CssClass="table table-hover table-custom mb-0" DataKeyNames="ID" OnRowCommand="gvEmployees_RowCommand" OnRowDataBound="gvEmployees_RowDataBound" OnRowDeleting="gvEmployees_RowDeleting">
            <Columns>
                <asp:TemplateField HeaderText="S.No">
                    <ItemTemplate>
                        <%# Container.DataItemIndex + 1 %>
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:BoundField DataField="ID" HeaderText="ID" />
                <asp:BoundField DataField="Name" HeaderText="Name" />
                <asp:BoundField DataField="Department" HeaderText="Department" />
                <asp:BoundField DataField="Category" HeaderText="Category" />
                <asp:BoundField DataField="JoinDate" HeaderText="Join Date" DataFormatString="{0:dd-MM-yyyy}" />
                <asp:BoundField DataField="LeaveBalance" HeaderText="Leave" />
                <asp:TemplateField HeaderText="Status">
                    <ItemTemplate>
                        <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-select form-select-sm status-badge" onchange="handleStatusChange(this)" OnSelectedIndexChanged="ddlStatus_SelectedIndexChanged">
                            <asp:ListItem Value="Active">Active</asp:ListItem>
                            <asp:ListItem Value="Resigned">Resigned</asp:ListItem>
                        </asp:DropDownList>
                        <asp:HiddenField ID="hfEmpID" runat="server" Value='<%# Eval("ID") %>' />
                        <asp:HiddenField ID="hfStatus" runat="server" Value='<%# Eval("Status") %>' />
                        <asp:HiddenField ID="hfResignDate" runat="server" Value="" />
                    </ItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderText="Actions">
                    <ItemTemplate>
                        <div class="d-flex gap-2">
                            <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditEmp" CommandArgument='<%# Eval("ID") %>' CssClass="btn btn-sm btn-outline-primary mr-1">Edit</asp:LinkButton>
                            <asp:LinkButton ID="btnDelete" runat="server" CommandName="DeleteEmp" CommandArgument='<%# Eval("ID") %>' CssClass="btn btn-sm btn-outline-danger" OnClientClick="return confirm('Are you sure you want to completely delete this employee and their attendance history?');">Delete</asp:LinkButton>
                        </div>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>
    </div>

    <!-- EMPLOYEE MODAL -->
    <div class="modal fade" id="employeeModal" tabindex="-1" role="dialog" aria-labelledby="employeeModalLabel" aria-hidden="true">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header text-white">
                    <h5 class="modal-title font-weight-bold" id="employeeModalLabel">Add New Employee</h5>
                    <button type="button" class="close text-white" data-bs-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body text-dark">
                    <div class="form-group">
                        <label for="<%= txtEmpID.ClientID %>" class="font-weight-bold">Employee ID</label>
                        <asp:TextBox ID="txtEmpID" runat="server" CssClass="form-control" placeholder="e.g. 1001"></asp:TextBox>
                    </div>
                    <div class="form-group">
                        <label for="<%= txtEmpName.ClientID %>" class="font-weight-bold">Employee Name</label>
                        <asp:TextBox ID="txtEmpName" runat="server" CssClass="form-control" placeholder="e.g. John Doe"></asp:TextBox>
                    </div>
                    <div class="form-group">
                        <label for="<%= ddlDept.ClientID %>" class="font-weight-bold">Division / Department</label>
                        <asp:DropDownList ID="ddlDept" runat="server" CssClass="form-control">
                        </asp:DropDownList>
                    </div>
                    <div class="form-group">
                        <label for="<%= ddlCat.ClientID %>" class="font-weight-bold">Category</label>
                        <asp:DropDownList ID="ddlCat" runat="server" CssClass="form-control">
                        </asp:DropDownList>
                    </div>
                    <div class="form-group">
                        <label for="<%= txtJoinDate.ClientID %>" class="font-weight-bold">Joining Date</label>
                        <asp:TextBox ID="txtJoinDate" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                    </div>
                    <div class="form-group">
                        <label for="<%= txtLeaveBalance.ClientID %>" class="font-weight-bold">Leave Balance</label>
                        <asp:TextBox ID="txtLeaveBalance" runat="server" CssClass="form-control" placeholder="Leave Balance" TextMode="Number"></asp:TextBox>
                    </div>
                    <asp:HiddenField ID="hfEditOldID" runat="server" Value="" />
                    <asp:Button ID="btnCancelEdit" runat="server" Text="Cancel" CssClass="btn btn-secondary" OnClick="btnCancelEdit_Click" Visible="false" style="display:none;" formnovalidate="formnovalidate" />
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    <asp:Button ID="btnAddEmployee" runat="server" Text="Add Employee" CssClass="btn btn-success" OnClick="btnAddEmployee_Click" />
                </div>
            </div>
        </div>
    </div>

    <!-- IMPORT MODAL -->
    <div class="modal fade" id="importModal" tabindex="-1" role="dialog" aria-labelledby="importModalLabel" aria-hidden="true">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header text-white">
                    <h5 class="modal-title font-weight-bold" id="importModalLabel">Import Employees from CSV</h5>
                    <button type="button" class="close text-white" data-bs-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body text-dark">
                    <div class="form-group">
                        <label for="<%= ddlImportCat.ClientID %>" class="font-weight-bold">Category for Imported Employees</label>
                        <asp:DropDownList ID="ddlImportCat" runat="server" CssClass="form-control">
                        </asp:DropDownList>
                    </div>
                    <div class="form-group">
                        <label for="<%= fileCSV.ClientID %>" class="font-weight-bold">Select CSV File</label>
                        <asp:FileUpload ID="fileCSV" runat="server" CssClass="form-control" style="height: auto;" />
                        <small class="text-muted d-block mt-2">Format: id,name,department,join_date,leave_balance</small>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    <asp:Button ID="btnImport" runat="server" Text="Import" CssClass="btn btn-primary" OnClick="btnImport_Click" />
                </div>
            </div>
        </div>
    </div>

    <script>
        // Move modals inside the form tag using vanilla JS as soon as the DOM is parsed
        document.addEventListener('DOMContentLoaded', function() {
            var form = document.getElementById('form1');
            var empModal = document.getElementById('employeeModal');
            var importModal = document.getElementById('importModal');
            if (form) {
                if (empModal) form.appendChild(empModal);
                if (importModal) form.appendChild(importModal);
            }
        });

        // Prevent enter key from triggering default button (Logout)
        document.addEventListener('keydown', function(event) {
            if (event.keyCode === 13 && event.target.tagName === 'INPUT') {
                event.preventDefault();
                return false;
            }
        });

        function clearForm() {
            var txtId = document.getElementById('<%= txtEmpID.ClientID %>');
            var txtName = document.getElementById('<%= txtEmpName.ClientID %>');
            var txtLeave = document.getElementById('<%= txtLeaveBalance.ClientID %>');
            var txtJoin = document.getElementById('<%= txtJoinDate.ClientID %>');
            var hfId = document.getElementById('<%= hfEditOldID.ClientID %>');
            
            if (txtId) txtId.value = '';
            if (txtName) txtName.value = '';
            if (txtLeave) txtLeave.value = '';
            if (txtJoin) txtJoin.value = '';
            if (hfId) hfId.value = '';
            
            // Reset button text and modal header
            var btn = document.getElementById('<%= btnAddEmployee.ClientID %>');
            if (btn) btn.value = 'Add Employee';
            var label = document.getElementById('employeeModalLabel');
            if (label) label.textContent = 'Add New Employee';
        }

        function filterEmployees() {
            var txtSearch = document.getElementById('<%= txtSearch.ClientID %>');
            if (!txtSearch) return;
            var input = txtSearch.value.toLowerCase();
            var gv = document.getElementById('<%= gvEmployees.ClientID %>');
            if (!gv) return;
            var rows = gv.querySelectorAll('tr:not(:first-child)');
            
            var sNo = 1;
            rows.forEach(function(row) {
                // columns: 0=S.No, 1=ID, 2=Name
                var idCell = row.cells[1];
                var nameCell = row.cells[2];
                if (idCell && nameCell) {
                    var idText = idCell.textContent.toLowerCase();
                    var nameText = nameCell.textContent.toLowerCase();
                    if (idText.includes(input) || nameText.includes(input)) {
                        row.style.display = '';
                        row.cells[0].textContent = sNo++;
                    } else {
                        row.style.display = 'none';
                    }
                }
            });
        }

        function handleStatusChange(ddl) {
            var val = ddl.value;
            var row = ddl.closest('tr');
            var hfResignDate = row.querySelector('input[id*="hfResignDate"]');
            var hfStatus = row.querySelector('input[id*="hfStatus"]');
            
            if (val === 'Resigned') {
                var dateStr = prompt("Please enter the Resignation Date (YYYY-MM-DD):", new Date().toISOString().split('T')[0]);
                if (!dateStr) {
                    ddl.value = hfStatus.value || 'Active';
                    return;
                }
                hfResignDate.value = dateStr;
            } else {
                hfResignDate.value = "";
            }
            
            __doPostBack(ddl.name, '');
        }
    </script>
</asp:Content>

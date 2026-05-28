<%@ Page Title="Calculation" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Calculation.aspx.cs" Inherits="AttendanceApp.Calculation" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Calculation
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <script src="Static/js/xlsx.full.min.js"></script>
    <style>
        /* Modern Premium Table Styling for Calculation Page */
        .table-calc {
            border-collapse: separate !important;
            border-spacing: 0 !important;
            width: 100% !important;
            border: none !important; /* Managed by the outer responsive container border */
            background-color: #fff;
        }
        .table-calc th {
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
            text-align: center !important;
        }
        .table-calc th:last-child {
            border-right: none !important;
        }
        .table-calc td {
            padding: 14px 20px !important;
            color: #334155 !important; /* Charcoal slate */
            font-size: 0.92rem !important;
            font-weight: 500 !important;
            border-bottom: 1px solid #e2e8f0 !important; /* Horizontal separating lines */
            border-left: none !important;
            border-right: 1px solid #f1f5f9 !important; /* Soft vertical separating lines */
            vertical-align: middle !important;
            text-align: center !important;
        }
        .table-calc td.name-col {
            text-align: left !important;
            padding-left: 20px !important;
            font-weight: 600 !important;
            color: #0f172a !important;
        }
        .table-calc td:last-child {
            border-right: none !important;
        }
        .table-calc tr:last-child td {
            border-bottom: none !important; /* Remove bottom border on the last row */
        }
        .table-calc tr {
            transition: background-color 0.2s ease;
        }
        .table-calc tr:hover {
            background-color: #eef2ff !important; /* Distinct light indigo hover */
        }
        .table-calc tr:nth-child(even) {
            background-color: #fbfcfd;
        }
        /* Custom Styling for Total Row */
        .table-calc tr.total-row {
            background-color: #ecfdf5 !important; /* Light emerald green */
        }
        .table-calc tr.total-row td {
            color: #047857 !important; /* Dark emerald green */
            border-bottom: none !important;
            font-weight: 700 !important;
        }
        
        .table-calc .btn-outline-primary {
            border-color: #e2e8f0 !important;
            color: #4f46e5 !important;
            background-color: #f8fafc !important;
            border-radius: 6px !important;
            font-weight: 600 !important;
            padding: 5px 12px !important;
            font-size: 0.8rem !important;
            transition: all 0.2s ease !important;
        }
        .table-calc .btn-outline-primary:hover {
            background-color: #4f46e5 !important;
            border-color: #4f46e5 !important;
            color: white !important;
            transform: translateY(-1.5px) !important;
            box-shadow: 0 4px 10px rgba(79, 70, 229, 0.15) !important;
        }
        
        /* Premium Invoice Summary Card */
        .summary-card {
            margin-top: 24px;
            background: #ffffff;
            border: 1px solid #e3e6f0;
            border-radius: 8px;
            padding: 20px;
            max-width: 400px;
            margin-left: auto;
            box-shadow: 0 4px 12px rgba(0,0,0,0.03);
            border-top: 4px solid #4f46e5;
        }
        .summary-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 8px;
            font-size: 0.95rem;
            color: #4e73df;
        }
        .summary-row-total {
            display: flex;
            justify-content: space-between;
            margin-top: 12px;
            padding-top: 12px;
            border-top: 2px dashed #e3e6f0;
            font-size: 1.15rem;
            font-weight: bold;
            color: #1a237e;
        }

        /* Custom spacing and layout for Calculation page controls */
        .calc-controls-container {
            display: flex;
            flex-wrap: wrap;
            align-items: flex-end;
            justify-content: space-between;
            width: 100%;
        }
        .calc-left-group {
            display: flex;
            flex-wrap: wrap;
            align-items: flex-end;
            flex-grow: 1;
        }
        .calc-control-item {
            margin-right: 16px;
            margin-bottom: 12px;
            min-width: 110px;
            flex: 1 1 auto;
        }
        .calc-control-item-category {
            margin-right: 16px;
            margin-bottom: 12px;
            min-width: 160px;
            flex: 1.5 1 auto;
        }
        .calc-control-item-wage {
            margin-right: 16px;
            margin-bottom: 12px;
            min-width: 240px;
            max-width: 260px;
            flex: 1.2 1 auto;
        }
        .calc-right-group {
            display: flex;
            flex-wrap: wrap;
            align-items: flex-end;
            margin-bottom: 12px;
        }
        
        /* Select and Input styling to ensure matching heights */
        .calc-left-group select.form-control, 
        .calc-left-group input.form-control {
            height: 38px !important;
            font-size: 0.9rem;
            border-radius: 4px;
            border: 1px solid #d1d3e2;
            color: #111827;
            font-weight: 500;
            box-shadow: inset 0 1px 2px rgba(0,0,0,0.05);
        }
        .calc-left-group select.form-control:focus, 
        .calc-left-group input.form-control:focus {
            border-color: #4f46e5;
            box-shadow: 0 0 0 0.2rem rgba(79,70,229,0.25);
        }
        
        /* Appended Save Wage button specific styling */
        .btn-save-wage {
            height: 38px !important;
            border-top-right-radius: 4px !important;
            border-bottom-right-radius: 4px !important;
            border-top-left-radius: 0 !important;
            border-bottom-left-radius: 0 !important;
            background-color: #4f46e5;
            border-color: #4f46e5;
            color: white !important;
            font-size: 0.85rem;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 0 12px;
            transition: all 0.2s ease;
            cursor: pointer;
            font-weight: bold;
        }
        .btn-save-wage:hover {
            background-color: #3730a3;
            border-color: #3730a3;
        }
        .btn-save-wage i {
            margin-right: 4px;
        }

        /* Standalone Actions Button Styling */
        .btn-custom {
            height: 38px !important;
            padding: 0 18px;
            font-size: 0.9rem;
            font-weight: 600;
            border-radius: 4px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border: none;
            transition: all 0.2s ease;
            box-shadow: 0 2px 4px rgba(0,0,0,0.08);
            cursor: pointer;
            color: white !important;
        }
        .btn-custom i {
            margin-right: 6px;
        }
        .btn-custom-calc {
            background-color: #10b981;
            margin-right: 8px;
        }
        .btn-custom-calc:hover {
            background-color: #059669;
            box-shadow: 0 4px 8px rgba(16,185,129,0.2);
            transform: translateY(-1px);
        }
        .btn-custom-export {
            background-color: #f59e0b;
        }
        .btn-custom-export:hover {
            background-color: #d97706;
            box-shadow: 0 4px 8px rgba(245,158,11,0.2);
            transform: translateY(-1px);
        }

        /* Custom styled Override Modal Overlay */
        #overrideModal {
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
            background: #fef3c7;
            color: #d97706;
            width: 42px;
            height: 42px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 4px 6px -1px rgba(217, 119, 6, 0.1);
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
        
        .btn-modal-save {
            background: linear-gradient(135deg, #4f46e5 0%, #4338ca 100%);
            color: white;
            box-shadow: 0 4px 12px rgba(79, 70, 229, 0.25);
        }
        .btn-modal-save:hover {
            box-shadow: 0 6px 16px rgba(79, 70, 229, 0.35);
            transform: translateY(-1px);
            color: white !important;
        }
    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h2 class="h3 mb-0 text-gray-800">Salary Calculation</h2>
    </div>
    
    <div class="card shadow-sm border-0 rounded-lg mb-4">
        <div class="card-body p-4 bg-white text-dark">
            <div class="calc-controls-container">
                <!-- Left Side: Dropdowns and Wage Input -->
                <div class="calc-left-group">
                    <!-- Year selector -->
                    <div class="calc-control-item">
                        <label class="form-label font-weight-bold mb-1 text-gray-800">
                            <i class="fas fa-calendar mr-1 text-primary"></i> Year
                        </label>
                        <select id="year" class="form-control" onchange="onSelectionChange()"></select>
                    </div>
                    
                    <!-- Month selector -->
                    <div class="calc-control-item">
                        <label class="form-label font-weight-bold mb-1 text-gray-800">
                            <i class="fas fa-calendar-alt mr-1 text-primary"></i> Month
                        </label>
                        <select id="month" class="form-control" onchange="onSelectionChange()"></select>
                    </div>
                    
                    <!-- Category selector -->
                    <div class="calc-control-item-category">
                        <label class="form-label font-weight-bold mb-1 text-gray-800">
                            <i class="fas fa-th-list mr-1 text-primary"></i> Category
                        </label>
                        <select id="category" class="form-control" onchange="onSelectionChange()">
                        </select>
                    </div>
                    
                    <!-- Division selector -->
                    <div class="calc-control-item-category">
                        <label class="form-label font-weight-bold mb-1 text-gray-800">
                            <i class="fas fa-building mr-1 text-primary"></i> Division
                        </label>
                        <select id="division" class="form-control" onchange="onSelectionChange()">
                        </select>
                    </div>
                    
                    <!-- Wage Rate selector with integrated Save button -->
                    <div class="calc-control-item-wage">
                        <label class="form-label font-weight-bold mb-1 text-gray-800">
                            <i class="fas fa-money-bill-wave mr-1 text-primary"></i> Wage Rate
                        </label>
                        <div class="input-group">
                            <div class="input-group-prepend">
                                <span class="input-group-text bg-light"><i class="fas fa-rupee-sign text-secondary"></i></span>
                            </div>
                            <input type="number" id="wage" class="form-control" placeholder="Rate" />
                            <div class="input-group-append">
                                <button type="button" class="btn btn-save-wage" onclick="saveWage()" title="Save Wage Rate">
                                    <i class="fas fa-save"></i> Save
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Right Side: Action Buttons -->
                <div class="calc-right-group">
                    <button type="button" class="btn btn-custom btn-custom-calc" onclick="render()">
                        <i class="fas fa-calculator"></i> Calculate
                    </button>
                    <button type="button" class="btn btn-custom btn-custom-export" onclick="exportFull()">
                        <i class="fas fa-file-excel"></i> Export Excel
                    </button>
                </div>
            </div>
        </div>
    </div>

    <div id="result"></div>

    <!-- Custom Override Modal Overlay -->
    <div id="overrideModal">
        <div class="confirm-modal-box">
            <div class="confirm-modal-header" style="background: #eef2ff; border-bottom: 1px solid #e2e8f0;">
                <div class="confirm-modal-icon-container" style="background: #e0e7ff; color: #4f46e5; box-shadow: 0 4px 6px -1px rgba(79, 70, 229, 0.1);">
                    <i class="fas fa-edit"></i>
                </div>
                <span class="confirm-modal-title">Override Final Days</span>
            </div>
            <div class="confirm-modal-body">
                <div style="font-size: 0.95rem; color: #475569; margin-bottom: 16px;">
                    Enter the final working days to override for employee <strong id="overrideEmpName" class="text-dark"></strong> (ID: <span id="overrideEmpId" class="text-secondary"></span>).
                </div>
                <div class="form-group mb-0">
                    <label for="overrideDaysInput" class="font-weight-bold" style="font-size: 0.88rem; color: #334155; margin-bottom: 6px;">New Final Days Value</label>
                    <input type="number" id="overrideDaysInput" class="form-control" step="0.5" placeholder="e.g. 26, 24.5" style="height: 42px; font-size: 1rem; border-radius: 8px;" />
                </div>
            </div>
            <div class="confirm-modal-footer">
                <button id="btnOverrideCancel" type="button" class="btn-modal-action btn-modal-cancel">Cancel</button>
                <button id="btnOverrideApply" type="button" class="btn-modal-action btn-modal-save">Apply</button>
            </div>
        </div>
    </div>

    <script>
        const year = document.getElementById("year");
        const month = document.getElementById("month");
        const category = document.getElementById("category");
        const division = document.getElementById("division");
        const wage = document.getElementById("wage");
        const result = document.getElementById("result");
        let calcData = [];

        for(let y=2020; y<=2100; y++) year.innerHTML+=`<option>${y}</option>`;
        ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"].forEach((m, i) => {
            month.innerHTML += `<option value="${i}">${m}</option>`;
        });

        year.value = new Date().getFullYear();
        month.value = new Date().getMonth();

        // Fetch categories from DB and populate selector
        fetch('Calculation.aspx/GetCategories', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' }
        }).then(r => r.json()).then(res => {
            const categories = JSON.parse(res.d);
            category.innerHTML = '<option value="All">All Categories</option>';
            categories.forEach(cat => {
                category.innerHTML += `<option>${cat}</option>`;
            });
            
            // Fetch divisions from DB and populate selector
            return fetch('Calculation.aspx/GetDivisions', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' }
            });
        }).then(r => r.json()).then(res => {
            const divisions = JSON.parse(res.d);
            division.innerHTML = '<option value="All">All Divisions</option>';
            divisions.forEach(div => {
                division.innerHTML += `<option>${div}</option>`;
            });
            onSelectionChange();
        }).catch(e => {
            console.error(e);
            onSelectionChange();
        });

        function onSelectionChange() {
            wage.value = ""; // Clear wage to fetch stored rate
            render();
        }

        function render() {
            const req = {
                year: parseInt(year.value),
                month: parseInt(month.value),
                category: category.value,
                division: division.value,
                wage: parseFloat(wage.value) || 0
            };

            fetch('Calculation.aspx/GetCalculationData', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(req)
            }).then(r => r.json()).then(res => {
                calcData = JSON.parse(res.d);
                if (calcData.length > 0 && req.wage === 0) {
                    if (category.value !== "All") {
                        wage.value = calcData[0].WageRate;
                    } else {
                        wage.value = "";
                    }
                }
                drawTable();
            }).catch(e => console.error(e));
        }

        function drawTable() {
            if (calcData.length === 0) {
                result.innerHTML = "<h4>No records found</h4>";
                return;
            }

            let totalDays = 0, totalAmount = 0;
            let dayCountMap = {};
            let tableHtml = `<div class="table-responsive bg-white rounded-lg shadow-sm border mb-4" style="border-radius: 12px; overflow: hidden;">`;
            tableHtml += `<table class="table-calc"><thead><tr><th>ID</th><th>Name</th><th>Dept</th><th>Present</th><th>Final</th><th>Edit</th><th>Amount</th></tr></thead><tbody>`;

            calcData.forEach(emp => {
                totalDays += emp.Final;
                totalAmount += emp.Amount;
                
                // Populate Days vs Employees map
                dayCountMap[emp.Final] = (dayCountMap[emp.Final] || 0) + 1;

                tableHtml += `<tr>
                    <td>${emp.ID}</td>
                    <td class="name-col">${emp.Name}</td>
                    <td>${emp.Department}</td>
                    <td>${emp.Present}</td>
                    <td>${emp.Final}</td>
                    <td><button type="button" class="btn btn-sm btn-outline-primary" onclick="editOverride('${emp.ID}')"><i class="fas fa-edit"></i> Edit</button></td>
                    <td>${emp.Amount.toFixed(2)}</td>
                </tr>`;
            });

            tableHtml += `<tr class="total-row">
                <td colspan="4">Total</td>
                <td>${totalDays}</td><td></td>
                <td>${totalAmount.toFixed(2)}</td>
            </tr></tbody></table></div>`;

            // Build Days vs Employees Breakdown
            let breakdownHtml = `<div class="list-group list-group-flush">`;
            Object.keys(dayCountMap).sort((a, b) => b - a).forEach(d => {
                breakdownHtml += `<div class="list-group-item d-flex justify-content-between align-items-center py-2 px-3">
                    <span class="text-gray-800 font-weight-bold" style="font-size: 0.9rem;">
                        <i class="fas fa-calendar-day text-secondary mr-2"></i>${d} days
                    </span>
                    <span class="badge badge-primary badge-pill px-3 py-2 font-weight-bold" style="font-size: 0.85rem; border-radius: 20px;">
                        ${dayCountMap[d]} ${dayCountMap[d] === 1 ? 'person' : 'people'}
                    </span>
                </div>`;
            });
            breakdownHtml += `</div>`;

            // Save calculated data to localStorage for the invoice generator
            const finalEmployees = calcData.map(emp => ({
                id: emp.ID,
                name: emp.Name,
                dept: emp.Department,
                days: emp.Final,
                present: emp.Present,
                final: emp.Final,
                amt: emp.Amount,
                rate: emp.WageRate
            }));

            localStorage.setItem("finalData", JSON.stringify({
                employees: finalEmployees,
                rate: parseFloat(wage.value) || 0,
                category: category.value,
                year: parseInt(year.value),
                month: parseInt(month.value)
            }));

            // Build Invoice Summary Card with "Generate Invoice" button
            let summaryCardHtml = `<div class="card shadow-sm border-0 h-100" style="border-top: 4px solid #4f46e5 !important;">
                <div class="card-header bg-white py-3 border-0">
                    <h6 class="m-0 font-weight-bold text-primary"><i class="fas fa-receipt mr-2"></i>Invoice Summary</h6>
                </div>
                <div class="card-body pt-0">
                    <div class="summary-row mb-2 d-flex justify-content-between">
                        <span class="text-gray-600">Subtotal:</span>
                        <strong class="text-gray-800">${totalAmount.toFixed(2)}</strong>
                    </div>
                    <div class="summary-row mb-2 d-flex justify-content-between">
                        <span class="text-gray-600">Service Charge (3.85%):</span>
                        <strong class="text-gray-800">${(totalAmount * 0.0385).toFixed(2)}</strong>
                    </div>
                    <div class="summary-row mb-2 d-flex justify-content-between">
                        <span class="text-gray-600">GST (18%):</span>
                        <strong class="text-gray-800">${(totalAmount * 0.18).toFixed(2)}</strong>
                    </div>
                    <div class="summary-row-total pt-2 mt-2 border-top d-flex justify-content-between" style="border-top: 2px dashed #e3e6f0 !important;">
                        <span class="text-primary font-weight-bold h5 mb-0">Grand Total:</span>
                        <span class="text-primary font-weight-bold h5 mb-0">${(totalAmount * 1.2185).toFixed(2)}</span>
                    </div>
                    <div class="mt-4 text-right">
                        <button type="button" class="btn btn-primary px-4 font-weight-bold" onclick="generateInvoice()" style="height: 38px; border-radius: 6px; box-shadow: 0 2px 4px rgba(79,70,229,0.15);">
                            <i class="fas fa-file-invoice mr-2"></i> Generate Invoice
                        </button>
                    </div>
                </div>
            </div>`;

            // Combine everything into side-by-side cards below the table
            let footerHtml = `
            <div class="row mt-4">
                <!-- Days vs Employees Card -->
                <div class="col-md-6 mb-4">
                    <div class="card shadow-sm border-0 h-100">
                        <div class="card-header bg-white py-3 border-0">
                            <h6 class="m-0 font-weight-bold text-primary"><i class="fas fa-users mr-2"></i>Days vs Employees Breakdown</h6>
                        </div>
                        <div class="card-body p-0">
                            ${breakdownHtml}
                        </div>
                    </div>
                </div>
                
                <!-- Invoice Summary Card -->
                <div class="col-md-6 mb-4">
                    ${summaryCardHtml}
                </div>
            </div>`;

            result.innerHTML = tableHtml + footerHtml;
        }

        function generateInvoice() {
            window.open("Invoice.aspx", "_blank");
        }

        function saveWage() {
            if (category.value === "All") {
                alert("Please select a specific category to save its wage rate.");
                return;
            }
            const req = {
                year: parseInt(year.value),
                month: parseInt(month.value),
                category: category.value,
                wage: parseFloat(wage.value) || 0
            };
            fetch('Calculation.aspx/SaveWage', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(req)
            }).then(r => r.json()).then(() => alert("Saved Wage")).catch(e => console.error(e));
        }

        function editOverride(id) {
            const emp = calcData.find(e => e.ID === id);
            if (!emp) return;

            const modal = document.getElementById("overrideModal");
            const empNameLabel = document.getElementById("overrideEmpName");
            const empIdLabel = document.getElementById("overrideEmpId");
            const inputField = document.getElementById("overrideDaysInput");
            const btnApply = document.getElementById("btnOverrideApply");
            const btnCancel = document.getElementById("btnOverrideCancel");

            if (!modal || !empNameLabel || !empIdLabel || !inputField) return;

            empNameLabel.textContent = emp.Name;
            empIdLabel.textContent = id;
            inputField.value = emp.Final;

            modal.style.display = "flex";
            modal.offsetHeight; // trigger reflow
            modal.style.opacity = "1";
            modal.querySelector(".confirm-modal-box").style.transform = "scale(1)";

            function closeModal() {
                modal.style.opacity = "0";
                modal.querySelector(".confirm-modal-box").style.transform = "scale(0.92)";
                setTimeout(() => {
                    modal.style.display = "none";
                }, 250);
            }

            btnCancel.onclick = function() {
                closeModal();
            };

            btnApply.onclick = function() {
                const val = inputField.value.trim();
                if (val === "") {
                    alert("Please enter a valid override value.");
                    return;
                }

                const finalDays = parseFloat(val);
                if (isNaN(finalDays)) {
                    alert("Please enter a valid number.");
                    return;
                }

                const req = {
                    year: parseInt(year.value),
                    month: parseInt(month.value),
                    category: category.value,
                    empId: id,
                    finalDays: finalDays
                };

                fetch('Calculation.aspx/SaveOverride', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(req)
                }).then(r => r.json()).then(() => {
                    closeModal();
                    render();
                }).catch(e => {
                    console.error(e);
                    alert("Error saving override");
                });
            };
        }

        function exportFull() {
            if (calcData.length === 0) return alert("No data to export");
            const data = calcData.map(e => ({
                ID: e.ID, Name: e.Name, Department: e.Department,
                Present: e.Present, FinalDays: e.Final, Amount: e.Amount
            }));
            const ws = XLSX.utils.json_to_sheet(data);
            const wb = XLSX.utils.book_new();
            XLSX.utils.book_append_sheet(wb, ws, "Full Report");
            XLSX.writeFile(wb, "Full_Report.xlsx");
        }
    </script>
</asp:Content>

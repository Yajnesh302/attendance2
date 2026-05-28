<%@ Page Title="Attendance" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Attendance.aspx.cs" Inherits="AttendanceApp.Attendance" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Attendance Management
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        /* Custom spacing and layout for controls */
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
            margin-right: 12px;
            margin-bottom: 6px;
            min-width: 110px;
            flex: 1 1 auto;
        }
        .calc-control-item-category {
            margin-right: 12px;
            margin-bottom: 6px;
            min-width: 160px;
            flex: 1.5 1 auto;
        }
        .calc-control-item-wage {
            margin-right: 12px;
            margin-bottom: 6px;
            min-width: 220px;
            flex: 2 1 auto;
        }
        .calc-right-group {
            display: flex;
            flex-wrap: wrap;
            align-items: flex-end;
            margin-bottom: 6px;
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

        /* Holiday Buttons Styling */
        .calc-left-group .btn {
            height: 38px !important;
            font-size: 0.85rem;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 0 12px;
            transition: all 0.2s ease;
            cursor: pointer;
            font-weight: bold;
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
            background-color: #17a2b8;
        }
        .btn-custom-export:hover {
            background-color: #117a8b;
            box-shadow: 0 4px 8px rgba(23,162,184,0.2);
            transform: translateY(-1px);
        }
        .wrapper {
            height: calc(100vh - 195px);
            min-height: 450px;
            overflow: auto;
            border: 1px solid #e3e6f0;
            background: white;
            border-radius: 8px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.05);
        }
        table.att-table {
            border-collapse: collapse;
            width: max-content;
            min-width: 100%;
        }
        .att-table th, .att-table td {
            border: 1px solid #ddd;
            padding: 4px;
            text-align: center;
            font-size: 14px;
            min-width: 40px;
            height: 50px;
            position: relative;
            vertical-align: top;
        }
        .att-table th {
            position: sticky;
            top: 0;
            background: #f0f2f5;
            z-index: 10;
        }
        #tbody tr {
            transition: background-color 0.15s ease;
        }
        #tbody tr:hover {
            background-color: #eef2ff !important;
        }
        #tbody tr:hover td {
            box-shadow: inset 0 0 0 9999px rgba(79, 70, 229, 0.06);
        }
        .green { background: #d9f7be !important; }
        .red { background: #ffa39e !important; }
        .royal-blue { background: #4169E1 !important; color: white !important; }
        .light-yellow { background: #fff9c4 !important; }
        .gray { background: #e5e7eb !important; color: #666; }
        input.att {
            width: 35px;
            text-align: center;
            border: 1px solid #999;
            font-weight: bold;
            background: transparent;
            outline: none;
            font-size: 14px;
            margin-top: 2px;
        }
        .label-text {
            display: block;
            font-size: 11px;
            font-weight: bold;
            color: #333;
            margin-top: 1px;
        }
        select.leave-opt {
            position: absolute;
            bottom: 1px;
            left: 1px;
            width: calc(100% - 2px);
            font-size: 10px;
            padding: 0;
            height: 16px;
            box-sizing: border-box;
        }
        /* Elegant Toast Container at Top Right */
        #toast-container {
            position: fixed;
            top: 24px;
            right: 24px;
            display: flex;
            flex-direction: column;
            gap: 12px;
            z-index: 99999;
            pointer-events: none;
        }
        
        .modern-toast {
            display: flex;
            align-items: center;
            gap: 14px;
            background: rgba(255, 255, 255, 0.9);
            backdrop-filter: blur(12px) saturate(180%);
            -webkit-backdrop-filter: blur(12px) saturate(180%);
            border-radius: 12px;
            padding: 14px 20px;
            min-width: 320px;
            max-width: 420px;
            color: #1e293b;
            font-size: 0.92rem;
            font-weight: 600;
            font-family: 'Segoe UI', system-ui, -apple-system, sans-serif;
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04), inset 0 0 0 1px rgba(255, 255, 255, 0.5);
            transform: translateX(120%);
            transition: transform 0.4s cubic-bezier(0.16, 1, 0.3, 1), opacity 0.3s ease;
            opacity: 0;
            pointer-events: auto;
            border-left: 6px solid #64748b;
        }
        
        .modern-toast.toast-show {
            transform: translateX(0);
            opacity: 1;
        }
        
        .modern-toast.toast-hide {
            transform: translateY(-20px) scale(0.9);
            opacity: 0;
        }
        
        .toast-icon {
            font-size: 1.35rem;
            flex-shrink: 0;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        /* Toast Alert States with Curated Color Accents */
        .toast-success {
            border-left-color: #10b981;
            background: rgba(240, 253, 250, 0.95);
        }
        .toast-success .toast-icon {
            color: #10b981;
        }
        
        .toast-error {
            border-left-color: #ef4444;
            background: rgba(254, 242, 242, 0.95);
        }
        .toast-error .toast-icon {
            color: #ef4444;
        }
        
        .toast-warning {
            border-left-color: #f59e0b;
            background: rgba(255, 251, 235, 0.95);
        }
        .toast-warning .toast-icon {
            color: #f59e0b;
        }
        
        .toast-info {
            border-left-color: #3b82f6;
            background: rgba(239, 246, 255, 0.95);
        }
        .toast-info .toast-icon {
            color: #3b82f6;
        }
        
        .toast-close-btn {
            background: transparent;
            border: none;
            color: #94a3b8;
            cursor: pointer;
            font-size: 1.2rem;
            padding: 2px;
            line-height: 1;
            transition: color 0.15s ease;
            margin-left: auto;
        }
        .toast-close-btn:hover {
            color: #475569;
        }

        /* Custom styled Confirm Dialog Modal */
        #confirmModal, #globalAdjustModal {
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
        
        .btn-modal-discard {
            background: #fee2e2;
            color: #dc2626;
            border: 1px solid #fecaca;
        }
        .btn-modal-discard:hover {
            background: #fecaca;
            color: #b91c1c;
            box-shadow: 0 4px 12px rgba(220, 38, 38, 0.15);
        }
        
        .btn-modal-save {
            background: linear-gradient(135deg, #4f46e5 0%, #4338ca 100%);
            color: white;
            box-shadow: 0 4px 12px rgba(79, 70, 229, 0.25);
        }
        .btn-modal-save:hover {
            background: linear-gradient(135deg, #4338ca 0%, #3730a3 100%);
            box-shadow: 0 6px 16px rgba(79, 70, 229, 0.35);
            transform: translateY(-1px);
        }
        
        .btn-purple {
            background-color: #9333ea;
            color: white;
            border: none;
            padding: 8px 15px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            font-weight: bold;
        }
        .btn-purple:hover {
            background-color: #7e22ce;
        }

        #loadingOverlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100vw;
            height: 100vh;
            background: rgba(255, 255, 255, 0.7);
            backdrop-filter: blur(4px);
            -webkit-backdrop-filter: blur(4px);
            z-index: 99999;
            align-items: center;
            justify-content: center;
            flex-direction: column;
            font-family: 'Segoe UI', system-ui, sans-serif;
        }
        .spinner-border-custom {
            width: 3.5rem;
            height: 3.5rem;
            border: 5px solid #e2e8f0;
            border-top: 5px solid #4f46e5;
            border-radius: 50%;
            animation: spin 1s linear infinite;
        }
        @keyframes spin {
            to { transform: rotate(360deg); }
        }
    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    
    <div id="toast-container"></div>

    <div id="loadingOverlay">
        <div class="spinner-border-custom" role="status"></div>
        <div style="margin-top: 16px; font-size: 1.1rem; font-weight: 700; color: #0f172a;">Loading Attendance Data...</div>
    </div>
    
    <!-- Custom Confirm Dialog Modal -->
    <div id="confirmModal">
        <div class="confirm-modal-box">
            <div class="confirm-modal-header">
                <div class="confirm-modal-icon-container">
                    <i class="fas fa-exclamation-triangle"></i>
                </div>
                <span class="confirm-modal-title">Unsaved Changes</span>
            </div>
            <div class="confirm-modal-body">
                You have unsaved changes in the attendance grid. What would you like to do?
            </div>
            <div class="confirm-modal-footer">
                <button id="btnModalCancel" type="button" class="btn-modal-action btn-modal-cancel">Cancel</button>
                <button id="btnModalDiscard" type="button" class="btn-modal-action btn-modal-discard">Discard Changes</button>
                <button id="btnModalSave" type="button" class="btn-modal-action btn-modal-save">Save & Continue</button>
            </div>
        </div>
    </div>

    <!-- Custom Pairing Confirm Modal -->
    <div id="pairingModal" style="display: none; position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; background: rgba(15, 23, 42, 0.4); backdrop-filter: blur(8px); -webkit-backdrop-filter: blur(8px); z-index: 100000; align-items: center; justify-content: center; opacity: 0; transition: opacity 0.3s cubic-bezier(0.16, 1, 0.3, 1);">
        <div class="confirm-modal-box">
            <div class="confirm-modal-header" style="background: #f0fdf4; border-bottom: 1px solid #bbf7d0;">
                <div class="confirm-modal-icon-container" style="background: #dcfce7; color: #15803d;">
                    <i class="fas fa-users-cog"></i>
                </div>
                <span class="confirm-modal-title">Half Day Pairing Options</span>
            </div>
            <div class="confirm-modal-body">
                Please select the type of pairing to apply for this employee's half day:
                <div style="margin-top: 12px; font-size: 0.88rem; color: #64748b; line-height: 1.5;">
                    • <strong>Paid Pairing:</strong> Value becomes 1 (Present) and deducts 1 Paid Leave from their balance.<br/>
                    • <strong>Unpaid Pairing:</strong> Value becomes 0 (Absent) without affecting their paid leave balance.
                </div>
            </div>
            <div class="confirm-modal-footer">
                <button id="btnPairingCancel" type="button" class="btn-modal-action btn-modal-cancel">Cancel</button>
                <button id="btnPairingUnpaid" type="button" class="btn-modal-action btn-modal-discard" style="background: #fee2e2; color: #dc2626; border: 1px solid #fecaca;">Unpaid (Value: 0)</button>
                <button id="btnPairingPaid" type="button" class="btn-modal-action btn-modal-save" style="background: linear-gradient(135deg, #10b981 0%, #059669 100%); box-shadow: 0 4px 12px rgba(16, 185, 129, 0.25);">Paid (Value: 1)</button>
            </div>
        </div>
    </div>

    <!-- Custom Global Adjust Modal -->
    <div id="globalAdjustModal">
        <div class="confirm-modal-box">
            <div class="confirm-modal-header" style="background: #faf5ff; border-bottom: 1px solid #e9d5ff;">
                <div class="confirm-modal-icon-container" style="background: #f3e8ff; color: #9333ea;">
                    <i class="fas fa-sliders-h"></i>
                </div>
                <span class="confirm-modal-title">Global Adjustment</span>
            </div>
            <div class="confirm-modal-body">
                <div style="font-size: 0.95rem; color: #475569; margin-bottom: 16px;">
                    Apply a global offset value (in days) to all employee totals for this month.
                </div>
                <div style="background: #f8fafc; border-radius: 8px; padding: 12px; border: 1px solid #e2e8f0; margin-bottom: 16px;">
                    <span style="font-weight: 600; color: #1e293b;">Current Adjustment:</span>
                    <span id="globalAdjustCurrentVal" style="font-weight: 700; color: #9333ea; margin-left: 6px;">0</span>
                </div>
                <div class="form-group mb-0">
                    <label for="globalAdjustInput" class="font-weight-bold" style="font-size: 0.88rem; color: #334155; margin-bottom: 6px;">New Adjustment Value</label>
                    <input type="number" id="globalAdjustInput" class="form-control" step="0.5" placeholder="e.g. 1, -1, 0.5, -0.5" style="height: 42px; font-size: 1rem; border-radius: 8px;" />
                </div>
            </div>
            <div class="confirm-modal-footer">
                <button id="btnGlobalAdjustCancel" type="button" class="btn-modal-action btn-modal-cancel">Cancel</button>
                <button id="btnGlobalAdjustApply" type="button" class="btn-modal-action btn-modal-save" style="background: linear-gradient(135deg, #9333ea 0%, #7e22ce 100%); box-shadow: 0 4px 12px rgba(147, 51, 234, 0.25);">Apply</button>
            </div>
        </div>
    </div>

    <div class="d-flex justify-content-between align-items-center mb-3">
        <h2 class="h3 mb-0 text-gray-800">Attendance Management</h2>
    </div>
    
    <div class="card shadow-sm border-0 rounded-lg mb-2">
        <div class="card-body py-2 px-3 bg-white text-dark">
            <div class="calc-controls-container">
                <!-- Left Side: Dropdowns, Search and Holiday inputs -->
                <div class="calc-left-group">
                    <!-- Year selector -->
                    <div class="calc-control-item">
                        <label class="form-label font-weight-bold mb-1 text-gray-800">
                            <i class="fas fa-calendar mr-1 text-primary"></i> Year
                        </label>
                        <select id="yearSel" class="form-control"></select>
                    </div>
                    
                    <!-- Month selector -->
                    <div class="calc-control-item">
                        <label class="form-label font-weight-bold mb-1 text-gray-800">
                            <i class="fas fa-calendar-alt mr-1 text-primary"></i> Month
                        </label>
                        <select id="monthSel" class="form-control"></select>
                    </div>
                    
                    <!-- Category selector -->
                    <div class="calc-control-item-category">
                        <label class="form-label font-weight-bold mb-1 text-gray-800">
                            <i class="fas fa-th-list mr-1 text-primary"></i> Category
                        </label>
                        <select id="catSel" class="form-control">
                        </select>
                    </div>

                    <!-- Division selector -->
                    <div class="calc-control-item-category">
                        <label class="form-label font-weight-bold mb-1 text-gray-800">
                            <i class="fas fa-building mr-1 text-primary"></i> Division
                        </label>
                        <select id="divSel" class="form-control">
                        </select>
                    </div>
                    
                    <!-- Search input -->
                    <div class="calc-control-item-category">
                        <label class="form-label font-weight-bold mb-1 text-gray-800">
                            <i class="fas fa-search mr-1 text-primary"></i> Search
                        </label>
                        <input id="search" class="form-control" placeholder="Search ID/Name" />
                    </div>
                    
                    <!-- Holidays input group -->
                    <div id="holidayDiv" class="calc-control-item-wage">
                        <label class="form-label font-weight-bold mb-1 text-gray-800">
                            <i class="fas fa-umbrella-beach mr-1 text-danger"></i> Holiday
                        </label>
                        <div class="input-group">
                            <input id="holidayInput" class="form-control" placeholder="14,26" />
                            <div class="input-group-append">
                                <button type="button" class="btn btn-primary" onclick="applyHoliday()" title="Apply Holidays">
                                    Apply
                                </button>
                                <button type="button" class="btn btn-danger" onclick="removeHoliday()" title="Remove Holidays">
                                    Remove
                                </button>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Global Adjust Button -->
                    <div id="globalAdjustDiv" class="calc-control-item" style="min-width: 140px;">
                        <label class="form-label d-block mb-1">&nbsp;</label>
                        <button type="button" onclick="globalAdjust()" class="btn btn-custom w-100" style="background-color: #9333ea; font-size: 0.85rem; font-weight: bold; height: 38px !important;">
                            <i class="fas fa-adjust mr-1"></i> Global Adjust
                        </button>
                    </div>
                </div>
                
                <!-- Right Side: Save and Refresh Actions -->
                <div class="calc-right-group">
                    <button type="button" class="btn btn-custom btn-custom-calc" onclick="saveData()">
                        <i class="fas fa-save"></i> Save
                    </button>
                    <button type="button" class="btn btn-custom btn-custom-export" onclick="fetchData()" style="background-color: #17a2b8;">
                        <i class="fas fa-sync-alt"></i> Refresh
                    </button>
                </div>
            </div>
        </div>
    </div>

    <div class="wrapper">
        <table class="att-table" id="attTable">
            <thead id="thead"></thead>
            <tbody id="tbody"></tbody>
        </table>
    </div>

    <script>
        const role = '<%= Session["Role"] != null ? Session["Role"].ToString() : "0" %>';
        let attendanceData = {};
        let prevAttendanceData = {};
        let employees = [];
        let isDirty = false;

        const yS = document.getElementById('yearSel');
        const mS = document.getElementById('monthSel');
        const cS = document.getElementById('catSel');
        const divS = document.getElementById('divSel');
        const searchBox = document.getElementById('search');
        const tb = document.getElementById('tbody');
        const th = document.getElementById('thead');

        // Add keyboard arrow key navigation for attendance inputs
        tb.addEventListener('keydown', function(event) {
            if (event.target.classList.contains('att')) {
                if (event.key === 'ArrowLeft' || event.keyCode === 37) {
                    let currentTd = event.target.closest('td');
                    let prevTd = currentTd.previousElementSibling;
                    while (prevTd) {
                        let prevInp = prevTd.querySelector('.att');
                        if (prevInp && !prevInp.readOnly) {
                            prevInp.focus();
                            prevInp.select();
                            event.preventDefault();
                            break;
                        }
                        prevTd = prevTd.previousElementSibling;
                    }
                } else if (event.key === 'ArrowRight' || event.keyCode === 39) {
                    let currentTd = event.target.closest('td');
                    let nextTd = currentTd.nextElementSibling;
                    while (nextTd) {
                        let nextInp = nextTd.querySelector('.att');
                        if (nextInp && !nextInp.readOnly) {
                            nextInp.focus();
                            nextInp.select();
                            event.preventDefault();
                            break;
                        }
                        nextTd = nextTd.nextElementSibling;
                    }
                }
            }
        });

        const currentYear = new Date().getFullYear();
        for (let y = currentYear - 2; y <= currentYear + 5; y++) {
            yS.innerHTML += `<option value="${y}">${y}</option>`;
        }

        ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"].forEach((m, i) => {
            mS.innerHTML += `<option value="${i}">${m}</option>`;
        });

        yS.value = currentYear;
        mS.value = new Date().getMonth();

        let currentYearVal;
        let currentMonthVal;
        let currentCatVal;
        let currentDivVal;
        let currentSearchVal;

        const userDivision = '<%= Session["Division"] != null ? Session["Division"].ToString() : "" %>';

        function initSelectors() {
            if (role != 1) {
                const hd = document.getElementById("holidayDiv");
                if (hd) hd.style.display = "none";
                const ga = document.getElementById("globalAdjustDiv");
                if (ga) ga.style.display = "none";
            }

            // Fetch categories
            const p1 = fetch('Attendance.aspx/GetCategories', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' }
            }).then(r => r.json()).then(res => {
                const categories = JSON.parse(res.d);
                cS.innerHTML = '<option value="All">All</option>';
                categories.forEach(cat => {
                    cS.innerHTML += `<option value="${cat}">${cat}</option>`;
                });
                cS.value = "All";
            });

            // Fetch divisions
            const p2 = fetch('Attendance.aspx/GetDivisions', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' }
            }).then(r => r.json()).then(res => {
                const divisions = JSON.parse(res.d);
                divS.innerHTML = '';
                if (role == 1) {
                    divS.innerHTML += '<option value="All">All</option>';
                }
                divisions.forEach(d => {
                    divS.innerHTML += `<option value="${d}">${d}</option>`;
                });
                if (divisions.length > 0) {
                    divS.value = role == 1 ? "All" : divisions[0];
                }
                if (role != 1 && divisions.length <= 1) {
                    divS.disabled = true;
                } else {
                    divS.disabled = false;
                }
            });

            Promise.all([p1, p2]).then(() => {
                // Initialize tracking values
                currentYearVal = yS.value;
                currentMonthVal = mS.value;
                currentCatVal = cS.value;
                currentDivVal = divS.value;
                currentSearchVal = searchBox.value;
                
                // Fetch data
                fetchData();
            }).catch(e => {
                console.error("Error loading dropdown data: ", e);
                currentYearVal = yS.value;
                currentMonthVal = mS.value;
                currentCatVal = cS.value;
                currentDivVal = divS.value;
                currentSearchVal = searchBox.value;
                fetchData();
            });
        }

        window.onbeforeunload = function() {
            if (isDirty) return "You have unsaved changes! Are you sure you want to leave?";
        };

        // Prevent enter key from triggering default button (Logout)
        document.addEventListener('keydown', function(event) {
            if (event.keyCode === 13 && event.target.tagName === 'INPUT') {
                event.preventDefault();
                return false;
            }
        });

        // Custom Confirm Dialog Modal controller
        function showConfirmSaveModal(onSave, onDiscard, onCancel) {
            const modal = document.getElementById("confirmModal");
            if (!modal) return;
            
            const btnSave = document.getElementById("btnModalSave");
            const btnDiscard = document.getElementById("btnModalDiscard");
            const btnCancel = document.getElementById("btnModalCancel");
            
            modal.style.display = "flex";
            // trigger reflow
            modal.offsetHeight;
            modal.style.opacity = "1";
            modal.querySelector(".confirm-modal-box").style.transform = "scale(1)";
            
            function closeModal() {
                modal.style.opacity = "0";
                modal.querySelector(".confirm-modal-box").style.transform = "scale(0.92)";
                setTimeout(() => {
                    modal.style.display = "none";
                }, 250);
            }
            
            btnSave.onclick = function() {
                closeModal();
                if (onSave) onSave();
            };
            
            btnDiscard.onclick = function() {
                closeModal();
                if (onDiscard) onDiscard();
            };
            
            btnCancel.onclick = function() {
                closeModal();
                if (onCancel) onCancel();
            };
        }

        // Custom Pairing Confirm Modal controller
        function showPairingConfirmModal(onPaid, onUnpaid, onCancel) {
            const modal = document.getElementById("pairingModal");
            if (!modal) return;
            
            const btnPaid = document.getElementById("btnPairingPaid");
            const btnUnpaid = document.getElementById("btnPairingUnpaid");
            const btnCancel = document.getElementById("btnPairingCancel");
            
            modal.style.display = "flex";
            // trigger reflow
            modal.offsetHeight;
            modal.style.opacity = "1";
            modal.querySelector(".confirm-modal-box").style.transform = "scale(1)";
            
            function closeModal() {
                modal.style.opacity = "0";
                modal.querySelector(".confirm-modal-box").style.transform = "scale(0.92)";
                setTimeout(() => {
                    modal.style.display = "none";
                }, 250);
            }
            
            btnPaid.onclick = function() {
                closeModal();
                if (onPaid) onPaid();
            };
            
            btnUnpaid.onclick = function() {
                closeModal();
                if (onUnpaid) onUnpaid();
            };
            
            btnCancel.onclick = function() {
                closeModal();
                if (onCancel) onCancel();
            };
        }

        // Upgraded Toast Notification System
        function showToast(msg, type = 'info') {
            let container = document.getElementById("toast-container");
            if (!container) {
                container = document.createElement("div");
                container.id = "toast-container";
                document.body.appendChild(container);
            }

            const toast = document.createElement("div");
            toast.className = `modern-toast toast-${type}`;
            
            let iconClass = "fas fa-info-circle";
            if (type === "success") iconClass = "fas fa-check-circle";
            else if (type === "warning") iconClass = "fas fa-exclamation-triangle";
            else if (type === "error") iconClass = "fas fa-times-circle";

            toast.innerHTML = `
                <div class="toast-icon"><i class="${iconClass}"></i></div>
                <div style="flex-grow: 1; padding-right: 8px;">${msg}</div>
                <button type="button" class="toast-close-btn" onclick="this.parentElement.classList.remove('toast-show'); setTimeout(() => this.parentElement.remove(), 400);">&times;</button>
            `;

            container.appendChild(toast);
            
            // Trigger reflow to run transition
            toast.offsetHeight;
            toast.classList.add("toast-show");

            // Auto dismiss
            setTimeout(() => {
                if (toast.parentElement) {
                    toast.classList.remove("toast-show");
                    toast.classList.add("toast-hide");
                    setTimeout(() => {
                        toast.remove();
                    }, 400);
                }
            }, 4000);
        }

        // Maintain compatibility with existing code calling showPop
        function showPop(msg) {
            let type = "info";
            let lowerMsg = msg.toLowerCase();
            if (lowerMsg.includes("success") || lowerMsg.includes("reset")) {
                type = "success";
            } else if (lowerMsg.includes("error") || lowerMsg.includes("fail") || lowerMsg.includes("invalid")) {
                type = "error";
            } else if (lowerMsg.includes("saturday cut") || lowerMsg.includes("unsaved")) {
                type = "warning";
            }
            showToast(msg, type);
        }

        function handleDropdownChange(dropdown, prevValName) {
            const newVal = dropdown.value;
            const prevVal = window[prevValName];
            if (newVal === prevVal) return;
            
            if (isDirty) {
                // Revert UI immediately to preserve user view until choice is made
                dropdown.value = prevVal;
                
                showConfirmSaveModal(() => {
                    // Save and Continue
                    dropdown.value = newVal;
                    window[prevValName] = newVal;
                    saveData();
                    fetchData();
                }, () => {
                    // Discard and Continue
                    isDirty = false;
                    dropdown.value = newVal;
                    window[prevValName] = newVal;
                    fetchData();
                }, () => {
                    // Cancel - stay on page, do not change dropdown value
                });
            } else {
                window[prevValName] = newVal;
                fetchData();
            }
        }

        yS.onchange = () => handleDropdownChange(yS, 'currentYearVal');
        mS.onchange = () => handleDropdownChange(mS, 'currentMonthVal');
        cS.onchange = () => handleDropdownChange(cS, 'currentCatVal');
        divS.onchange = () => handleDropdownChange(divS, 'currentDivVal');

        let searchTimeout = null;
        searchBox.oninput = function() {
            const newVal = searchBox.value;
            if (newVal === currentSearchVal) return;
            
            if (isDirty) {
                searchBox.value = currentSearchVal;
                showConfirmSaveModal(() => {
                    searchBox.value = newVal;
                    currentSearchVal = newVal;
                    saveData();
                    fetchData();
                }, () => {
                    isDirty = false;
                    searchBox.value = newVal;
                    currentSearchVal = newVal;
                    fetchData();
                }, () => {
                    // Cancel - keep previous value
                });
            } else {
                clearTimeout(searchTimeout);
                searchTimeout = setTimeout(() => {
                    currentSearchVal = newVal;
                    fetchData();
                }, 300);
            }
        };

        // Intercept navigation links
        document.addEventListener("DOMContentLoaded", () => {
            const interceptLinks = () => {
                const links = document.querySelectorAll('a[href]');
                links.forEach(link => {
                    if (link.dataset.intercepted) return;
                    link.dataset.intercepted = "true";
                    
                    link.addEventListener('click', function(e) {
                        const href = this.getAttribute('href');
                        if (!href || href.startsWith('#') || href.startsWith('javascript:') || this.getAttribute('target') === '_blank') return;
                        
                        if (isDirty) {
                            e.preventDefault();
                            showConfirmSaveModal(() => {
                                saveData();
                                isDirty = false;
                                window.location.href = href;
                            }, () => {
                                isDirty = false;
                                window.location.href = href;
                            }, () => {
                                // Cancel
                            });
                        }
                    });
                });
            };
            
            interceptLinks();
            // Periodically check for dynamically added links
            setInterval(interceptLinks, 1500);

            // Intercept standard postback triggers like Logout button
            const form = document.getElementById('form1');
            if (form) {
                form.addEventListener('submit', function(e) {
                    const activeElement = document.activeElement;
                    if (activeElement && activeElement.id && activeElement.id.includes('btnLogout')) {
                        if (isDirty) {
                            e.preventDefault();
                            showConfirmSaveModal(() => {
                                saveData();
                                isDirty = false;
                                __doPostBack(activeElement.name || activeElement.id, '');
                            }, () => {
                                isDirty = false;
                                __doPostBack(activeElement.name || activeElement.id, '');
                            }, () => {
                                // Cancel
                            });
                        }
                    }
                });
            }
        });

        function showLoading() {
            const overlay = document.getElementById("loadingOverlay");
            if (overlay) overlay.style.display = "flex";
        }
        
        function hideLoading() {
            const overlay = document.getElementById("loadingOverlay");
            if (overlay) overlay.style.display = "none";
        }

        function fetchData() {
            showLoading();
            const req = {
                year: parseInt(yS.value),
                month: parseInt(mS.value),
                category: cS.value,
                division: divS.value,
                search: searchBox.value
            };

            fetch('Attendance.aspx/GetData', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(req)
            }).then(r => r.json()).then(res => {
                const data = JSON.parse(res.d);
                employees = data.Employees;
                attendanceData = data.Attendance || {};
                prevAttendanceData = data.PrevAttendance || {};
                
                // Automatically run Saturday Cut calculations for all loaded employees on load
                employees.forEach(emp => {
                    attendanceData[emp.ID] = attendanceData[emp.ID] || {};
                    calcSat(emp.ID, true);
                });
                
                isDirty = false;
                render();
                hideLoading();
                
                // Show loaded notification
                const year = yS.value;
                const monthText = mS.options[mS.selectedIndex].text;
                const category = cS.value;
                const division = divS.value;
                showPop(`Loaded attendance for ${monthText} ${year} (${category} - ${division}) successfully!`);
            }).catch(e => {
                console.error(e);
                hideLoading();
                showPop("Error loading attendance data");
            });
        }

        function saveData() {
            const req = {
                year: parseInt(yS.value),
                month: parseInt(mS.value),
                category: cS.value,
                data: JSON.stringify(attendanceData)
            };

            fetch('Attendance.aspx/SaveData', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(req)
            }).then(r => r.json()).then(res => {
                isDirty = false;
                showPop("Saved Successfully");
            }).catch(e => {
                console.error(e);
                showPop("Error saving");
            });
        }

        function getRefDays(y, m) {
            let d = new Date(y, m, 0), arr = [];
            while (d.getDay() != 6) {
                if (d.getDay() != 0) {
                    arr.unshift(new Date(d));
                }
                d.setDate(d.getDate() - 1);
            }
            return arr;
        }

        function render() {
            const y = parseInt(yS.value);
            const m = parseInt(mS.value);
            const days = new Date(y, m + 1, 0).getDate();
            const refs = getRefDays(y, m);
            
            let head = `<tr><th>ID</th><th>Name</th>`;
            
            refs.forEach(d => {
                head += `<th class="gray">${String(d.getDate()).padStart(2, '0')}<br>${d.toLocaleDateString('en', { weekday: 'short' })}</th>`;
            });

            for (let i = 1; i <= days; i++) {
                let d = new Date(y, m, i);
                if (d.getDay() !== 0) { 
                    head += `<th>${String(i).padStart(2, '0')}<br>${d.toLocaleDateString('en', { weekday: 'short' })}</th>`;
                }
            }
            head += `<th>Present</th><th>Adj</th><th>Total</th></tr>`;
            th.innerHTML = head;

            let rows = "";
            employees.forEach((emp, empIdx) => {
                attendanceData[emp.ID] = attendanceData[emp.ID] || {};
                let count = 0;
                let maxTotal = 0;
                let r = `<tr data-empid="${emp.ID}"><td>${emp.ID}</td><td style="text-align:left;">${emp.Name}</td>`;

                refs.forEach(d => {
                    let prevDay = d.getDate();
                    let pCell = (prevAttendanceData[emp.ID] && prevAttendanceData[emp.ID][prevDay]) ? prevAttendanceData[emp.ID][prevDay] : { Val: null, Leave: "" };
                    let pVal = (pCell.Val === null || pCell.Val === undefined) ? "" : pCell.Val;
                    let pLabel = pCell.Leave ? `<span class="label-text" style="color:gray;">${pCell.Leave}</span>` : "";
                    
                    r += `<td class="gray"><input class="att" value="${pVal}" readonly tabindex="-1" style="color:gray;border-color:#ccc;">${pLabel}</td>`;
                });

                for (let i = 1; i <= days; i++) {
                    let d = new Date(y, m, i);
                    let isToday = false;
                    const todayDate = new Date();
                    if (d.getDate() === todayDate.getDate() && d.getMonth() === todayDate.getMonth() && d.getFullYear() === todayDate.getFullYear()) {
                        isToday = true;
                    }
                    const cell = attendanceData[emp.ID][i] || { Val: null, Holiday: false, Leave: "" };
                    
                    if (d.getDay() === 0 && !cell.Holiday) continue;

                    let cls = "", drop = "", label = "";
                    let valToDisplay = (cell.Val === null || cell.Val === undefined) ? '' : cell.Val;

                    let readonlyAttr = "";
                    let dStr = `${y}-${String(m + 1).padStart(2, '0')}-${String(i).padStart(2, '0')}`;
                    let isOutOfBounds = (emp.JoinDate && dStr < emp.JoinDate) || (emp.ResignDate && dStr > emp.ResignDate);

                    if (!isOutOfBounds) maxTotal++;

                    if (isOutOfBounds) {
                        cls = "";
                        valToDisplay = "";
                        readonlyAttr = 'readonly tabindex="-1" style="background:#d1d5db; border:1px solid #9ca3af; cursor:not-allowed;"';
                    } else {
                        if (cell.Holiday) { 
                            cls = "royal-blue"; 
                            valToDisplay = "H";
                            count += 1;
                            readonlyAttr = 'readonly tabindex="-1" style="background:transparent; border:none;"';
                        }
                        else if (cell.Leave === "Carried") {
                            cls = "green";
                            valToDisplay = "1";
                            count += 1;
                        }
                        else if (cell.Leave === "Paired Paid") {
                            cls = "light-yellow";
                            valToDisplay = "1";
                            count += 1;
                        }
                        else if (cell.Leave === "Paired Unpaid") {
                            cls = "light-yellow";
                            valToDisplay = "0";
                        }
                        else if (cell.Val === 1) { 
                            cls = "green"; 
                            count += 1; 
                        }
                        else if (cell.Val === 0.5) { 
                            cls = "light-yellow"; 
                            count += 0.5;
                        }
                        else if (cell.Val === 0) { 
                            if (cell.Leave === "Paid") {
                                cls = "green";
                                valToDisplay = "1";
                                count += 1;
                            } else {
                                cls = "red";
                            }
                        }

                        if (cell.Leave) {
                            label = `<span class="label-text">${cell.Leave}</span>`;
                        }

                        if (d.getDay() === 6) {
                            readonlyAttr = 'readonly tabindex="-1" style="background:#e5e7eb; color:#6b7280; border:1px solid #d1d5db; cursor:not-allowed;"';
                        } else if (parseInt(role) !== 1 && !isToday) {
                            readonlyAttr = 'readonly tabindex="-1" style="background:#f3f4f6; color:#4b5563; border:1px solid #e5e7eb; cursor:not-allowed;"';
                        } else {
                            if (cell.Leave === "Carried" || cell.Leave === "Paired Paid" || cell.Leave === "Paired Unpaid") {
                                drop = `<select class="leave-opt" onchange="setLeave('${emp.ID}', ${i}, this.value, event)">
                                    <option value="${cell.Leave}" selected>${cell.Leave}</option>
                                    <option value="Reset">Reset</option>
                                </select>`;
                            }
                            else if (cell.Val == 0.5) {
                                drop = `<select class="leave-opt" onchange="setLeave('${emp.ID}', ${i}, this.value, event)">
                                    <option value=""></option>
                                    <option value="Carried">Carried</option>
                                    <option value="Pairing">Pairing</option>
                                </select>`;
                            }
                            else if (cell.Val == 0 && cell.Val !== "") {
                                drop = `<select class="leave-opt" onchange="setLeave('${emp.ID}', ${i}, this.value, event)">
                                    <option value=""></option>
                                    <option value="Paid" ${cell.Leave=="Paid"?"selected":""}>Paid</option>
                                    <option value="Unpaid" ${cell.Leave=="Unpaid"?"selected":""}>Unpaid</option>
                                </select>`;
                            }
                        }
                    }

                    r += `<td class="${cls}" data-day="${i}">
                            <input class="att" value="${valToDisplay}" oninput="setVal('${emp.ID}', ${i}, this.value, event)" ${readonlyAttr}>
                            ${label}
                            ${drop}
                          </td>`;
                }
                
                let adj = 0;
                if (attendanceData["GLOBAL"] && attendanceData["GLOBAL"][0]) {
                    adj = attendanceData["GLOBAL"][0].Val || 0;
                }
                
                r += `<td class="total-col fw-bold">${count}</td>
                      <td class="total-col">${(adj > 0 ? '+' : '') + (adj !== 0 ? adj : '-')}</td>
                      <td class="total-col text-primary fw-bold">${maxTotal}</td></tr>`;
                rows += r;
            });
            tb.innerHTML = rows;
        }

        function setLeave(id, day, val, event) {
            const y = parseInt(yS.value);
            const m = parseInt(mS.value);
            const d = new Date(y, m, day);
            const todayDate = new Date();
            const isToday = (d.getDate() === todayDate.getDate() && 
                             d.getMonth() === todayDate.getMonth() && 
                             d.getFullYear() === todayDate.getFullYear());
            if (parseInt(role) !== 1 && !isToday) {
                if (event && event.target) {
                    event.target.value = attendanceData[id]?.[day]?.Leave || "";
                }
                return;
            }

            let cell = attendanceData[id][day];
            
            if (val === "Reset") {
                cell.Val = (cell.Leave.includes("Paired") || cell.Leave === "Carried") ? 0.5 : 0;
                cell.Leave = "";
                showPop("Reset Completed");
            }
            else if (val === "Carried") {
                cell.Val = 1;
                cell.Leave = "Carried";
                showPop("Half Day Carried to Ledger Pending");
            }
            else if (val === "Pairing") {
                showPairingConfirmModal(() => {
                    cell.Val = 1;
                    cell.Leave = "Paired Paid";
                    showPop("Paired Paid applied (-1 Paid Leave)");
                    isDirty = true;
                    calcSat(id);
                    updateRowUI(event.target.closest("tr"), id);
                }, () => {
                    cell.Val = 0;
                    cell.Leave = "Paired Unpaid";
                    showPop("Paired Unpaid applied");
                    isDirty = true;
                    calcSat(id);
                    updateRowUI(event.target.closest("tr"), id);
                }, () => {
                    event.target.value = "";
                });
                return;
            }
            else if (val === "Paid") {
                cell.Val = 0;
                cell.Leave = "Paid";
                showPop("Paid Leave Added");
            }
            else if (val === "Unpaid") {
                cell.Val = 0;
                cell.Leave = "Unpaid";
                showPop("Unpaid Leave Added");
            }
            else {
                cell.Leave = "";
            }
            
            isDirty = true;
            calcSat(id);
            updateRowUI(event.target.closest("tr"), id);
        }

        function calcSat(id, isInitialLoad) {
            const y = parseInt(yS.value);
            const m = parseInt(mS.value);
            const days = new Date(y, m + 1, 0).getDate();
            const data = attendanceData[id];
            const emp = employees.find(e => e.ID === id) || {};

            let halfEntries = 0;
            Object.keys(data).forEach(d => {
                if (data[d]?.Val === 0.5) halfEntries++;
            });
            const halfPairExists = halfEntries >= 2 && halfEntries % 2 === 0;

            let satChanged = false;

            for (let i = 1; i <= days; i++) {
                let d = new Date(y, m, i);
                if (d.getDay() == 6) {
                    let ok = true;
                    
                    // If employee joined in the middle of this week (Monday < JoinDate <= Friday), Saturday is 0
                    let monday = new Date(d);
                    monday.setDate(d.getDate() - 5);
                    let friday = new Date(d);
                    friday.setDate(d.getDate() - 1);
                    
                    let monStr = `${monday.getFullYear()}-${String(monday.getMonth() + 1).padStart(2, '0')}-${String(monday.getDate()).padStart(2, '0')}`;
                    let friStr = `${friday.getFullYear()}-${String(friday.getMonth() + 1).padStart(2, '0')}-${String(friday.getDate()).padStart(2, '0')}`;
                    
                    if (emp.JoinDate && emp.JoinDate > monStr && emp.JoinDate <= friStr) {
                        ok = false;
                    } else {
                        for (let k = 1; k <= 5; k++) {
                            let c = new Date(d);
                            c.setDate(d.getDate() - k);

                            // Check employee JoinDate and ResignDate bounds
                            let cStr = `${c.getFullYear()}-${String(c.getMonth() + 1).padStart(2, '0')}-${String(c.getDate()).padStart(2, '0')}`;
                            if ((emp.JoinDate && cStr < emp.JoinDate) || (emp.ResignDate && cStr > emp.ResignDate)) {
                                continue; // Out of bounds, skip checking (ignored, does not penalize Saturday)
                            }

                            let v = null;
                            let l = "";
                            let isHol = false;
                            if (c.getMonth() == m) {
                                v = data[c.getDate()]?.Val;
                                l = data[c.getDate()]?.Leave;
                                isHol = data[c.getDate()]?.Holiday || false;
                            } else {
                                v = prevAttendanceData[id]?.[c.getDate()]?.Val;
                                l = prevAttendanceData[id]?.[c.getDate()]?.Leave;
                                isHol = prevAttendanceData[id]?.[c.getDate()]?.Holiday || false;
                            }
                            
                            let came = (v === 1) || (v === 0.5) || (l === "Paid") || (l === "Carried") || (l === "Paired Paid") || (l === "Paired Unpaid") || (isHol === true);
                            if (!came) {
                                ok = false;
                                break;
                            }
                        }
                    }

                    let oldVal = data[i]?.Val;
                    if (!ok && !halfPairExists) {
                        if (!data[i]?.Holiday) {
                            data[i] = data[i] || {};
                            data[i].Val = 0;
                            data[i].AutoSat = true;
                            if (oldVal !== 0) { 
                                satChanged = true; 
                                if (!isInitialLoad) {
                                    showPop("Saturday Cut Applied");
                                    isDirty = true;
                                }
                            }
                        }
                    } else {
                        data[i] = data[i] || {};
                        data[i].Val = 1;
                        data[i].AutoSat = true;
                        if (oldVal !== 1) { 
                            satChanged = true; 
                            if (!isInitialLoad) {
                                isDirty = true;
                            }
                        }
                    }
                }
            }
            return satChanged;
        }

        function updateRowUI(tr, empID) {
            const emp = employees.find(e => e.ID === empID) || {};
            let count = 0;
            let maxTotal = 0;
            const y = parseInt(yS.value);
            const m = parseInt(mS.value);
            const days = new Date(y, m + 1, 0).getDate();
            const data = attendanceData[empID];
            
            // First loop: calculate total count
            for (let i = 1; i <= days; i++) {
                const cell = data[i] || { Val: null, Holiday: false, Leave: "" };
                let d = new Date(y, m, i);
                
                let dStr = `${y}-${String(m + 1).padStart(2, '0')}-${String(i).padStart(2, '0')}`;
                if ((emp.JoinDate && dStr < emp.JoinDate) || (emp.ResignDate && dStr > emp.ResignDate)) {
                    continue;
                }
                
                if (d.getDay() === 0 && !cell.Holiday) continue;
                maxTotal++;

                if (cell.Holiday) count += 1;
                else if (cell.Leave === "Carried") count += 1;
                else if (cell.Leave === "Paired Paid") count += 1;
                else if (cell.Leave === "Paired Unpaid") { /* count += 0 */ }
                else if (cell.Val === 1) count += 1;
                else if (cell.Val === 0.5) count += 0.5;
                else if (cell.Val === 0) {
                    if (cell.Leave === "Paid") count += 1;
                }
            }
            
            let adj = (attendanceData["GLOBAL"] && attendanceData["GLOBAL"][0]) ? attendanceData["GLOBAL"][0].Val : 0;
            let cols = tr.querySelectorAll(".total-col");
            cols[0].innerText = count;
            cols[1].innerText = (adj > 0 ? '+' : '') + (adj !== 0 ? adj : '-');
            cols[2].innerText = maxTotal;

            for (let i = 1; i <= days; i++) {
                let d = new Date(y, m, i);
                let isToday = false;
                const todayDate = new Date();
                if (d.getDate() === todayDate.getDate() && d.getMonth() === todayDate.getMonth() && d.getFullYear() === todayDate.getFullYear()) {
                    isToday = true;
                }
                const cell = data[i] || { Val: null, Holiday: false, Leave: "" };
                if (d.getDay() === 0 && !cell.Holiday) continue;
                
                const td = tr.querySelector(`td[data-day="${i}"]`);
                if (!td) continue;

                let cls = "", valToDisplay = cell.Val;
                let readonlyAttr = "";
                let dStr = `${y}-${String(m + 1).padStart(2, '0')}-${String(i).padStart(2, '0')}`;
                let isOutOfBounds = (emp.JoinDate && dStr < emp.JoinDate) || (emp.ResignDate && dStr > emp.ResignDate);
                
                if (isOutOfBounds) {
                    cls = "";
                    valToDisplay = "";
                    readonlyAttr = 'readonly tabindex="-1" style="background:#d1d5db; border:1px solid #9ca3af; cursor:not-allowed;"';
                } else {
                    if (cell.Holiday) { 
                        cls = "royal-blue"; 
                        valToDisplay = "H"; 
                        readonlyAttr = 'readonly tabindex="-1" style="background:transparent; border:none;"';
                    }
                    else if (cell.Leave === "Carried") {
                        cls = "green";
                        valToDisplay = "1";
                    }
                    else if (cell.Leave === "Paired Paid") {
                        cls = "light-yellow";
                        valToDisplay = "1";
                    }
                    else if (cell.Leave === "Paired Unpaid") {
                        cls = "light-yellow";
                        valToDisplay = "0";
                    }
                    else if (cell.Val === 1) {
                        cls = "green";
                        valToDisplay = "1";
                    }
                    else if (cell.Val === 0.5) {
                        cls = "light-yellow";
                        valToDisplay = "0.5";
                    }
                    else if (cell.Val === 0) {
                        if (cell.Leave === "Paid") {
                            cls = "green";
                            valToDisplay = "1";
                        } else {
                            cls = "red";
                        }
                    }
                    
                    if (d.getDay() === 6) {
                        readonlyAttr = 'readonly tabindex="-1" style="background:#e5e7eb; color:#6b7280; border:1px solid #d1d5db; cursor:not-allowed;"';
                    } else if (parseInt(role) !== 1 && !isToday) {
                        readonlyAttr = 'readonly tabindex="-1" style="background:#f3f4f6; color:#4b5563; border:1px solid #e5e7eb; cursor:not-allowed;"';
                    }
                }
                
                td.className = cls;
                
                const inp = td.querySelector(".att");
                if (inp && document.activeElement !== inp) { 
                    inp.value = (valToDisplay === null || valToDisplay === undefined) ? "" : valToDisplay;
                    if (readonlyAttr.includes("readonly")) {
                        inp.setAttribute("readonly", "readonly");
                        inp.setAttribute("tabindex", "-1");
                    } else {
                        inp.removeAttribute("readonly");
                        inp.removeAttribute("tabindex");
                    }
                    inp.setAttribute("style", readonlyAttr.split('style="')[1]?.split('"')[0] || "");
                }

                let drop = td.querySelector(".leave-opt");
                let shouldShowDrop = false;
                let dropHtml = "";

                if (!isOutOfBounds && d.getDay() !== 6 && !cell.Holiday && !(parseInt(role) !== 1 && !isToday)) {
                    if (cell.Leave === "Carried" || cell.Leave === "Paired Paid" || cell.Leave === "Paired Unpaid") {
                        shouldShowDrop = true;
                        dropHtml = `<option value="${cell.Leave}" selected>${cell.Leave}</option><option value="Reset">Reset</option>`;
                    }
                    else if (cell.Val == 0.5) {
                        shouldShowDrop = true;
                        dropHtml = `<option value=""></option><option value="Carried">Carried</option><option value="Pairing">Pairing</option>`;
                    }
                    else if (cell.Val == 0 && cell.Val !== "") {
                        shouldShowDrop = true;
                        dropHtml = `<option value=""></option><option value="Paid" ${cell.Leave=="Paid"?"selected":""}>Paid</option><option value="Unpaid" ${cell.Leave=="Unpaid"?"selected":""}>Unpaid</option>`;
                    }
                }

                if (shouldShowDrop) {
                    if (!drop) {
                        drop = document.createElement("select");
                        drop.className = "leave-opt";
                        drop.onchange = (e) => {
                            setLeave(empID, i, e.target.value, e);
                        };
                        td.appendChild(drop);
                    }
                    drop.innerHTML = dropHtml;
                } else {
                    if (drop) drop.remove();
                }

                let labelSpan = td.querySelector(".label-text");
                if (cell.Leave) {
                    if (!labelSpan) {
                        labelSpan = document.createElement("span");
                        labelSpan.className = "label-text";
                        td.appendChild(labelSpan);
                    }
                    labelSpan.innerText = cell.Leave;
                } else {
                    if (labelSpan) labelSpan.remove();
                }
            }
        }

        function setVal(id, day, v, event) {
            const y = parseInt(yS.value);
            const m = parseInt(mS.value);
            const d = new Date(y, m, day);
            
            const todayDate = new Date();
            const isToday = (d.getDate() === todayDate.getDate() && 
                             d.getMonth() === todayDate.getMonth() && 
                             d.getFullYear() === todayDate.getFullYear());
            if (parseInt(role) !== 1 && !isToday) {
                if (event && event.target) {
                    event.target.value = attendanceData[id]?.[day]?.Val !== null ? attendanceData[id][day].Val : "";
                }
                return;
            }

            if (d.getDay() === 6) {
                event.target.value = attendanceData[id]?.[day]?.Val !== null ? attendanceData[id][day].Val : "";
                return;
            }

            if (v === "5") {
                v = "0.5";
                event.target.value = "0.5";
            }

            if (v !== "" && v !== "0" && v !== "1" && v !== "0.5" && v !== ".5") {
                if (v !== ".") event.target.value = "";
                return;
            }

            if (v === ".") return;

            let num = (v === "") ? null : Number(v);
            attendanceData[id][day] = attendanceData[id][day] || {};
            attendanceData[id][day].Val = num;
            
            if (num === 0.5) {
                showPop("0.5 Half Day Added");
            }
            
            isDirty = true;
            if (num !== 0 && attendanceData[id][day].Leave) attendanceData[id][day].Leave = "";

            calcSat(id);
            updateRowUI(event.target.closest("tr"), id);

            if (v !== "") {
                let currentTd = event.target.closest("td");
                let nextTd = currentTd.nextElementSibling;
                while (nextTd) {
                    let nextInp = nextTd.querySelector(".att");
                    if (nextInp && !nextInp.readOnly) { nextInp.focus(); nextInp.select(); break; }
                    nextTd = nextTd.nextElementSibling;
                }
            }
        }

        function setValDropdown(id, day, v, event) {
            let num = (v === "") ? null : parseFloat(v);
            attendanceData[id][day] = attendanceData[id][day] || {};
            attendanceData[id][day].Val = num;
            if (num !== 0 && attendanceData[id][day].Leave) attendanceData[id][day].Leave = "";
            
            if (num === 0.5) {
                showPop("0.5 Half Day Added");
            }
            
            isDirty = true;
            calcSat(id);
            updateRowUI(event.target.closest("tr"), id);
        }

        function applyHoliday() {
            const days = document.getElementById('holidayInput').value.split(',').map(Number);
            employees.forEach(emp => {
                days.forEach(d => {
                    if(d > 0 && d <= 31) {
                        attendanceData[emp.ID][d] = { Holiday: true, Val: null, Leave: "" };
                    }
                });
            });
            isDirty = true;
            render();
        }

        function removeHoliday() {
            const days = document.getElementById('holidayInput').value.split(',').map(Number);
            employees.forEach(emp => {
                days.forEach(d => {
                    if (d > 0 && d <= 31 && attendanceData[emp.ID]?.[d]?.Holiday) {
                        attendanceData[emp.ID][d] = { Holiday: false, Val: null, Leave: "" };
                        isDirty = true;
                    }
                });
            });
            render();
        }

        function globalAdjust() {
            let current = 0;
            if (attendanceData["GLOBAL"] && attendanceData["GLOBAL"][0]) {
                current = attendanceData["GLOBAL"][0].Val || 0;
            }
            
            const modal = document.getElementById("globalAdjustModal");
            const currentLabel = document.getElementById("globalAdjustCurrentVal");
            const inputField = document.getElementById("globalAdjustInput");
            const btnApply = document.getElementById("btnGlobalAdjustApply");
            const btnCancel = document.getElementById("btnGlobalAdjustCancel");
            
            if (!modal || !currentLabel || !inputField) return;
            
            currentLabel.textContent = (current > 0 ? '+' : '') + current;
            inputField.value = current !== 0 ? current : "";
            
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
                    // Reset adjustment
                    attendanceData["GLOBAL"] = attendanceData["GLOBAL"] || {};
                    attendanceData["GLOBAL"][0] = { Val: 0 };
                    isDirty = true;
                    showPop("Global Adjustment Reset");
                    render();
                    closeModal();
                    return;
                }
                
                const num = Number(val);
                if (isNaN(num)) {
                    showPop("Please enter a valid number");
                    return;
                }
                
                attendanceData["GLOBAL"] = attendanceData["GLOBAL"] || {};
                attendanceData["GLOBAL"][0] = { Val: num };
                isDirty = true;
                showPop(`Global Adjustment ${num > 0 ? '+' : ''}${num} Applied`);
                render();
                closeModal();
            };
        }

        setTimeout(initSelectors, 100);
    </script>
</asp:Content>

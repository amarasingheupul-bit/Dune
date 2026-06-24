pageextension 50113 BusinessManagerRoleCenter extends "Business Manager Role Center"
{
    layout
    {
        addfirst(rolecenter)
        {
            group(DuneBannerGroup)
            {
                Caption = '';
                ShowCaption = false;

                part(DuneBannerControl; "Dune RC Banner Part")
                {
                    ApplicationArea = All;
                    UpdatePropagation = Both;
                }
            }
        }

        addlast(rolecenter)
        {
            part(ApprovalsActivitiess; "Approvals Activities")
            {
                ApplicationArea = Suite;
            }
            part(BankAccounts; "Dashboard Bank Acc. Tile")
            {
                ApplicationArea = All;
            }
            part("DashboardInvoicesOwedList"; "Dashboard Invoices Owed List")
            {
                ApplicationArea = All;
            }
            part(DashboardBillsToPayList; "Dashboard Bills To Pay List")
            {
                ApplicationArea = All;
            }
            part(CashFlowChart; "Dashboard Cash Flow Chart")
            {
                ApplicationArea = All;
            }
            part(NetProfitChart; "Dashboard Net Profit Chart")
            {
                ApplicationArea = All;
            }
            part(Watchlist; "Dashboard Watchlist Part")
            {
                ApplicationArea = All;
            }
            part(RecentPayments; "Dashboard Recent Payments")
            {
                ApplicationArea = All;
            }
            part(TaskAssignByMe; "Dashboard Tasks Assigned By Me")
            {
                ApplicationArea = All;
            }
            part(TaskAssignToMe; "Dashboard Tasks Assigned To Me")
            {
                ApplicationArea = All;
            }
            part(Control91; "Trial Balance")
            {
                AccessByPermission = TableData "G/L Entry" = R;
                ApplicationArea = Basic, Suite;
            }
            part(PowerBIEmbeddedReportParts; "Power BI Embedded Report Part")
            {
                AccessByPermission = TableData "Power BI Context Settings" = I;
                ApplicationArea = Basic, Suite;
            }
            part(Control961; "Report Inbox Part")
            {
                AccessByPermission = TableData "Report Inbox" = IMD;
                ApplicationArea = Suite;
            }
        }

        modify("User Tasks Activities") { Visible = false; }
        modify(Control16) { Visible = false; }
        modify("Job Queue Tasks Activities") { Visible = false; }
        modify("Emails") { Visible = false; }
        modify("Intercompany Activities") { Visible = false; }
        modify(Control46) { Visible = false; }
        modify(Control55) { Visible = false; }
        modify("Favorite Accounts") { Visible = false; }
        modify(Control139) { Visible = false; }
        modify(ApprovalsActivities) { Visible = false; }
        modify(Control9) { Visible = false; }
        modify(PowerBIEmbeddedReportPart) { Visible = false; }
        modify(Control96) { Visible = false; }
    }

    actions
    {
        addbefore(Customers)
        {
            action(SetupDashboard)
            {
                ApplicationArea = All;
                Caption = 'Dashboard KPI Setup';
                RunObject = page "Dashboard KPI Setup List";
                ToolTip = 'Configure the G/L accounts and widgets for this dashboard.';
            }
        }
        addafter("Bank Accounts")
        {
            action(ResourceAllocation)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Resource Allocation';
                RunObject = Page "Transport MatrixS365";
                ToolTip = 'Open a Resource Allocation Page';
            }
        }
    }
}
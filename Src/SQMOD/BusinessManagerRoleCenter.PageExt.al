pageextension 50113 BusinessManagerRoleCenter extends "Business Manager Role Center"
{
    layout
    {
        addafter(Control55)
        {
            part(BankAccounts; "Dashboard Bank Acc. Part")
            {
                ApplicationArea = All;
            }
            part(InvoicesOwed; "Dashboard Invoices Owed")
            {
                ApplicationArea = All;
            }
            part(BillsToPay; "Dashboard Bills To Pay")
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
            // part(Tasks; "Dashboard Tasks Part")
            // {
            //     ApplicationArea = All;
            // }
            part(TaskAssignByMe; "Dashboard Tasks Assigned By Me")
            {
                ApplicationArea = All;
            }
            part(TaskAssignToMe; "Dashboard Tasks Assigned To Me")
            {
                ApplicationArea = All;
            }

        }
        modify("User Tasks Activities")
        {
            Visible = false;
        }
        modify(Control16)
        {
            Visible = false;
        }
        modify("Job Queue Tasks Activities")
        {
            Visible = false;
        }
        modify("Emails")
        {
            Visible = false;
        }
        modify("Intercompany Activities")
        {
            Visible = false;
        }
        modify(Control46)
        {
            Visible = false;
        }
        modify(Control55)
        {
            Visible = false;
        }
        modify("Favorite Accounts")
        {
            Visible = false;
        }
        modify(Control139)
        {
            Visible = false;
        }

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

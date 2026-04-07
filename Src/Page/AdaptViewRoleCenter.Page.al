page 50112 "AdaptView Role Center"
{
    PageType = RoleCenter;
    Caption = 'AdaptView Financials';

    layout
    {
        area(RoleCenter)
        {
            part(Control139; "Headline RC Business Manager")
            {
                ApplicationArea = Basic, Suite;
            }
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
            part(Tasks; "Dashboard Tasks Part")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(Embedding)
        {
            action(SetupDashboard)
            {
                ApplicationArea = All;
                Caption = 'Dashboard KPI Setup';
                RunObject = page "Dashboard KPI Setup List";
                ToolTip = 'Configure the G/L accounts and widgets for this dashboard.';
            }
        }
    }
}

profile "AdaptView Financials"
{
    Caption = 'AdaptView Financials';
    RoleCenter = "AdaptView Role Center";
}

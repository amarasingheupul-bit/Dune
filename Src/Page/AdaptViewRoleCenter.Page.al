page 50112 "AdaptView Role Center"
{
    PageType = RoleCenter;
    Caption = 'AdaptView Financials';

    layout
    {
        area(RoleCenter)
        {
            part(BankAccounts; "Dashboard Bank Acc. Tile")
            {
                ApplicationArea = All;
            }
            part(InvoicesOwed; "Dashboard Invoices Owed")
            {
                ApplicationArea = All;
            }
            // part(BillsToPay; "Dashboard Bills To Pay")
            // {
            //     ApplicationArea = All;
            // }
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
            part(Tasks; "Dashboard Tasks Part")
            {
                ApplicationArea = All;
            }
            part(Equity; "Dashboard Equity Part")
            {
                ApplicationArea = All;
            }
            // custom charts
            part(MyProjects; "My Jobs")
            {
                ApplicationArea = All;
                Caption = 'My Projects';
            }
            part(CustomPrice; "Custom Project Price Chart")
            {
                ApplicationArea = All;
            }
            part(CustomProfit; "Custom Project Profit Chart")
            {
                ApplicationArea = All;
            }
            part(CustomCost; "Custom Project Cost Chart")
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

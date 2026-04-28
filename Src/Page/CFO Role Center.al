page 50135 "CFO Role Center"
{
    PageType = RoleCenter;
    Caption = 'CFO';
    ApplicationArea = All;

    layout
    {
        area(RoleCenter)
        {
            part(BankAccountsD; "Dashboard Bank Acc. Tile")
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
        }
    }

    actions
    {
        area(Sections)
        {
            group(Finance)
            {
                Caption = 'Finance';
                action(ChartOfAccounts)
                {
                    ApplicationArea = All;
                    Caption = 'Chart of Accounts';
                    RunObject = Page "Chart of Accounts";
                    ToolTip = 'View the chart of accounts.';
                }
                action(GLEntries)
                {
                    ApplicationArea = All;
                    Caption = 'G/L Entries';
                    RunObject = Page "General Ledger Entries";
                    ToolTip = 'View general ledger entries.';
                }
                action(BudgetAction)
                {
                    ApplicationArea = All;
                    Caption = 'Budgets';
                    RunObject = Page "G/L Budget Names";
                    ToolTip = 'View and manage budgets.';
                }
                action(BankAccounts)
                {
                    ApplicationArea = All;
                    Caption = 'Bank Accounts';
                    RunObject = Page "Bank Account List";
                    ToolTip = 'View bank accounts.';
                }
            }
            group(Payables)
            {
                Caption = 'Payables';
                action(PurchaseInvoices)
                {
                    ApplicationArea = All;
                    Caption = 'Purchase Invoices';
                    RunObject = Page "Purchase Invoices";
                    ToolTip = 'View purchase invoices.';
                }
                action(Vendors)
                {
                    ApplicationArea = All;
                    Caption = 'Vendors';
                    RunObject = Page "Vendor List";
                    ToolTip = 'View vendors.';
                }
                action(VendorLedger)
                {
                    ApplicationArea = All;
                    Caption = 'Vendor Ledger Entries';
                    RunObject = Page "Vendor Ledger Entries";
                    ToolTip = 'View vendor ledger entries.';
                }
            }
            group(Receivables)
            {
                Caption = 'Receivables';
                action(SalesInvoices)
                {
                    ApplicationArea = All;
                    Caption = 'Sales Invoices';
                    RunObject = Page "Sales Invoice List";
                    ToolTip = 'View sales invoices.';
                }
                action(Customers)
                {
                    ApplicationArea = All;
                    Caption = 'Customers';
                    RunObject = Page "Customer List";
                    ToolTip = 'View customers.';
                }
                action(CustomerLedger)
                {
                    ApplicationArea = All;
                    Caption = 'Customer Ledger Entries';
                    RunObject = Page "Customer Ledger Entries";
                    ToolTip = 'View customer ledger entries.';
                }
            }
            group(Setup)
            {
                Caption = 'Setup';
                action(SetupDashboard)
                {
                    ApplicationArea = All;
                    Caption = 'Dashboard KPI Setup';
                    RunObject = Page "Dashboard KPI Setup List";
                    ToolTip = 'Configure the G/L accounts and widgets for this dashboard.';
                }
            }
        }
    }
}
profile "CFO"
{
    Caption = 'CFO';
    ProfileDescription = 'Role center for Chief Financial Officers.';
    RoleCenter = "CFO Role Center";
    Enabled = true;
    Promoted = true;
}
page 50138 "Dune Dashboard Role Center"
{
    ApplicationArea = All;
    Caption = 'DUNE Executive Dashboard';
    PageType = RoleCenter;

    layout
    {
        area(rolecenter)
        {
            part(DuneDashboardControl; "Dune RC Banner Part")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(creation)
        {
            action("Sales Quote")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Create new sales quotes for prospective leads or active clients.';
                Caption = 'Sales Quote';
                Image = NewSalesQuote;
                RunObject = Page "Sales Quote";
                RunPageMode = Create;
            }

            action("Sales Order")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Convert quotes or record fresh direct customer orders.';
                Caption = 'Sales Order';
                Image = NewOrder;
                RunObject = Page "Sales Order";
                RunPageMode = Create;
            }

            action("Sales Invoice")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Generate and view finalized sales invoices for transactions.';
                Caption = 'Sales Invoice';
                Image = NewSalesInvoice;
                RunObject = Page "Sales Invoice";
                RunPageMode = Create;
            }

            action("Purchase Order")
            {
                ApplicationArea = Suite;
                ToolTip = 'Manage commercial procurement cycles and track incoming items.';
                Caption = 'Purchase Order';
                Image = NewOrder;
                RunObject = Page "Purchase Order";
                RunPageMode = Create;
            }
        }

        area(sections)
        {
            group(Reports)
            {
                Caption = 'All Reports';

                action("Chart of Accounts")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Review or modify corporate ledger account codes and tracking balances.';
                    Caption = 'Chart of Accounts';
                    RunObject = Page "Chart of Accounts";
                }

                action(Customers)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Browse the registered client directory and track client statements.';
                    Caption = 'Customers';
                    RunObject = Page "Customer List";
                }

                action(Vendors)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Access supplier master sheets to execute supplier settlement flows.';
                    Caption = 'Vendors';
                    RunObject = Page "Vendor List";
                }

                action(Items)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Manage raw material descriptions, inventories, and unit values.';
                    Caption = 'Items';
                    RunObject = Page "Item List";
                }
            }
        }
    }
}
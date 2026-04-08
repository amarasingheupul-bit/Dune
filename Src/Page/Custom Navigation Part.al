page 50123 "Custom Navigation ListPart"
{
    PageType = ListPart;
    Caption = 'Quick Navigation';
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(CustomSalesGroup)
            {
                Caption = 'Sales';

                field(SalesInvoice; 'Sales Invoice')
                {
                    ApplicationArea = All;
                    Caption = 'Sales Invoice';
                    ToolTip = 'Create a new sales invoice.';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"Sales Invoice");
                    end;
                }
                field(PostedSalesInvoices; 'Posted Sales Invoices')
                {
                    ApplicationArea = All;
                    Caption = 'Posted Sales Invoices';
                    ToolTip = 'View posted sales invoices.';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"Posted Sales Invoices");
                    end;
                }
                field(SalesCreditMemo; 'Sales Credit Memo')
                {
                    ApplicationArea = All;
                    Caption = 'Sales Credit Memo';
                    ToolTip = 'Create a new sales credit memo.';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"Sales Credit Memo");
                    end;
                }
                field(PostedSalesCreditMemos; 'Posted Sales Credit Memos')
                {
                    ApplicationArea = All;
                    Caption = 'Posted Sales Credit Memos';
                    ToolTip = 'View posted sales credit memos.';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"Posted Sales Credit Memos");
                    end;
                }
            }

            group(CustomCashMgmtGroup)
            {
                Caption = 'Cash Management';

                field(BankAccounts; 'Bank Accounts')
                {
                    ApplicationArea = All;
                    Caption = 'Bank Accounts';
                    ToolTip = 'View and manage bank accounts.';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"Bank Account List");
                    end;
                }
                field(CashReceiptJournals; 'Cash Receipt Journals')
                {
                    ApplicationArea = All;
                    Caption = 'Cash Receipt Journals';
                    ToolTip = 'Open cash receipt journals.';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"Cash Receipt Journal");
                    end;
                }
                field(PaymentJournals; 'Payment Journals')
                {
                    ApplicationArea = All;
                    Caption = 'Payment Journals';
                    ToolTip = 'Open payment journals.';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"Payment Journal");
                    end;
                }
                // field(BankDeposits; 'Bank Deposits')
                // {
                //     ApplicationArea = All;
                //     Caption = 'Bank Deposits';
                //     ToolTip = 'View and create bank deposits.';

                //     trigger OnDrillDown()
                //     begin
                //         Page.Run(Page::bankdepo);
                //     end;
                // }
            }

            group(CustomPurchasingGroup)
            {
                Caption = 'Purchasing';

                field(PurchaseInvoice; 'Purchase Invoice')
                {
                    ApplicationArea = All;
                    Caption = 'Purchase Invoice';
                    ToolTip = 'Create a new purchase invoice.';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"Purchase Invoice");
                    end;
                }
                field(PostedPurchaseInvoices; 'Posted Purchase Invoices')
                {
                    ApplicationArea = All;
                    Caption = 'Posted Purchase Invoices';
                    ToolTip = 'View posted purchase invoices.';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"Posted Purchase Invoices");
                    end;
                }
            }

            group(CustomFinanceGroup)
            {
                Caption = 'Finance';

                field(GeneralJournals; 'General Journals')
                {
                    ApplicationArea = All;
                    Caption = 'General Journals';
                    ToolTip = 'Open general journals.';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"General Journal");
                    end;
                }
                field(Currencies; 'Currencies')
                {
                    ApplicationArea = All;
                    Caption = 'Currencies';
                    ToolTip = 'View and manage currencies.';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"Currencies");
                    end;
                }
            }
        }
    }
}
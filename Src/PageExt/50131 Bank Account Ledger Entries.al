pageextension 50135 "Bank Acc Led EntriesDuBase" extends "Bank Account Ledger Entries"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        addlast(Reporting)
        {
            action(PaymentVoucherAfterPost)
            {
                Caption = 'Payment Voucher - After Post';
                ApplicationArea = All;
                Image = Print;

                trigger OnAction()
                var
                    BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
                begin
                    CurrPage.SetSelectionFilter(BankAccountLedgerEntry);
                    Report.RunModal(Report::"Payment Voucher-After Post", true, true, BankAccountLedgerEntry);
                end;
            }
            action(PettyCashVoucherAfterPost)
            {
                Caption = 'Petty Cash Voucher';
                ApplicationArea = All;
                Image = Print;

                trigger OnAction()
                var
                    BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
                begin
                    CurrPage.SetSelectionFilter(BankAccountLedgerEntry);
                    Report.RunModal(Report::"Petty Cash Voucher", true, true, BankAccountLedgerEntry);
                end;
            }
        }
    }

    var
        myInt: Integer;
}
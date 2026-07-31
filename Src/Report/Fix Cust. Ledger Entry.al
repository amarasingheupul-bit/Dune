report 50118 "Fix Cust. Ledger Entry"
{
    ApplicationArea = All;
    Caption = 'Fix Customer Ledger Entry - Reset Remaining/Open';
    ProcessingOnly = true;
    UsageCategory = Administration;
    Permissions = tabledata "Cust. Ledger Entry" = RIMD,
                  tabledata "Detailed Cust. Ledg. Entry" = RIMD;

    dataset
    {
        dataitem(CustLedgerEntry; "Cust. Ledger Entry")
        {

            RequestFilterFields = "Entry No.", "Document No.";

            trigger OnAfterGetRecord()
            var
                CLE: Record "Cust. Ledger Entry";
            begin
                CLE.LockTable();
                if not CLE.Get(CustLedgerEntry."Entry No.") then
                    Error('Entry No. %1 not found.', CustLedgerEntry."Entry No.");

                CLE."Remaining Amount" := -1856149.77;
                CLE."Remaining Amt. (LCY)" := -1856149.77;
                CLE.Open := true;

                if not CLE.Modify(true) then
                    Error('Modify FAILED for Entry No. %1: %2', CLE."Entry No.", GetLastErrorText());

                Commit();

                Message('Entry No. %1 updated. Remaining Amount = %2, Open = %3',
                    CLE."Entry No.", CLE."Remaining Amount", CLE.Open);

                ProcessedCount += 1;
            end;

            trigger OnPreDataItem()
            begin
                if CustLedgerEntry.GetFilter("Entry No.") = '' then
                    if CustLedgerEntry.GetFilter("Document No.") = '' then
                        Error('Please enter a filter on Entry No. or Document No. before running this report.');
            end;
        }
    }

    requestpage
    {
        SaveValues = true;
        layout
        {
            area(Content)
            {
            }
        }
    }

    trigger OnPostReport()
    begin
        Message('%1 customer ledger entry/entries updated.', ProcessedCount);
    end;

    var
        ProcessedCount: Integer;
}
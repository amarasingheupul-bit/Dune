report 50119 "Delete Application Entry"
{
    ApplicationArea = All;
    Caption = 'Delete Application Entry (Detailed Cust. Ledg. Entry)';
    ProcessingOnly = true;
    UsageCategory = Administration;
    Permissions = tabledata "Cust. Ledger Entry" = RIMD,
                  tabledata "Detailed Cust. Ledg. Entry" = RIMD;

    dataset
    {
        dataitem(DetailedCustLedgEntry; "Detailed Cust. Ledg. Entry")
        {
            RequestFilterFields = "Document No.", "Document Type", "Entry No.";

            trigger OnAfterGetRecord()
            var
                CustLedgEntry: Record "Cust. Ledger Entry";
                DtldCustLedgEntry2: Record "Detailed Cust. Ledg. Entry";
                RemainingAmount: Decimal;
                RemainingAmountLCY: Decimal;
                CustLedgerEntryNo: Integer;
            begin
                if DetailedCustLedgEntry."Entry Type" <> DetailedCustLedgEntry."Entry Type"::Application then begin
                    Message('Entry No. %1 is not an Application entry (Entry Type = %2). Skipping.',
                        DetailedCustLedgEntry."Entry No.", DetailedCustLedgEntry."Entry Type");
                    exit;
                end;

                CustLedgerEntryNo := DetailedCustLedgEntry."Cust. Ledger Entry No.";

                DetailedCustLedgEntry.Delete();

                // Recalculate remaining amount from what's left in Detailed Ledger Entries
                DtldCustLedgEntry2.SetRange("Cust. Ledger Entry No.", CustLedgerEntryNo);
                DtldCustLedgEntry2.CalcSums(Amount, "Amount (LCY)");
                RemainingAmount := DtldCustLedgEntry2.Amount;
                RemainingAmountLCY := DtldCustLedgEntry2."Amount (LCY)";

                if CustLedgEntry.Get(CustLedgerEntryNo) then begin
                    CustLedgEntry."Remaining Amount" := RemainingAmount;
                    CustLedgEntry."Remaining Amt. (LCY)" := RemainingAmountLCY;
                    CustLedgEntry.Open := (RemainingAmount <> 0);
                    CustLedgEntry.Modify(true);

                    Message('Deleted Application Entry No. %1. Cust. Ledger Entry %2 updated: Remaining Amount = %3, Open = %4',
                        DetailedCustLedgEntry."Entry No.", CustLedgerEntryNo, RemainingAmount, CustLedgEntry.Open);
                end else
                    Message('Deleted Application Entry No. %1, but Cust. Ledger Entry %2 was not found.',
                        DetailedCustLedgEntry."Entry No.", CustLedgerEntryNo);

                Commit();
                ProcessedCount += 1;
            end;

            trigger OnPreDataItem()
            begin
                if (DetailedCustLedgEntry.GetFilter("Document No.") = '') and
                   (DetailedCustLedgEntry.GetFilter("Document Type") = '') and
                   (DetailedCustLedgEntry.GetFilter("Entry No.") = '')
                then
                    Error('Please enter a filter on Document No., Document Type, or Entry No. before running this report.');
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
        Message('%1 application entry/entries deleted.', ProcessedCount);
    end;

    var
        ProcessedCount: Integer;
}
report 50126 "Correct  Amount LCY"
{
    Caption = 'Correct  Amount LCY';
    ProcessingOnly = true;
    UseRequestPage = false;
    UsageCategory = Tasks;
    ApplicationArea = All;
    Permissions = tabledata "Vendor Ledger Entry" = R,
                  tabledata "Detailed Vendor Ledg. Entry" = RM,
                  tabledata "Bank Account Ledger Entry" = RM,
                  tabledata "G/L Entry" = RM;

    dataset
    {
    }

    trigger OnPreReport()
    begin
        if not Confirm(ConfirmQst, false) then
            CurrReport.Quit();

        // Vendor Ledger Entry No., corrected Amount, corrected Amount (LCY)
        CorrectVendorEntry(5476, 3826.18, 14129.82);
        CorrectVendorEntry(5474, 352.87, 1303.12);

        Message(DoneMsg, UpdatedCount);
    end;

    // Only Modify() is used below - nothing is inserted, so no new entries are created.
    local procedure CorrectVendorEntry(VendLedgEntryNo: Integer; NewAmount: Decimal; NewAmountLCY: Decimal)
    var
        VendLedgEntry: Record "Vendor Ledger Entry";
        DtldVendLedgEntry: Record "Detailed Vendor Ledg. Entry";
        BankAccLedgEntry: Record "Bank Account Ledger Entry";
        GLEntry: Record "G/L Entry";
        OldAmountLCY: Decimal;
    begin
        if not VendLedgEntry.Get(VendLedgEntryNo) then
            Error(EntryNotFoundErr, VendLedgEntryNo);

        // Vendor Ledger Entry "Amount" / "Amount (LCY)" are FlowFields (sum of the
        // detailed entries), so they cannot be changed directly. Update the
        // Initial Entry in Detailed Vendor Ledg. Entry instead.
        DtldVendLedgEntry.SetRange("Vendor Ledger Entry No.", VendLedgEntryNo);
        DtldVendLedgEntry.SetRange("Entry Type", DtldVendLedgEntry."Entry Type"::"Initial Entry");
        if not DtldVendLedgEntry.FindFirst() then
            Error(InitialEntryNotFoundErr, VendLedgEntryNo);

        OldAmountLCY := DtldVendLedgEntry."Amount (LCY)";
        DtldVendLedgEntry.Amount := KeepSign(DtldVendLedgEntry.Amount, NewAmount);
        DtldVendLedgEntry."Amount (LCY)" := KeepSign(DtldVendLedgEntry."Amount (LCY)", NewAmountLCY);
        DtldVendLedgEntry.Modify();
        UpdatedCount += 1;

        // Bank Account Ledger Entry has its own Entry No. series, so the vendor entry
        // number cannot be used there. Find the bank line by Document No. + Posting Date
        // and by the old LCY amount (ignoring sign).
        BankAccLedgEntry.SetRange("Document No.", VendLedgEntry."Document No.");
        BankAccLedgEntry.SetRange("Posting Date", VendLedgEntry."Posting Date");
        if BankAccLedgEntry.FindSet() then
            repeat
                if Abs(BankAccLedgEntry."Amount (LCY)") = Abs(OldAmountLCY) then begin
                    BankAccLedgEntry.Amount := KeepSign(BankAccLedgEntry.Amount, NewAmount);
                    BankAccLedgEntry."Amount (LCY)" := KeepSign(BankAccLedgEntry."Amount (LCY)", NewAmountLCY);
                    BankAccLedgEntry.Modify();
                    UpdatedCount += 1;
                end;
            until BankAccLedgEntry.Next() = 0;

        // G/L Entry: same idea - existing lines of this document whose old amount
        // matches are edited in place (Amount + Debit/Credit Amount).
        GLEntry.SetRange("Document No.", VendLedgEntry."Document No.");
        GLEntry.SetRange("Posting Date", VendLedgEntry."Posting Date");
        if GLEntry.FindSet() then
            repeat
                if Abs(GLEntry.Amount) = Abs(OldAmountLCY) then begin
                    GLEntry.Amount := KeepSign(GLEntry.Amount, NewAmountLCY);
                    if GLEntry.Amount > 0 then begin
                        GLEntry."Debit Amount" := GLEntry.Amount;
                        GLEntry."Credit Amount" := 0;
                    end else begin
                        GLEntry."Debit Amount" := 0;
                        GLEntry."Credit Amount" := -GLEntry.Amount;
                    end;
                    GLEntry.Modify();
                    UpdatedCount += 1;
                end;
            until GLEntry.Next() = 0;
    end;

    // Amounts above are typed as positive numbers; each ledger record keeps its
    // existing debit/credit direction (a negative record stays negative).
    local procedure KeepSign(OldValue: Decimal; NewValue: Decimal): Decimal
    begin
        if OldValue < 0 then
            exit(-Abs(NewValue));
        exit(Abs(NewValue));
    end;

    var
        UpdatedCount: Integer;
        ConfirmQst: Label 'This directly modifies posted Vendor, Bank and G/L records for entries 5474 and 5476. Continue?';
        DoneMsg: Label '%1 ledger record(s) updated.';
        EntryNotFoundErr: Label 'Vendor Ledger Entry %1 was not found.';
        InitialEntryNotFoundErr: Label 'No Initial Entry found in Detailed Vendor Ledg. Entry for Vendor Ledger Entry %1.';
}

report 50127 "Correct  Amount"
{
    Caption = 'Correct  Amount';
    ProcessingOnly = true;
    UseRequestPage = false;
    UsageCategory = Tasks;
    ApplicationArea = All;
    Permissions = tabledata "Vendor Ledger Entry" = RIMD,
                  tabledata "Detailed Vendor Ledg. Entry" = RIMD,
                  tabledata "Cust. Ledger Entry" = RIMD,
                  tabledata "Detailed Cust. Ledg. Entry" = RIMD,
                  tabledata "G/L Entry" = RIMD;

    dataset
    {
    }

    trigger OnPreReport()
    begin
        if not Confirm(ConfirmQst, false) then
            CurrReport.Quit();

        // ---- Vendor entries: Entry No., corrected Amount, corrected Amount (LCY) ----
        CorrectVendorEntry(5306, -30000, -128589.00);
        // CorrectVendorEntry(5304, 122465.71, 28571.43);
        // CorrectVendorEntry(5305, 6123.29, 1428.57);    // TODO: vendor entry 3
        // CorrectVendorEntry(702, -128589.00, -30000);    // TODO: vendor entry 4

        // ---- Customer entries: Entry No., corrected Amount, corrected Amount (LCY) ----
        // CorrectCustomerEntry(5035, -632.93, -150.5);  // TODO: customer entry 1
        // CorrectCustomerEntry(5034, -12658.69, -3010.07);  // TODO: customer entry 2
        // CorrectCustomerEntry(5036, 13291.62, 3160.57);  // TODO: customer entry 3
        // CorrectCustomerEntry(53, 13291.62, 3160.57);  // TODO: customer entry 4

        Message(DoneMsg, UpdatedCount);
    end;

    // Only Modify() is used below - nothing is inserted, so no new entries are created.
    local procedure CorrectVendorEntry(VendLedgEntryNo: Integer; NewAmount: Decimal; NewAmountLCY: Decimal)
    var
        VendLedgEntry: Record "Vendor Ledger Entry";
        DtldVendLedgEntry: Record "Detailed Vendor Ledg. Entry";
        GLEntry: Record "G/L Entry";
        OldAmountLCY: Decimal;
    begin
        if VendLedgEntryNo = 0 then
            exit;

        if not VendLedgEntry.Get(VendLedgEntryNo) then
            Error(VendEntryNotFoundErr, VendLedgEntryNo);

        // Vendor Ledger Entry "Amount" / "Amount (LCY)" are FlowFields (sum of the
        // detailed entries), so they cannot be changed directly. Update the
        // Initial Entry in Detailed Vendor Ledg. Entry instead.
        DtldVendLedgEntry.SetRange("Vendor Ledger Entry No.", VendLedgEntryNo);
        DtldVendLedgEntry.SetRange("Entry Type", DtldVendLedgEntry."Entry Type"::"Initial Entry");
        if not DtldVendLedgEntry.FindFirst() then
            Error(InitialVendEntryNotFoundErr, VendLedgEntryNo);

        OldAmountLCY := DtldVendLedgEntry."Amount (LCY)";
        DtldVendLedgEntry.Amount := KeepSign(DtldVendLedgEntry.Amount, NewAmount);
        DtldVendLedgEntry."Amount (LCY)" := KeepSign(DtldVendLedgEntry."Amount (LCY)", NewAmountLCY);
        DtldVendLedgEntry.Modify();
        UpdatedCount += 1;

        // G/L Entry: existing lines of this document whose old amount matches are
        // edited in place (Amount + Debit/Credit Amount).
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

    // Only Modify() is used below - nothing is inserted, so no new entries are created.
    local procedure CorrectCustomerEntry(CustLedgEntryNo: Integer; NewAmount: Decimal; NewAmountLCY: Decimal)
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
        DtldCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        GLEntry: Record "G/L Entry";
        OldAmountLCY: Decimal;
    begin
        if CustLedgEntryNo = 0 then
            exit;

        if not CustLedgEntry.Get(CustLedgEntryNo) then
            Error(CustEntryNotFoundErr, CustLedgEntryNo);

        // Customer Ledger Entry "Amount" / "Amount (LCY)" are FlowFields (sum of the
        // detailed entries), so they cannot be changed directly. Update the
        // Initial Entry in Detailed Cust. Ledg. Entry instead.
        DtldCustLedgEntry.SetRange("Cust. Ledger Entry No.", CustLedgEntryNo);
        DtldCustLedgEntry.SetRange("Entry Type", DtldCustLedgEntry."Entry Type"::"Initial Entry");
        if not DtldCustLedgEntry.FindFirst() then
            Error(InitialCustEntryNotFoundErr, CustLedgEntryNo);

        OldAmountLCY := DtldCustLedgEntry."Amount (LCY)";
        DtldCustLedgEntry.Amount := KeepSign(DtldCustLedgEntry.Amount, NewAmount);
        DtldCustLedgEntry."Amount (LCY)" := KeepSign(DtldCustLedgEntry."Amount (LCY)", NewAmountLCY);
        DtldCustLedgEntry.Modify();
        UpdatedCount += 1;

        // G/L Entry: existing lines of this document whose old amount matches are
        // edited in place (Amount + Debit/Credit Amount).
        GLEntry.SetRange("Document No.", CustLedgEntry."Document No.");
        GLEntry.SetRange("Posting Date", CustLedgEntry."Posting Date");
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

    // Amounts above are typed as positive or negative numbers directly; each ledger
    // record keeps its existing debit/credit direction (sign of the OLD value wins).
    local procedure KeepSign(OldValue: Decimal; NewValue: Decimal): Decimal
    begin
        if OldValue < 0 then
            exit(-Abs(NewValue));
        exit(Abs(NewValue));
    end;

    var
        UpdatedCount: Integer;
        ConfirmQst: Label 'This directly modifies posted Vendor, Customer and G/L records. Continue?';
        DoneMsg: Label '%1 ledger record(s) updated.';
        VendEntryNotFoundErr: Label 'Vendor Ledger Entry %1 was not found.';
        InitialVendEntryNotFoundErr: Label 'No Initial Entry found in Detailed Vendor Ledg. Entry for Vendor Ledger Entry %1.';
        CustEntryNotFoundErr: Label 'Customer Ledger Entry %1 was not found.';
        InitialCustEntryNotFoundErr: Label 'No Initial Entry found in Detailed Cust. Ledg. Entry for Customer Ledger Entry %1.';
}

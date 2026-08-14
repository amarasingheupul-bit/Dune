report 50120 "Update Posted Purch. Invoice"
{
    ProcessingOnly = true;
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'Update Posted Purch. Invoice';
    Permissions = tabledata "Purch. Inv. Header" = RIMD,
                  tabledata "Purch. Inv. Line" = RIMD;

    dataset
    {
        dataitem(PurchInvHeader; "Purch. Inv. Header")
        {
            RequestFilterFields = "No.";

            trigger OnAfterGetRecord()
            var
                PurchInvLine: Record "Purch. Inv. Line";
                LinesUpdated: Integer;
                LineListText: Text;
                RemainingText: Text;
                PairText: Text;
                LineNoText: Text;
                AmountText: Text;
                LineNoValue: Integer;
                AmountValue: Decimal;
                CommaPos: Integer;
                EqPos: Integer;
            begin
                // --- Currency Code (safe: real header field) ---
                if NewCurrencyCode <> '' then begin
                    PurchInvHeader.Validate("Currency Code", NewCurrencyCode);
                    PurchInvHeader.Modify(true);
                end;

                // --- Amount: MULTI-LINE mode (use when invoice has several lines,
                // each needing a different amount) ---
                // Format: "LineNo=Amount,LineNo=Amount,..."
                // e.g. "10000=4376.17,20000=4732.61,30000=5020.73"
                if LineAmountsText <> '' then begin
                    RemainingText := LineAmountsText;
                    while RemainingText <> '' do begin
                        CommaPos := StrPos(RemainingText, ',');
                        if CommaPos = 0 then begin
                            PairText := RemainingText;
                            RemainingText := '';
                        end else begin
                            PairText := CopyStr(RemainingText, 1, CommaPos - 1);
                            RemainingText := CopyStr(RemainingText, CommaPos + 1);
                        end;
                        PairText := DelChr(PairText, '<>', ' ');
                        EqPos := StrPos(PairText, '=');
                        if EqPos = 0 then
                            Error('Invalid Line Amounts format near "%1". Use LineNo=Amount, comma-separated.', PairText);

                        LineNoText := CopyStr(PairText, 1, EqPos - 1);
                        AmountText := CopyStr(PairText, EqPos + 1);
                        if not Evaluate(LineNoValue, LineNoText) then
                            Error('Could not read Line No. from "%1".', LineNoText);
                        if not Evaluate(AmountValue, AmountText) then
                            Error('Could not read Amount from "%1".', AmountText);

                        if not PurchInvLine.Get(PurchInvHeader."No.", LineNoValue) then
                            Error('Line No. %1 not found on invoice %2.', LineNoValue, PurchInvHeader."No.");

                        PurchInvLine.Amount := AmountValue;
                        PurchInvLine."VAT Base Amount" := AmountValue;
                        PurchInvLine."VAT Base Amount" := Round(AmountValue * PurchInvLine."VAT %" / 100);
                        PurchInvLine."Amount Including VAT" :=
                            PurchInvLine.Amount + PurchInvLine."VAT Base Amount";
                        PurchInvLine.Modify(true);
                        LinesUpdated += 1;
                    end;
                end
                // --- Amount: SINGLE-VALUE mode (only safe when invoice has one line,
                // or when a specific Line No. is given) ---
                else if NewAmount <> 0 then begin
                    PurchInvLine.SetRange("Document No.", PurchInvHeader."No.");
                    if LineNo <> 0 then
                        PurchInvLine.SetRange("Line No.", LineNo);

                    // Guard: refuse to apply one amount to every line on a
                    // multi-line invoice - that would multiply the total.
                    if LineNo = 0 then
                        if PurchInvLine.Count() > 1 then begin
                            LineListText := '';
                            if PurchInvLine.FindSet() then
                                repeat
                                    LineListText += StrSubstNo('\Line %1: %2 (Amount %3)',
                                        PurchInvLine."Line No.", PurchInvLine.Description, PurchInvLine.Amount);
                                until PurchInvLine.Next() = 0;
                            Error('Invoice %1 has more than one line. Use the Line Amounts field instead, or enter a specific Line No.:%2',
                                PurchInvHeader."No.", LineListText);
                        end;

                    if PurchInvLine.FindSet(true) then begin
                        repeat
                            PurchInvLine.Amount := NewAmount;
                            PurchInvLine."VAT Base Amount" := NewAmount;
                            PurchInvLine."VAT Base Amount" := Round(NewAmount * PurchInvLine."VAT %" / 100);
                            PurchInvLine."Amount Including VAT" :=
                                PurchInvLine.Amount + PurchInvLine."VAT Base Amount";
                            PurchInvLine.Modify(true);
                            LinesUpdated += 1;
                        until PurchInvLine.Next() = 0;
                    end else
                        Error('No matching line(s) found on invoice %1 to update the amount.', PurchInvHeader."No.");
                end;

                Message('Invoice %1 updated.\Currency Code: %2\Lines updated: %3',
                    PurchInvHeader."No.",
                    PurchInvHeader."Currency Code",
                    LinesUpdated);
            end;
        }
    }

    requestpage
    {
        SaveValues = false;

        layout
        {
            area(content)
            {
                group(Updates)
                {
                    Caption = 'New Values';

                    field(NewCurrencyCodeField; NewCurrencyCode)
                    {
                        ApplicationArea = All;
                        Caption = 'New Currency Code';
                        TableRelation = Currency.Code;
                        ToolTip = 'Leave blank to skip updating Currency Code.';
                    }
                    field(LineAmountsTextField; LineAmountsText)
                    {
                        ApplicationArea = All;
                        Caption = 'Line Amounts (LineNo=Amount, comma-separated)';
                        ToolTip = 'Use for multi-line invoices, e.g. 10000=4376.17,20000=4732.61,30000=5020.73. Takes priority over New Amount below.';
                        MultiLine = true;
                    }
                    field(LineNoField; LineNo)
                    {
                        ApplicationArea = All;
                        Caption = 'Line No. (optional, single-line mode only)';
                        ToolTip = 'Leave blank/0 to apply New Amount to the only line on the invoice. Ignored if Line Amounts above is filled in.';
                    }
                    field(NewAmountField; NewAmount)
                    {
                        ApplicationArea = All;
                        Caption = 'New Amount (single-line mode only)';
                        ToolTip = 'Leave blank/0 to skip. Ignored if Line Amounts above is filled in.';
                    }
                }
            }
        }
    }

    var
        LineNo: Integer;
        NewCurrencyCode: Code[10];
        NewAmount: Decimal;
        LineAmountsText: Text;
}

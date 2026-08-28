tableextension 50117 "4HC Purchase Line" extends "Purchase Line"
{
    fields
    {
        field(50103; "Qty. to Post %"; Integer)
        {
            Caption = 'Qty. to Post %';
            MinValue = 0;
            MaxValue = 100;
            ToolTip = 'Specifies the value of the Qty. to Post % field.';
        }
        field(50104; "Qty. Remaining %"; Integer)
        {
            Caption = 'Qty. Remaining %';
            ToolTip = 'Specifies the value of the Qty. Remaining % field.';
        }
        field(50105; "Qty Posted %"; Integer)
        {
            Caption = 'Qty Posted %';
            MaxValue = 100;
            MinValue = 0;
        }
        field(50106; "Amount (AED)"; Decimal)
        {
            Caption = 'Line Amount (AED)';
            DecimalPlaces = 2;
            Editable = true;
            DataClassification = CustomerContent;
        }
        field(50107; "Unit Cost (AED)"; Decimal)
        {
            Caption = 'Direct Unit Cost (AED)';
            DecimalPlaces = 2;
            Editable = true;
            DataClassification = CustomerContent;
        }

        // Recalculate automatically whenever these fields change
        modify(Amount)
        {
            trigger OnAfterValidate()
            begin
                Rec.UpdateAEDAmounts();
            end;
        }
        modify("Direct Unit Cost")
        {
            trigger OnAfterValidate()
            begin
                Rec.UpdateAEDAmounts();
            end;
        }
        modify("Currency Code")
        {
            trigger OnAfterValidate()
            begin
                Rec.UpdateAEDAmounts();
            end;
        }
    }
    procedure UpdateAEDAmounts()
    var
        PurchHeader: Record "Purchase Header";
        CurrExchRate: Record "Currency Exchange Rate";
        DocCurrencyCode: Code[10];
        PostingDate: Date;
    begin
        if not PurchHeader.Get(Rec."Document Type", Rec."Document No.") then
            exit;

        PostingDate := PurchHeader."Posting Date";
        if PostingDate = 0D then
            PostingDate := WorkDate();

        DocCurrencyCode := Rec."Currency Code";
        if DocCurrencyCode = '' then
            DocCurrencyCode := GetLCYCode(); // e.g. EUR if that's your company currency

        // If the line itself is already AED, no conversion needed
        if DocCurrencyCode = 'AED' then begin
            Rec."Amount (AED)" := Rec.Amount;
            Rec."Unit Cost (AED)" := Rec."Direct Unit Cost";
            exit;
        end;

        Rec."Amount (AED)" :=
            CurrExchRate.ExchangeAmtFCYToFCY(PostingDate, DocCurrencyCode, 'AED', Rec.Amount);
        Rec."Unit Cost (AED)" :=
            CurrExchRate.ExchangeAmtFCYToFCY(PostingDate, DocCurrencyCode, 'AED', Rec."Direct Unit Cost");
    end;

    local procedure GetLCYCode(): Code[10]
    var
        GLSetup: Record "General Ledger Setup";
    begin
        GLSetup.Get();
        exit(GLSetup."LCY Code");
    end;
}
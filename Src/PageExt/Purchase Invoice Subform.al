pageextension 50138 "Purch. Invoice Subform AED" extends "Purch. Invoice Subform"
{
    layout
    {
        addafter("Line Amount")
        {
            field("Amount (AED)"; Rec."Amount (AED)")
            {
                ApplicationArea = All;
                Caption = 'Amount (AED)';
                ToolTip = 'Specifies the line amount converted to AED using the exchange rate as of the posting date.';
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Rec.UpdateAEDAmounts();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        Rec.UpdateAEDAmounts();
    end;
}
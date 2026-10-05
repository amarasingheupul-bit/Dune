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
        modify("Shortcut Dimension 1 Code")
        {
            ApplicationArea = All;
            visible = true;
            Caption = 'Project Code';
        }
        modify("Shortcut Dimension 2 Code")
        {
            ApplicationArea = All;
            visible = true;
            Caption = 'Div Code';
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
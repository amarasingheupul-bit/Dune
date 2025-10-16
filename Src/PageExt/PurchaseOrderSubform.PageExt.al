pageextension 50127 "4HC Purchase Order Subform" extends "Purchase Order Subform"
{
    layout
    {
        modify("Job No.")
        {
            Visible = true;
        }
        modify("Job Task No.")
        {
            Visible = true;
        }
        modify("Job Planning Line No.")
        {
            Visible = true;
        }
        addafter(Quantity)
        {
            field("Qty. to Post %"; Rec."Qty. to Post %")
            {
                Visible = false;
                ApplicationArea = All;
                trigger OnValidate()
                var
                    Text001Err: Label 'cannot exceed qty remaining precentage.';
                begin
                    if Rec."Qty. to Post %" > Rec."Qty. Remaining %" then
                        Rec.FieldError("Qty. to Post %", Text001Err);
                    Rec.Validate("Qty. to Receive", (Rec."Qty. to Post %" / 100) * Rec.Quantity);

                    Rec."Qty. Remaining %" := 100 - Rec."Qty Posted %";
                end;
            }
            field("Qty. Remaining %"; Rec."Qty. Remaining %")
            {
                ToolTip = 'Specifies the value of the Qty. Remaining % field.';
                ApplicationArea = All;
                Editable = false;
                Visible = false;
            }
            field("Qty Posted %"; Rec."Qty Posted %")
            {
                ToolTip = 'Specifies the value of the Qty Posted % field.';
                ApplicationArea = All;
                Editable = false;
                Visible = false;
            }
        }
    }
}

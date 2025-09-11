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
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Qty. to Post % field.';
                trigger OnValidate()
                var
                    Text001Err: Label 'cannot exceed qty remaining precentage.';
                begin
                    Rec."Qty. Remaining %" := 100 - Rec."Qty Posted %";
                    if Rec."Qty. to Post %" > Rec."Qty. Remaining %" then
                        Rec.FieldError("Qty. to Post %", Text001Err);
                    Rec.Validate("Qty. to Receive", (Rec."Qty. to Post %" / 100) * Rec.Quantity);

                    Rec."Qty. Remaining %" := 100 - Rec."Qty Posted %" - Rec."Qty. to Post %";
                end;
            }
            field("Qty. Remaining %"; Rec."Qty. Remaining %")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies the value of the Qty. Remaining % field.';
            }
        }
    }
}

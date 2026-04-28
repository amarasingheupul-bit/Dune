page 50134 "Dashboard Bills To Pay List"
{
    PageType = ListPart;
    Caption = 'Bills to Pay';
    SourceTable = "Vendor Ledger Entry";
    SourceTableView = where(Open = const(true), "Document Type" = const(Invoice));
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    Caption = 'Invoice No.';
                }
                field("Vendor Name"; Rec."Vendor Name")
                {
                    ApplicationArea = All;
                    Caption = 'Vendor';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    Caption = 'Date of Invoice';
                }
                field("Remaining Amount"; Rec."Remaining Amount")
                {
                    ApplicationArea = All;
                    Caption = 'Value';
                    AutoFormatType = 1;
                    AutoFormatExpression = Rec."Currency Code";
                }
                field("Due Date"; Rec."Due Date")
                {
                    ApplicationArea = All;
                    Caption = 'Due Date';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    Caption = 'Currency';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields("Remaining Amount");
    end;
}
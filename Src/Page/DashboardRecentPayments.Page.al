page 50119 "Dashboard Recent Payments"
{
    PageType = ListPart;
    SourceTable = "Vendor Ledger Entry";
    SourceTableView = sorting("Posting Date") order(descending) where("Document Type" = filter(Payment));
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                Visible = IsVisible;

                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    Caption = 'Invoice #';
                    Style = StrongAccent;
                }

                field(CustomerName; CustName)
                {
                    ApplicationArea = All;
                    Caption = 'Contact';
                }

                field(FormattedDate; DisplayDate)
                {
                    ApplicationArea = All;
                    Caption = 'Date received';
                }

                field(AmountLCY; DisplayAmount)  // ← use the calculated variable
                {
                    ApplicationArea = All;
                    Caption = 'Amount';
                    AutoFormatType = 1;
                }
            }
        }
    }

    var
        CalcMgt: Codeunit "Dashboard Calc. Mgt.";
        CustName: Text;
        DisplayDate: Text;
        DisplayAmount: Decimal;  // ← new variable
        IsVisible: Boolean;

    trigger OnOpenPage()
    begin
        IsVisible := CalcMgt.CheckIsWidgetVisible(Enum::"Dashboard Widget Identity"::"Recent Payments");
    end;

    trigger OnAfterGetRecord()
    var
        Vend: Record Vendor;
    begin
        if Vend.Get(Rec."Vendor No.") then
            CustName := Vend.Name
        else
            CustName := '';

        DisplayDate := Format(Rec."Posting Date", 0, '<Month Text,3> <Day>');

        Rec.CalcFields("Amount (LCY)");

        if Rec."Amount (LCY)" <> 0 then
            DisplayAmount := Abs(Rec."Amount (LCY)")
        else
            DisplayAmount := Abs(Rec.Amount);
    end;
}
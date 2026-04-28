page 50119 "Dashboard Recent Payments"
{
    PageType = ListPart;
    SourceTable = "Cust. Ledger Entry";
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

                field(AmountLCY; Abs(Rec."Amount (LCY)"))
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
        IsVisible: Boolean;

    trigger OnOpenPage()
    begin
        IsVisible := CalcMgt.CheckIsWidgetVisible(Enum::"Dashboard Widget Identity"::"Recent Payments");
    end;

    trigger OnAfterGetRecord()
    var
        Cust: Record Customer;
    begin
        if Cust.Get(Rec."Customer No.") then
            CustName := Cust.Name
        else
            CustName := '';

        DisplayDate := Format(Rec."Posting Date", 0, '<Month Text,3> <Day>');
    end;
}

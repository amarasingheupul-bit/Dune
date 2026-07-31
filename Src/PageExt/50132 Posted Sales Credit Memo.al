pageextension 50136 "Posted Sales Credit MemoDBase" extends "Posted Sales Credit Memo"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        addlast(Reporting)
        {
            group("P&ostingSqBase")
            {
                action("TAX Credit Note")
                {
                    ApplicationArea = All;
                    Caption = 'TAX Credit Note';
                    Image = Print;
                    Promoted = true;
                    PromotedCategory = Report;
                    trigger OnAction()
                    var
                        SalesCrMemHeader: Record "Sales Cr.Memo Header";
                    begin
                        SalesCrMemHeader.Reset();
                        SalesCrMemHeader.SetFilter("No.", Rec."No.");
                        Report.RunModal(50109, true, true, SalesCrMemHeader);
                    end;
                }
            }
        }
    }

    var
        myInt: Integer;
}
pageextension 50137 "Posted General JournalExt" extends "Posted General Journal"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        addlast(Reporting)
        {
            action(JournalReport)
            {
                ApplicationArea = All;
                Caption = 'Journal Report';
                Image = Print;
                trigger OnAction()
                var
                    GenJnlLine: Record "Posted Gen. Journal Line";
                begin
                    GenJnlLine.SetRange("Journal Template Name", Rec."Journal Template Name");
                    GenJnlLine.SetRange("Journal Batch Name", Rec."Journal Batch Name");
                    GenJnlLine.SetRange("Document No.", Rec."Document No.");
                    Report.Run(Report::"Journal Report", true, true, GenJnlLine);
                end;
            }
        }
    }

    var
        myInt: Integer;
}
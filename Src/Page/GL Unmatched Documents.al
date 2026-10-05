page 50141 "GL Unmatched Documents"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'Unmatched G/L Documents';
    SourceTable = "Doc Balance Buffer";
    SourceTableTemporary = true;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Document No."; Rec."Document No.") { }
                field("Posting Date"; Rec."Posting Date") { }
                field("Total Debit"; Rec."Total Debit") { }
                field("Total Credit"; Rec."Total Credit") { }
                field(Difference; Rec.Difference)
                {
                    StyleExpr = StyleTxt;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Refresh)
            {
                ApplicationArea = All;
                Image = Refresh;
                Caption = 'Refresh';

                trigger OnAction()
                begin
                    LoadData();
                end;
            }
        }
    }

    var
        GLUnmatchedMgt: Codeunit "GL Unmatched Doc Finder";
        StyleTxt: Text;

    trigger OnOpenPage()
    begin
        LoadData();
    end;

    local procedure LoadData()
    begin
        Rec.Reset();
        Rec.DeleteAll();
        GLUnmatchedMgt.GetUnmatchedDocuments(Rec);
        if Rec.FindFirst() then;
    end;

    trigger OnAfterGetRecord()
    begin
        StyleTxt := 'Unfavorable'; // highlights the row red since it's always a mismatch
    end;
}
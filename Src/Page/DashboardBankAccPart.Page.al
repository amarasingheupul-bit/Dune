page 50113 "Dashboard Bank Acc. Part"
{
    PageType = ListPart;
    Caption = 'Bank Account';
    Editable = false;
    SourceTable = "Bank Account";

    layout
    {
        area(Content)
        {
            repeater(BankList)
            {
                field(BankName; Rec.Name)
                {
                    ApplicationArea = All;
                    Caption = 'Bank Account';
                    Style = Strong;
                }

                field(BankNo; Rec."Bank Account No.")
                {
                    ApplicationArea = All;
                    Caption = 'Account No.';
                    Style = Subordinate;
                }

                field(BankBal; Rec."Balance (LCY)")
                {
                    ApplicationArea = All;
                    Caption = 'Balance (LCY)';
                    Style = Strong;
                    AutoFormatType = 1;
                }

                field(LastStatementDate; LastStatementDateText)
                {
                    ApplicationArea = All;
                    Caption = 'Last Statement';
                    Style = Subordinate;
                }

                field(ImportLink; ImportLinkTxt)
                {
                    ApplicationArea = All;
                    Caption = 'Action';
                    DrillDown = true;

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"Bank Acc. Reconciliation List");
                    end;
                }
            }
        }
    }

    var
        LastStatementDateText: Text;
        ImportLinkTxt: Text;

    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields("Balance (LCY)");
        LastStatementDateText := GetLastStatementDate(Rec."No.");
        ImportLinkTxt := 'Import bank statement';
    end;

    local procedure GetLastStatementDate(BankAccNo: Code[20]): Text
    var
        BankAccStmt: Record "Bank Account Statement";
        DateLbl: Label 'Statement balance (%1)', Locked = true;
    begin
        BankAccStmt.SetRange("Bank Account No.", BankAccNo);
        if BankAccStmt.FindLast() then
            exit(StrSubstNo(DateLbl, Format(BankAccStmt."Statement Date", 0, '<Month Text,3> <Day>')))
        else
            exit('No statements found');
    end;
}
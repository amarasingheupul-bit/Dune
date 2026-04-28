page 50131 "Dashboard Bank Acc. Tile"
{
    PageType = CardPart;
    SourceTable = "Bank Account";
    Caption = 'Bank Accounts';
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            cuegroup(BankCue1)
            {
                ShowCaption = false;
                Visible = IsVisible;
                field(BankBalance1; BankBalance1)
                {
                    ApplicationArea = All;
                    CaptionClass = '1,5,,' + BankName1 + ' (' + BankAccountNo1 + ')';
                    Image = Cash;
                    StyleExpr = Style1;
                    ToolTip = 'Specifies the current balance of the selected bank account.';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"Bank Account Card", Rec);
                    end;
                }
            }
            cuegroup(BankCue2)
            {
                ShowCaption = false;
                Visible = IsVisible;

                field(BankBalance2; BankBalance2)
                {
                    ApplicationArea = All;
                    CaptionClass = '1,5,,' + BankName2 + ' (' + BankAccountNo2 + ')';
                    Image = Cash;
                    StyleExpr = Style2;
                    ToolTip = 'Specifies the current balance of the selected bank account.';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"Bank Account Card", Rec);
                    end;
                }
            }
            cuegroup(BankCue3)
            {
                ShowCaption = false;
                Visible = IsVisible;

                field(BankBalance3; BankBalance3)
                {
                    ApplicationArea = All;
                    CaptionClass = '1,5,,' + BankName3 + ' (' + BankAccountNo3 + ')';
                    Image = Cash;
                    StyleExpr = Style3;
                    ToolTip = 'Specifies the current balance of the selected bank account.';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"Bank Account Card", Rec);
                    end;
                }
            }
            cuegroup(BankCue4)
            {
                ShowCaption = false;
                Visible = IsVisible;

                field(BankBalance4; BankBalance4)
                {
                    ApplicationArea = All;
                    CaptionClass = '1,5,,' + BankName4 + ' (' + BankAccountNo4 + ')';
                    Image = Cash;
                    StyleExpr = Style4;
                    ToolTip = 'Specifies the current balance of the selected bank account.';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"Bank Account Card", Rec);
                    end;
                }
            }
        }
    }
    var
        CalcMgt: Codeunit "Dashboard Calc. Mgt.";
        BankBalance1, BankBalance2, BankBalance3, BankBalance4 : decimal;
        BankName1, BankName2, BankName3, BankName4 : text;
        BankAccountNo1, BankAccountNo2, BankAccountNo3, BankAccountNo4 : text;
        Style1, Style2, Style3, Style4 : text;
        IsVisible: Boolean;

    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields("Balance (LCY)");
    end;

    trigger OnOpenPage()
    var
        KPISetup: Record "Dashboard KPI Setup";
    begin
        IsVisible := CalcMgt.CheckIsWidgetVisible(Enum::"Dashboard Widget Identity"::"Bank Tiles");

        if KPISetup.Get(KPISetup."KPI Code"::BANK_1) then
            if Rec.Get(KPISetup."Bank Account No.") then begin
                Rec.CalcFields("Balance (LCY)");
                BankBalance1 := Rec."Balance (LCY)";
                BankName1 := Rec.Name;
                BankAccountNo1 := Rec."Bank Account No.";
                Style1 := SetStyle(BankBalance1);
            end;
        if KPISetup.Get(KPISetup."KPI Code"::BANK_2) then
            if Rec.Get(KPISetup."Bank Account No.") then begin
                Rec.CalcFields("Balance (LCY)");
                BankBalance2 := Rec."Balance (LCY)";
                BankName2 := Rec.Name;
                BankAccountNo2 := Rec."Bank Account No.";
                Style2 := SetStyle(BankBalance2);
            end;
        if KPISetup.Get(KPISetup."KPI Code"::BANK_3) then
            if Rec.Get(KPISetup."Bank Account No.") then begin
                Rec.CalcFields("Balance (LCY)");
                BankBalance3 := Rec."Balance (LCY)";
                BankName3 := Rec.Name;
                BankAccountNo3 := Rec."Bank Account No.";
                Style3 := SetStyle(BankBalance3);
            end;
        if KPISetup.Get(KPISetup."KPI Code"::BANK_4) then
            if Rec.Get(KPISetup."Bank Account No.") then begin
                Rec.CalcFields("Balance (LCY)");
                BankBalance4 := Rec."Balance (LCY)";
                BankName4 := Rec.Name;
                BankAccountNo4 := Rec."Bank Account No.";
                Style4 := SetStyle(BankBalance4);
            end;
    end;

    local procedure SetStyle(Amount: Decimal): Text
    begin
        case true of
            Amount > 5000:
                exit('Favorable'); // Green
            Amount < 0:
                exit('Unfavorable'); // Red
            Amount <= 5000:
                exit('Ambiguous'); // Yellow
            else
                exit('None'); // Grey
        end;
    end;
}
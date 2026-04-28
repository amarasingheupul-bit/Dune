page 50132 "Dashboard Equity Part"
{
    PageType = ListPart;
    Caption = 'Equity';
    SourceTable = "G/L Account";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                ShowCaption = false;
                Visible = IsVisible;
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    Caption = 'Account';
                }
                field(Balance; Rec."Balance at Date")
                {
                    ApplicationArea = All;
                    Caption = 'Balance';
                    AutoFormatType = 1;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        DashboardSetup: Record "Dashboard KPI Setup";
        CalcMgt: Codeunit "Dashboard Calc. Mgt.";
    begin
        IsVisible := CalcMgt.CheckIsWidgetVisible(Enum::"Dashboard Widget Identity"::Equity);

        if DashboardSetup.Get(DashboardSetup."KPI Code"::EQUITY) then
            Rec.SetFilter("No.", DashboardSetup."G/L Account Filter");

    end;

    var
        IsVisible: Boolean;
}
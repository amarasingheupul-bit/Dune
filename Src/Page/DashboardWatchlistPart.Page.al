page 50122 "Dashboard Watchlist Part"
{
    PageType = ListPart;
    Caption = 'Chart of accounts watchlist';
    SourceTable = "G/L Account";
    SourceTableView = sorting("No.") where("Account Type" = const(Posting));
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Watchlist)
            {
                ShowCaption = false;

                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Caption = 'Code';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    Caption = 'Account';
                }
                field(ThisMonthAmount; ThisMonthAmount)
                {
                    ApplicationArea = All;
                    Caption = 'This month';
                    AutoFormatType = 1;
                }
                field(YTDAmount; YTDAmount)
                {
                    ApplicationArea = All;
                    Caption = 'YTD';
                    AutoFormatType = 1;
                }
            }
        }
    }

    var
        ThisMonthAmount: Decimal;
        YTDAmount: Decimal;

    trigger OnOpenPage()
    var
        DashboardSetup: Record "Dashboard KPI Setup";
    begin
        if DashboardSetup.Get('WATCH_LIST') then
            Rec.SetFilter("No.", DashboardSetup."G/L Account Filter");
    end;

    trigger OnAfterGetRecord()
    var
        StartOfMonth, EndOfMonth, StartOfYear : Date;
    begin
        StartOfMonth := CalcDate('<-CM>', WorkDate());
        EndOfMonth := CalcDate('<CM>', WorkDate());
        StartOfYear := CalcDate('<-CY>', WorkDate());

        Rec.SetRange("Date Filter", StartOfMonth, EndOfMonth);
        Rec.CalcFields("Net Change");
        ThisMonthAmount := Rec."Net Change";

        Rec.SetRange("Date Filter", StartOfYear, EndOfMonth);
        Rec.CalcFields("Net Change");
        YTDAmount := Rec."Net Change";
    end;
}
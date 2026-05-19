page 50122 "Dashboard Watchlist Part"
{
    PageType = ListPart;
    Caption = 'Chart of Accounts Watchlist';
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
                Visible = IsVisible;

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
                    Caption = 'This Month';
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

    actions
    {
        area(Processing)
        {
            action(ManageWatchlist)
            {
                ApplicationArea = All;
                Caption = 'Manage My Watchlist';
                Image = Setup;
                ToolTip = 'Add or remove accounts from your personal watchlist.';

                trigger OnAction()
                begin
                    // Open setup page and refresh after user closes it
                    Page.RunModal(Page::"Dashboard Watchlist Setup");
                    ApplyUserFilter();
                    CurrPage.Update(false);
                end;
            }
        }
    }

    var
        CalcMgt: Codeunit "Dashboard Calc. Mgt.";
        ThisMonthAmount: Decimal;
        YTDAmount: Decimal;
        IsVisible: Boolean;

    trigger OnOpenPage()
    begin
        IsVisible := CalcMgt.CheckIsWidgetVisible(Enum::"Dashboard Widget Identity"::Watchlist);
        ApplyUserFilter();
    end;

    trigger OnAfterGetRecord()
    var
        GLAccount: Record "G/L Account";
        StartOfMonth: Date;
        EndOfMonth: Date;
        StartOfYear: Date;
    begin
        StartOfMonth := CalcDate('<-CM>', WorkDate());
        EndOfMonth := CalcDate('<CM>', WorkDate());
        StartOfYear := CalcDate('<-CY>', WorkDate());

        GLAccount.Get(Rec."No.");

        GLAccount.SetRange("Date Filter", StartOfMonth, EndOfMonth);
        GLAccount.CalcFields("Net Change");
        ThisMonthAmount := GLAccount."Net Change";

        GLAccount.SetRange("Date Filter", StartOfYear, EndOfMonth);
        GLAccount.CalcFields("Net Change");
        YTDAmount := GLAccount."Net Change";
    end;

    // ── Centralised filter logic ─────────────────────────────────────────────
    local procedure ApplyUserFilter()
    var
        AccountFilter: Text;
    begin
        AccountFilter := GetUserAccountFilter();

        Rec.FilterGroup(2);  // use filter group 2 so it can't be overridden by the user
        if AccountFilter <> '' then
            Rec.SetFilter("No.", AccountFilter)
        else
            Rec.SetRange("No.", '');  // no setup → show nothing
        Rec.FilterGroup(0);
    end;

    local procedure GetUserAccountFilter(): Text
    var
        WatchlistSetup: Record "Dashboard Watchlist Setup";
        FilterText: Text;
    begin
        WatchlistSetup.SetRange("User ID", CopyStr(UserId(), 1, MaxStrLen(WatchlistSetup."User ID")));
        if not WatchlistSetup.FindSet() then
            exit('');

        repeat
            if FilterText <> '' then
                FilterText += '|';
            // Escape any pipe chars in account numbers for safety
            FilterText += WatchlistSetup."G/L Account No.";
        until WatchlistSetup.Next() = 0;

        exit(FilterText);
    end;
}
codeunit 50104 "Dashboard Calc. Mgt."
{
    /// Calculates the total Net Change for a given KPI Setup over a specific date range.
    procedure GetKPITotal(KPICode: Code[20]; StartDate: Date; EndDate: Date): Decimal
    var
        DashboardSetup: Record "Dashboard KPI Setup";
        GLAccount: Record "G/L Account";
        TotalAmount: Decimal;
    begin
        TotalAmount := 0;

        if not DashboardSetup.Get(KPICode) then
            exit(0);

        if DashboardSetup."G/L Account Filter" = '' then
            exit(0);

        GLAccount.SetFilter("No.", DashboardSetup."G/L Account Filter");

        GLAccount.SetRange("Account Type", GLAccount."Account Type"::Posting);

        // Apply Date Filters
        if (StartDate <> 0D) and (EndDate <> 0D) then
            GLAccount.SetRange("Date Filter", StartDate, EndDate)
        else
            if (StartDate <> 0D) then
                GLAccount.SetFilter("Date Filter", '%1..', StartDate)
            else
                if (EndDate <> 0D) then
                    GLAccount.SetFilter("Date Filter", '..%1', EndDate);

        if GLAccount.FindSet() then
            repeat
                GLAccount.CalcFields("Net Change");
                TotalAmount += GLAccount."Net Change";
            until GLAccount.Next() = 0;

        exit(TotalAmount);
    end;
}

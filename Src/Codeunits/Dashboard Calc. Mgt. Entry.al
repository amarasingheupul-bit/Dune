codeunit 50107 "Dashboard Calc. Mgt. Entry"
{
    // Returns total amount from G/L Entries (Net Change equivalent).
    procedure GetKPITotalFromEntries(KPICode: Enum "Dashboard Kpi Code"; StartDate: Date; EndDate: Date): Decimal
    var
        DashboardSetup: Record "Dashboard KPI Setup";
        GLEntry: Record "G/L Entry";
        TotalAmount: Decimal;
    begin
        TotalAmount := 0;

        if not DashboardSetup.Get(KPICode) then
            exit(0);

        if DashboardSetup."G/L Account Filter" = '' then
            exit(0);

        GLEntry.SetFilter("G/L Account No.", DashboardSetup."G/L Account Filter");
        ApplyDateFilter(GLEntry, StartDate, EndDate);

        if GLEntry.FindSet() then
            repeat
                TotalAmount += GLEntry.Amount;
            until GLEntry.Next() = 0;

        exit(TotalAmount);
    end;

    // Cash In: returns total Debit Amount from G/L Entries.
    procedure GetKPIDebitTotalFromEntries(KPICode: Enum "Dashboard Kpi Code"; StartDate: Date; EndDate: Date): Decimal
    var
        DashboardSetup: Record "Dashboard KPI Setup";
        GLEntry: Record "G/L Entry";
        TotalAmount: Decimal;
    begin
        TotalAmount := 0;

        if not DashboardSetup.Get(KPICode) then
            exit(0);

        if DashboardSetup."G/L Account Filter" = '' then
            exit(0);

        GLEntry.SetFilter("G/L Account No.", DashboardSetup."G/L Account Filter");
        ApplyDateFilter(GLEntry, StartDate, EndDate);

        if GLEntry.FindSet() then
            repeat
                TotalAmount += GLEntry."Debit Amount";
            until GLEntry.Next() = 0;

        exit(TotalAmount);
    end;

    // Cash Out: returns total Credit Amount from G/L Entries.
    procedure GetKPICreditTotalFromEntries(KPICode: Enum "Dashboard Kpi Code"; StartDate: Date; EndDate: Date): Decimal
    var
        DashboardSetup: Record "Dashboard KPI Setup";
        GLEntry: Record "G/L Entry";
        TotalAmount: Decimal;
    begin
        TotalAmount := 0;

        if not DashboardSetup.Get(KPICode) then
            exit(0);

        if DashboardSetup."G/L Account Filter" = '' then
            exit(0);

        GLEntry.SetFilter("G/L Account No.", DashboardSetup."G/L Account Filter");
        ApplyDateFilter(GLEntry, StartDate, EndDate);

        if GLEntry.FindSet() then
            repeat
                TotalAmount += GLEntry."Credit Amount";
            until GLEntry.Next() = 0;

        exit(TotalAmount);
    end;

    // Overload: ad-hoc total by account filter string.
    procedure GetEntriesTotalByAccountFilter(AccountFilter: Text; StartDate: Date; EndDate: Date): Decimal
    var
        GLEntry: Record "G/L Entry";
        TotalAmount: Decimal;
    begin
        TotalAmount := 0;

        if AccountFilter = '' then
            exit(0);

        GLEntry.SetFilter("G/L Account No.", AccountFilter);
        ApplyDateFilter(GLEntry, StartDate, EndDate);

        if GLEntry.FindSet() then
            repeat
                TotalAmount += GLEntry.Amount;
            until GLEntry.Next() = 0;

        exit(TotalAmount);
    end;

    // Returns a per-account breakdown into a temporary G/L Entry table.
    procedure GetKPIEntriesBreakdown(KPICode: Enum "Dashboard Kpi Code"; StartDate: Date; EndDate: Date; var TempGLEntry: Record "G/L Entry" temporary)
    var
        DashboardSetup: Record "Dashboard KPI Setup";
        GLEntry: Record "G/L Entry";
    begin
        TempGLEntry.Reset();
        TempGLEntry.DeleteAll();

        if not DashboardSetup.Get(KPICode) then
            exit;

        if DashboardSetup."G/L Account Filter" = '' then
            exit;

        GLEntry.SetFilter("G/L Account No.", DashboardSetup."G/L Account Filter");
        ApplyDateFilter(GLEntry, StartDate, EndDate);

        if GLEntry.FindSet() then
            repeat
                TempGLEntry.SetRange("G/L Account No.", GLEntry."G/L Account No.");
                if TempGLEntry.FindFirst() then begin
                    TempGLEntry.Amount += GLEntry.Amount;
                    TempGLEntry."Debit Amount" += GLEntry."Debit Amount";
                    TempGLEntry."Credit Amount" += GLEntry."Credit Amount";
                    TempGLEntry.Modify();
                end else begin
                    TempGLEntry.Init();
                    TempGLEntry."Entry No." := GLEntry."Entry No.";
                    TempGLEntry."G/L Account No." := GLEntry."G/L Account No.";
                    TempGLEntry."Posting Date" := GLEntry."Posting Date";
                    TempGLEntry.Amount := GLEntry.Amount;
                    TempGLEntry."Debit Amount" := GLEntry."Debit Amount";
                    TempGLEntry."Credit Amount" := GLEntry."Credit Amount";
                    TempGLEntry.Insert();
                end;
            until GLEntry.Next() = 0;

        TempGLEntry.Reset();
    end;

    // Shared date filter helper to avoid repetition across all procedures.
    local procedure ApplyDateFilter(var GLEntry: Record "G/L Entry"; StartDate: Date; EndDate: Date)
    begin
        if (StartDate <> 0D) and (EndDate <> 0D) then
            GLEntry.SetRange("Posting Date", StartDate, EndDate)
        else
            if StartDate <> 0D then
                GLEntry.SetFilter("Posting Date", '%1..', StartDate)
            else
                if EndDate <> 0D then
                    GLEntry.SetFilter("Posting Date", '..%1', EndDate);
    end;
}

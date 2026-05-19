codeunit 50104 "Dashboard Calc. Mgt."
{
    // Routes to G/L Entry or G/L Account based on KPI Setup flags
    procedure GetKPITotal(KPICode: Enum "Dashboard Kpi Code"; StartDate: Date; EndDate: Date): Decimal
    var
        DashboardSetup: Record "Dashboard KPI Setup";
    begin
        if not DashboardSetup.Get(KPICode) then
            exit(0);

        if DashboardSetup."G/L Account Filter" = '' then
            exit(0);

        if DashboardSetup."Load from G/L Entries" then
            exit(GetKPITotalFromEntries(DashboardSetup, StartDate, EndDate))
        else
            exit(GetKPITotalFromAccounts(DashboardSetup, StartDate, EndDate));
    end;

    // Fetches totals from G/L Entry table using Debit Amount (LCY) or Credit Amount (LCY)
    local procedure GetKPITotalFromEntries(DashboardSetup: Record "Dashboard KPI Setup"; StartDate: Date; EndDate: Date): Decimal
    var
        GLEntry: Record "G/L Entry";
        TotalAmount: Decimal;
    begin
        TotalAmount := 0;

        GLEntry.SetFilter("G/L Account No.", DashboardSetup."G/L Account Filter");

        // Apply Date Filter
        if (StartDate <> 0D) and (EndDate <> 0D) then
            GLEntry.SetRange("Posting Date", StartDate, EndDate)
        else
            if StartDate <> 0D then
                GLEntry.SetFilter("Posting Date", '%1..', StartDate)
            else
                if EndDate <> 0D then
                    GLEntry.SetFilter("Posting Date", '..%1', EndDate);

        if GLEntry.FindSet() then
            repeat
                if DashboardSetup."Show Debit" then
                    TotalAmount += GLEntry."Debit Amount"
                else
                    if DashboardSetup."Show Credit" then
                        TotalAmount += GLEntry."Credit Amount"
                    else
                        // Neither flag: fall back to net (Debit - Credit)
                        TotalAmount += GLEntry."Debit Amount" - GLEntry."Credit Amount"
            until GLEntry.Next() = 0;

        exit(TotalAmount);
    end;

    // Fetches totals from G/L Account using CalcFields (Debit Amount / Credit Amount / Net Change)
    local procedure GetKPITotalFromAccounts(DashboardSetup: Record "Dashboard KPI Setup"; StartDate: Date; EndDate: Date): Decimal
    var
        GLAccount: Record "G/L Account";
        TotalAmount: Decimal;
    begin
        TotalAmount := 0;

        GLAccount.SetFilter("No.", DashboardSetup."G/L Account Filter");
        GLAccount.SetRange("Account Type", GLAccount."Account Type"::Posting);

        // Apply Date Filter
        if (StartDate <> 0D) and (EndDate <> 0D) then
            GLAccount.SetRange("Date Filter", StartDate, EndDate)
        else
            if StartDate <> 0D then
                GLAccount.SetFilter("Date Filter", '%1..', StartDate)
            else
                if EndDate <> 0D then
                    GLAccount.SetFilter("Date Filter", '..%1', EndDate);

        if GLAccount.FindSet() then
            repeat
                if DashboardSetup."Show Debit" then begin
                    GLAccount.CalcFields("Debit Amount");
                    TotalAmount += GLAccount."Debit Amount";
                end else
                    if DashboardSetup."Show Credit" then begin
                        GLAccount.CalcFields("Credit Amount");
                        TotalAmount += GLAccount."Credit Amount";
                    end else begin
                        // Neither flag: fall back to Net Change
                        GLAccount.CalcFields("Net Change");
                        TotalAmount += GLAccount."Net Change";
                    end;
            until GLAccount.Next() = 0;

        exit(TotalAmount);
    end;

    procedure CheckIsWidgetVisible(Identity: Enum "Dashboard Widget Identity"): Boolean
    var
        VisibleSetup: Record "DashboardVisible KPI Setup";
    begin
        if VisibleSetup.Get(Identity) then
            exit(VisibleSetup."Show on Dashboard");

        exit(true);
    end;

    // Calculation for "Project Actual Price to Budget Price"
    procedure GetProjectPricePerformance(JobNo: Code[20]; var ActualPrice: Decimal; var BudgetPrice: Decimal)
    var
        Job: Record Job;
    begin
        ActualPrice := 0;
        BudgetPrice := 0;
        if Job.Get(JobNo) then begin
            Job.CalcFields("Calc. Recog. Sales G/L Amount", "Total WIP Sales G/L Amount");
            ActualPrice := Job."Calc. Recog. Sales G/L Amount";
            BudgetPrice := Job."Total WIP Sales G/L Amount";
        end;
    end;

    procedure GetProjectStatistics(JobNo: Code[20]; var ActualCost: Decimal; var BudgetCost: Decimal; var ActualPrice: Decimal; var BudgetPrice: Decimal; var PriceVariance: Decimal; var ProfitMargin: Decimal; var CostVariance: Decimal)
    var
        Job: Record Job;
        JobCalcStats: Codeunit "Job Calculate Statistics";
        CL: array[16] of Decimal;
        PL: array[16] of Decimal;
    begin
        if Job.Get(JobNo) then begin
            JobCalcStats.JobCalculateCommonFilters(Job);
            JobCalcStats.CalculateAmounts();

            JobCalcStats.GetLCYCostAmounts(CL);
            BudgetCost := CL[4];
            ActualCost := CL[8];
            CostVariance := BudgetCost - ActualCost;

            JobCalcStats.GetLCYPriceAmounts(PL);
            BudgetPrice := PL[12];
            ActualPrice := PL[16];
            PriceVariance := BudgetPrice - ActualPrice;

            ProfitMargin := ActualPrice - ActualCost;
        end;
    end;
}
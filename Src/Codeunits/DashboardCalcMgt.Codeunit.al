codeunit 50104 "Dashboard Calc. Mgt."
{
    // Calculates the total Net Change for a given KPI Setup over a specific date range.
    procedure GetKPITotal(KPICode: Enum "Dashboard Kpi Code"; StartDate: Date; EndDate: Date): Decimal
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
            CostVariance := BudgetCost - ActualCost; // Calculate Variance

            JobCalcStats.GetLCYPriceAmounts(PL);
            BudgetPrice := PL[12];
            ActualPrice := PL[16];
            PriceVariance := BudgetPrice - ActualPrice; // Calculate Variance

            ProfitMargin := ActualPrice - ActualCost; // Calculate Margin
        end;
    end;
}

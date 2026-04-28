page 50128 "Custom Project Cost Chart"
{
    ApplicationArea = All;
    PageType = CardPart;
    Caption = 'Project Actual Cost to Budget Cost';

    layout
    {
        area(Content)
        {
            usercontrol(CostChart; "Custom Cash Flow Chart")
            {
                ApplicationArea = All;
                Visible = IsVisible;
                trigger ControlReady()
                begin
                    LoadChartData();
                end;
            }
        }
    }
    var
        CalcMgt: Codeunit "Dashboard Calc. Mgt.";
        IsVisible: Boolean;

    trigger OnOpenPage()
    begin
        IsVisible := CalcMgt.CheckIsWidgetVisible(Enum::"Dashboard Widget Identity"::"Cost Performance");
    end;

    local procedure LoadChartData()
    var
        MyJob: Record "My Job";
        CalcMgt: Codeunit "Dashboard Calc. Mgt.";
        Labels: JsonArray;
        ActualCostData: JsonArray;
        BudgetCostData: JsonArray;
        CostData: JsonArray;
        ActualCost: Decimal;
        BudgetCost: Decimal;
        ActualPrice: Decimal;
        BudgetPrice: Decimal;
        Var_Cost: Decimal;
        Dummy1: Decimal;
        Dummy2: Decimal;
    begin
        MyJob.SetRange("User ID", UserId());
        if MyJob.FindSet() then
            repeat
                CalcMgt.GetProjectStatistics(MyJob."Job No.", ActualCost, BudgetCost, ActualPrice, BudgetPrice, Dummy1, Dummy2, Var_Cost);

                Labels.Add(MyJob."Job No.");
                ActualCostData.Add(ActualCost);
                BudgetCostData.Add(BudgetCost);
                CostData.Add(Var_Cost);
            until MyJob.Next() = 0;

        CurrPage.CostChart.RenderChart3('Actual Cost', 'Budget Cost', 'Cost Variance', Labels, ActualCostData, BudgetCostData, CostData);
    end;
}

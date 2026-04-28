page 50130 "Custom Project Profit Chart"
{
    ApplicationArea = All;
    PageType = CardPart;
    Caption = 'Project Profitability';

    layout
    {
        area(Content)
        {
            usercontrol(ProfitChart; "Custom Cash Flow Chart")
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
        IsVisible := CalcMgt.CheckIsWidgetVisible(Enum::"Dashboard Widget Identity"::Profitability);
    end;

    local procedure LoadChartData()
    var
        MyJob: Record "My Job";
        CalcMgt: Codeunit "Dashboard Calc. Mgt.";
        Labels: JsonArray;
        RevData: JsonArray;
        CostData: JsonArray;
        MarginData: JsonArray;
        ActualCost: Decimal;
        BudgetCost: Decimal;
        ActualPrice: Decimal;
        BudgetPrice: Decimal;
        Mar_Profit: Decimal;
        Dummy1: Decimal;
        Dummy2: Decimal;
    begin
        MyJob.SetRange("User ID", UserId());
        if MyJob.FindSet() then
            repeat
                CalcMgt.GetProjectStatistics(MyJob."Job No.", ActualCost, BudgetCost, ActualPrice, BudgetPrice, Dummy1, Mar_Profit, Dummy2);

                Labels.Add(MyJob."Job No.");
                RevData.Add(ActualPrice);
                CostData.Add(ActualCost);
                MarginData.Add(Mar_Profit);
            until MyJob.Next() = 0;

        CurrPage.ProfitChart.RenderChart3('Total Revenue', 'Total Usage Cost', 'Profit Margin', Labels, RevData, CostData, MarginData);
    end;
}

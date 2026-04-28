page 50129 "Custom Project Price Chart"
{
    ApplicationArea = All;
    PageType = CardPart;
    Caption = 'Project Actual Price to Budget Price';

    layout
    {
        area(Content)
        {
            usercontrol(PriceChart; "Custom Cash Flow Chart")
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
        IsVisible := CalcMgt.CheckIsWidgetVisible(Enum::"Dashboard Widget Identity"::"Price Performance");
    end;

    local procedure LoadChartData()
    var
        MyJob: Record "My Job";
        CalcMgt: Codeunit "Dashboard Calc. Mgt.";
        Labels: JsonArray;
        ActualData: JsonArray;
        BudgetData: JsonArray;
        VarianceData: JsonArray;
        A_Price: Decimal;
        B_Price: Decimal;
        Var_Price: Decimal;
        Dummy1: Decimal;
        Dummy2: Decimal;
        Dummy3: Decimal;
        Dummy4: Decimal;
    begin
        if MyJob.FindSet() then
            repeat
                CalcMgt.GetProjectStatistics(MyJob."Job No.", Dummy1, Dummy2, A_Price, B_Price, Var_Price, Dummy3, Dummy4);

                Labels.Add(MyJob."Job No.");
                ActualData.Add(A_Price);
                BudgetData.Add(B_Price);
                VarianceData.Add(Var_Price); // Add the 3rd value
            until MyJob.Next() = 0;

        CurrPage.PriceChart.RenderChart3('Actual Price', 'Budget Price', 'Price Variance', Labels, ActualData, BudgetData, VarianceData);
    end;
}

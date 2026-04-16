page 50115 "Dashboard Cash Flow Chart"
{
    PageType = CardPart;
    Caption = 'Cash in and out • Last 6 months';
    Editable = false;

    layout
    {
        area(Content)
        {
            field(TotalCashIn; TotalCashInText)
            {
                ApplicationArea = All;
                Caption = 'Cash in';
                Style = Strong;
                ToolTip = 'Specifies the total cash received over the last 6 months.';
            }
            field(TotalCashOut; TotalCashOutText)
            {
                ApplicationArea = All;
                Caption = 'Cash out';
                Style = Strong;
                ToolTip = 'Specifies the total cash paid out over the last 6 months.';
            }
            field(Difference; DifferenceText)
            {
                ApplicationArea = All;
                Caption = 'Difference';
                Style = Favorable;
                StyleExpr = NetDifference > 0;
                ToolTip = 'Specifies the net difference between cash in and cash out.';
            }

            usercontrol(CustomChart; "Custom Cash Flow Chart")
            {
                ApplicationArea = All;

                trigger ControlReady()
                begin
                    GenerateChart();
                end;
            }
        }
    }

    var
        CalcMgt: Codeunit "Dashboard Calc. Mgt.";
        TotalCashInText: Text;
        TotalCashOutText: Text;
        DifferenceText: Text;
        NetDifference: Decimal;

    local procedure GenerateChart()
    var
        i: Integer;
        MonthStart: Date;
        MonthEnd: Date;
        CashInAmt: Decimal;
        CashOutAmt: Decimal;
        AggCashIn: Decimal;
        AggCashOut: Decimal;
        MonthName: Text;
        DateFormulaLbl: Label '<-%1M>-<CM>', Locked = true;

        LabelsArray: JsonArray;
        CashInArray: JsonArray;
        CashOutArray: JsonArray;
    begin
        AggCashIn := 0;
        AggCashOut := 0;

        for i := 5 downto 0 do begin
            MonthStart := CalcDate(StrSubstNo(DateFormulaLbl, i), WorkDate());
            MonthEnd := CalcDate('<CM>', MonthStart);

            MonthName := Format(MonthStart, 0, '<Month Text,3>');
            LabelsArray.Add(MonthName);

            CashInAmt := -CalcMgt.GetKPITotal('CASH_IN', MonthStart, MonthEnd);
            CashOutAmt := CalcMgt.GetKPITotal('CASH_OUT', MonthStart, MonthEnd);

            CashInArray.Add(Abs(CashInAmt));
            CashOutArray.Add(Abs(CashOutAmt));

            AggCashIn += CashInAmt;
            AggCashOut += CashOutAmt;
        end;

        NetDifference := AggCashIn - AggCashOut;
        TotalCashInText := Format(AggCashIn, 0, '<Precision,2:2><Standard Format,0>');
        TotalCashOutText := Format(AggCashOut, 0, '<Precision,2:2><Standard Format,0>');
        DifferenceText := Format(NetDifference, 0, '<Precision,2:2><Standard Format,0>');

        CurrPage.CustomChart.RenderChart('Cash in', 'Cash out', LabelsArray, CashInArray, CashOutArray);
    end;
}
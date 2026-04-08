page 50118 "Dashboard Net Profit Chart"
{
    PageType = CardPart;
    Caption = 'Net profit or loss • Year to date';
    Editable = false;

    layout
    {
        area(Content)
        {
            group(HeaderNumbers)
            {
                ShowCaption = false;

                field(TotalNetProfit; TotalNetProfitText)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    Style = Strong;
                    ToolTip = 'Total calculated net profit for the year to date.';
                }
                field(DateRange; DateRangeText)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    Style = Subordinate;
                }
                field(Comparison; ComparisonText)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    StyleExpr = ComparisonStyle;
                }
            }

            usercontrol(NetProfitChart; "Custom Cash Flow Chart")
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
        // TempChartBuffer: Record "Business Chart Buffer" temporary;
        CalcMgt: Codeunit "Dashboard Calc. Mgt.";
        TotalNetProfitText: Text;
        DateRangeText: Text;
        ComparisonText: Text;
        ComparisonStyle: Text;

    local procedure GenerateChart()
    var
        StartOfYear, EndOfMonth : Date;
        PrevStartOfYear, PrevEndOfMonth : Date;
        IncomeTotal, ExpenseTotal, NetProfit : Decimal;
        PrevIncomeTotal, PrevExpenseTotal, PrevNetProfit : Decimal;
        PctChange: Decimal;
        ChangeDirection, ArrowStr : Text;
        LabelsArray: JsonArray;
        IncomeArray: JsonArray;
        ExpenseArray: JsonArray;
    begin
        StartOfYear := CalcDate('<-CY>', WorkDate());
        EndOfMonth := CalcDate('<CM>', WorkDate());

        PrevStartOfYear := CalcDate('<-1Y>', StartOfYear);
        PrevEndOfMonth := CalcDate('<-1Y>', EndOfMonth);

        DateRangeText := Format(StartOfYear, 0, '<Month Text,3> <Day>') + ' – ' + Format(EndOfMonth, 0, '<Month Text,3> <Day>, <Year4>');

        // Pull Current Data
        IncomeTotal := -CalcMgt.GetKPITotal('CASH_IN', StartOfYear, EndOfMonth);
        ExpenseTotal := CalcMgt.GetKPITotal('CASH_OUT', StartOfYear, EndOfMonth);
        NetProfit := IncomeTotal - ExpenseTotal;

        // Pull Previous Year Data for Comparison
        PrevIncomeTotal := -CalcMgt.GetKPITotal('CASH_IN', PrevStartOfYear, PrevEndOfMonth);
        PrevExpenseTotal := CalcMgt.GetKPITotal('CASH_OUT', PrevStartOfYear, PrevEndOfMonth);
        PrevNetProfit := PrevIncomeTotal - PrevExpenseTotal;

        // Calculate Percentage Difference Logic
        if PrevNetProfit <> 0 then
            PctChange := Round(((NetProfit - PrevNetProfit) / Abs(PrevNetProfit)) * 100, 1)
        else
            PctChange := 0;

        if PctChange >= 0 then begin
            ChangeDirection := 'Up ';
            ArrowStr := ' ↑';
            ComparisonStyle := 'Favorable';
        end else begin
            ChangeDirection := 'Down ';
            ArrowStr := ' ↓';
            ComparisonStyle := 'Unfavorable';
            PctChange := Abs(PctChange);
        end;

        if PrevNetProfit = 0 then
            ComparisonText := 'No data for previous year'
        else
            ComparisonText := ChangeDirection + Format(PctChange) + '% from ' +
                Format(PrevStartOfYear, 0, '<Month Text,3> <Day>') + ' – ' +
                Format(PrevEndOfMonth, 0, '<Month Text,3> <Day>, <Year4>') + ArrowStr;

        TotalNetProfitText := Format(NetProfit, 0, '<Precision,2:2><Standard Format,0>');

        // ── REPLACED: TempChartBuffer → Custom ControlAddIn ──────────────────────
        LabelsArray.Add('Income');
        LabelsArray.Add('Expenses');

        IncomeArray.Add(Abs(IncomeTotal));
        IncomeArray.Add(0);                   // Income bar only on first column

        ExpenseArray.Add(0);                  // Expense bar only on second column
        ExpenseArray.Add(Abs(ExpenseTotal));

        CurrPage.NetProfitChart.RenderChart('Income', 'Expenses', LabelsArray, IncomeArray, ExpenseArray);

    end;
}

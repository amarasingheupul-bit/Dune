page 50116 "Dashboard Invoices Owed"
{
    PageType = CardPart;
    Caption = 'Invoices owed to you';
    Editable = false;

    layout
    {
        area(Content)
        {
            grid(HeaderGrid)
            {
                ShowCaption = false;
                GridLayout = Columns;

                group(LeftHeader)
                {
                    ShowCaption = false;
                    field(TotalAmount; TotalAmtText)
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        Style = Strong;
                    }
                    field(AwaitingPayment; AwaitingPaymentText)
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        Style = Subordinate;
                    }
                }

                group(RightHeader)
                {
                    ShowCaption = false;
                    field(OverdueAmount; OverdueAmtText)
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        Style = Strong;
                    }
                    field(OverdueCount; OverdueCountText)
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        Style = Subordinate;
                        DrillDown = true;
                    }
                }
            }

            usercontrol(InvoiceChart; "Custom Cash Flow Chart")
            {
                ApplicationArea = All;
                trigger ControlReady()
                begin
                    GenerateChart();
                end;
            }

            grid(FooterDataGrid)
            {
                ShowCaption = false;
                GridLayout = Columns;

                group(FooterLabels)
                {
                    ShowCaption = false;
                    field(DraftsCount; DraftsCountText)
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        DrillDown = true;
                        Style = StrongAccent;
                    }
                    field(ApprCount; AwaitingApprCountText)
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        DrillDown = true;
                        Style = StrongAccent;
                    }
                }

                group(FooterAmounts)
                {
                    ShowCaption = false;
                    field(DraftsAmt; DraftsAmtText)
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                    }
                    field(ApprAmt; AwaitingApprAmtText)
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                    }
                }
            }

            group(BottomButtons)
            {
                ShowCaption = false;
                grid(ButtonGrid)
                {
                    ShowCaption = false;
                    group(Btn1)
                    {
                        ShowCaption = false;
                        field(AddInvoice; 'New invoice')
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            DrillDown = true;
                            Editable = false;
                            trigger OnDrillDown()
                            begin
                                Page.Run(Page::"Sales Invoice");
                            end;
                        }
                    }
                    group(Btn2)
                    {
                        ShowCaption = false;
                        field(ViewAll; 'View all invoices')
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            DrillDown = true;
                            Editable = false;
                            trigger OnDrillDown()
                            begin
                                Page.Run(Page::"Sales Invoice List");
                            end;
                        }
                    }
                }
            }
        }
    }

    var
        // TempChartBuffer: Record "Business Chart Buffer" temporary;
        TotalAmtText: Text;
        AwaitingPaymentText: Text;
        OverdueAmtText, OverdueCountText : Text;
        DraftsCountText, AwaitingApprCountText : Text;
        DraftsAmtText, AwaitingApprAmtText : Text;

    local procedure GenerateChart()
    var
        SalesHeader: Record "Sales Header";
        CustLedger: Record "Cust. Ledger Entry";
        TotalRemaining: Decimal;
        OverdueRemaining: Decimal;
        OverdueCount: Integer;
        DraftAmt: Decimal;
        LabelsArray: JsonArray;
        DataArray: JsonArray;
    begin
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Invoice);
        SalesHeader.SetRange(Status, SalesHeader.Status::Open);

        DraftAmt := 0;
        if SalesHeader.FindSet() then begin
            DraftsCountText := Format(SalesHeader.Count) + ' drafts';
            repeat
                SalesHeader.CalcFields("Amount Including VAT");
                DraftAmt += SalesHeader."Amount Including VAT";
            until SalesHeader.Next() = 0;
            DraftsAmtText := Format(DraftAmt, 0, '<Precision,2:2><Standard Format,0>');
        end else begin
            DraftsCountText := '0 drafts';
            DraftsAmtText := '0.00';
        end;

        CustLedger.SetRange(Open, true);
        if CustLedger.FindSet() then
            repeat
                CustLedger.CalcFields("Remaining Amount");
                if CustLedger."Due Date" < WorkDate() then begin
                    OverdueRemaining += CustLedger."Remaining Amount";
                    OverdueCount += 1;
                end;
            until CustLedger.Next() = 0;

        OverdueAmtText := Format(Abs(OverdueRemaining), 0, '<Precision,2:2><Standard Format,0>');
        OverdueCountText := Format(OverdueCount) + ' overdue';

        AwaitingApprCountText := '0 awaiting approval';
        AwaitingApprAmtText := '0.00';

        TotalRemaining := 0;
        OverdueRemaining := 0;
        OverdueCount := 0;

        CustLedger.SetRange(Open, true);
        if CustLedger.FindSet() then
            repeat
                CustLedger.CalcFields("Remaining Amount");
                TotalRemaining += CustLedger."Remaining Amount";
                if CustLedger."Due Date" < WorkDate() then begin
                    OverdueRemaining += CustLedger."Remaining Amount";
                    OverdueCount += 1;
                end;
            until CustLedger.Next() = 0;

        TotalAmtText := Format(Abs(TotalRemaining), 0, '<Precision,2:2><Standard Format,0>');
        AwaitingPaymentText := Format(CustLedger.Count) + ' awaiting payment';
        OverdueAmtText := Format(Abs(OverdueRemaining), 0, '<Precision,2:2><Standard Format,0>');
        OverdueCountText := Format(OverdueCount) + ' of ' + Format(CustLedger.Count) + ' overdue';


        LabelsArray.Add('Older');
        LabelsArray.Add('This week');
        LabelsArray.Add('Future');

        DataArray.Add(GetInvoiceAmount(-1000, -8));
        DataArray.Add(GetInvoiceAmount(-7, 0));
        DataArray.Add(GetInvoiceAmount(1, 1000));

        CurrPage.InvoiceChart.RenderSingleChart('Invoices', LabelsArray, DataArray, '#14b8a6');

    end;

    local procedure GetInvoiceAmount(StartDays: Integer; EndDays: Integer): Decimal
    var
        CustLedger: Record "Cust. Ledger Entry";
        Amt: Decimal;
        DateFilterLbl: Label '<%1D>', Locked = true;
    begin
        Amt := 0;
        CustLedger.SetRange(Open, true);

        CustLedger.SetFilter("Due Date", '%1..%2',
            CalcDate(StrSubstNo(DateFilterLbl, StartDays), WorkDate()),
            CalcDate(StrSubstNo(DateFilterLbl, EndDays), WorkDate()));

        if CustLedger.FindSet() then
            repeat
                CustLedger.CalcFields("Remaining Amount");
                Amt += CustLedger."Remaining Amount";
            until CustLedger.Next() = 0;
        exit(Amt);
    end;
}

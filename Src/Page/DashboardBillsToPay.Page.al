page 50114 "Dashboard Bills To Pay"
{
    PageType = CardPart;
    Caption = 'Bills to pay';
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
                    }
                }
            }

            usercontrol(BillsChart; "Custom Cash Flow Chart")
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
                        Style = StrongAccent;
                        DrillDown = true;
                    }
                    field(ApprCount; AwaitingApprCountText)
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        Style = StrongAccent;
                        DrillDown = true;
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

            grid(ButtonGrid)
            {
                ShowCaption = false;
                GridLayout = Columns;
                group(Btn1)
                {
                    ShowCaption = false;
                    field(AddBill; 'Add bill')
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        DrillDown = true;
                        trigger OnDrillDown()
                        begin
                            Page.Run(Page::"Purchase Invoice");
                        end;
                    }
                }
                group(Btn2)
                {
                    ShowCaption = false;
                    field(ViewAll; 'View all bills')
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        DrillDown = true;
                        trigger OnDrillDown()
                        begin
                            Page.Run(Page::"Purchase Invoices");
                        end;
                    }
                }
            }
        }
    }

    var
        // TempChartBuffer: Record "Business Chart Buffer" temporary;
        TotalAmtText: Text;
        AwaitingPaymentText: Text;
        OverdueAmtText: Text;
        OverdueCountText: Text;
        DraftsCountText, AwaitingApprCountText : Text;
        DraftsAmtText, AwaitingApprAmtText : Text;

    local procedure GenerateChart()
    var
        PurchHeader: Record "Purchase Header";
        VendLedger: Record "Vendor Ledger Entry";
        TotalRemaining: Decimal;
        OverdueRemaining: Decimal;
        OverdueCount: Integer;
        DraftAmt: Decimal;
        LabelsArray: JsonArray;
        DataArray: JsonArray;
    begin
        PurchHeader.SetRange("Document Type", PurchHeader."Document Type"::Invoice);
        PurchHeader.SetRange(Status, PurchHeader.Status::Open);

        DraftAmt := 0;
        if PurchHeader.FindSet() then begin
            DraftsCountText := Format(PurchHeader.Count) + ' drafts';
            repeat
                PurchHeader.CalcFields("Amount Including VAT");
                DraftAmt += PurchHeader."Amount Including VAT";
            until PurchHeader.Next() = 0;
            DraftsAmtText := Format(DraftAmt, 0, '<Precision,2:2><Standard Format,0>');
        end else begin
            DraftsCountText := '0 drafts';
            DraftsAmtText := '0.00';
        end;

        AwaitingApprCountText := '0 awaiting approval';
        AwaitingApprAmtText := '0.00';

        VendLedger.SetRange(Open, true);
        if VendLedger.FindSet() then
            repeat
                VendLedger.CalcFields("Remaining Amount");
                TotalRemaining += VendLedger."Remaining Amount";
                if VendLedger."Due Date" < WorkDate() then begin
                    OverdueRemaining += VendLedger."Remaining Amount";
                    OverdueCount += 1;
                end;
            until VendLedger.Next() = 0;

        TotalAmtText := Format(Abs(TotalRemaining), 0, '<Precision,2:2><Standard Format,0>');
        AwaitingPaymentText := Format(VendLedger.Count) + ' awaiting payment';
        OverdueAmtText := Format(Abs(OverdueRemaining), 0, '<Precision,2:2><Standard Format,0>');
        OverdueCountText := Format(OverdueCount) + ' of ' + Format(VendLedger.Count) + ' overdue';


        LabelsArray.Add('Older');
        LabelsArray.Add('This week');
        LabelsArray.Add('Mar 15-21');
        LabelsArray.Add('Mar 22-28');
        LabelsArray.Add('Future');

        DataArray.Add(GetBillAmount(-1000, -31));
        DataArray.Add(GetBillAmount(-7, 0));
        DataArray.Add(GetBillAmount(-21, -15));  // Mar 15-21 (real data, not placeholder)
        DataArray.Add(GetBillAmount(-28, -22));  // Mar 22-28 (real data, not hardcoded 45000)
        DataArray.Add(GetBillAmount(1, 1000));

        CurrPage.BillsChart.RenderSingleChart('Bills', LabelsArray, DataArray, '#e85d4a');

    end;

    local procedure GetBillAmount(StartDays: Integer; EndDays: Integer): Decimal
    var
        VendLedger: Record "Vendor Ledger Entry";
        Amt: Decimal;
        DateFilterLbl: Label '<%1D>', Locked = true;
    begin
        Amt := 0;
        VendLedger.SetRange(Open, true);

        // Build the date filter using the Label
        VendLedger.SetFilter("Due Date", '%1..%2',
            CalcDate(StrSubstNo(DateFilterLbl, StartDays), WorkDate()),
            CalcDate(StrSubstNo(DateFilterLbl, EndDays), WorkDate()));

        if VendLedger.FindSet() then
            repeat
                VendLedger.CalcFields("Remaining Amount");
                Amt += Abs(VendLedger."Remaining Amount");
            until VendLedger.Next() = 0;
        exit(Amt);
    end;
}
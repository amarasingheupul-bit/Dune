report 50113 "Sales Tax Summary"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    Caption = 'Sales Tax Summary';
    DefaultLayout = RDLC;
    RDLCLayout = 'Src/Report/Layouts/Sales Tax Summary.rdl';

    dataset
    {
        // ── Company Header ────────────────────────────────────────────────────
        dataitem(CompanyInfoDummy; Integer)
        {
            DataItemTableView = sorting(Number) where(Number = const(1));

            column(CompanyName; ComInfo.Name) { }
            column(CompanyLogo; ComInfo.Picture) { }
            column(CompanyRegNo; ComInfo."Registration No.") { }
            column(TaxBasis; TaxBasisTxt) { }
            column(TaxPeriodCovered; TaxPeriodCoveredTxt) { }
            column(PeriodFrom; Format(StartDate, 0, '<Day,2>/<Month,2>/<Year4>')) { }
            column(PeriodTo; Format(EndDate, 0, '<Day,2>/<Month,2>/<Year4>')) { }
            column(ReportTitle; ReportTitleLbl) { }
            column(PeriodHeader; PeriodHeaderTxt) { }

            // ── Section: Taxes by Tax Component ──────────────────────────────
            dataitem(VATEntry; "VAT Entry")
            {
                DataItemTableView = sorting(Type, "VAT Bus. Posting Group", "VAT Prod. Posting Group", "Posting Date");

                column(VATType; VATTypeTxt) { }
                column(VATDescription; VATDescription) { }
                column(VATRate; VATRate) { }
                column(NetAmount; NetAmount) { }
                column(TaxAmount; TaxAmount) { }
                column(IsGroupHeader; IsGroupHeader) { }
                column(IsTotal; IsTotal) { }
                column(TotalNetAmount; TotalNetAmount) { }
                column(TotalTaxAmount; TotalTaxAmount) { }
                column(GroupKey; GroupKey) { }

                // trigger OnPreDataItem()
                // begin
                //     SetRange("Posting Date", StartDate, EndDate);
                //     if StartDate = 0D then
                //         RemoveRange("Posting Date");
                // end;

                trigger OnAfterGetRecord()
                var
                    VATPostingSetup: Record "VAT Posting Setup";
                begin
                    // Build group key: Type + VAT Bus. PG + VAT Prod. PG
                    GroupKey := Format(Type) + '|' + "VAT Bus. Posting Group" + '|' + "VAT Prod. Posting Group";

                    VATTypeTxt := Format(Type);

                    Clear(VATDescription);
                    if VATPostingSetup.Get("VAT Bus. Posting Group", "VAT Prod. Posting Group") then begin
                        VATRate := VATPostingSetup."VAT %";
                        VATDescription := VATPostingSetup.Description;
                        if VATDescription = '' then
                            VATDescription := "VAT Bus. Posting Group" + ' (' + Format(VATPostingSetup."VAT %", 0, '<Precision,1:1><Standard Format,0>') + '%)';
                    end else begin
                        VATRate := 0;
                        VATDescription := "VAT Bus. Posting Group";
                    end;

                    NetAmount := Base;
                    TaxAmount := Amount;

                    IsGroupHeader := false;
                    IsTotal := false;
                    TotalNetAmount := 0;
                    TotalTaxAmount := 0;
                end;
            }
        }
    }

    // ── Request Page ──────────────────────────────────────────────────────────
    requestpage
    {
        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';

                    field(StartDateField; StartDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Start Date';
                        ToolTip = 'Specifies the first date of the reporting period.';
                    }
                    field(EndDateField; EndDate)
                    {
                        ApplicationArea = All;
                        Caption = 'End Date';
                        ToolTip = 'Specifies the last date of the reporting period.';
                    }
                    field(TaxBasisField; TaxBasisTxt)
                    {
                        ApplicationArea = All;
                        Caption = 'Tax Basis';
                        ToolTip = 'Specifies the tax basis (e.g. Accrual Basis, Cash Basis).';
                    }
                    field(TaxPeriodField; TaxPeriodCoveredTxt)
                    {
                        ApplicationArea = All;
                        Caption = 'Tax Period Covered';
                        ToolTip = 'Specifies the tax period description (e.g. 3 Monthly).';
                    }
                }
            }
        }
    }

    trigger OnPreReport()
    begin
        ComInfo.Get();

        // Build period header string
        PeriodHeaderTxt := 'For the period ' +
            Format(StartDate, 0, '<Day,2> <Month Text> <Year4>') +
            ' to ' +
            Format(EndDate, 0, '<Day,2> <Month Text> <Year4>');
        ComInfo.Get();
        ComInfo.CalcFields(Picture);
    end;

    var
        ComInfo: Record "Company Information";
        StartDate: Date;
        EndDate: Date;
        TaxBasisTxt: Text[50];
        TaxPeriodCoveredTxt: Text[50];
        PeriodHeaderTxt: Text[200];
        VATTypeTxt: Text[30];
        VATDescription: Text[100];
        VATRate: Decimal;
        NetAmount: Decimal;
        TaxAmount: Decimal;
        TotalNetAmount: Decimal;
        TotalTaxAmount: Decimal;
        IsGroupHeader: Boolean;
        IsTotal: Boolean;
        GroupKey: Text[100];
        ReportTitleLbl: Label 'Sales Tax Summary';
}

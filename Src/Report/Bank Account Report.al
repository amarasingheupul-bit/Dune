report 50115 "Bank Acc Report"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = LayoutName;
    Caption = 'FAB - EUR Transactions';

    dataset
    {
        dataitem("Bank Account Ledger Entry"; "Bank Account Ledger Entry")
        {
            column(Posting_Date; "Posting Date") { }
            column(Document_Type; "Document Type") { }
            column(Description; Description) { }
            column(Currency_Code; "Currency Code") { }
            column(Debit_Amount__LCY_; "Debit Amount (LCY)") { }
            column(Credit_Amount__LCY_; "Credit Amount (LCY)") { }
            column(Debit_Amount; "Debit Amount") { }
            column(Credit_Amount; "Credit Amount") { }
            column(RunningBalance; GetBankAccBalance("Bank Account Ledger Entry")) { }
            column(CompanyPicture; this.CompanyInformation.Picture) { }
            column(CompanyInfReportFooter; this.CompanyInformation."Report Footer") { }
            column(CompanyName; this.CompanyInformation.Name) { }
            column(CompanyAddress; this.CompanyInformation.Address) { }
            column(CompanyAddress2; this.CompanyInformation."Address 2") { }
            column(CompanyCity; this.CompanyInformation.City) { }
            column(CompanyCounty; this.CompanyInformation.County) { }
            column(CompanyPhoneNo; this.CompanyInformation."Phone No.") { }
            column(CompanyFaxNo; this.CompanyInformation."Fax No.") { }
            column(CompanyEmail; this.CompanyInformation."E-Mail") { }
            column(CompanyVatRegistration; this.CompanyInformation."VAT Registration No.") { }

            trigger OnPreDataItem()
            begin
                if PostingDateFilter <> '' then
                    SetFilter("Posting Date", PostingDateFilter);
                if DocumentNoFilter <> '' then
                    SetFilter("Document No.", DocumentNoFilter);
            end;
        }
    }

    requestpage
    {
        AboutTitle = 'Teaching tip title';
        AboutText = 'Teaching tip content';
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    Caption = 'Filters';

                    field(PostingDateFilter; PostingDateFilter)
                    {
                        ApplicationArea = All;
                        Caption = 'Posting Date';
                        ToolTip = 'Specifies the posting date filter for the bank account ledger entries.';
                    }
                    field(DocumentNoFilter; DocumentNoFilter)
                    {
                        ApplicationArea = All;
                        Caption = 'Document No.';
                        ToolTip = 'Specifies the document number filter for the bank account ledger entries.';
                    }
                }
            }
        }

        actions
        {
            area(processing)
            {
            }
        }
    }

    rendering
    {
        layout(LayoutName)
        {
            Type = RDLC;
            LayoutFile = 'Src\Report\Layouts\BankAccReport.rdl';
        }
    }

    trigger OnPreReport()
    begin
        CompanyInformation.Get();
        CompanyInformation.CalcFields(Picture);
        CompanyInformation.CalcFields("Report Footer");
    end;

    procedure GetBankAccBalance(var BankAccountLedgerEntry: Record "Bank Account Ledger Entry"): Decimal
    var
        RunningBalance: Decimal;
        RunningBalanceLCY: Decimal;
    begin
        CalcBankAccBalance(BankAccountLedgerEntry, RunningBalance, RunningBalanceLCY);
        exit(RunningBalance);
    end;

    local procedure CalcBankAccBalance(var BankAccountLedgerEntry: Record "Bank Account Ledger Entry"; var RunningBalance: Decimal; var RunningBalanceLCY: Decimal)
    var
        DateTotal: Decimal;
        DateTotalLCY: Decimal;
    begin
        if ClientTypeManagement.GetCurrentClientType() in [ClientType::OData, ClientType::ODataV4] then
            exit;
        if (PrevAccNo <> '') and (PrevAccNo <> BankAccountLedgerEntry."Bank Account No.") then begin
            Clear(DayTotals);
            Clear(DayTotalsLCY);
        end;
        PrevAccNo := BankAccountLedgerEntry."Bank Account No.";

        if EntryValues.Get(BankAccountLedgerEntry."Entry No.", RunningBalance) and EntryValuesLCY.Get(BankAccountLedgerEntry."Entry No.", RunningBalanceLCY) then
            exit;

        BankAccountLedgerEntry2.Reset();
        BankAccountLedgerEntry2.SetLoadFields("Entry No.", "Bank Account No.", "Posting Date", Amount, "Amount (LCY)");
        BankAccountLedgerEntry2.SetRange("Bank Account No.", BankAccountLedgerEntry."Bank Account No.");
        if not (DayTotals.Get(BankAccountLedgerEntry."Posting Date", DateTotal) and DayTotalsLCY.Get(BankAccountLedgerEntry."Posting Date", DateTotalLCY)) then begin
            BankAccountLedgerEntry2.SetFilter("Posting Date", '<=%1', BankAccountLedgerEntry."Posting Date");
            BankAccountLedgerEntry2.CalcSums(Amount, "Amount (LCY)");
            DateTotal := BankAccountLedgerEntry2.Amount;
            DateTotalLCY := BankAccountLedgerEntry2."Amount (LCY)";
            DayTotals.Add(BankAccountLedgerEntry."Posting Date", DateTotal);
            DayTotalsLCY.Add(BankAccountLedgerEntry."Posting Date", DateTotalLCY);
        end;
        RunningBalance := DateTotal;
        RunningBalanceLCY := DateTotalLCY;
        BankAccountLedgerEntry2.SetRange("Posting Date", BankAccountLedgerEntry."Posting Date");
        BankAccountLedgerEntry2.SetCurrentKey("Entry No.");
        BankAccountLedgerEntry2.Ascending(false);
        if BankAccountLedgerEntry2.FindSet() then
            repeat
                if BankAccountLedgerEntry2."Entry No." = BankAccountLedgerEntry."Entry No." then begin
                    RunningBalance := DateTotal;
                    RunningBalanceLCY := DateTotalLCY;
                end;
                if not EntryValues.ContainsKey(BankAccountLedgerEntry2."Entry No.") then
                    EntryValues.Add(BankAccountLedgerEntry2."Entry No.", DateTotal);
                if not EntryValuesLCY.ContainsKey(BankAccountLedgerEntry2."Entry No.") then
                    EntryValuesLCY.Add(BankAccountLedgerEntry2."Entry No.", DateTotalLCY);
                DateTotal -= BankAccountLedgerEntry2.Amount;
                DateTotalLCY -= BankAccountLedgerEntry2."Amount (LCY)";
            until BankAccountLedgerEntry2.Next() = 0;
    end;

    var
        CompanyInformation: Record "Company Information";
        BankAccountLedgerEntry2: Record "Bank Account Ledger Entry";
        ClientTypeManagement: Codeunit System.Environment."Client Type Management";
        DayTotals: Dictionary of [Date, Decimal];
        DayTotalsLCY: Dictionary of [Date, Decimal];
        EntryValues: Dictionary of [Integer, Decimal];
        EntryValuesLCY: Dictionary of [Integer, Decimal];
        PrevAccNo: Code[20];
        PostingDateFilter: Text[30];
        DocumentNoFilter: Text[20];
}
report 50111 "Receipt Voucher"
{
    Caption = 'Receipt Voucher';
    DefaultLayout = RDLC;
    RDLCLayout = 'Src\Report\Layouts\ReceiptVoucher.rdl';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;

    dataset
    {
        dataitem(GenJournalLine; "Gen. Journal Line")
        {
            DataItemTableView = sorting("Journal Template Name", "Journal Batch Name", "Line No.");
            RequestFilterFields = "Journal Template Name", "Journal Batch Name", "Document No.", "Posting Date";

            column(CompanyName; CompanyInfo.Name) { }
            column(CompanyAddress; CompanyInfo.Address + ' ' + CompanyInfo."Address 2") { }
            column(CompanyLogoBase64; CompanyInformation.Picture) { }

            column(ReceivedWithThanksFrom; ReceivedWithThanksFrom) { }
            column(RemittanceDetails; RemittanceDetails) { }
            column(CustomerName; CustomerName) { }
            column(CustomerTel; CustomerTel) { }
            column(CustomerFax; CustomerFax) { }
            column(TRN; TRN) { }
            column(PaymentMode; GenJournalLine."Payment Method Code") { }
            column(Amount; GenJournalLine.Amount) { }
            column(CurrencyCode; GenJournalLine."Currency Code") { }
            column(PostingDate; GenJournalLine."Posting Date") { }
            column(DocumentNo; GenJournalLine."Document No.") { }
            column(VoucherNo; GenJournalLine."Document No.") { }
            column(Description; GenJournalLine.Description) { }
            column(GLCode; GenJournalLine."Account No.") { }
            column(SLCode; GenJournalLine."Bal. Account No.") { }
            column(AccountDescription; AccountDescription) { }
            column(OnAccountAmount; GenJournalLine.Amount) { }
            column(CurrencySettledAmount; CurrencySettledAmount) { }
            column(TotalAmount; TotalAmount) { }
            column(AEDAmount; AEDAmount) { }
            column(AmountInWords; AmountInWords) { }
            column(PreparedBy; PreparedBy) { }
            column(CheckedBy; CheckedBy) { }
            column(AuthorizedBy; AuthorizedBy) { }
            column(PageNo; PageNo) { }

            trigger OnAfterGetRecord()
            begin
                PageNo += 1;
                GetCustomerDetails();
                GetAccountDescription();
                CalculateAmounts();
                GetAmountInWords();
            end;

            trigger OnPreDataItem()
            begin
                CompanyInfo.Get();
                CompanyInfo.CalcFields(Picture);
                PageNo := 0;
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(PreparedByField; PreparedBy)
                    {
                        ApplicationArea = All;
                        Caption = 'Prepared By';
                    }
                    field(CheckedByField; CheckedBy)
                    {
                        ApplicationArea = All;
                        Caption = 'Checked By';
                    }
                    field(AuthorizedByField; AuthorizedBy)
                    {
                        ApplicationArea = All;
                        Caption = 'Authorized By';
                    }
                }
            }
        }
    }

    var
        CompanyInfo: Record "Company Information";
        Customer: Record Customer;
        GLAccount: Record "G/L Account";
        CompanyLogoBase64: Text;
        ReceivedWithThanksFrom: Text[250];
        RemittanceDetails: Text[250];
        CustomerName: Text[100];
        CustomerTel: Text[30];
        CustomerFax: Text[30];
        TRN: Text[50];
        AccountDescription: Text[100];
        CurrencySettledAmount: Decimal;
        TotalAmount: Decimal;
        AEDAmount: Decimal;
        AmountInWords: Text[250];
        PreparedBy: Text[50];
        CheckedBy: Text[50];
        AuthorizedBy: Text[50];
        PageNo: Integer;

    local procedure GetCustomerDetails()
    begin
        ReceivedWithThanksFrom := '';
        CustomerName := '';
        CustomerTel := '';
        CustomerFax := '';
        TRN := '';
        RemittanceDetails := GenJournalLine.Description;

        case GenJournalLine."Account Type" of
            GenJournalLine."Account Type"::Customer:
                begin
                    if Customer.Get(GenJournalLine."Account No.") then begin
                        ReceivedWithThanksFrom := Customer.Name;
                        CustomerName := Customer.Name;
                        CustomerTel := Customer."Phone No.";
                        CustomerFax := Customer."Fax No.";
                        TRN := Customer."VAT Registration No.";
                    end;
                end;
            GenJournalLine."Account Type"::"G/L Account":
                begin
                    if GLAccount.Get(GenJournalLine."Account No.") then
                        ReceivedWithThanksFrom := GLAccount.Name;
                end;
            GenJournalLine."Account Type"::Vendor:
                begin
                    // Handle Vendor if needed
                end;
        end;
    end;

    local procedure GetAccountDescription()
    begin
        AccountDescription := '';
        case GenJournalLine."Account Type" of
            GenJournalLine."Account Type"::"G/L Account":
                if GLAccount.Get(GenJournalLine."Account No.") then
                    AccountDescription := GLAccount.Name;
            GenJournalLine."Account Type"::Customer:
                if Customer.Get(GenJournalLine."Account No.") then
                    AccountDescription := Customer.Name;
        end;
    end;

    local procedure CalculateAmounts()
    begin
        CurrencySettledAmount := GenJournalLine.Amount;
        TotalAmount := GenJournalLine.Amount;

        if GenJournalLine."Currency Code" <> '' then begin
            if GenJournalLine."Currency Factor" <> 0 then
                AEDAmount := GenJournalLine.Amount / GenJournalLine."Currency Factor"
            else
                AEDAmount := GenJournalLine.Amount;
        end else
            AEDAmount := GenJournalLine.Amount;
    end;

    local procedure GetAmountInWords()
    var
        TempGenJnlLine: Record "Gen. Journal Line" temporary;
        CurrencyText: Text[30];
        WholeAmount: Integer;
        FracAmount: Integer;
        Words: array[100] of Text[30];
        NoOfWords: Integer;
    begin
        if GenJournalLine."Currency Code" = '' then
            CurrencyText := 'AED'
        else
            CurrencyText := GenJournalLine."Currency Code";

        AmountInWords := ConvertAmountToWords(Abs(AEDAmount), CurrencyText);
        AmountInWords := UpperCase(AmountInWords);
    end;

    local procedure ConvertAmountToWords(Amount: Decimal; CurrencyCode: Text[30]): Text[250]
    var
        WholeAmt: Integer;
        FracAmt: Integer;
        ResultText: Text[250];
        FilsText: Text[50];
    begin
        WholeAmt := Round(Amount, 1, '<');
        FracAmt := Round((Amount - WholeAmt) * 100, 1, '<');

        ResultText := NumberToWords(WholeAmt);

        if FracAmt > 0 then begin
            FilsText := NumberToWords(FracAmt);
            ResultText := ResultText + ' AND ' + FilsText + ' FILS';
        end else
            ResultText := ResultText + ' AND FILS ZERO';

        ResultText := ResultText + ' ONLY';
        exit(ResultText);
    end;

    local procedure NumberToWords(Num: Integer): Text[250]
    var
        Ones: array[19] of Text[20];
        Tens: array[9] of Text[20];
        ResultText: Text[250];
    begin
        if Num = 0 then
            exit('ZERO');

        Ones[1] := 'ONE';
        Ones[2] := 'TWO';
        Ones[3] := 'THREE';
        Ones[4] := 'FOUR';
        Ones[5] := 'FIVE';
        Ones[6] := 'SIX';
        Ones[7] := 'SEVEN';
        Ones[8] := 'EIGHT';
        Ones[9] := 'NINE';
        Ones[10] := 'TEN';
        Ones[11] := 'ELEVEN';
        Ones[12] := 'TWELVE';
        Ones[13] := 'THIRTEEN';
        Ones[14] := 'FOURTEEN';
        Ones[15] := 'FIFTEEN';
        Ones[16] := 'SIXTEEN';
        Ones[17] := 'SEVENTEEN';
        Ones[18] := 'EIGHTEEN';
        Ones[19] := 'NINETEEN';

        Tens[2] := 'TWENTY';
        Tens[3] := 'THIRTY';
        Tens[4] := 'FORTY';
        Tens[5] := 'FIFTY';
        Tens[6] := 'SIXTY';
        Tens[7] := 'SEVENTY';
        Tens[8] := 'EIGHTY';
        Tens[9] := 'NINETY';

        ResultText := '';

        if Num >= 1000000 then begin
            ResultText := ResultText + NumberToWords(Num div 1000000) + ' MILLION ';
            Num := Num mod 1000000;
        end;

        if Num >= 1000 then begin
            ResultText := ResultText + NumberToWords(Num div 1000) + ' THOUSAND ';
            Num := Num mod 1000;
        end;

        if Num >= 100 then begin
            ResultText := ResultText + Ones[Num div 100] + ' HUNDRED ';
            Num := Num mod 100;
        end;

        if Num >= 20 then begin
            ResultText := ResultText + Tens[Num div 10] + ' ';
            Num := Num mod 10;
        end;

        if Num > 0 then
            ResultText := ResultText + Ones[Num] + ' ';

        exit(DelChr(ResultText, '>', ' '));
    end;

    trigger OnPreReport()
    begin
        CompanyInformation.Get();
        CompanyInformation.CalcFields(Picture);
        CompanyInformation.CalcFields("Report Footer");
    end;

    var
        CompanyInformation: Record "Company Information";
}

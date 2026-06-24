report 50108 "Petty Cash Voucher"
{
    DefaultLayout = RDLC;
    RDLCLayout = 'Src\Report\Layouts\PettyCashVoucher.rdl';
    Caption = 'Petty Cash Voucher';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;

    dataset
    {
        dataitem(BankAccountLedgerEntry; "Bank Account Ledger Entry")
        {
            RequestFilterFields = "Bank Account No.", "Posting Date", "Document No.";

            column(CompanyName; CompanyInfo.Name) { }
            column(CompanyAddress; CompanyInfo.Address) { }
            column(CompanyAddress2; CompanyInfo."Address 2") { }
            column(CompanyCity; CompanyInfo.City) { }
            column(CompanyLogo; CompanyInfo.Picture) { }

            column(PVNumber; PVNumber) { }
            column(CHEQUENo; "Document No.") { }
            column(CHEQUEDate; Format("Posting Date")) { }
            column(DepositBank; "Bank Account No.") { }
            column(Date; Format("Posting Date")) { }
            column(SuppID; "Bal. Account No.") { }
            column(Supplier; VendorName) { }
            column(Address; VendorAddress) { }
            column(TRN; VendorTRN) { }
            column(PaidTo; VendorName) { }
            column(PaymentDetails; Description) { }
            column(Mode; 'BANK TRANSFER') { }

            column(GLCode; "Bal. Account No.") { }
            column(SLCode; "Entry No.") { }
            column(OnAc; '') { }
            column(Amount; Amount) { }
            column(Curr; "Currency Code") { }
            column(Settled; 'Dr') { }
            column(TotalAmount; Amount) { }
            column(AEDAmount; "Amount (LCY)") { }
            column(Description; Description) { }

            column(TotalAmt; Amount) { }
            column(AmountInWords; AmountInWords) { }
            column(Remarks; "External Document No.") { }
            column(TextAmt; TextAmount[1]) { }

            dataitem("Vendor Ledger Entry"; "Vendor Ledger Entry")
            {
                DataItemLink = "Document No." = field("Document No."),
                               "Vendor No." = field("Bal. Account No.");
                DataItemTableView = sorting("Document No.", "Posting Date");
                column(Remaining_Amount; "Remaining Amount") { }
                column(Original_Amount; "Original Amount") { }
                column(VendAmount; Amount) { }
            }
            trigger OnAfterGetRecord()
            begin
                if not CompanyInfo.Get() then
                    Clear(CompanyInfo)
                else
                    CompanyInfo.Get();
                CompanyInfo.CalcFields(Picture);

                PVNumber := "Document No.";

                // Get Vendor Information
                if Vendor.Get("Bal. Account No.") then begin
                    VendorName := Vendor.Name;
                    VendorAddress := Vendor.Address + ' ' + Vendor."Address 2" + ' ' + Vendor.City;
                    VendorTRN := Vendor."VAT Registration No.";
                end else begin
                    VendorName := '';
                    VendorAddress := '';
                    VendorTRN := '';
                end;
                CheckReport.InitTextVariable();
                CheckReport.FormatNoText(TextAmount, Abs(Amount), '');
                AmountInWords := TextAmount[1];
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(ShowDetails; ShowDetails)
                    {
                        ApplicationArea = All;
                        Caption = 'Show Details';
                    }
                }
            }
        }
    }
    var
        CompanyInfo: Record "Company Information";
        Vendor: Record Vendor;
        PVNumber: Text[50];
        VendorName: Text[100];
        VendorAddress: Text[250];
        VendorTRN: Text[50];
        AmountInWords: Text[250];
        ShowDetails: Boolean;
        TextAmount: array[2] of Text[200];
        CheckReport: Report Check;

    // local procedure ConvertAmountToWords(Amount: Decimal): Text[250]
    // var
    //     AmountWords: Text[250];
    // begin
    //     // Simplified conversion - you may want to use a more sophisticated method


    //     AmountWords := Format(Amount) + ' ONLY';
    //     exit('AED ' + UpperCase(AmountWords));
    // end;
}
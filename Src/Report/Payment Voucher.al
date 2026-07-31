report 50112 "Payment voucher"
{
    UsageCategory = None;
    DefaultLayout = RDLC;
    RDLCLayout = 'Src/Report/Layouts/Payment Voucher.rdl';

    dataset
    {
        dataitem("Gen. Journal Line"; "Gen. Journal Line")
        {
            column(companylogo; ComInfo.Picture)
            {
            }
            column(ComInfo_Name; ComInfo.Name)
            {
            }
            column(CompanyAddress; ComInfo.Address)
            {
            }
            column(CompanyAddress2; ComInfo."Address 2")
            {
            }
            column(CompanyCity; ComInfo.City)
            {
            }
            column(CompanyCounty; ComInfo.County)
            {
            }
            column(GetAddressDetails; GetAddressDetails)
            {
            }
            column(ComInfo_Phone_No; ComInfo."Phone No.")
            {
            }
            column(ComInfo_Fax_No; ComInfo."Fax No.")
            {
            }
            column(Title; Title)
            {
            }
            column(ComInfo_Registration_No; ComInfo."Registration No.")
            {
            }
            // ── Payee Name ────────────────────────────────────────────────────
            column(Payee_Name; PayeeName)
            {
            }
            column(Voucher_No; "Document No.")
            {
            }
            column(Posting_Date; "Posting Date")
            {
            }
            column(Account_Details; GetAccountDetails)
            {
            }
            column(Description; Description)
            {
            }
            column(Amount; Amount)
            {
            }
            column(NoText1; NoText[1])
            {
            }
            column(NoText2; NoText[2])
            {
            }
            column(NoText3; NoText[3])
            {
            }
            column(GetBankDetails; GetBankDetails)
            {
            }
            column(Cheque_No; "External Document No.")
            {
            }
            column(GetCurrencyCode; GetCurrencyCode)
            {
            }
            column(GetPaymentMethodDesc; GetPaymentMethodDesc)
            {
            }
            column(Payment_Reference; "Payment Reference")
            {
            }

            trigger OnAfterGetRecord()
            var
                GLAccount: Record "G/L Account";
                Vendor: Record Vendor;
                Customer: Record Customer;
                Employee: Record Employee;
                AmountInWords: Codeunit "Amount In Words";
                GLSetup: Record "General Ledger Setup";
                PaymentMethod: Record "Payment Method";
            begin
                // ── Account Details ───────────────────────────────────────────
                Clear(GetAccountDetails);
                if GLAccount.Get("Account No.") then
                    GetAccountDetails := GLAccount."No." + ' ' + GLAccount.Name
                else
                    if Vendor.Get("Account No.") then
                        GetAccountDetails := Vendor.Name;

                // ── Payee Name — resolved by Account Type ─────────────────────
                Clear(PayeeName);
                case "Account Type" of
                    "Account Type"::Vendor:
                        if Vendor.Get("Account No.") then
                            PayeeName := Vendor.Name;

                    "Account Type"::Customer:
                        if Customer.Get("Account No.") then
                            PayeeName := Customer.Name;

                    "Account Type"::"G/L Account":
                        if GLAccount.Get("Account No.") then
                            PayeeName := GLAccount.Name;

                    "Account Type"::Employee:
                        if Employee.Get("Account No.") then
                            PayeeName := Employee.FullName();

                    "Account Type"::"Bank Account":
                        if BankAccount.Get("Account No.") then
                            PayeeName := BankAccount.Name;
                end;

                // ── Amount in Words ───────────────────────────────────────────
                AmountInWords.FormatNoTextV2(NoText, "Gen. Journal Line".Amount, "Gen. Journal Line"."Currency Code", false, false, false);

                // ── Bank Details ──────────────────────────────────────────────
                Clear(GetBankDetails);
                if BankAccount.Get("Bal. Account No.") then
                    GetBankDetails := BankAccount."No." + ' ' + BankAccount.Name + ' ' + BankAccount."Bank Account No.";

                // ── Currency Code ─────────────────────────────────────────────
                GetCurrencyCode := "Gen. Journal Line"."Currency Code";
                if GetCurrencyCode = '' then begin
                    GLSetup.Get();
                    GetCurrencyCode := GLSetup."LCY Code";
                end;

                // ── Payment Method ────────────────────────────────────────────
                Clear(GetPaymentMethodDesc);
                if PaymentMethod.Get("Payment Method Code") then
                    GetPaymentMethodDesc := PaymentMethod.Description;
            end;
        }
    }

    trigger OnPreReport()
    begin
        ComInfo.Get();
        ComInfo.CalcFields(Picture);
        CountryRegion.Get(ComInfo."Country/Region Code");

        Clear(GetAddressDetails);
        if (ComInfo.Address <> '') and (ComInfo."Address 2" <> '') and (ComInfo.City <> '') then
            GetAddressDetails := ComInfo.Address + ',' + ComInfo."Address 2" + ',' + ComInfo.City + ',' + CountryRegion.Name + '.'
        else
            if (ComInfo.Address <> '') and (ComInfo."Address 2" = '') and (ComInfo.City <> '') then
                GetAddressDetails := ComInfo.Address + ',' + ComInfo.City + ',' + CountryRegion.Name + '.'
            else
                if (ComInfo.Address <> '') and (ComInfo."Address 2" <> '') and (ComInfo.City = '') then
                    GetAddressDetails := ComInfo.Address + ',' + ComInfo."Address 2" + ',' + CountryRegion.Name + '.';
    end;

    var
        ComInfo: Record "Company Information";
        CountryRegion: Record "Country/Region";
        BankAccount: Record "Bank Account";
        GetAddressDetails: Text[250];
        GetAccountDetails: Text[150];
        GetBankDetails: Text;
        PayeeName: Text[100];
        NoText: array[3] of Text[50];
        Title: Label 'PAYMENT VOUCHER';
        GetCurrencyCode: Text;
        GetPaymentMethodDesc: Text[100];
}

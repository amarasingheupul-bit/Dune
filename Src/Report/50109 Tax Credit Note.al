report 50109 "Tax Credit Note"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultLayout = RDLC;
    RDLCLayout = 'Src\Report\Layouts\TaxCreditNote.rdl';
    Caption = 'Tax Credit Note';

    dataset
    {
        dataitem("Sales Cr.Memo Header"; "Sales Cr.Memo Header")
        {
            RequestFilterFields = "No.";

            column(CompanyName; CompanyInfo.Name) { }
            column(CompanyAddress; CompanyInfo.Address) { }
            column(CompanyAddress2; CompanyInfo."Address 2") { }
            column(CompanyCity; CompanyInfo.City) { }
            column(CompanyLogo; CompanyInfo.Picture) { }
            column(CompanyPhone; CompanyInfo."Phone No.")
            {
            }
            column(CompanyFax; CompanyInfo."Fax No.")
            {
            }
            column(CompanyVATRegNo; CompanyInfo."VAT Registration No.")
            {
            }
            column(DocumentNo; "Sales Cr.Memo Header"."No.")
            {
            }
            column(CustomerNo; "Sales Cr.Memo Header"."Sell-to Customer No.")
            {
            }
            column(CustomerName; CustomerName)
            {
            }
            column(CustomerAddress; "Sales Cr.Memo Header"."Sell-to Address")
            {
            }
            column(CustomerAddress2; "Sales Cr.Memo Header"."Sell-to Address 2")
            {
            }
            column(CustomerCity; "Sales Cr.Memo Header"."Sell-to City")
            {
            }
            column(CustomerVATRegNo; Customer."VAT Registration No.")
            {
            }
            column(PostingDate; "Sales Cr.Memo Header"."Posting Date")
            {
            }
            column(ExternalDocumentNo; "Sales Cr.Memo Header"."External Document No.")
            {
            }
            column(SalespersonName; Salesperson.Name)
            {
            }
            column(InvoiceDiscountAmount; "Sales Cr.Memo Header"."Invoice Discount Amount")
            {
            }
            column(LocationName; Location.Name)
            {
            }
            column(AppliesToDocNo; "Sales Cr.Memo Header"."Applies-to Doc. No.")
            {
            }
            column(ReturnReasonDescription; ReasonCodeDescription)
            {
            }
            column(PartyBillNo; "Sales Cr.Memo Header"."External Document No.")
            {
            }
            column(PartyBillDate; "Sales Cr.Memo Header"."Document Date")
            {
            }
            column(TotalAmount; TotalAmount)
            {
            }
            column(TotalVATAmount; TotalVATAmount)
            {
            }
            column(TotalAmountIncVAT; TotalAmountIncVAT)
            {
            }

            dataitem("Sales Cr.Memo Line"; "Sales Cr.Memo Line")
            {
                DataItemLink = "Document No." = FIELD("No.");
                DataItemTableView = WHERE(Amount = FILTER(<> 0));

                column(GLCode; "Sales Cr.Memo Line"."No.")
                {
                }
                column(ItemDescription; "Sales Cr.Memo Line".Description)
                {
                }
                column(Quantity; "Sales Cr.Memo Line".Quantity)
                {
                }
                column(UnitPrice; "Sales Cr.Memo Line"."Unit Price")
                {
                }
                column(LineAmount; "Sales Cr.Memo Line".Amount)
                {
                }
                column(AmountIncludingVAT; "Sales Cr.Memo Line"."Amount Including VAT")
                {
                }
                column(LineDiscountAmount; "Sales Cr.Memo Line"."Line Discount Amount")
                {
                }
                column(VATProdPostingGroup; "Sales Cr.Memo Line"."VAT Prod. Posting Group")
                {
                }
                column(VATPercentage; VATPercentage)
                {
                }
                column(VATAmount; VATAmount)
                {
                }
                column(SupplyDate; "Sales Cr.Memo Line"."Shipment Date")
                {
                }
                column(SignColumn; '')
                {
                }
                column(TextAmt; TextAmount[1]) { }
                trigger OnAfterGetRecord()
                begin
                    // Calculate VAT Amount
                    VATAmount := "Amount Including VAT" - Amount;

                    // Accumulate totals
                    TotalAmount += Amount;
                    TotalVATAmount += VATAmount;
                    TotalAmountIncVAT += "Amount Including VAT";
                    AmountInWords := TextAmount[1];
                    CheckReport.InitTextVariable();
                    CheckReport.FormatNoText(TextAmount, Abs(Amount), '');
                end;

                trigger OnPreDataItem()
                begin
                    // Reset totals
                    TotalAmount := 0;
                    TotalVATAmount := 0;
                    TotalAmountIncVAT := 0;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                // Get Company Information
                if not CompanyInfoRead then begin
                    CompanyInfo.Get();
                    CompanyInfoRead := true;
                end;

                // Get Customer Information
                if Customer.Get("Sell-to Customer No.") then;

                // Get Salesperson
                if Salesperson.Get("Salesperson Code") then;

                // Get Location
                if Location.Get("Location Code") then;

                // Set Customer Name
                CustomerName := "Sell-to Customer Name";
            end;

            trigger OnPreDataItem()
            begin
                CompanyInfo.Get();
                CompanyInfo.CalcFields(Picture);
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Options';
                }
            }
        }

        actions
        {
        }
    }

    var
        CompanyInfo: Record "Company Information";
        Customer: Record Customer;
        Salesperson: Record "Salesperson/Purchaser";
        Location: Record Location;
        ReasonCode: Record "Reason Code";
        CompanyInfoRead: Boolean;
        VATPercentage: Decimal;
        VATAmount: Decimal;
        CustomerName: Text[100];
        ReasonCodeDescription: Text[100];
        TotalAmount: Decimal;
        TotalVATAmount: Decimal;
        TotalAmountIncVAT: Decimal;
        TextAmount: array[2] of Text[200];
        AmountInWords: Text[250];
        CheckReport: Report Check;
}

reportextension 50100 "Posted Purchase InvoiceExt" extends "Purchase - Invoice"
{
    dataset
    {
        add("Purch. Inv. Header")
        {
            column(Companylogo; CompanyInformation.Picture) { }
            column(CompanyName; CompanyInformation.Name) { }
        }
    }

    requestpage
    {
        // Add changes to the requestpage here
    }

    rendering
    {
        layout(PostedPurchInvoice)
        {
            Type = RDLC;
            LayoutFile = 'Src\Report Ext\Layouts\PurchaseInvoice.rdl';
        }
    }
    trigger OnPreReport()
    begin
        CompanyInformation.Get();
        CompanyInformation.CalcFields(Picture);
        CompanyInformation.CalcFields("Report Footer");
    end;

    var
        CompanyInformation: Record "Company Information";
}
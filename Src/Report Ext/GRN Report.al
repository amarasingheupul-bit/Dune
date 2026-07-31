reportextension 50103 "Purchase - ReceiptExt" extends "Purchase - Receipt"
{
    dataset
    {
        add("Purch. Rcpt. Header")
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
        layout(LayoutName)
        {
            Type = RDLC;
            LayoutFile = 'Src\Report Ext\Layouts\PurchaseReceipt.rdl';
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
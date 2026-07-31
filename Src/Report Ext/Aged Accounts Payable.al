reportextension 50101 "Aged Accounts PayableExt" extends "Aged Accounts Payable"
{
    dataset
    {
        add(Vendor)
        {
            column(Companylogo; CompanyInformation.Picture) { }
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
            LayoutFile = 'Src\Report Ext\Layouts\AgedAccountsPayable.rdl';
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
reportextension 50102 "Aged Accounts ReceivableExt" extends "Aged Accounts Receivable"
{
    dataset
    {
        add(Header)
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
            LayoutFile = 'Src\Report Ext\Layouts\AgedAccountsReceivable.rdl';
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
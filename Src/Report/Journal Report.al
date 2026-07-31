report 50114 "Journal Report"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = JournalReport;

    dataset
    {
        dataitem("Posted Gen. Journal Line"; "Posted Gen. Journal Line")
        {
            column(Document_No_; "Document No.") { }
            column(Description; Description) { }
            column(Debit_Amount; "Debit Amount") { }
            column(Credit_Amount; "Credit Amount") { }
            column(Posting_Date; "Posting Date") { }
            column(Currency_Code; "Currency Code") { }
            column(CompanyName; CompanyInformation.Name) { }
            column(CompanyAddress; CompanyInformation.Address) { }
            column(CompanyAddress2; CompanyInformation."Address 2") { }
            column(CompanyCity; CompanyInformation.City) { }
            column(CompanyCounty; CompanyInformation.County) { }
            column(CompanyPhoneNo; CompanyInformation."Phone No.") { }
            column(CompanyFaxNo; CompanyInformation."Fax No.") { }
            column(CompanyEmail; CompanyInformation."E-Mail") { }
            column(CompanyLogo; CompanyInformation.Picture) { }
            column(CompanyVatRegistration; CompanyInformation."VAT Registration No.") { }

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

            }
        }

        actions
        {
            area(processing)
            {
                // action(LayoutName)
                // {

                // }
            }
        }
    }

    rendering
    {
        layout(JournalReport)
        {
            Type = RDLC;
            LayoutFile = 'Src\Report\Layouts\JournalReport.rdl';
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
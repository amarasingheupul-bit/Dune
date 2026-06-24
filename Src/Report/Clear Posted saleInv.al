report 50102 "Clear Posted Sale Inv"
{
    UsageCategory = ReportsAndAnalysis;
    Caption = 'Clear Posted Sale Invoices';
    ApplicationArea = All;
    ProcessingOnly = true;
    Permissions = tabledata "Sales Invoice Header" = RIMD,
                    tabledata "Sales Invoice Line" = RIMD;

    dataset
    {
        dataitem("Sales Invoice Line"; "Sales Invoice Line")
        {
            RequestFilterFields = "Document No.";
            trigger OnAfterGetRecord()
            begin
                Delete();
            end;

        }

        dataitem("Sales Invoice Header"; "Sales Invoice Header")
        {
            RequestFilterFields = "No.";
            trigger OnAfterGetRecord()
            begin
                Delete();
            end;

        }
    }
}
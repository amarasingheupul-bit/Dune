report 50102 "Clear Posted Sale Inv"
{
    UsageCategory = ReportsAndAnalysis;
    Caption = 'Clear Posted Sale Invoices';
    ApplicationArea = All;
    ProcessingOnly = true;
    Permissions = tabledata "Sales Invoice Header" = RIMD,
                    tabledata "Sales Invoice Line" = RIMD,
                    tabledata "Purch. Inv. Header" = RIMD,
                   tabledata "Purch. Inv. Line" = RIMD,
                   tabledata "Vendor Ledger Entry" = RIMD,
                   tabledata "G/L Entry" = RIMD,
                   tabledata "Detailed Vendor Ledg. Entry" = RIMD,
                   tabledata "VAT Entry" = RIMD;

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
        dataitem("Purch. Inv. Header"; "Purch. Inv. Header")
        {
            RequestFilterFields = "No.";
            trigger OnAfterGetRecord()
            begin
                Delete();
            end;

        }
        dataitem("Vendor Ledger Entry"; "Vendor Ledger Entry")
        {
            RequestFilterFields = "Document No.";
            trigger OnAfterGetRecord()
            begin
                Delete();
            end;

        }
        dataitem("G/L Entry"; "G/L Entry")
        {
            RequestFilterFields = "Document No.";
            trigger OnAfterGetRecord()
            begin
                Delete();
            end;

        }
        dataitem("Detailed Vendor Ledg. Entry"; "Detailed Vendor Ledg. Entry")
        {
            RequestFilterFields = "Document No.";
            trigger OnAfterGetRecord()
            begin
                Delete();
            end;

        }
        dataitem("VAT Entry"; "VAT Entry")
        {
            RequestFilterFields = "Document No.";
            trigger OnAfterGetRecord()
            begin
                Delete();
            end;

        }
        dataitem("Purch. Inv. Line"; "Purch. Inv. Line")
        {
            RequestFilterFields = "No.";
            trigger OnAfterGetRecord()
            begin
                Delete();
            end;

        }

    }
}
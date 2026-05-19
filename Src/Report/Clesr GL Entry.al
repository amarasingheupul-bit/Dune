report 50101 "Clear GL Entry Currency"
{
    UsageCategory = ReportsAndAnalysis;
    Caption = 'Clear G/L Entry Currency Code';
    ApplicationArea = All;
    ProcessingOnly = true;

    Permissions = tabledata "G/L Entry" = RIMD,
   tabledata "Vendor Ledger Entry" = RIMD,
   tabledata "Detailed Vendor Ledg. Entry" = RIMD,
   tabledata "Bank Account Ledger Entry" = RIMD,
   tabledata "Posted Gen. Journal Line" = RIMD;

    dataset
    {
        dataitem("G/L Entry"; "G/L Entry")
        {
            RequestFilterFields = "Document No.";

            trigger OnAfterGetRecord()
            begin
                if "Source Currency Code" <> '' then begin
                    "Source Currency Code" := '';
                    Modify();
                end;
            end;
        }
        dataitem("Vendor Ledger Entry"; "Vendor Ledger Entry")
        {
            RequestFilterFields = "Document No.";

            trigger OnAfterGetRecord()
            begin
                if "Currency Code" <> '' then begin
                    "Currency Code" := '';
                    Modify();
                end;
            end;
        }
        dataitem("Detailed Vendor Ledg. Entry"; "Detailed Vendor Ledg. Entry")
        {
            RequestFilterFields = "Document No.";

            trigger OnAfterGetRecord()
            begin
                if "Currency Code" <> '' then begin
                    "Currency Code" := '';
                    Modify();
                end;
            end;
        }
        dataitem("Bank Account Ledger Entry"; "Bank Account Ledger Entry")
        {
            RequestFilterFields = "Document No.";

            trigger OnAfterGetRecord()
            begin
                if "Currency Code" <> '' then begin
                    "Currency Code" := '';
                    Modify();
                end;
            end;
        }
        dataitem("Posted Gen. Journal Line"; "Posted Gen. Journal Line")
        {
            RequestFilterFields = "Document No.";

            trigger OnAfterGetRecord()
            begin
                if "Currency Code" <> '' then begin
                    "Currency Code" := '';
                    Modify();
                end;
            end;
        }
    }
}
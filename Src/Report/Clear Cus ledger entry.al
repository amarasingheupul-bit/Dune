report 50122 "Clear Cust. Ledger Entry"
{
    UsageCategory = ReportsAndAnalysis;
    Caption = 'Clear Cust. Ledger Entry';
    ApplicationArea = All;
    ProcessingOnly = true;
    Permissions = tabledata "Cust. Ledger Entry" = RIMD,
                    tabledata "Detailed Cust. Ledg. Entry" = RIMD,
                    tabledata "G/L Entry" = RIMD,
                    tabledata "Bank Account Ledger Entry" = RIMD;

    dataset
    {
        // dataitem("Cust. Ledger Entry"; "Cust. Ledger Entry")
        // {
        //     RequestFilterFields = "Document No.";
        //     trigger OnAfterGetRecord()
        //     begin
        //         Delete();
        //     end;

        // }

        // dataitem("Detailed Cust. Ledg. Entry"; "Detailed Cust. Ledg. Entry")
        // {
        //     RequestFilterFields = "Document No.";
        //     trigger OnAfterGetRecord()
        //     begin
        //         Delete();
        //     end;

        // }
        dataitem("G/L Entry"; "G/L Entry")
        {
            RequestFilterFields = "Entry No.";
            trigger OnAfterGetRecord()
            begin
                Delete();
            end;

        }
        // dataitem("Bank Account Ledger Entry"; "Bank Account Ledger Entry")
        // {
        //     RequestFilterFields = "Document No.";
        //     trigger OnAfterGetRecord()
        //     begin
        //         Delete();
        //     end;

        // }
    }
}


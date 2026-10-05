report 50123 "Clear Bank Ledger Stmt Status"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    Caption = 'Clear Statement Status/No. by Document No.';
    ProcessingOnly = true;
    Permissions = tabledata "Bank Account Ledger Entry" = RIMD;

    dataset
    {
        dataitem(BankAccLedgerEntry; "Bank Account Ledger Entry")
        {
            trigger OnPreDataItem()
            var
                DocNoFilterText: Text;
            begin
                if DocumentNoFilter = '' then
                    Error('Please enter at least one Document No.');

                // Convert comma-separated input to BC filter OR-syntax
                DocNoFilterText := DocumentNoFilter.Replace(',', '|');
                BankAccLedgerEntry.SetFilter("Document No.", DocNoFilterText);
            end;

            trigger OnAfterGetRecord()
            begin
                "Statement Status" := "Statement Status"::Open;
                "Statement No." := '';
                "Statement Line No." := 0;
                Modify();
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    field(DocNoFilter; DocumentNoFilter)
                    {
                        ApplicationArea = All;
                        Caption = 'Document No. (comma-separated for multiple)';
                        ToolTip = 'Specify one or more Document Nos., separated by commas, e.g. REC-P-26/27-00194,REC-P-26/27-00195';
                    }
                }
            }
        }
    }

    var
        DocumentNoFilter: Text;
}
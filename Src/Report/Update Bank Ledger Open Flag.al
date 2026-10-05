report 50124 "Update Bank Ledger Open Flag"
{
    Caption = 'Update Bank Ledger Open Flag';
    ProcessingOnly = true;
    UsageCategory = Tasks;
    ApplicationArea = All;
    Permissions = tabledata "Bank Account Ledger Entry" = RIMD;

    dataset
    {
        dataitem(BankAccLedgerEntry; "Bank Account Ledger Entry")
        {
            DataItemTableView = sorting("Entry No.");

            trigger OnPreDataItem()
            begin
                // if CheckNo = '' then
                //     Error('Please enter a Check No.');
                if DocumentNo = '' then
                    Error('Please enter a Document No.');
                if EntryNo = 0 then
                    Error('Please enter an Entry No.');

                //SetRange("External Document No.", CheckNo);
                SetRange("Document No.", DocumentNo);
                SetRange("Entry No.", EntryNo);
            end;

            trigger OnAfterGetRecord()
            begin
                BankAccLedgerEntry.Open := true;
                BankAccLedgerEntry.Modify(true);
                UpdatedCount += 1;
            end;

            trigger OnPostDataItem()
            begin
                if UpdatedCount = 0 then
                    Message('No matching entries found.')
                else
                    Message('%1 entry(ies) updated successfully. Open set to TRUE.', UpdatedCount);
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Filters)
                {
                    Caption = 'Entry Filters';

                    // field(CheckNoField; CheckNo)
                    // {
                    //     ApplicationArea = All;
                    //     Caption = 'Check No.';
                    //     ToolTip = 'Enter the Check No. to filter entries.';
                    // }
                    field(DocumentNoField; DocumentNo)
                    {
                        ApplicationArea = All;
                        Caption = 'Document No.';
                        ToolTip = 'Enter the Document No. to filter entries.';
                    }
                    field(EntryNoField; EntryNo)
                    {
                        ApplicationArea = All;
                        Caption = 'Entry No.';
                        ToolTip = 'Enter the Entry No. to filter entries.';
                    }
                }
            }
        }
    }

    var
        CheckNo: Code[20];
        DocumentNo: Code[20];
        EntryNo: Integer;
        UpdatedCount: Integer;
}
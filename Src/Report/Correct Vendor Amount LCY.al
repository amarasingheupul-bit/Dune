report 50116 "Correct Vendor Amount LCY"
{
    Caption = 'Correct Vendor Amount LCY (Posts Adjustment)';
    ProcessingOnly = true;
    UsageCategory = Tasks;
    ApplicationArea = All;
    Permissions = tabledata "Vendor Ledger Entry" = RIMD,
                  tabledata "Gen. Journal Line" = RIMD,
                  tabledata "Detailed Vendor Ledg. Entry" = RIMD,
                  tabledata "G/L Entry" = RIMD,
                  tabledata "Bank Account Ledger Entry" = RIMD,
                  tabledata "Posted Gen. Journal Line" = RIMD;

    dataset
    {
        dataitem(VendLedgerEntry; "Vendor Ledger Entry")
        {
            DataItemTableView = sorting("Entry No.");

            trigger OnPreDataItem()
            begin
                if PostingDate = 0D then
                    Error('Please enter a Posting Date.');
                if DocumentNo = '' then
                    Error('Please enter a Document No.');
                // if CorrectedAmountLCY = 0 then
                //     Error('Please enter the corrected Amount (LCY).');
                if GenJnlTemplateName = '' then
                    Error('Please enter a Gen. Journal Template.');
                // if GenJnlBatchName = '' then
                //     Error('Please enter a Gen. Journal Batch.');

                SetRange("Posting Date", PostingDate);
                SetRange("Document No.", DocumentNo);
            end;

            trigger OnAfterGetRecord()
            var
                GenJnlLine: Record "Gen. Journal Line";
                DiffLCY: Decimal;
                LastLineNo: Integer;
            begin
                "Amount (LCY)" := 10945.65;
                Modify();
                // DiffLCY := CorrectedAmountLCY - VendLedgerEntry."Amount (LCY)";
                // if DiffLCY = 0 then begin
                //     Message('Entry %1 already matches the target amount. No adjustment posted.', VendLedgerEntry."Entry No.");
                //     exit;
                // end;

                // GenJnlLine.SetRange("Journal Template Name", GenJnlTemplateName);
                // GenJnlLine.SetRange("Journal Batch Name", GenJnlBatchName);
                // if GenJnlLine.FindLast() then
                //     LastLineNo := GenJnlLine."Line No." + 10000
                // else
                //     LastLineNo := 10000;

                // GenJnlLine.Init();
                // GenJnlLine."Journal Template Name" := GenJnlTemplateName;
                // GenJnlLine."Journal Batch Name" := GenJnlBatchName;
                // GenJnlLine."Line No." := LastLineNo;
                // GenJnlLine.Validate("Posting Date", WorkDate());
                // GenJnlLine.Validate("Document Type", GenJnlLine."Document Type"::Payment);
                // GenJnlLine.Validate("Document No.", VendLedgerEntry."Document No.");
                // GenJnlLine.Validate("Account Type", GenJnlLine."Account Type"::Vendor);
                // GenJnlLine.Validate("Account No.", VendLedgerEntry."Vendor No.");
                // GenJnlLine.Validate(Amount, DiffLCY);
                // GenJnlLine."Applies-to Doc. Type" := VendLedgerEntry."Document Type";
                // GenJnlLine."Applies-to Doc. No." := VendLedgerEntry."Document No.";
                // GenJnlLine.Description :=
                //     CopyStr(StrSubstNo('Correction Amt(LCY) entry %1: %2', VendLedgerEntry."Entry No.", ReasonText),
                //         1, MaxStrLen(GenJnlLine.Description));
                // GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"G/L Account";
                // GenJnlLine."Bal. Account No." := BalGLAccountNo;
                // GenJnlLine.Insert(true);

                // UpdatedCount += 1;
            end;

            trigger OnPostDataItem()
            begin
                // if UpdatedCount = 0 then
                //     Message('No matching Vendor Ledger Entries found, or no adjustment was needed.')
                // else
                //     Message('%1 correcting journal line(s) created in %2/%3. Review and post from the Gen. Journal.',
                //         UpdatedCount, GenJnlTemplateName, GenJnlBatchName);
            end;
        }
        dataitem("G/L Entry"; "G/L Entry")
        {
            DataItemTableView = sorting("Entry No.");

            trigger OnPreDataItem()
            begin
                if PostingDate = 0D then
                    Error('Please enter a Posting Date.');
                if DocumentNo = '' then
                    Error('Please enter a Document No.');
                if GenJnlTemplateName = '' then
                    Error('Please enter a Gen. Journal Template.');

                SetRange("Posting Date", PostingDate);
                SetRange("Document No.", DocumentNo);
            end;

            trigger OnAfterGetRecord()
            begin
                case "Entry No." of
                    4875:
                        Amount := 10945.65;
                    4874:
                        Amount := -10945.65;
                end;
                Modify();
            end;
        }
        dataitem("Detailed Vendor Ledg. Entry"; "Detailed Vendor Ledg. Entry")
        {
            DataItemTableView = sorting("Entry No.");

            trigger OnPreDataItem()
            begin
                if PostingDate = 0D then
                    Error('Please enter a Posting Date.');
                if DocumentNo = '' then
                    Error('Please enter a Document No.');
                // if CorrectedAmountLCY = 0 then
                //     Error('Please enter the corrected Amount (LCY).');
                if GenJnlTemplateName = '' then
                    Error('Please enter a Gen. Journal Template.');
                // if GenJnlBatchName = '' then
                //     Error('Please enter a Gen. Journal Batch.');

                SetRange("Posting Date", PostingDate);
                SetRange("Document No.", DocumentNo);
            end;

            trigger OnAfterGetRecord()
            var
                GenJnlLine: Record "Gen. Journal Line";
                DiffLCY: Decimal;
                LastLineNo: Integer;
            begin
                "Amount (LCY)" := 10945.65;
                Modify();
            end;
        }
        dataitem("Bank Account Ledger Entry"; "Bank Account Ledger Entry")
        {
            DataItemTableView = sorting("Entry No.");

            trigger OnPreDataItem()
            begin
                if PostingDate = 0D then
                    Error('Please enter a Posting Date.');
                if DocumentNo = '' then
                    Error('Please enter a Document No.');
                // if CorrectedAmountLCY = 0 then
                //     Error('Please enter the corrected Amount (LCY).');
                if GenJnlTemplateName = '' then
                    Error('Please enter a Gen. Journal Template.');
                // if GenJnlBatchName = '' then
                //     Error('Please enter a Gen. Journal Batch.');

                SetRange("Posting Date", PostingDate);
                SetRange("Document No.", DocumentNo);
            end;

            trigger OnAfterGetRecord()
            var
                GenJnlLine: Record "Gen. Journal Line";
                DiffLCY: Decimal;
                LastLineNo: Integer;
            begin
                "Amount (LCY)" := 10945.65;
                Modify();
            end;
        }
        dataitem("Gen. Journal Line"; "Gen. Journal Line")
        {
            //DataItemTableView = sorting("Entry No.");

            trigger OnPreDataItem()
            begin
                if PostingDate = 0D then
                    Error('Please enter a Posting Date.');
                if DocumentNo = '' then
                    Error('Please enter a Document No.');
                // if CorrectedAmountLCY = 0 then
                //     Error('Please enter the corrected Amount (LCY).');
                if GenJnlTemplateName = '' then
                    Error('Please enter a Gen. Journal Template.');
                // if GenJnlBatchName = '' then
                //     Error('Please enter a Gen. Journal Batch.');

                SetRange("Posting Date", PostingDate);
                SetRange("Document No.", DocumentNo);
            end;

            trigger OnAfterGetRecord()
            var
                GenJnlLine: Record "Gen. Journal Line";
                DiffLCY: Decimal;
                LastLineNo: Integer;
            begin
                "Amount (LCY)" := 10945.65;
                Modify();
            end;
        }
        dataitem("Posted Gen. Journal Line"; "Posted Gen. Journal Line")
        {
            // DataItemTableView = sorting("Entry No.");

            trigger OnPreDataItem()
            begin
                if PostingDate = 0D then
                    Error('Please enter a Posting Date.');
                if DocumentNo = '' then
                    Error('Please enter a Document No.');
                // if CorrectedAmountLCY = 0 then
                //     Error('Please enter the corrected Amount (LCY).');
                if GenJnlTemplateName = '' then
                    Error('Please enter a Gen. Journal Template.');
                // if GenJnlBatchName = '' then
                //     Error('Please enter a Gen. Journal Batch.');

                SetRange("Posting Date", PostingDate);
                SetRange("Document No.", DocumentNo);
            end;

            trigger OnAfterGetRecord()
            var
                GenJnlLine: Record "Gen. Journal Line";
                DiffLCY: Decimal;
                LastLineNo: Integer;
            begin
                "Amount (LCY)" := 10945.65;
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
                group(Filters)
                {
                    Caption = 'Entry to Correct';

                    field(PostingDateField; PostingDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Posting Date';
                        ToolTip = 'Posting Date of the Vendor Ledger Entry to correct.';
                    }
                    field(EntryNO; EntryNo)
                    {
                        ApplicationArea = All;
                        Caption = 'Posting Date';
                        ToolTip = 'Posting Date of the Vendor Ledger Entry to correct.';
                    }
                    field(DocumentNoField; DocumentNo)
                    {
                        ApplicationArea = All;
                        Caption = 'Document No.';
                        ToolTip = 'Document No. of the Vendor Ledger Entry to correct.';
                    }
                    field(CorrectedAmountLCYField; CorrectedAmountLCY)
                    {
                        ApplicationArea = All;
                        Caption = 'Corrected Amount (LCY)';
                        ToolTip = 'The Amount (LCY) the entry should be after correction.';
                    }
                    field(ReasonField; ReasonText)
                    {
                        ApplicationArea = All;
                        Caption = 'Reason for Correction';
                        ToolTip = 'Mandatory explanation, stored on the journal line description.';
                    }
                }
                group(Posting)
                {
                    Caption = 'Journal Target';

                    field(GenJnlTemplateNameField; GenJnlTemplateName)
                    {
                        ApplicationArea = All;
                        Caption = 'Gen. Journal Template';
                        TableRelation = "Gen. Journal Template";
                    }
                    // field(GenJnlBatchNameField; GenJnlBatchName)
                    // {
                    //     ApplicationArea = All;
                    //     Caption = 'Gen. Journal Batch';
                    //     TableRelation = "Gen. Journal Batch".Name where("Journal Template Name" = field(GenJnlTemplateName));
                    // }
                    field(BalGLAccountNoField; BalGLAccountNo)
                    {
                        ApplicationArea = All;
                        Caption = 'Balancing G/L Account';
                        TableRelation = "G/L Account";
                        ToolTip = 'Account to absorb the correction difference (e.g. Realized Exch. Gain/Loss).';
                    }
                }
            }
        }
    }

    var
        PostingDate: Date;
        EntryNo: Code[20];
        DocumentNo: Code[20];
        CorrectedAmountLCY: Decimal;
        ReasonText: Text[100];
        GenJnlTemplateName: Code[10];
        GenJnlBatchName: Code[10];
        BalGLAccountNo: Code[20];
        UpdatedCount: Integer;
}

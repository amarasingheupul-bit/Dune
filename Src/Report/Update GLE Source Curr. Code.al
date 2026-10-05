report 50125 "Update GLE Source Curr. Code"
{
    ProcessingOnly = true;
    UsageCategory = Tasks;
    ApplicationArea = All;
    Caption = 'Update G/L Entry Source Currency Code';
    Permissions = tabledata "G/L Entry" = RIMD;

    dataset
    {
        dataitem(GLEntry; "G/L Entry")
        {
            RequestFilterFields = "Entry No.", "Document No.";

            trigger OnPreDataItem()
            begin
                if NewSourceCurrencyCode = '' then
                    Error('Please enter a New Source Currency Code before running the report.');

                if not Confirm(
                    'This will update the Source Currency Code on the selected G/L Entries to %1.\Do you want to continue?',
                    false, NewSourceCurrencyCode)
                then
                    CurrReport.Break();
            end;

            trigger OnAfterGetRecord()
            begin
                // Skip entries that already have the target value
                if GLEntry."Source Currency Code" = NewSourceCurrencyCode then
                    exit;

                GLEntry."Source Currency Code" := NewSourceCurrencyCode;
                GLEntry.Modify();

                UpdatedCount += 1;
            end;

            trigger OnPostDataItem()
            var
                ResultText: Text;
            begin
                if UpdatedCount = 0 then
                    Message('No G/L Entries were updated. Check your Entry No. / Document No. filters.')
                else begin
                    if UpdatedCount = 1 then
                        ResultText := 'entry'
                    else
                        ResultText := 'entries';

                    Message('%1 G/L %2 updated with Source Currency Code %3.',
                        UpdatedCount, ResultText, NewSourceCurrencyCode);
                end;
            end;
        }
    }

    requestpage
    {
        SaveValues = false;

        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Options';

                    field(NewSourceCurrencyCodeField; NewSourceCurrencyCode)
                    {
                        ApplicationArea = All;
                        Caption = 'New Source Currency Code';
                        ToolTip = 'Specifies the Source Currency Code value to set on the filtered G/L Entries.';
                        TableRelation = Currency.Code;
                    }
                }
                group(FilterHint)
                {
                    Caption = '';
                    Editable = false;

                    label(Instructions)
                    {
                        ApplicationArea = All;
                        Caption = 'Use the Filter (G/L Entry) tab to enter the Entry No. and/or Document No. of the entries you want to update.';
                    }
                }
            }
        }
    }

    trigger OnInitReport()
    begin
        UpdatedCount := 0;
    end;

    var
        NewSourceCurrencyCode: Code[10];
        UpdatedCount: Integer;
}

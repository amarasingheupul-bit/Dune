page 50140 "Sales Excel Export Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Sales Excel Export Setup";
    Caption = 'Sales Invoice Excel Export Setup';
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Recipient Email"; Rec."Recipient Email")
                {
                    ApplicationArea = All;
                    ToolTip = 'The email address that the Excel export of every posted sales invoice will be sent to.';
                }
                field("Send Email On Post"; Rec."Send Email On Post")
                {
                    ApplicationArea = All;
                    ToolTip = 'If enabled, the Excel file is emailed automatically every time a sales invoice is posted.';
                }
                field("Attach To Invoice"; Rec."Attach To Invoice")
                {
                    ApplicationArea = All;
                    ToolTip = 'If enabled, the Excel file is also saved as a Document Attachment on the posted sales invoice.';
                }
            }
            group(Diagnostics)
            {
                Caption = 'Last Attempt (for troubleshooting)';
                field("Last Send DateTime"; Rec."Last Send DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'When the last automatic send was attempted.';
                }
                field("Last Send Result"; Rec."Last Send Result")
                {
                    ApplicationArea = All;
                    ToolTip = 'Whether Business Central reported the last send as successful.';
                }
                field("Last Send Info"; Rec."Last Send Info")
                {
                    ApplicationArea = All;
                    ToolTip = 'Details or error message from the last send attempt.';
                    MultiLine = true;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        Setup: Record "Sales Excel Export Setup";
    begin
        if not Setup.Get('') then begin
            Setup.Init();
            Setup."Primary Key" := '';
            Setup.Insert();
        end;
        Rec.Get('');
    end;
}

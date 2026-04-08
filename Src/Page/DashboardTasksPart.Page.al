page 50121 "Dashboard Tasks Part"
{
    PageType = ListPart;
    Caption = 'Tasks';
    SourceTable = "Approval Entry";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                ShowCaption = false;

                field(TaskCount; TaskCountInt)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    Style = Strong;
                }

                field(TaskDesc; 'Bills awaiting approval')
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                }

                field(Arrow; '→')
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    Style = StrongAccent;
                }
            }
        }
    }

    var
        TaskCountInt: Integer;

    trigger OnOpenPage()
    var
        ApprovalEntry: Record "Approval Entry";
    begin
        ApprovalEntry.SetRange(Status, ApprovalEntry.Status::Open);
        ApprovalEntry.SetRange("Table ID", Database::"Purchase Header");
        TaskCountInt := ApprovalEntry.Count();
    end;
}

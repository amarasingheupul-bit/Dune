page 50121 "Dashboard Tasks Part"
{
    PageType = ListPart;
    Caption = 'Tasks';
    SourceTable = "To-do";
    SourceTableTemporary = true;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(TaskCategory; TaskCategory)
                {
                    ApplicationArea = All;
                    Caption = 'Category';
                    Editable = false;
                    Style = Strong;
                }
                field(No; Rec."No.")
                {
                    ApplicationArea = All;
                    Caption = 'No.';

                    trigger OnDrillDown()
                    begin
                        OpenTaskCard();
                    end;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Caption = 'Description';

                    trigger OnDrillDown()
                    begin
                        OpenTaskCard();
                    end;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Caption = 'Status';
                }
                field(Date; Rec.Date)
                {
                    ApplicationArea = All;
                    Caption = 'Date';
                }
                field(AssignedTo; Rec."User")
                {
                    ApplicationArea = All;
                    Caption = 'Assigned To';
                }
                field(CreatedBy; CreatedByUser)
                {
                    ApplicationArea = All;
                    Caption = 'Assigned By';
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(OpenTask)
            {
                ApplicationArea = All;
                Caption = 'Open Task';
                Image = Open;
                ToolTip = 'Open the selected task.';

                trigger OnAction()
                begin
                    OpenTaskCard();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        LoadTasks();
    end;

    trigger OnAfterGetRecord()
    var
        UserRec: Record User;
    begin
        // Resolve SystemCreatedBy GUID to User Name
        CreatedByUser := '';
        if UserRec.Get(Rec.SystemCreatedBy) then
            CreatedByUser := UserRec."User Name";

        // Set Category
        if Rec."User" = UserId() then
            TaskCategory := '📋 Assigned to Me'
        else
            if CreatedByUser = UserId() then
                TaskCategory := '✏️ Assigned by Me';
    end;

    local procedure LoadTasks()
    var
        TodoRec: Record "To-do";
        UserRec: Record User;
    begin
        Rec.Reset();
        Rec.DeleteAll();

        // Load tasks Assigned to Me
        TodoRec.Reset();
        TodoRec.SetRange("User", UserId());
        TodoRec.SetRange(Status, TodoRec.Status::"Not Started");
        if TodoRec.FindSet() then
            repeat
                Rec := TodoRec;
                if Rec.Insert() then;
            until TodoRec.Next() = 0;

        // Load tasks Created by Me - resolve UserId to GUID first
        UserRec.SetRange("User Name", UserId());
        if UserRec.FindFirst() then begin
            TodoRec.Reset();
            TodoRec.SetRange(SystemCreatedBy, UserRec."User Security ID");
            TodoRec.SetRange(Status, TodoRec.Status::"Not Started");
            if TodoRec.FindSet() then
                repeat
                    Rec := TodoRec;
                    if Rec.Insert() then;
                until TodoRec.Next() = 0;
        end;
    end;

    local procedure OpenTaskCard()
    var
        TodoRec: Record "To-do";
        TaskCard: Page "Task Card";
    begin
        if TodoRec.Get(Rec."No.") then begin
            TaskCard.SetRecord(TodoRec);
            TaskCard.Run();
        end;
    end;

    var
        TaskCategory: Text;
        CreatedByUser: Text;
}
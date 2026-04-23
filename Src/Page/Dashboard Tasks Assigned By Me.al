page 50126 "Dashboard Tasks Assigned By Me"
{
    PageType = ListPart; // 🔥 FIXED
    Caption = 'Task Assigned by Me';
    SourceTable = "To-do";
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
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
                }
                field(Date; Rec.Date)
                {
                    ApplicationArea = All;
                }
                field(AssignedTo; Rec."User")
                {
                    ApplicationArea = All;
                    Caption = 'Assigned To';
                }
                field(AssignedBy; CreatedByUser)
                {
                    ApplicationArea = All;
                    Caption = 'Assigned By';
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
                trigger OnAction()
                begin
                    OpenTaskCard();
                end;
            }
            action(Refresh)
            {
                ApplicationArea = All;
                Caption = 'Refresh';
                Image = Refresh;
                trigger OnAction()
                begin
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        ApplyFilters();
    end;

    trigger OnAfterGetRecord()
    var
        UserRec: Record User;
    begin
        CreatedByUser := '';
        if UserRec.Get(Rec.SystemCreatedBy) then
            CreatedByUser := UserRec."User Name";
    end;

    procedure ApplyFilters()
    begin
        Rec.Reset();

        // 🔥 Correct filtering
        Rec.SetRange(SystemCreatedBy, UserSecurityId());
        Rec.SetRange(Status, Rec.Status::"Not Started");
    end;

    local procedure OpenTaskCard()
    var
        TodoRec: Record "To-do";
    begin
        if TodoRec.Get(Rec."No.") then
            Page.Run(Page::"Task Card", TodoRec);
    end;

    var
        CreatedByUser: Text;
}
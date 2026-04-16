page 50124 "Dashboard Tasks Assigned To Me"
{
    PageType = ListPart;
    Caption = 'Task Assigned to Me';
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
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    begin
                        OpenTaskCard();
                    end;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
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
                field("User"; Rec."User")
                {
                    ApplicationArea = All;
                    Caption = 'Assigned To';
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
        }
    }

    trigger OnOpenPage()
    begin
        ApplyFilters();
    end;

    procedure ApplyFilters()
    begin
        Rec.Reset();

        // ✅ Correct and reliable filter
        Rec.SetRange("User", UserId());

        // Optional: only open tasks
        Rec.SetRange(Status, Rec.Status::"Not Started");
    end;

    local procedure OpenTaskCard()
    var
        TodoRec: Record "To-do";
    begin
        if TodoRec.Get(Rec."No.") then
            Page.Run(Page::"Task Card", TodoRec);
    end;
}
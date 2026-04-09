pageextension 50131 "Create TaskExt" extends "Create Task"
{
    layout
    {
        addafter("Salesperson Code")
        {
            field(User; User)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the user name associated with this to-do.';
                TableRelation = User."User Name";
                ShowMandatory = true;

                trigger OnLookup(var Text: Text): Boolean
                var
                    UserRec: Record User;
                begin
                    if Page.RunModal(Page::"Users", UserRec) = Action::LookupOK then begin
                        Rec."User" := UserRec."User Name";
                        Rec.Modify(true);
                    end;
                end;
            }
        }

        modify(AllDayEvent)
        {
            Visible = false;
        }
        modify("Start Time")
        {
            Visible = false;
        }
        modify(Date)
        {
            Visible = false;
        }
        modify(Duration)
        {
            Visible = false;
        }
        modify("Ending Date")
        {
            Visible = false;
        }
        modify("Ending Time")
        {
            Visible = false;
        }
        modify(TeamTask)
        {
            Visible = false;
        }
        modify("Wizard Contact Name")
        {
            Visible = false;
        }
        // modify("Salesperson Code")
        // {
        //     Visible = false;
        // }
        modify("Team Code")
        {
            Visible = false;
        }
        modify("Wizard Campaign Description")
        {
            Visible = false;
        }
        modify("Wizard Opportunity Description")
        {
            Visible = false;
        }
        modify(RecurringOptions)
        {
            Visible = false;
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}
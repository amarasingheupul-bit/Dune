pageextension 50133 "Incoming Doc Delete Ext" extends "Incoming Document"
{
    actions
    {
        addafter(Release)
        {
            action(DeletePostedIncomingDoc)
            {
                ApplicationArea = All;
                Caption = 'Delete (incl. Posted)';
                ToolTip = 'Removes the posted reference and deletes this Incoming Document entry.';
                Image = Delete;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    DeleteIncomingDocCU: Codeunit "Delete Incoming Document";
                    IncomingDoc: Record "Incoming Document";
                begin
                    IncomingDoc := Rec;
                    DeleteIncomingDocCU.DeleteIncomingDoc(IncomingDoc);
                    CurrPage.Close();
                end;
            }
        }
    }
}
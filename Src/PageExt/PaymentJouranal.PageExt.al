pageextension 50119 "4HC Payment Journal" extends "Payment Journal"
{
    layout
    {
    }
    actions
    {
        addlast(processing)
        {
            group(IncomingDocGroup)
            {
                Caption = 'Incoming Document';
                Image = Document;

                action(AttachDocument)
                {
                    ApplicationArea = All;
                    Caption = 'Attach Document';
                    Image = Attach;
                    ToolTip = 'Attach an incoming document to this line.';

                    trigger OnAction()
                    var
                        IncomingDocument: Record "Incoming Document";
                    begin
                        Rec.Validate(
                            "Incoming Document Entry No.",
                            IncomingDocument.SelectIncomingDocument(
                                Rec."Incoming Document Entry No.",
                                Rec.RecordId()
                            )
                        );
                        CurrPage.SaveRecord();
                    end;
                }

                action(RemoveAttachment)
                {
                    ApplicationArea = All;
                    Caption = 'Remove Attachment';
                    Image = Delete;
                    ToolTip = 'Remove the attached incoming document from this line.';

                    trigger OnAction()
                    var
                        IncomingDocument: Record "Incoming Document";
                        EmptyRecordId: RecordId;
                    begin
                        if Rec."Incoming Document Entry No." = 0 then begin
                            Message('No incoming document is attached to this line.');
                            exit;
                        end;

                        if not IncomingDocument.Get(Rec."Incoming Document Entry No.") then begin
                            Message('Incoming document not found.');
                            exit;
                        end;

                        if IncomingDocument.Status <> IncomingDocument.Status::Posted then begin
                            Error('The attached document status must be Posted before it can be removed.');
                            exit;
                        end;

                        if not Confirm('Are you sure you want to remove the attached document from this line?', false) then
                            exit;

                        IncomingDocument.Posted := false;
                        IncomingDocument.Status := IncomingDocument.Status::Released;
                        Clear(EmptyRecordId);
                        IncomingDocument."Related Record ID" := EmptyRecordId;
                        IncomingDocument.Modify(false);

                        Rec."Incoming Document Entry No." := 0;
                        Rec.Modify(true);
                        CurrPage.Update(false);
                    end;
                }
            }
        }

        addlast("Category_Category9")
        {
            actionref(AttachDocument_Promoted; AttachDocument) { }
            actionref(RemoveAttachment_Promoted; RemoveAttachment) { }
        }
    }
}
codeunit 50108 "Delete Incoming Document"
{
    Permissions = tabledata "Incoming Document" = RIMD,
                  tabledata "Incoming Document Attachment" = RIMD;

    procedure DeleteIncomingDoc(var IncomingDocument: Record "Incoming Document")
    var
        IncomingDocAttachment: Record "Incoming Document Attachment";
        ConfirmMsg: Label 'This Incoming Document has Status = Posted. Deleting it will remove the link to the posted record and cannot be undone. Continue?';
    begin
        if not Confirm(ConfirmMsg, false) then
            exit;

        // Step 1: If posted, clear the Posted flag and related reference fields
        // so BC allows deletion (mimics "Remove Reference to Record")
        if IncomingDocument.Posted then begin
            IncomingDocument.Posted := false;
            IncomingDocument."Related Record ID" := IncomingDocument."Related Record ID"; // keep compile happy
            IncomingDocument."Document No." := '';
            IncomingDocument."Posting Date" := 0D;
            IncomingDocument.Status := IncomingDocument.Status::New;
            IncomingDocument.Modify();
        end;

        // Step 2: Delete all attachments for this entry
        IncomingDocAttachment.SetRange("Incoming Document Entry No.", IncomingDocument."Entry No.");
        if IncomingDocAttachment.FindSet() then
            IncomingDocAttachment.DeleteAll(true);

        // Step 3: Delete the record
        IncomingDocument.Delete(true);

        Message('Incoming Document deleted successfully.');
    end;
}
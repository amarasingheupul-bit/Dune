codeunit 50111 "Sales Inv. Excel Export"
{
    // Fires automatically every time a Sales Invoice is posted.
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', false, false)]
    local procedure OnAfterPostSalesDoc(var SalesHeader: Record "Sales Header"; SalesShptHdrNo: Code[20]; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20])
    var
        SalesInvHeader: Record "Sales Invoice Header";
    begin
        // Only react to Invoices (SalesInvHdrNo is blank for orders that only ship, credit memos, etc.)
        if SalesInvHdrNo = '' then
            exit;

        if not SalesInvHeader.Get(SalesInvHdrNo) then
            exit;

        ProcessInvoiceExport(SalesInvHeader);
    end;

    local procedure ProcessInvoiceExport(SalesInvHeader: Record "Sales Invoice Header")
    var
        Setup: Record "Sales Excel Export Setup";
        TempBlob: Codeunit "Temp Blob";
        FileName: Text;
        OutStr: OutStream;
        InStr: InStream;
    begin
        Setup := Setup.GetSetup();

        FileName := StrSubstNo('SalesInvoice_%1.xlsx', SalesInvHeader."No.");

        // Build the Excel file into a TempBlob (in-memory, works on SaaS - no file system needed)
        TempBlob.CreateOutStream(OutStr);
        BuildExcelStream(SalesInvHeader, OutStr);

        // Save as Document Attachment on the posted invoice (this is the SaaS-safe
        // stand-in for "save it in a folder" - each invoice keeps its own attachment)
        if Setup."Attach To Invoice" then begin
            TempBlob.CreateInStream(InStr);
            SaveAsDocumentAttachment(SalesInvHeader, InStr, FileName);
        end;

        // Email the Excel file to the configured recipient
        if Setup."Send Email On Post" and (Setup."Recipient Email" <> '') then begin
            TempBlob.CreateInStream(InStr);
            SendExcelByEmail(SalesInvHeader, InStr, FileName, Setup."Recipient Email");
        end;
    end;

    local procedure LogSendResult(Success: Boolean; Info: Text)
    var
        Setup: Record "Sales Excel Export Setup";
    begin
        if not Setup.Get('') then
            exit;
        Setup."Last Send Result" := Success;
        Setup."Last Send Info" := CopyStr(Info, 1, MaxStrLen(Setup."Last Send Info"));
        Setup."Last Send DateTime" := CurrentDateTime();
        Setup.Modify();
    end;

    local procedure BuildExcelStream(SalesInvHeader: Record "Sales Invoice Header"; var OutStr: OutStream)
    var
        SalesInvLine: Record "Sales Invoice Line";
        TempExcelBuffer: Record "Excel Buffer" temporary;
        SheetName: Label 'Invoice Lines';
    begin
        TempExcelBuffer.CreateNewBook(SheetName);

        // ----- Header row -----
        TempExcelBuffer.AddColumn('Document No.', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Line No.', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Item No.', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Description', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Quantity', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Number);
        TempExcelBuffer.AddColumn('Unit Price', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Number);
        TempExcelBuffer.AddColumn('Line Amount', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Number);

        // ----- Data rows -----
        SalesInvLine.SetRange("Document No.", SalesInvHeader."No.");
        if SalesInvLine.FindSet() then
            repeat
                TempExcelBuffer.NewRow();
                TempExcelBuffer.AddColumn(SalesInvLine."Document No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(SalesInvLine."Line No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                TempExcelBuffer.AddColumn(SalesInvLine."No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(SalesInvLine.Description, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(SalesInvLine.Quantity, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                TempExcelBuffer.AddColumn(SalesInvLine."Unit Price", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                TempExcelBuffer.AddColumn(SalesInvLine.Amount, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
            until SalesInvLine.Next() = 0;

        TempExcelBuffer.WriteSheet(SheetName, CompanyName(), UserId());
        TempExcelBuffer.CloseBook();

        // Writes the finished .xlsx binary content into the stream we pass in
        TempExcelBuffer.SaveToStream(OutStr, true);
    end;

    local procedure SaveAsDocumentAttachment(SalesInvHeader: Record "Sales Invoice Header"; var InStr: InStream; FileName: Text)
    var
        DocumentAttachment: Record "Document Attachment";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(SalesInvHeader);
        // Built-in helper: writes the stream as a new Document Attachment row
        // linked to this Sales Invoice Header record (Table ID + No.).
        DocumentAttachment.SaveAttachmentFromStream(InStr, RecRef, FileName, true);
    end;

    local procedure SendExcelByEmail(SalesInvHeader: Record "Sales Invoice Header"; var InStr: InStream; FileName: Text; RecipientEmail: Text)
    var
        EmailMessage: Codeunit "Email Message";
        Subject: Text;
        Body: Text;
        SendOk: Boolean;
    begin
        Subject := StrSubstNo('Sales Invoice %1 - Excel Export', SalesInvHeader."No.");
        Body := StrSubstNo('Hello,<br><br>Please find attached the Excel export for posted Sales Invoice <b>%1</b>, Customer <b>%2</b>.<br><br>Regards.', SalesInvHeader."No.", SalesInvHeader."Sell-to Customer Name");

        EmailMessage.Create(RecipientEmail, Subject, Body, true);
        EmailMessage.AddAttachment(FileName, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', InStr);

        // Wrapped in a TryFunction so a mail failure never rolls back the posting itself,
        // and so we can capture and log exactly what went wrong (see Setup page > Diagnostics).
        SendOk := TrySendEmail(EmailMessage);

        if SendOk then
            LogSendResult(true, 'Sent (or queued) successfully via Email.Send.')
        else
            LogSendResult(false, GetLastErrorText());

        ClearLastError();
    end;

    [TryFunction]
    local procedure TrySendEmail(var EmailMessage: Codeunit "Email Message")
    var
        Email: Codeunit Email;
    begin
        // NOTE: Email.Send does NOT guarantee immediate delivery. Depending on your
        // Email Account setup and any approval workflow enabled on Email Scenarios,
        // BC may place this in the "Email Outbox" pending approval rather than sending
        // it straight out. Check Email Outbox / Sent Emails in BC after a test run.
        Email.Send(EmailMessage, Enum::"Email Scenario"::Default);
    end;
}

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

    // ==========================================================================
    // Columns below mirror PEOPPOL_Sample.xlsx exactly, in the same order
    // (217 columns). Columns with no available data source are still emitted
    // as blank text cells so the layout matches 1:1 - each is marked
    // "// GAP - col N: <header>" in the data row below. See
    // Peppol_Field_Gap_Analysis.xlsx for the full reasoning per column.
    //
    // IMPORTANT DEPENDENCY: many columns reference custom fields on
    // SalesInvHeader (e.g. "Invoice Type Code", the 30 new *S365 fields,
    // "Sales Contract No.", "Job No. S365", etc.). These only exist on
    // SalesInvHeader if you ALSO add the same field ID/name/type to a
    // tableextension of "Sales Invoice Header" (and "Sales Invoice Line" for
    // the couple of line-level custom fields). Business Central's standard
    // posting routine copies matching custom fields automatically by field
    // ID as long as both table extensions define them - so no extra copy
    // code is needed, but the fields must exist on both tables or this won't
    // compile. If you haven't done that yet for the *S365 header fields, say
    // so and I'll give you that tableextension too.
    // ==========================================================================
    local procedure BuildExcelStream(SalesInvHeader: Record "Sales Invoice Header"; var OutStr: OutStream)
    var
        SalesInvLine: Record "Sales Invoice Line";
        CompanyInfo: Record "Company Information";
        TempExcelBuffer: Record "Excel Buffer" temporary;
        InvoiceType: Record "Dimension Value";
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        PaymentTerms: Record "Payment Terms";
        PaymentMethod: Record "Payment Method";
        SheetName: Label 'Invoice Lines';
        CurrCode: Code[10];
        HeaderAmount: Decimal;
        HeaderAmountInclVAT: Decimal;
        LineVATAmount: Decimal;
        NetPrice: Decimal;
        InvoiceTypeText: Text;
        ItemGTIN: Text;
        ItemCountryOfOrigin: Code[10];
        LineVATPct: Decimal;
        PaymentTermsDescription: Text;
        PaymentMethodDescription: Text;
    begin
        TempExcelBuffer.CreateNewBook(SheetName);
        CompanyInfo.Get();

        // Header totals - CalcFields needed because these are FlowFields on the posted header
        SalesInvHeader.CalcFields(Amount, "Amount Including VAT");
        HeaderAmount := SalesInvHeader.Amount;
        HeaderAmountInclVAT := SalesInvHeader."Amount Including VAT";

        CurrCode := SalesInvHeader."Currency Code";
        if CurrCode = '' then
            CurrCode := 'AED'; // adjust to your LCY / default currency if different

        InvoiceTypeText := SalesInvHeader."Invoice Type Code";
        if SalesInvHeader."Invoice Type Code" <> '' then
            if InvoiceType.Get('INVOICETYPECODE', SalesInvHeader."Invoice Type Code") then
                InvoiceTypeText := SalesInvHeader."Invoice Type Code" + ' - ' + InvoiceType.Name;

        PaymentTermsDescription := '';
        if PaymentTerms.Get(SalesInvHeader."Payment Terms Code") then
            PaymentTermsDescription := PaymentTerms.Description;

        PaymentMethodDescription := '';
        if PaymentMethod.Get(SalesInvHeader."Payment Method Code") then
            PaymentMethodDescription := PaymentMethod.Description;

        // ----- Header row (217 columns, same order as PEOPPOL_Sample.xlsx) -----
        TempExcelBuffer.AddColumn('Invoice number', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Invoice type code', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Invoice issue date', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Invoice Issue Time', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Is Free Trade Zone Supply', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Is Deemed Supply', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Is Profit Margin Scheme applicable', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Is Summary Invoice', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Is Continuous Supply', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Is Agent Billing applicable', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Is Supply through E-commerce', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Is Exports Supply', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Credit note reason code', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Frequency of billing', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Invoice note', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Preceding Invoice reference', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Preceding Invoice issue date', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Invoice currency code', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Tax accounting currency', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Currency exchange rate (If currency other than ''AED'')', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Invoicing period start date', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Invoicing period end date', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Seller name', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Seller trading name', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Seller electronic address', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Seller VAT identifier', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Seller Tax registration identifier', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Seller identifier', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Seller Identifier Scheme Identifier', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Seller legal registration identifier', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Seller legal registration identifier_Scheme identifier', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Seller legal registration identifier type', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Seller Authority name', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Seller Passport issuing country code', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Seller additional legal information', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Seller address line 1', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Seller address line 2', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Seller address line 3', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Seller city', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Seller post code', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Seller country subdivision', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Seller country code', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Seller contact name', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Seller contact telephone', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Seller contact email address', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Seller tax representative name', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Seller VAT representative tax identifier', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Tax representative address line 1', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Tax representative address line 2', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Tax representative address line 3', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Tax representative city', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Tax representative post code', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Tax representative country subdivision', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Tax representative country code', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Buyer name', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Buyer trading name', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Buyer electronic address', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Buyer VAT identifier', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Buyer identifier', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Buyer identifier_Scheme identifier', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Buyer legal registration identifier', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Buyer legal registration identifier_Scheme identifier', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Buyer legal registration identifier type', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Buyer Authority name', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Buyer Passport issuing country code', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Beneficiary ID', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Buyer address line 1', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Buyer address line 2', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Buyer address line 3', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Buyer city', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Buyer post code', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Buyer country subdivision', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Buyer country code', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Buyer contact name', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Buyer contact telephone', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Buyer contact email address', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Sales Order Reference', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Purchase order reference', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Buyer internal reference', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Buyer internal accounting reference', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Contract reference', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Contract value', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Project reference', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Receiving Advice Reference', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Despatch Advice Reference', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Tender Or Lot Reference', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Customs Reference Number', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Invoice Line Note', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Invoice Line Object Identifier', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Invoice Line Object Identifier Scheme Identifier', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Referenced Purchase Order Line Reference', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Invoice Line Purchase Order Reference', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Referenced Despatch Advice Line Reference', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Invoice Line Despatch Advice Reference', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Invoice Line Buyer Internal Accounting Reference', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Invoice Line Batch Number', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Seller Item Identifier', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Buyer Item Identifier', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Invoice Line Period Start Date', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Invoice Line Period End Date', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Invoice line identifier', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Item name', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Item description', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Item Type', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Type of goods or services', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Item classification identifier', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Item classification identifier scheme version identifier', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Service Accounting code', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Service Accounting code Scheme version identifier', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Item standard identifier', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Item standard identifier_Scheme identifier', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Item country of origin', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Invoiced quantity', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Invoiced quantity unit of measure code', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Item price base quantity', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Item Price Base Quantity Unit Of Measure Code', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Item gross price', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Item price discount', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Item net price', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Invoice Line Allowance Base Amount', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Invoice line allowance percentage', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Invoice line allowance amount', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Invoice line allowance reason code', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Invoice Line Allowance Reason', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Invoice Line Charge Base Amount', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Invoice line charge percentage', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Invoice line charge amount', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Invoice line charge reason code', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Invoice Line Charge Reason', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Invoice line net amount', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Tax inclusive pricing', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Invoiced item VAT category code', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Invoiced item VAT rate', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('VAT exemption reason text', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('VAT exemption reason code', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Sum of Invoice line net amount', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('VAT line amount in AED', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Document level allowance reason', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Document level allowance reason code', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Document Level Allowance Base Amount', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Document level allowance percentage', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Document level allowance amount', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Document level allowance VAT category code', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Document level allowance VAT rate', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Document Level Allowance VAT Exemption Reason Text', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Document level allowance VAT exemption reason code', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Document level charge reason', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Document level charge reason code', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Document Level Charge Base Amount', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Document level charge percentage', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Document level charge amount', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Document level charge VAT category code', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Document level charge VAT rate', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Document Level Charge VAT Exemption Reason Text', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Document level charge VAT exemption reason code', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Invoice total amount without Tax', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Invoice total Tax amount', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Invoice total amount with Tax', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Paid amount', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Rounding amount', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Amount due for payment', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Payment due date', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Payment terms note', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Payment terms amount', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Terms Payment Instructions ID', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Terms Installment Due Date', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Payment Instructions ID', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Payment means type code', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Payment means text', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Payment account identifier', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Payment account name', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Payment service provider identifier', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Payment Account Identifier Scheme Identifier', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Account Address Line 1', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Account Address Line 2', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Account City', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Account Post Code', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Account Country Subdivision', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Account Address Line 3', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Account Country Code', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Payee name', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Payee identifier', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Payee identifier_Scheme identifier', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Payee Legal Registration Identifier', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Payee Legal Registration Identifier Scheme Identifier', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Delivery Incoterms', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Deliver to party name', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Deliver to Party ID', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Deliver to location identifier', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Deliver to location identifier_Scheme identifier', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Actual delivery date', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Deliver to address line 1', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Deliver to address line 2', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Deliver to address line 3', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Deliver to city', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Deliver to post code', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Deliver to country subdivision', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Deliver to country code', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('VAT Tax point date', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Principle ID', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Invoiced Object Identifier', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Invoiced Object Identifier Scheme Identifier', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Remittance Information', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Remittance Information Scheme Identifier', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Payment Card Primary Account Number', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Payment Card Holder Name', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Mandate Reference Identifier', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Bank Assigned Creditor Identifier', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Debited Account Identifier', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Supporting Document Reference', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Supporting Document Description', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Attached Document', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Attached Document Mime Code', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Attached Document Filename', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('External Document Location', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Item Attribute Name', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Item Attribute Value', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);

        // ----- Data rows -----
        SalesInvLine.SetRange("Document No.", SalesInvHeader."No.");
        if SalesInvLine.FindSet() then
            repeat
                // NOTE: "Amount Including VAT" on Sales Invoice Line is a stored field
                // (posted lines are immutable snapshots), so no CalcFields is needed here -
                // unlike the header's FlowFields, which do require CalcFields below.
                LineVATAmount := SalesInvLine."Amount Including VAT" - SalesInvLine.Amount;
                if SalesInvLine.Quantity <> 0 then
                    NetPrice := SalesInvLine.Amount / SalesInvLine.Quantity
                else
                    NetPrice := SalesInvLine."Unit Price";

                // Item-level lookups (blank if the line isn't a real Item, e.g. G/L Account lines)
                ItemGTIN := '';
                ItemCountryOfOrigin := '';
                if (SalesInvLine.Type = SalesInvLine.Type::Item) and Item.Get(SalesInvLine."No.") then begin
                    ItemGTIN := Item.GTIN;
                    ItemCountryOfOrigin := Item."Country/Region of Origin Code";
                end;

                // VAT % lookup for this line's posting group combo
                LineVATPct := 0;
                if VATPostingSetup.Get(SalesInvLine."VAT Bus. Posting Group", SalesInvLine."VAT Prod. Posting Group") then
                    LineVATPct := VATPostingSetup."VAT %";

                TempExcelBuffer.NewRow();

                TempExcelBuffer.AddColumn(SalesInvHeader."No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(InvoiceTypeText, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(SalesInvHeader."Posting Date", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Date);
                TempExcelBuffer.AddColumn(SalesInvHeader.SystemCreatedAt, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Time);
                TempExcelBuffer.AddColumn(Format(SalesInvHeader."Is Free Trade Zone Supply"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(Format(SalesInvHeader."Is Deemed Supply"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(Format(SalesInvHeader."Is Profit Margin Scheme applicable"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(Format(SalesInvHeader."Is Summary Invoice"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(Format(SalesInvHeader."Is Continuous Supply"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(Format(SalesInvHeader."Is Agent Billing applicable"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(Format(SalesInvHeader."Is Supply through E-commerce"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(Format(SalesInvHeader."Is Exports Supply"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(SalesInvHeader."Credit Note Reason Code S365", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(SalesInvHeader."Frequency of Billing S365", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(SalesInvHeader."Invoice Note S365", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(SalesInvHeader."Preceding Invoice Ref. S365", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(SalesInvHeader."Preceding Invoice Date S365", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Date);
                TempExcelBuffer.AddColumn(CurrCode, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(SalesInvHeader."Tax Accounting Currency S365", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(Format(SalesInvHeader."Currency Factor"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(SalesInvHeader."Invoicing Period Start S365", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Date);
                TempExcelBuffer.AddColumn(SalesInvHeader."Invoicing Period End S365", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Date);
                TempExcelBuffer.AddColumn(CompanyInfo.Name, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 24: Seller trading name
                TempExcelBuffer.AddColumn(CompanyInfo."E-Mail", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(CompanyInfo."VAT Registration No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 27: Seller Tax registration identifier
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 28: Seller identifier
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 29: Seller Identifier Scheme Identifier
                TempExcelBuffer.AddColumn(CompanyInfo."VAT Registration No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn('TRN', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn('TRN', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 33: Seller Authority name
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 34: Seller Passport issuing country code
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 35: Seller additional legal information
                TempExcelBuffer.AddColumn(CompanyInfo.Address, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(CompanyInfo."Address 2", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 38: Seller address line 3
                TempExcelBuffer.AddColumn(CompanyInfo.City, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(CompanyInfo."Post Code", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(CompanyInfo.County, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(CompanyInfo."Country/Region Code", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 43: Seller contact name
                TempExcelBuffer.AddColumn(CompanyInfo."Phone No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(CompanyInfo."E-Mail", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 46: Seller tax representative name
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 47: Seller VAT representative tax identifier
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 48: Tax representative address line 1
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 49: Tax representative address line 2
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 50: Tax representative address line 3
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 51: Tax representative city
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 52: Tax representative post code
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 53: Tax representative country subdivision
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 54: Tax representative country code
                TempExcelBuffer.AddColumn(SalesInvHeader."Sell-to Customer Name", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 56: Buyer trading name
                TempExcelBuffer.AddColumn(SalesInvHeader."Sell-to E-Mail", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(SalesInvHeader."VAT Registration No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 59: Buyer identifier
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 60: Buyer identifier_Scheme identifier
                TempExcelBuffer.AddColumn(SalesInvHeader."VAT Registration No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 62: Buyer legal registration identifier_Scheme identifier
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 63: Buyer legal registration identifier type
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 64: Buyer Authority name
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 65: Buyer Passport issuing country code
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 66: Beneficiary ID
                TempExcelBuffer.AddColumn(SalesInvHeader."Sell-to Address", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(SalesInvHeader."Sell-to Address 2", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 69: Buyer address line 3
                TempExcelBuffer.AddColumn(SalesInvHeader."Sell-to City", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(SalesInvHeader."Sell-to Post Code", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(SalesInvHeader."Sell-to County", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(SalesInvHeader."Sell-to Country/Region Code", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(SalesInvHeader."Sell-to Contact", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 75: Buyer contact telephone
                TempExcelBuffer.AddColumn(SalesInvHeader."Sell-to E-Mail", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(SalesInvHeader."Order No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(SalesInvHeader."External Document No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(SalesInvHeader."Your Reference", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(SalesInvHeader."Buyer Int. Acct. Ref. S365", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(SalesInvHeader."Sales Contract No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(Format(SalesInvHeader."Contract Value S365"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(SalesInvHeader."Job No. S365", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(SalesInvHeader."Receiving Advice Ref. S365", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(SalesInvHeader."Despatch Advice Ref. S365", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(SalesInvHeader."Tender Or Lot Reference S365", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(SalesInvHeader."Customs Reference No. S365", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 88: Invoice Line Note
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 89: Invoice Line Object Identifier
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 90: Invoice Line Object Identifier Scheme Identifier
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 91: Referenced Purchase Order Line Reference
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 92: Invoice Line Purchase Order Reference
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 93: Referenced Despatch Advice Line Reference
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 94: Invoice Line Despatch Advice Reference
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 95: Invoice Line Buyer Internal Accounting Reference
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 96: Invoice Line Batch Number
                TempExcelBuffer.AddColumn(SalesInvLine."No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 98: Buyer Item Identifier
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 99: Invoice Line Period Start Date
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 100: Invoice Line Period End Date
                TempExcelBuffer.AddColumn(Format(SalesInvLine."Line No."), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(SalesInvLine.Description, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(SalesInvLine.Description, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(Format(SalesInvLine.Type), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 105: Type of goods or services
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 106: Item classification identifier
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 107: Item classification identifier scheme version identifier
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 108: Service Accounting code
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 109: Service Accounting code Scheme version identifier
                TempExcelBuffer.AddColumn(ItemGTIN, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 111: Item standard identifier_Scheme identifier
                TempExcelBuffer.AddColumn(ItemCountryOfOrigin, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(Format(SalesInvLine.Quantity), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(Format(SalesInvLine."Unit of Measure Code"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 115: Item price base quantity
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 116: Item Price Base Quantity Unit Of Measure Code
                TempExcelBuffer.AddColumn(Format(SalesInvLine."Unit Price"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(Format(SalesInvLine."Line Discount %"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(Format(NetPrice), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 120: Invoice Line Allowance Base Amount
                TempExcelBuffer.AddColumn(Format(SalesInvLine."Line Discount %"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(Format(SalesInvLine."Line Discount Amount"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 123: Invoice line allowance reason code
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 124: Invoice Line Allowance Reason
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 125: Invoice Line Charge Base Amount
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 126: Invoice line charge percentage
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 127: Invoice line charge amount
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 128: Invoice line charge reason code
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 129: Invoice Line Charge Reason
                TempExcelBuffer.AddColumn(Format(SalesInvLine.Amount), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 131: Tax inclusive pricing
                TempExcelBuffer.AddColumn(Format(SalesInvLine."VAT Prod. Posting Group"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(Format(LineVATPct) + '%', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 134: VAT exemption reason text
                TempExcelBuffer.AddColumn(SalesInvHeader."Reasons for exemption from tax", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(Format(HeaderAmount), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(Format(LineVATAmount), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 138: Document level allowance reason
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 139: Document level allowance reason code
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 140: Document Level Allowance Base Amount
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 141: Document level allowance percentage
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 142: Document level allowance amount
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 143: Document level allowance VAT category code
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 144: Document level allowance VAT rate
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 145: Document Level Allowance VAT Exemption Reason Text
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 146: Document level allowance VAT exemption reason code
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 147: Document level charge reason
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 148: Document level charge reason code
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 149: Document Level Charge Base Amount
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 150: Document level charge percentage
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 151: Document level charge amount
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 152: Document level charge VAT category code
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 153: Document level charge VAT rate
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 154: Document Level Charge VAT Exemption Reason Text
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 155: Document level charge VAT exemption reason code
                TempExcelBuffer.AddColumn(Format(HeaderAmount), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(Format(HeaderAmountInclVAT - HeaderAmount), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(Format(HeaderAmountInclVAT), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 159: Paid amount
                TempExcelBuffer.AddColumn(Format(SalesInvHeader."Rounding Amount S365"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(Format(HeaderAmountInclVAT), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(SalesInvHeader."Due Date", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Date);
                TempExcelBuffer.AddColumn(PaymentTermsDescription, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(Format(SalesInvHeader."Payment Terms Amount S365"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(SalesInvHeader."Terms Payment Instr. ID S365", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(SalesInvHeader."Terms Installment Due S365", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Date);
                TempExcelBuffer.AddColumn(SalesInvHeader."Payment Instructions ID S365", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(Format(SalesInvHeader."Payment Method Code"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(PaymentMethodDescription, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(SalesInvHeader."Bank Details", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 171: Payment account name
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 172: Payment service provider identifier
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 173: Payment Account Identifier Scheme Identifier
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 174: Account Address Line 1
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 175: Account Address Line 2
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 176: Account City
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 177: Account Post Code
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 178: Account Country Subdivision
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 179: Account Address Line 3
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 180: Account Country Code
                TempExcelBuffer.AddColumn(CompanyInfo.Name, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 182: Payee identifier
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 183: Payee identifier_Scheme identifier
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 184: Payee Legal Registration Identifier
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 185: Payee Legal Registration Identifier Scheme Identifier
                TempExcelBuffer.AddColumn(SalesInvHeader."Delivery Incoterms S365", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(SalesInvHeader."Ship-to Name", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 188: Deliver to Party ID
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 189: Deliver to location identifier
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 190: Deliver to location identifier_Scheme identifier
                TempExcelBuffer.AddColumn(SalesInvHeader."Shipment Date", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Date);
                TempExcelBuffer.AddColumn(SalesInvHeader."Ship-to Address", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(SalesInvHeader."Ship-to Address 2", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 194: Deliver to address line 3
                TempExcelBuffer.AddColumn(SalesInvHeader."Ship-to City", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(SalesInvHeader."Ship-to Post Code", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(SalesInvHeader."Ship-to County", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(SalesInvHeader."Ship-to Country/Region Code", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(SalesInvHeader."VAT Tax Point Date S365", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Date);
                TempExcelBuffer.AddColumn(SalesInvHeader."Principle ID S365", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(SalesInvHeader."Invoiced Object ID S365", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(SalesInvHeader."Invoiced Object ID Scheme S365", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(SalesInvHeader."Remittance Information S365", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(SalesInvHeader."Remittance Info Scheme S365", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 205: Payment Card Primary Account Number
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 206: Payment Card Holder Name
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 207: Mandate Reference Identifier
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 208: Bank Assigned Creditor Identifier
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 209: Debited Account Identifier
                TempExcelBuffer.AddColumn(SalesInvHeader."Supporting Doc. Ref. S365", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(SalesInvHeader."Supporting Doc. Desc. S365", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 212: Attached Document
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 213: Attached Document Mime Code
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 214: Attached Document Filename
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 215: External Document Location
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 216: Item Attribute Name
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text); // GAP - col 217: Item Attribute Value
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

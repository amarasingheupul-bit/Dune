pageextension 50119 "4HC Payment Journal" extends "Payment Journal"
{
    layout
    {
    }
    actions
    {
        addlast("&Line")
        {
            action("Payment Voucher")
            {
                ApplicationArea = All;
                Caption = 'Payment Voucher';
                Image = Print;
                trigger OnAction()
                var
                    GenJnlLine: Record "Gen. Journal Line";
                begin
                    GenJnlLine.SetRange("Journal Template Name", Rec."Journal Template Name");
                    GenJnlLine.SetRange("Journal Batch Name", Rec."Journal Batch Name");
                    GenJnlLine.SetRange("Document No.", Rec."Document No.");
                    Report.Run(Report::"Payment voucher", true, true, GenJnlLine);
                end;
            }
        }

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
                action(PrintReceiptVoucher)
                {
                    ApplicationArea = All;
                    Caption = 'Receipt Voucher';
                    Image = Print;
                    ToolTip = 'Print the Receipt Voucher for the selected payment journal line.';

                    trigger OnAction()
                    var
                        GenJournalLine: Record "Gen. Journal Line";
                        ReceiptVoucher: Report "Receipt Voucher";
                    begin
                        GenJournalLine.SetRange("Journal Template Name", Rec."Journal Template Name");
                        GenJournalLine.SetRange("Journal Batch Name", Rec."Journal Batch Name");
                        GenJournalLine.SetRange("Line No.", Rec."Line No.");
                        ReceiptVoucher.SetTableView(GenJournalLine);
                        ReceiptVoucher.Run();
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

            // // ── Receipt Voucher Print ──────────────────────────────────────────
            // group(PrintGroup)
            // {
            //     Caption = 'Print';
            //     Image = Print;


            // }
        }

        // ── Promoted refs (NoPromotedActionProperties / actionref syntax) ──────
        addlast("Category_Category10")
        {
            actionref(AttachDocument_Promoted; AttachDocument) { }
            actionref(RemoveAttachment_Promoted; RemoveAttachment) { }

        }

        addlast("Category_Report")
        {
            actionref(PaymentVoucher_Promoted; "Payment Voucher") { }
            actionref(PrintReceiptVoucher_Promoted; PrintReceiptVoucher) { }
        }
    }
}

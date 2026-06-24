pageextension 50134 "FA GL Journal Approval Ext" extends "Fixed Asset G/L Journal"
{
    actions
    {
        addafter("P&ost")
        {
            group(Approval)
            {
                Caption = 'Approval';
                Image = SendApprovalRequest;

                action(SendApprovalRequest)
                {
                    ApplicationArea = All;
                    Caption = 'Send Approval Request';
                    Image = SendApprovalRequest;
                    ToolTip = 'Send the journal batch for approval.';
                    Enabled = NOT OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.TrySendJournalBatchApprovalRequest(Rec);
                    end;
                }

                action(CancelApprovalRequest)
                {
                    ApplicationArea = All;
                    Caption = 'Cancel Approval Request';
                    Image = Cancel;
                    ToolTip = 'Cancel the approval request for this journal batch.';
                    Enabled = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.TryCancelJournalBatchApprovalRequest(Rec);
                    end;
                }
            }

        }
    }

    var
        OpenApprovalEntriesExistForCurrUser: Boolean;

    trigger OnOpenPage()
    begin
        SetControlAppearance();
    end;

    trigger OnAfterGetRecord()
    begin
        SetControlAppearance();
    end;

    local procedure SetControlAppearance()
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
    begin
        OpenApprovalEntriesExistForCurrUser :=
            ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(Rec.RecordId);
    end;
}
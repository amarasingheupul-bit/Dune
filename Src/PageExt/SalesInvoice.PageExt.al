pageextension 50128 "4HC Sales Invoice" extends "Sales Invoice"
{
    layout
    {
        addlast(General)
        {
            field("Job No. S365"; Rec."Job No. S365")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the Job No.';

                trigger OnAssistEdit()
                var
                    RecJob: Record Job;
                    JobCardPageID: Integer;
                begin
                    JobCardPageID := PAGE::"Job Card";
                    if RecJob.Get(Rec."Job No. S365") then PAGE.RUN(JobCardPageID, RecJob);
                end;
            }
            field("Quote Type S365"; Rec."Quote Type S365")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Quote Type field.';
                TableRelation = "Quote Type S365"."Code S365";
            }
        }

        addafter(General)
        {
            group("New Fields S365")
            {
                ShowCaption = true;
                Caption = 'Additional Order Details';
                Visible = false;

                field("Change Reason S365"; Rec."Change Reason S365")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Change Reason field.';
                }
                field("Original Quote No. S365"; Rec."Original Quote No. S365")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Original Quote No. field.';
                }
                field("Quote Status S365"; Rec."Quote Status S365")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quote Status field.';
                }
                field("Shipment Method Code S365"; Rec."Shipment Method Code")
                {
                    Caption = 'Incoterms';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Incoterms field.';
                    Visible = false;
                }
                field("End User/ Main Customer"; Rec."End User/ Main Customer")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the End User field.', Comment = '%';
                }
                field("Supplier to Services"; Rec."Supplier to Services")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Supplier to Services field.', Comment = '%';
                }

                field("Sales Derector/ Area Director"; Rec."Sales Director/ Area Director")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Derector/ Area Director field.', Comment = '%';
                }
                field("Sales/ Area Director Name"; Rec."Sales/ Area Director Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales/ Area Director Name field.', Comment = '%';
                    Editable = false;
                }
                field("Sales Secretary No."; Rec."Sales Secretary No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Secretary No. field.', Comment = '%';
                }
                field("Sales Secretary Name"; Rec."Sales Secretary Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Secretary Name field.', Comment = '%';
                }
                field("Yard No."; Rec."Yard No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Yard No. field.', Comment = '%';
                }
                field("Milestones Dates and Amounts"; Rec."Milestones Dates and Amounts")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Milestones with Dates and Amounts field.', Comment = '%';
                }
                field("Sales Area"; Rec."Sales Area")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Area field.', Comment = '%';
                }
                field("4HC Type"; Rec."4HC Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field.', Comment = '%';
                }
                field("COST Reference"; Rec."COST Reference")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the COST Reference field.', Comment = '%';
                }
                field("Cost Center"; Rec."Cost Center")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cost Center field.', Comment = '%';
                }
                field(Budget; Rec.Budget)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Budget field.', Comment = '%';
                }
                field("G/L Account"; Rec."G/L Account")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the G/L Account field.', Comment = '%';
                }
                field("Incoming PO"; Rec."Incoming PO")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Incoming PO field.', Comment = '%';
                }
                field("OPCO Customer"; Rec."OPCO Customer")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the OPCO Customer field.', Comment = '%';
                }
                field("Sales Manager"; Rec."Sales Manager")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Manager field.', Comment = '%';
                }
            }
        }
        // addlast(General)
        // {
        //     field("Invoice Type Code"; Rec."Invoice Type Code")
        //     {
        //         ApplicationArea = All;
        //         ToolTip = 'Specifies the value of the Invoice Type Code field.';
        //     }
        //     field("Registration identifier type"; Rec."Registration identifier type")
        //     {
        //         ApplicationArea = All;
        //         ToolTip = 'Specifies the value of the Registration identifier type field.';

        //     }
        //     field("Country Sub-division"; Rec."Country Sub-division")
        //     {
        //         ApplicationArea = All;
        //         ToolTip = 'Specifies the value of the Country Sub-division field.';

        //     }
        //     field("Allowance/Charge Identity code"; Rec."Allowance/Charge Identity code")
        //     {
        //         ApplicationArea = All;
        //         ToolTip = 'Specifies the value of the Allowance/Charge Identity code field.';

        //     }
        //     field("AE VAT category codes"; Rec."AE VAT category codes")
        //     {
        //         ApplicationArea = All;
        //         ToolTip = 'Specifies the value of the AE VAT category codes field.';

        //     }
        //     field("Reasons for exemption from tax"; Rec."Reasons for exemption from tax")
        //     {
        //         ApplicationArea = All;
        //         ToolTip = 'Specifies the value of the Reasons for exemption from tax field.';

        //     }
        // }
        addafter(General)
        {
            group("Peppol E-Invoice Fields S365")
            {
                ShowCaption = true;
                Caption = 'E-Invoice (Peppol) Additional Details';
                Visible = true;
                field("Invoice Type Code"; Rec."Invoice Type Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Invoice Type Code field.';
                }
                field("Is Free Trade Zone Supply"; Rec."Is Free Trade Zone Supply")
                {
                    ApplicationArea = All;
                }
                field("Is Deemed Supply"; Rec."Is Deemed Supply")
                {
                    ApplicationArea = All;
                }
                field("Is Profit Margin Scheme applicable"; Rec."Is Profit Margin Scheme applicable")
                {
                    ApplicationArea = All;
                }
                field("Is Summary Invoice"; Rec."Is Summary Invoice")
                {
                    ApplicationArea = All;
                }
                field("Is Continuous Supply"; Rec."Is Continuous Supply")
                {
                    ApplicationArea = All;
                }
                field("Is Agent Billing applicable"; Rec."Is Agent Billing applicable")
                {
                    ApplicationArea = All;
                }
                field("Is Supply through E-commerce"; Rec."Is Supply through E-commerce")
                {
                    ApplicationArea = All;
                }
                field("Is Exports Supply"; Rec."Is Exports Supply")
                {
                    ApplicationArea = All;
                }

                field("Registration identifier type"; Rec."Registration identifier type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Registration identifier type field.';

                }
                field("Country Sub-division"; Rec."Country Sub-division")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Country Sub-division field.';

                }
                field("Allowance/Charge Identity code"; Rec."Allowance/Charge Identity code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Allowance/Charge Identity code field.';

                }
                field("AE VAT category codes"; Rec."AE VAT category codes")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the AE VAT category codes field.';

                }
                field("Reasons for exemption from tax"; Rec."Reasons for exemption from tax")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reasons for exemption from tax field.';

                }
                field("Invoice Issue Time S365"; Rec.SystemCreatedAt)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Invoice Issue Time field.';
                }
                field("Credit Note Reason Code S365"; Rec."Credit Note Reason Code S365")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Credit Note Reason Code field.';
                }
                field("Frequency of Billing S365"; Rec."Frequency of Billing S365")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Frequency of Billing field.';
                }
                field("Invoice Note S365"; Rec."Invoice Note S365")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Invoice Note field.';
                }
                field("Preceding Invoice Ref. S365"; Rec."Preceding Invoice Ref. S365")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Preceding Invoice Reference field.';
                }
                field("Preceding Invoice Date S365"; Rec."Preceding Invoice Date S365")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Preceding Invoice Issue Date field.';
                }
                field("Tax Accounting Currency S365"; Rec."Tax Accounting Currency S365")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tax Accounting Currency field.';
                }
                field("Invoicing Period Start S365"; Rec."Invoicing Period Start S365")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Invoicing Period Start Date field.';
                }
                field("Invoicing Period End S365"; Rec."Invoicing Period End S365")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Invoicing Period End Date field.';
                }
                field("Sales Order Reference S365"; Rec."Sales Order Reference S365")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Order Reference field.';
                }
                field("Buyer Int. Acct. Ref. S365"; Rec."Buyer Int. Acct. Ref. S365")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Buyer Internal Accounting Reference field.';
                }
                field("Contract Value S365"; Rec."Contract Value S365")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Contract Value field.';
                }
                field("Receiving Advice Ref. S365"; Rec."Receiving Advice Ref. S365")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Receiving Advice Reference field.';
                }
                field("Despatch Advice Ref. S365"; Rec."Despatch Advice Ref. S365")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Despatch Advice Reference field.';
                }
                field("Tender Or Lot Reference S365"; Rec."Tender Or Lot Reference S365")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tender Or Lot Reference field.';
                }
                field("Customs Reference No. S365"; Rec."Customs Reference No. S365")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customs Reference Number field.';
                }
                field("VAT Exemption Reason S365"; Rec."VAT Exemption Reason S365")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the VAT Exemption Reason Text field.';
                }
                field("Rounding Amount S365"; Rec."Rounding Amount S365")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rounding Amount field.';
                }
                field("Payment Terms Amount S365"; Rec."Payment Terms Amount S365")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Payment Terms Amount field.';
                }
                field("Terms Payment Instr. ID S365"; Rec."Terms Payment Instr. ID S365")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Terms Payment Instructions ID field.';
                }
                field("Terms Installment Due S365"; Rec."Terms Installment Due S365")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Terms Installment Due Date field.';
                }
                field("Payment Instructions ID S365"; Rec."Payment Instructions ID S365")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Payment Instructions ID field.';
                }
                field("Delivery Incoterms S365"; Rec."Delivery Incoterms S365")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Delivery Incoterms field.';
                }
                field("VAT Tax Point Date S365"; Rec."VAT Tax Point Date S365")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the VAT Tax Point Date field.';
                }
                field("Principle ID S365"; Rec."Principle ID S365")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Principle ID field.';
                }
                field("Invoiced Object ID S365"; Rec."Invoiced Object ID S365")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Invoiced Object Identifier field.';
                }
                field("Invoiced Object ID Scheme S365"; Rec."Invoiced Object ID Scheme S365")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Invoiced Object Identifier Scheme Identifier field.';
                }
                field("Remittance Information S365"; Rec."Remittance Information S365")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Remittance Information field.';
                }
                field("Remittance Info Scheme S365"; Rec."Remittance Info Scheme S365")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Remittance Information Scheme Identifier field.';
                }
                field("Supporting Doc. Ref. S365"; Rec."Supporting Doc. Ref. S365")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Supporting Document Reference field.';
                }
                field("Supporting Doc. Desc. S365"; Rec."Supporting Doc. Desc. S365")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Supporting Document Description field.';
                }
            }
        }
    }
    actions
    {
        addlast("Request Approval")
        {
            group(CustomApproval)
            {
                action(in)
                {
                    ApplicationArea = All;
                    Caption = 'In';
                    Image = Info;
                    ToolTip = 'In';
                    trigger OnAction()
                    begin
                        Rec.Status := Rec.Status::Open;
                        //Rec."Approval Status" := Rec."Approval Status"::Open;
                        Rec.Modify();
                    end;
                }
                action(out)
                {
                    ApplicationArea = All;
                    Caption = 'Out';
                    Image = Info;
                    ToolTip = 'Out';
                    trigger OnAction()
                    begin
                        Rec.Status := Rec.Status::Released;
                        //Rec."Approval Status" := Rec."Approval Status"::Released;
                        Rec.Modify();
                    end;
                }
            }
        }
        modify(SendApprovalRequest)
        {
            visible = true;
        }
        modify(CancelApprovalRequest)
        {
            visible = true;
        }
    }
}

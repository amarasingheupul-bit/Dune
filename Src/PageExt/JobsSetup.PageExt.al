pageextension 50130 "4HC Jobs Setup" extends "Jobs Setup"
{
    layout
    {
        addafter(General)
        {
            group("4HC Jobs Setup")
            {
                Caption = 'Projec Summary Accounts';
              
                field("Advance Acc. No."; Rec."Advance Acc. No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Advance Account No. field.';
                }
                field("Cost of Sales Acc. No."; Rec."Cost of Sales Acc. No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cost of Sales Account No. field.';
                }
                field("Revenue Acc. No."; Rec."Revenue Acc. No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Revenue Account No. field.';
                }
                field("WIP Acc. No."; Rec."WIP Acc. No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the WIP Account No. field.';
                }
                field("Interim Acc. No."; Rec."Interim Acc. No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Interim Account No. field.';
                }
            }
        }
    }
}
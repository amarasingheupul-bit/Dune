tableextension 50118 "4HC Jobs Setup" extends "Jobs Setup"
{
    fields
    {
        field(50100; "Advance Acc. No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account"."No.";
            Caption = 'Advance Account No.';
        }
        field(50101; "Revenue Acc. No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account"."No.";
            Caption = 'Revenue Account No.';
        }
        field(50102; "Cost of Sales Acc. No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account"."No.";
            Caption = 'Cost of Sales Account No.';
        }
        field(50103; "WIP Acc. No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account"."No.";
            Caption = 'WIP Account No.';
        }
        field(50104; "Interim Acc. No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account"."No.";
            Caption = 'Interim Account No.';
        }
    }
}
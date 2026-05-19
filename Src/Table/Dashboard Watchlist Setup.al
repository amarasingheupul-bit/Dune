table 50109 "Dashboard Watchlist Setup"
{
    Caption = 'Dashboard Watchlist Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; "G/L Account No."; Code[20])
        {
            Caption = 'G/L Account No.';
            TableRelation = "G/L Account"."No." where("Account Type" = const(Posting));
        }
        field(4; "G/L Account Name"; Text[100])
        {
            Caption = 'G/L Account Name';
            FieldClass = FlowField;
            CalcFormula = lookup("G/L Account".Name where("No." = field("G/L Account No.")));
            Editable = false;
        }
    }

    keys
    {
        key(PK; "User ID", "Line No.")
        {
            Clustered = true;
        }
        key(K2; "User ID", "G/L Account No.") { }
    }
}
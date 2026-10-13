tableextension 50111 "4HC Customer" extends Customer
{
    fields
    {
        field(50100; "REF SAP ID"; Code[20])
        {
            Caption = 'REF SAP ID';
            DataClassification = CustomerContent;
        }
        field(50101; "REF IFS ID"; Code[20])
        {
            Caption = 'REF IFS ID';
            DataClassification = CustomerContent;
        }
        field(50102; "Creation Date"; Date)
        {
            Caption = 'Creation Date';
            DataClassification = SystemMetadata;
        }
        field(50103; "DUNS No."; Code[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'DUNS No.';
        }
        field(50104; "Country Sub-division"; Code[20])
        {
            Caption = 'Country Sub-division';
            TableRelation = "Dimension Value".Code
                WHERE("Dimension Code" = CONST('COUNTRYSUBDIV'));
        }
        field(50105; "PEPPOL ID"; code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'PEPPOL ID';
        }
    }
    trigger OnInsert()
    begin
        "Creation Date" := Today();
    end;
}
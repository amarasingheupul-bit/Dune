tableextension 50112 "4HC Company Information" extends "Company Information"
{
    fields
    {
        field(50100; "Report Footer"; Blob)
        {
            DataClassification = ToBeClassified;
            Caption = 'Report Footer';
            Subtype = Bitmap;
        }
        field(50101; "TIN Number"; code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'TIN Number';
        }
        field(50102; "PEPPOL ID"; code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'PEPPOL ID';
        }
        field(50103; "Country Sub-division"; Code[20])
        {
            Caption = 'Country Sub-division';
            TableRelation = "Dimension Value".Code
                WHERE("Dimension Code" = CONST('COUNTRYSUBDIV'));
        }
    }
}
namespace Dune.Visualization;

table 50110 "Dune RC Banner Setup"
{
    Caption = 'Dune RC Banner Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "Banner Image"; Media)
        {
            Caption = 'Banner Image';
        }
        field(3; "Mime Type"; Text[100])
        {
            Caption = 'Mime Type';
        }
    }
    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}

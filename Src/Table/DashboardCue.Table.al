table 50104 "Dashboard Cue"
{
    DataClassification = CustomerContent;
    Caption = 'Dashboard Cue';

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(2; "Invoices Owed"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Invoices owed to you';
            AutoFormatType = 1;
        }
        field(3; "Bills To Pay"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Bills to pay';
            AutoFormatType = 1;
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

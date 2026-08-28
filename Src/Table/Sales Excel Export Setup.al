table 50111 "Sales Excel Export Setup"
{
    Caption = 'Sales Invoice Excel Export Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }
        field(2; "Recipient Email"; Text[250])
        {
            Caption = 'Recipient Email Address';
            DataClassification = CustomerContent;
            // The email that every posted Sales Invoice Excel export is sent to.
            // Change this to a lookup on Customer/Salesperson email if you need
            // a different recipient per invoice instead of one fixed address.
        }
        field(3; "Send Email On Post"; Boolean)
        {
            Caption = 'Send Email On Post';
            DataClassification = SystemMetadata;
            InitValue = true;
        }
        field(4; "Attach To Invoice"; Boolean)
        {
            Caption = 'Attach Excel To Posted Invoice';
            DataClassification = SystemMetadata;
            InitValue = true;
        }
        field(5; "Last Send Result"; Boolean)
        {
            Caption = 'Last Send Succeeded';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(6; "Last Send Info"; Text[250])
        {
            Caption = 'Last Send Info';
            DataClassification = SystemMetadata;
            Editable = false;
            // Shows either "Queued to Outbox" or the actual error text from the last attempt.
        }
        field(7; "Last Send DateTime"; DateTime)
        {
            Caption = 'Last Send Attempt';
            DataClassification = SystemMetadata;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    procedure GetSetup(): Record "Sales Excel Export Setup"
    var
        Setup: Record "Sales Excel Export Setup";
    begin
        if not Setup.Get('') then begin
            Setup.Init();
            Setup."Primary Key" := '';
            Setup.Insert();
        end;
        exit(Setup);
    end;
}

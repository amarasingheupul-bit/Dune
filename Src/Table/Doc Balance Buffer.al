table 50112 "Doc Balance Buffer"
{
    Caption = 'Document Balance Buffer';
    fields
    {
        field(1; "Document No."; Code[20]) { }
        field(2; "Posting Date"; Date) { }
        field(3; "Total Debit"; Decimal) { }
        field(4; "Total Credit"; Decimal) { }
        field(5; "Difference"; Decimal) { }
    }
    keys
    {
        key(PK; "Document No.") { Clustered = true; }
    }
}
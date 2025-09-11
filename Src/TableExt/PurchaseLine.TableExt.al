tableextension 50117 "4HC Purchase Line" extends "Purchase Line"
{
    fields
    {
        field(50103; "Qty. to Post %"; Integer)
        {
            Caption = 'Qty. to Post %';
            MinValue = 0;
            MaxValue = 100;
        }
        field(50104; "Qty. Remaining %"; Integer)
        {
            Caption = 'Qty. Remaining %';
        }
        field(50105; "Qty Posted %"; Integer)
        {
            Caption = 'Qty Posted %';
            MaxValue = 100;
            MinValue = 0;
        }
    }
}
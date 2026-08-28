pageextension 50140 "Apply Vendor EntriesExt" extends "Apply Vendor Entries"
{
    layout
    {
        addafter("Currency Code")
        {
            field("Original Currency Factor"; Rec."Original Currency Factor")
            {
                ApplicationArea = All;
                Caption = 'Exchange Rate';
                DecimalPlaces = 0 : 6;
                ToolTip = 'Specifies the exchange rate used to convert the amount to LCY.';
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}
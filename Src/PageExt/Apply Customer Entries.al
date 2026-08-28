pageextension 50141 "Apply Customer EntriesExt" extends "Apply Customer Entries"
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
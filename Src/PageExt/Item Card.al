pageextension 50139 "Item CardExt" extends "Item Card"
{
    layout
    {
        modify(InventoryGrp)
        {
            Visible = false;
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}
tableextension 50119 "To-doExt" extends "To-do"
{
    fields
    {
        field(50100; "User"; Code[20])
        {
            //TableRelation = User."User Name";
        }
        field(50101; DashSortOrder; Integer)
        {
            DataClassification = SystemMetadata;
        }
    }


    fieldgroups
    {
        // Add changes to field groups here
    }

    var
        myInt: Integer;
}
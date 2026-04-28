page 50133 "Widget Visibility Subpage"
{
    ApplicationArea = All;
    Caption = 'Widget Visibility Subpage';
    PageType = ListPart;
    SourceTable = "DashboardVisible KPI Setup";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Widget Identity"; Rec."Widget Identity")
                {
                    ToolTip = 'Specifies the value of the Widget Name field.', Comment = '%';
                }
                field("Show on Dashboard"; Rec."Show on Dashboard")
                {
                    ToolTip = 'Specifies the value of the Show on Dashboard field.', Comment = '%';
                }
            }
        }
    }
}

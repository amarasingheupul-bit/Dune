page 50117 "Dashboard KPI Setup List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Dashboard KPI Setup";
    Caption = 'Dashboard KPI Setup';
    // CardPageId = "Dashboard KPI Setup Card"; // Optional: If you want a detailed card page later

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("KPI Code"; Rec."KPI Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique identifier for the dashboard widget.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a clear description of what this KPI measures.';
                }
                field("Widget Type"; Rec."Widget Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how this data will be displayed on the Role Center.';
                }
                field("G/L Account Filter"; Rec."G/L Account Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the G/L accounts to include in the calculation (e.g., 1000..1099).';
                }
                field("Date Formula"; Rec."Date Formula")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the default date range for the calculation (e.g., -6M).';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            // You can add actions here later, such as a "Test Calculation" button
        }
    }
}

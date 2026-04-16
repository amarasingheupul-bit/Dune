page 50121 "Dashboard Tasks Part"
{
    PageType = List; // 🔥 MUST
    Caption = 'Tasks';
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(Tasks)
            {
                part(AssignedToMe; "Dashboard Tasks Assigned To Me")
                {
                    ApplicationArea = All;
                    Caption = '📋 Assigned to Me';
                }
                part(AssignedByMe; "Dashboard Tasks Assigned By Me")
                {
                    ApplicationArea = All;
                    Caption = '✏️ Assigned by Me';
                }
            }
        }
    }
}
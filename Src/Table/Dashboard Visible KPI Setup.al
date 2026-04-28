table 50108 "DashboardVisible KPI Setup"
{
    Caption = 'Dashboard Visible KPI Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Widget Identity"; Enum "Dashboard Widget Identity")
        {
            Caption = 'Widget Name';
        }
        field(2; "Show on Dashboard"; Boolean)
        {
            Caption = 'Show on Dashboard';
        }
    }
    keys
    {
        key(PK; "Widget Identity")
        {
            Clustered = true;
        }
    }
}

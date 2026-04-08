table 50106 "Dashboard KPI Setup"
{
    DataClassification = CustomerContent;
    Caption = 'Dashboard KPI Setup';
    DrillDownPageId = "Dashboard KPI Setup List";
    LookupPageId = "Dashboard KPI Setup List";

    fields
    {
        field(1; "KPI Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'KPI Code';
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
        field(3; "Widget Type"; Enum "Dashboard Widget Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Widget Type';
        }
        field(4; "G/L Account Filter"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'G/L Account Filter';
            ToolTip = 'Enter a standard Business Central account filter (e.g., 1000..1099|2010).';
        }
        field(5; "Date Formula"; DateFormula)
        {
            DataClassification = CustomerContent;
            Caption = 'Date Formula';
            ToolTip = 'Optional: Set a default period like -6M for Last 6 Months or CM for Current Month.';
        }
    }

    keys
    {
        key(PK; "KPI Code")
        {
            Clustered = true;
        }
    }
}

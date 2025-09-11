tableextension 50107 "Job Planning Line" extends "Job Planning Line"
{
    fields
    {
        field(50100; "SEQNO S365"; Integer)
        {
            Caption = 'Seq. No.';
            DataClassification = CustomerContent;
        }
        field(50101; "Predecessor Seq S365"; Integer)
        {
            Caption = 'Predecessor Seq.';
            DataClassification = CustomerContent;
        }
        field(50102; "Completed S365"; Boolean)
        {
            Caption = 'Completed';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                JobPlanningLine: Record "Job Planning Line";
            begin
                if Rec."Predecessor Seq S365" = 0 then exit;
                JobPlanningLine.SetRange("Job No.", Rec."Job No.");
                JobPlanningLine.SetRange("SEQNO S365", Rec."Predecessor Seq S365");
                JobPlanningLine.SetRange("Completed S365", true);
                if JobPlanningLine.IsEmpty then Error('You must complete Seq. No. %1 first.', Rec."Predecessor Seq S365");
            end;
        }
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

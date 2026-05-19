page 50137 "Dashboard Watchlist Setup"
{
    PageType = List;
    Caption = 'My Watchlist Accounts';
    SourceTable = "Dashboard Watchlist Setup";
    DataCaptionExpression = '';
    Editable = true;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("G/L Account No."; Rec."G/L Account No.")
                {
                    ApplicationArea = All;
                    Caption = 'G/L Account No.';

                    trigger OnValidate()
                    begin
                        // Auto-assign next line number for new records
                    end;
                }
                field("G/L Account Name"; Rec."G/L Account Name")
                {
                    ApplicationArea = All;
                    Caption = 'Account Name';
                }
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."User ID" := CopyStr(UserId(), 1, MaxStrLen(Rec."User ID"));
        Rec."Line No." := GetNextLineNo();
    end;

    trigger OnOpenPage()
    begin
        Rec.FilterGroup(2);
        Rec.SetRange("User ID", CopyStr(UserId(), 1, MaxStrLen(Rec."User ID")));
        Rec.FilterGroup(0);
    end;

    local procedure GetNextLineNo(): Integer
    var
        WatchlistSetup: Record "Dashboard Watchlist Setup";
    begin
        WatchlistSetup.SetRange("User ID", CopyStr(UserId(), 1, MaxStrLen(WatchlistSetup."User ID")));
        if WatchlistSetup.FindLast() then
            exit(WatchlistSetup."Line No." + 10000);
        exit(10000);
    end;
}

codeunit 50112 "GL Unmatched Doc Finder"
{
    procedure GetUnmatchedDocuments(var UnmatchedBuffer: Record "Doc Balance Buffer" temporary)
    var
        GLEntry: Record "G/L Entry";
        Buffer: Record "Doc Balance Buffer" temporary;
    begin
        GLEntry.SetCurrentKey("Document No.");
        if GLEntry.FindSet() then
            repeat
                if Buffer.Get(GLEntry."Document No.") then begin
                    Buffer."Total Debit" += GLEntry."Debit Amount";
                    Buffer."Total Credit" += GLEntry."Credit Amount";
                    Buffer.Modify();
                end else begin
                    Buffer.Init();
                    Buffer."Document No." := GLEntry."Document No.";
                    Buffer."Posting Date" := GLEntry."Posting Date";
                    Buffer."Total Debit" := GLEntry."Debit Amount";
                    Buffer."Total Credit" := GLEntry."Credit Amount";
                    Buffer.Insert();
                end;
            until GLEntry.Next() = 0;

        if Buffer.FindSet() then
            repeat
                if Buffer."Total Debit" <> Buffer."Total Credit" then begin
                    UnmatchedBuffer := Buffer;
                    UnmatchedBuffer.Difference := Buffer."Total Debit" - Buffer."Total Credit";
                    UnmatchedBuffer.Insert();
                end;
            until Buffer.Next() = 0;
    end;
}
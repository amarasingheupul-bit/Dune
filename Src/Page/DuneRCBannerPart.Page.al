namespace Dune.Visualization;

using System.Text;
using System.Utilities;

page 50139 "Dune RC Banner Part"
{
    ApplicationArea = All;
    Caption = '';
    PageType = CardPart;
    SourceTable = "Dune RC Banner Setup";
    InstructionalText = '';      // forces BC to treat this as a standalone full-row part

    layout
    {
        area(Content)
        {
            usercontrol(DuneBannerAddin; "Dune RC Banner Addin")
            {
                ApplicationArea = All;

                trigger ControlReady()
                begin
                    LoadDuneBanner();
                end;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(UploadImage)
            {
                ApplicationArea = All;
                ToolTip = 'Select and upload a base64 corporate background graphic from your storage disk.';
                Caption = 'Upload Dune Banner';
                Image = Import;

                trigger OnAction()
                var
                    InStream: InStream;
                    FileName: Text;
                begin
                    if UploadIntoStream('Select Banner Image', '', 'Images|*.jpg;*.jpeg;*.png', FileName, InStream) then begin
                        Rec."Banner Image".ImportStream(InStream, FileName);
                        Rec."Mime Type" := CopyStr(GetMimeType(FileName), 1, MaxStrLen(Rec."Mime Type"));
                        Rec.Modify(true);
                        LoadDuneBanner();
                    end;
                end;
            }

            action(DeleteImage)
            {
                ApplicationArea = All;
                ToolTip = 'Purge the active banner configuration file to restore the standard default workspace.';
                Caption = 'Remove Dune Banner';
                Image = Delete;

                trigger OnAction()
                begin
                    Clear(Rec."Banner Image");
                    Clear(Rec."Mime Type");
                    Rec.Modify(true);
                    CurrPage.DuneBannerAddin.ClearDuneBanner();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get('DUNE-MAIN') then begin
            Rec.Init();
            Rec."Primary Key" := 'DUNE-MAIN';
            Rec.Insert();
        end;
    end;

    local procedure LoadDuneBanner()
    var
        Base64Convert: Codeunit "Base64 Convert";
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        InStr: InStream;
        Base64Text: Text;
        MimeType: Text;
    begin
        if not Rec."Banner Image".HasValue() then begin
            CurrPage.DuneBannerAddin.ClearDuneBanner();
            exit;
        end;

        TempBlob.CreateOutStream(OutStr);
        Rec."Banner Image".ExportStream(OutStr);
        TempBlob.CreateInStream(InStr);

        Base64Text := Base64Convert.ToBase64(InStr);

        MimeType := Rec."Mime Type";
        if MimeType = '' then
            MimeType := 'image/png';

        CurrPage.DuneBannerAddin.SetDuneBanner(Base64Text, MimeType);
    end;

    local procedure GetMimeType(FileName: Text): Text
    var
        LowerFileName: Text;
    begin
        LowerFileName := LowerCase(FileName);
        if LowerFileName.EndsWith('.png') then exit('image/png');
        if LowerFileName.EndsWith('.jpg') then exit('image/jpeg');
        if LowerFileName.EndsWith('.jpeg') then exit('image/jpeg');
        exit('image/png');
    end;
}
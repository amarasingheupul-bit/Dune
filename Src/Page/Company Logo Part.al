// page 50137 "Company Logo Part"
// {
//     PageType = UserControlHost;
//     ApplicationArea = All;

//     layout
//     {
//         area(Content)
//         {
//             usercontrol(LogoControl; "Company Logo Addin")
//             {
//                 ApplicationArea = All;

//                 trigger ControlReady()
//                 var
//                     CompanyInfo: Record "Company Information";
//                     Base64: Codeunit "Base64 Convert";
//                     InStream: InStream;
//                     Base64Text: Text;
//                 begin
//                     CompanyInfo.Get();
//                     CompanyInfo.CalcFields(Picture);
//                     if CompanyInfo.Picture.HasValue then begin
//                         CompanyInfo.Picture.CreateInStream(InStream);
//                         Base64Text := Base64.ToBase64(InStream);
//                         CurrPage.LogoControl.LoadImage(Base64Text);
//                     end;
//                 end;
//             }
//         }
//     }
// }
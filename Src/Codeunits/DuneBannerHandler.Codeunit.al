namespace Dune.Visualization;
using System.Environment.Configuration;
codeunit 50109 "Dune Banner Handler"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Checklist Banner", 'OnOpenChecklistBannerPage', '', false, false)]
    local procedure DisableDefaultChecklistBanner(var SkipWelcomeState: Boolean; IsEvaluationCompany: Boolean)
    begin
        SkipWelcomeState := true;
    end;
}
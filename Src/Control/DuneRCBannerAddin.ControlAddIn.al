namespace Dune.Visualization;

controladdin "Dune RC Banner Addin"
{
    RequestedHeight = 520;
    MinimumHeight = 480;
    MaximumHeight = 650;

    RequestedWidth = 1600;
    MinimumWidth = 320;
    MaximumWidth = 2000;

    HorizontalStretch = true;
    VerticalStretch = false;

    Scripts = 'src/js/DuneBanner.js';
    StyleSheets = 'src/js/DuneBanner.css';

    event ControlReady();
    event ActivityClicked(ActivityName: Text);

    procedure SetDuneBanner(Base64Image: Text; MimeType: Text);
    procedure SetBannerText(HeaderText: Text; MainText: Text; SubText: Text);
    procedure ClearDuneBanner();
}
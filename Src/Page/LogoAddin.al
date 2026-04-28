controladdin "Company Logo Addin"
{
    StartupScript = 'Src/Js/start.js';
    Scripts = 'Src/Js/logo.js';
    //StyleSheets = 'src/addin/logo.css';

    RequestedHeight = 80;
    MinimumHeight = 80;
    MaximumHeight = 80;
    RequestedWidth = 300;
    HorizontalStretch = true;
    VerticalShrink = false;


    event ControlReady();

    // ADD THIS — declare the procedure
    procedure LoadImage(imageBase64: Text);
}
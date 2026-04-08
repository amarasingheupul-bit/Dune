controladdin "Custom Cash Flow Chart"
{
    RequestedHeight = 220;
    MinimumHeight = 180;
    MaximumHeight = 260;
    RequestedWidth = 300;
    MinimumWidth = 200;
    //MaximumWidth = 600;
    VerticalStretch = true;
    HorizontalStretch = true;

    Scripts = 'https://cdn.jsdelivr.net/npm/chart.js',
              'src/js/main.js';

    StartupScript = 'src/js/startup.js';

    event ControlReady();

    procedure RenderChart(Dataset1Name: Text; Dataset2Name: Text; Labels: JsonArray; Data1: JsonArray; Data2: JsonArray);
    procedure RenderSingleChart(DatasetName: Text; Labels: JsonArray; Data: JsonArray; BarColor: Text);

}
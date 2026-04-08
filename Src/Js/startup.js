//document.getElementById('controlAddIn').innerHTML = '<canvas id="myChart"></canvas>';
//Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('ControlReady', []);

var wrapper = document.createElement('div');
wrapper.style.cssText = [
    'border: 1px solid #d1d5db',
    'border-radius: 6px',
    'padding: 8px',
    'background: #ffffff',
    'box-sizing: border-box',
    'width: 100%',
    'height: 100%'
].join(';');

var canvas = document.createElement('canvas');
canvas.id = 'myChart';
canvas.style.cssText = 'display:block;width:100%;height:100%;';

wrapper.appendChild(canvas);
document.getElementById('controlAddIn').appendChild(wrapper);
document.getElementById('controlAddIn').style.cssText = 'width:100%;height:100%;box-sizing:border-box;';

Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('ControlReady', []);

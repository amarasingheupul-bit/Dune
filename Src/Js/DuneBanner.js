var DuneBannerAddin = (function () {
    var container = null;
    var imgEl = null;
    var overlayHeader = null;
    var overlayMain = null;
    var overlaySub = null;
    var activitiesEl = null;

    function init() {
        container = document.getElementById('controlAddIn');
        if (!container) return;

        container.className = 'dune-dashboard-container';

        var bannerSection = document.createElement('div');
        bannerSection.id = 'dune-banner-section';

        imgEl = document.createElement('img');
        imgEl.id = 'dune-banner-img';
        imgEl.style.display = 'none';

        var overlay = document.createElement('div');
        overlay.id = 'dune-banner-overlay';

        overlayHeader = document.createElement('div');
        overlayHeader.id = 'dune-banner-header';

        overlayMain = document.createElement('div');
        overlayMain.id = 'dune-banner-main';

        overlaySub = document.createElement('div');
        overlaySub.id = 'dune-banner-sub';

        overlay.appendChild(overlayHeader);
        overlay.appendChild(overlayMain);
        overlay.appendChild(overlaySub);

        var placeholder = document.createElement('div');
        placeholder.id = 'dune-banner-placeholder';
        placeholder.innerText = 'No DUNE banner image set.';

        bannerSection.appendChild(imgEl);
        bannerSection.appendChild(overlay);
        bannerSection.appendChild(placeholder);

        activitiesEl = document.createElement('div');

        container.appendChild(bannerSection);

        Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('ControlReady', []);
    }

    function SetDuneBanner(base64, mimeType) {
        if (!imgEl) return;

        imgEl.src = 'data:' + mimeType + ';base64,' + base64;
        imgEl.style.display = 'block';

        var ph = document.getElementById('dune-banner-placeholder');
        if (ph) ph.style.display = 'none';
    }

    function SetBannerText(headerText, mainText, subText) {
        if (overlayHeader) overlayHeader.innerText = headerText;
        if (overlayMain) overlayMain.innerText = mainText;
        if (overlaySub) overlaySub.innerText = subText;
    }

    function ClearDuneBanner() {
        if (imgEl) {
            imgEl.src = '';
            imgEl.style.display = 'none';
        }

        var ph = document.getElementById('dune-banner-placeholder');
        if (ph) ph.style.display = 'flex';
    }

    window.SetDuneBanner = SetDuneBanner;
    window.SetBannerText = SetBannerText;
    window.ClearDuneBanner = ClearDuneBanner;

    if (document.readyState === 'complete') {
        init();
    } else {
        window.addEventListener('load', init);
    }
})();
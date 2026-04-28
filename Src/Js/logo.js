function LoadImage(imageBase64) {
    var img = document.createElement('img');
    img.src = 'data:image/png;base64,' + imageBase64;
    img.style.height = '60px';
    img.style.objectFit = 'contain';
    document.body.appendChild(img);
}
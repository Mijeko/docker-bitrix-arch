export default class Photo {
    constructor() {
        const productionElement = document.querySelector('meta[data-production]');

        if (productionElement) {
            if (productionElement.getAttribute('data-production') === 'dev') {
                const host = productionElement.getAttribute('data-host');
                this.replaceImageSrc(host);
                this.replaceBackground(host);
            }
        }
    }

    replaceImageSrc(host) {
        const images = document.querySelectorAll('img');
        if (images) {
            images.forEach(image => {
                if (image.hasAttribute('data-src')) {
                    let nUrlData = `http://${host}` + image.getAttribute('data-src');
                    image.setAttribute('data-src', nUrlData);
                }

                if (image.hasAttribute('src')) {
                    let nUrl = `http://${host}` + image.getAttribute('src');
                    image.setAttribute('src', nUrl);
                }

            });
        }
    }

    replaceBackground(host) {
        const elementsWithStyleAttribute = document.querySelectorAll('[style]');
        if (elementsWithStyleAttribute) {
            elementsWithStyleAttribute.forEach(element => {
                let styleData = element.getAttribute('style');

                // styleData.replace(/(?:\(['"]?)(.*?)(?:['"]?\))/i, `http://${host}$1`);
                // styleData.replace(/(?:\(['"]?)(.*?)(?:['"]?\))/i, ``);


                // console.log(styleData);
            });
        }
    }

}
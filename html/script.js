class Hud {

    constructor() {
        window.addEventListener('message', event => {
            switch (event.data.type) {
                case 'init':                return this.initLanguageFields(event.data.translatedLabels);
                case 'changeVisibility':    return this.changeVisibility(event.data.visible);
                case 'update':              return this.handleUpdate(event.data);
            }
        });

        this.routeName = $('#route-name');
        this.nextStop = $('#next-stop');
        this.moneyEarned = $('#money-earned');
        this.stopsRemaining = $('#stops-remaining');
    }

    initLanguageFields = translatedLabels => Object.entries(translatedLabels)
        .forEach(entry => $(`#${entry[0]}`).html(entry[1]));

    changeVisibility = isVisible => document.body.style.display = isVisible ? 'block' : 'none';

    handleUpdate = data => {
        this.routeName.text(data.routeName);
        this.nextStop.text(data.nextStop);
        this.moneyEarned.text(`$${data.moneyEarned}`);
        this.stopsRemaining.text(data.stopsRemaining);
    };
}

$(() => new Hud());

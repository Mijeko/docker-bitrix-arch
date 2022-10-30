import {Fancybox} from "@fancyapps/ui";


$('body').on('click', '.js-choose-city', function (event) {

    const $this = $(this), cityId = $this.attr('data-city-id'), city = $this.attr('data-city'), cityCode = $this.attr('data-city-code');
    let post_form_data = new FormData();

    post_form_data.append('cityid', cityId);
    post_form_data.append('cityCode', cityCode);
    post_form_data.append('city', city);
    post_form_data.append('action', 'setcookie');

    fetch('/local/handlers/check_city.php', {
        method: 'POST',
        body: post_form_data
    })
        .then(response => response.json())
        .then(data => {

            if (data.status === true) {
                Fancybox.close();
                window.location.href = '/';
            }
        })
});


let timeoutSearch = false;
$('.js-sinar-gps-search').keyup(function (event) {

    const $this = $(this), text = $this.val(), $list_dom = $('.sinar-gps-city-list');

    if (text.length === 0) {
        return false;
    }

    let post_form_data = new FormData();
    post_form_data.append('city', text);
    post_form_data.append('action', 'find');

    if (timeoutSearch) {
        clearTimeout(timeoutSearch);
    }

    timeoutSearch = setTimeout(() => {
        fetch('/local/handlers/check_city.php', {
            method: 'POST',
            body: post_form_data
        })
            .then(response => response.json())
            .then(data => {

                $list_dom.html('');
                for (let elem of data.data) {
                    if (elem.COUNTRY_LID === 'ru') {
                        $list_dom.append(`<div class="sinar-gps-city-item js-choose-city" data-city-code="${elem.CODE}" data-city="${elem.CITY_NAME}" data-city-id="${elem.ID}">${elem.CITY_NAME}</div>`);
                    }
                }

            })
    }, 450);
});
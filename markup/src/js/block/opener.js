export function Opener() {
    $('.opener_icon').click(function(e) {
        e.preventDefault();
        $(this).parent().find('a').trigger('click');
    });

    $('.jobs_wrapp .item .name tr').click(function(e) {
        $(this).closest('.item').toggleClass('opened');
        $(this).closest('.item').find('.description_wrapp').stop().slideToggle(600);
        $(this).closest('.item').find('.opener_icon').toggleClass('opened');
    });
}
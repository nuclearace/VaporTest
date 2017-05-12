/**
 * Created by eriklittle on 5/12/17.
 */

(function() {
    console.log('hello');

    window.submitPost = function() {
        console.log('adfadfad');
        $.ajax({
            url: '/api/post/',
            data: JSON.stringify({ content: $('#content').val() }),
            type: 'application/json',
            method: 'POST'
        });
    };
})();

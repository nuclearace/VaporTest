/**
 * Created by eriklittle on 5/12/17.
 */

(function() {
    console.log('hello');

    window.submitPost = function() {
        $.ajax({
            url: '/api/post/',
            data: JSON.stringify({
                content: $('#content').val(),
                user: 1
            }),
            type: 'application/json',
            method: 'POST'
        });
    };
})();

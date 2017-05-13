/**
 * Created by eriklittle on 5/12/17.
 */

(function() {
    window.submitPost = function() {
        $.ajax({
            url: '/api/post/',
            data: JSON.stringify({ content: $('#content').val() }),
            type: 'application/json',
            method: 'POST'
        });
    };
})();

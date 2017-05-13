/**
 * Created by eriklittle on 5/12/17.
 */

(function() {
    window.ws = new WebSocket("ws://127.0.0.1:8181/ws");

    ws.onmessage = function(msg) {
        console.log(msg);
    };

    ws.onopen = function(event) {
        console.log('Connected')
    };

    window.submitPost = function() {
        $.ajax({
            url: '/api/post/',
            data: JSON.stringify({ content: $('#content').val() }),
            type: 'application/json',
            method: 'POST'
        });

        $('#content').val('');
    };
})();

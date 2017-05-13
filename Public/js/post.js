/**
 * Created by eriklittle on 5/12/17.
 */

(function() {
    let ws = new WebSocket("ws://127.0.0.1:8181/ws");

    ws.onmessage = function(msg) {
        let parsed = JSON.parse(msg.data);

        if (parsed['type'] !== 1) { return; }

        let content = parsed['message']['content'];
        let id = parsed['message']['id'];
        let row = $('<tr/>').attr('id', `msg-${id}`);
        let time = moment(parsed['message']['timestamp']);

        row.append($('<td/>').text(time.format("MMMM Do YYYY, h:mm:ss a"))).css('width', '100%');
        row.append($('<td/>').text(content)).css('width', '100%').css('word-wrap', 'normal');

        $('#messageBuffer').append(row);
    };

    window.ws = ws;

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

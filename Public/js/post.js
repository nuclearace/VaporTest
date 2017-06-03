/**
 * Created by eriklittle on 5/12/17.
 */

(function() {
    let ws = new WebSocket("ws://127.0.0.1:8080/ws");

    ws.onmessage = function(msg) {
        let parsed = JSON.parse(msg.data);

        if (parsed['type'] !== 1) { return; }

        let content = parsed['message']['content'];
        let id = parsed['message']['id'];
        let row = $('<tr/>').attr('id', `msg-${id}`).css('width', '100%').css('word-wrap', 'normal');
        let time = moment(parsed['message']['timestamp']);

        row.append($('<td/>').text(time.format("MMMM Do YYYY, h:mm:ss a")));
        row.append($('<td/>').text(content));

        $('#messageBuffer').append(row);
        $('#messageContainer').animate({ scrollTop: $('#messageBuffer').find('tr:last').position().top }, 0);
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

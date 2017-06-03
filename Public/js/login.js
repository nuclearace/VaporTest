/**
 * Created by eriklittle on 5/13/17.
 */

(function() {
    window.login = () => {
        $.ajax({
            url: '/api/users/login/',
            beforeSend: (request) => {
                let b64Auth = btoa(`${$('#username').val()}:${$('#password').val()}`);

                request.setRequestHeader("Authorization", `Basic ${b64Auth}`);
            },
            type: 'application/json',
            method: 'POST',
            success: () => {
                window.location = '/wall';
            }
        });
    };

    window.create = () => {
        window.location = '/users/new';
    };
})();

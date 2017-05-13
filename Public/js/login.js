/**
 * Created by eriklittle on 5/13/17.
 */

(function() {
    window.login = () => {
        $.ajax({
            url: '/api/users/login/',
            data: JSON.stringify({
                username: $('#username').val(),
                password: $('#password').val(),
            }),
            type: 'application/json',
            method: 'POST',
            success: () => {
                window.location = '/post/create';
            }
        });
    }
})();

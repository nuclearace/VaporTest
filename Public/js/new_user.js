/**
 * Created by eriklittle on 5/12/17.
 */

(function() {
    window.saveUser = () => {
        $.ajax({
            url: '/api/users/new/',
            data: JSON.stringify({
                username: $('#username').val(),
                email: $('#email').val(),
                password: $('#password').val(),
            }),
            type: 'application/json',
            method: 'POST'
        });
    }
})();

/**
 * Created by eriklittle on 5/13/17.
 */

(function() {
    window.logoutUser = () => {
        $.ajax({
            url: '/api/users/logout/',
            method: 'POST'
        })
    }
})();

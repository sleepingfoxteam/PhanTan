$(document).ready(function () {
    Initialize();
});
function Initialize() {
    InitLoginButtonSubmit();
}
function InitLoginButtonSubmit() {
    $("#btnDangNhap").click(function () {
        let username = $("#username").val();
        let password = $("#password").val();
        let chinhanh = $("#chinhanh").val();
        let object = {
            username,
            password,
            chinhanh,
        };
        let object_json = JSON.stringify(object);
        $.ajax({
            url: '../../../Login/Check',
            data: object_json,
            method: 'POST',
            type: 'POST',
            success: function (result) {
                if (result === 1) {
                    location.href = '../../../User';
                }
                else {
                    alert(result);
                }
            }
        });
    });
}
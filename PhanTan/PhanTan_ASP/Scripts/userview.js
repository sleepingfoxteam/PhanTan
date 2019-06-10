$(document).ready(function () {
    initBtnCapNhat();
    initBtnLuu();
});
function initBtnLuu() {
    $("#btnLuu").click(function () {
        let _ = $(this);
        let form = $("#form-information");
        let username = form.find('[name="username"]').val();
        let tenkhachhang = form.find('[name="tenkhachhang"]').val();
        let diachi = form.find('[name="diachi"]').val();
        let sdt = form.find('[name="sdt"]').val();
        let ngaysinh = form.find('[name="ngaysinh"]').val();
        console.log(username, tenkhachhang, diachi, sdt, ngaysinh);
        // [TO DO] goi den ham backend o day
        // sau khi ajax thanh cong
        alert("thanh cong");
        $("#btnCapNhat").attr("disabled", false);
        _.css("display", "none");
        $("#form-information").children().children('[type="text"]').attr("disabled", true);
    });
}
function initBtnCapNhat() {
    $("#btnCapNhat").click(function () {
        $("#form-information").children().children('[type="text"]').removeAttr("disabled");
        $('[name="username"]').attr("disabled", true);
        $(this).attr("disabled", true);
        $("#btnLuu").css("display", "block");
    });
}
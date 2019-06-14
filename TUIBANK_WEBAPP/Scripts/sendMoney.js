$(document).ready(function () {
    initFindMethod();
    initBtnSendMoney();
});
function initBtnSendMoney() {
    $("#btnSendMoney").click(function () {
        let money = $("#sourcemoney").val();
        money = parseInt(money);
        let send_account = $("#sourcenumber").val();
        let recive_account = $("#desitnationnumber").val();
        $.ajax({
            type: 'POST',
            method: 'POST',
            url: '../../../Accounts/SendMoney',
            data: {
                money,
                send_account,
                recive_account
            },
            success: function (result) {
                if (result == -1) {
                    alert("khong giao dich duoc");
                }
                else {
                    alert("thanh cong");
                }
            }
        });
    });
}
function showSender(json_data) {
    let sendername = $("#sourcename");
    let sendernumber = $("#sourcenumber");
    let senderbranch = $("#sourcebranch");
    let object = JSON.parse(json_data);
    sendername.val(object['customername']);
    sendernumber.val(object['accountnumber']);
    senderbranch.val(object['branchname']);
}

function showReciver(json_data) {
    let desinationname = $("#destinationname");
    let destinationnumber = $("#desitnationnumber");
    let destinationbranch = $("#desitnationbranch");
    let object = JSON.parse(json_data);
    desinationname.val(object['customername']);
    destinationnumber.val(object['accountnumber']);
    destinationbranch.val(object['branchname']);
}
function initFindMethod() {
    let btnFindSender = $("#btnFindSender");
    let btnReciver = $("#btnFindReciver");
    btnFindSender.click(function () {
        let sendername = $("#sourcename").val();
        let sendernumber = $("#sourcenumber").val();
        findAccountInfor(sendernumber,showSender);
    });
    btnReciver.click(function () {
        let recivername = $("#desitnationname").val();
        let recivernumber = $("#desitnationnumber").val();
        findAccountInfor(recivernumber,showReciver);
    });
}

function findAccountInfor(accountnumber,callback) {
    $.ajax({
        type: 'GET',
        method: 'GET',
        url: '../../../Accounts/findAccountInfor',
        data: {
            accountnumber
        },
        success: function (result) {
            if (result === -1) {
                alert("khong tim thay tai khoan");
            }
            else {
                callback(result);
            }
        }
    });
}
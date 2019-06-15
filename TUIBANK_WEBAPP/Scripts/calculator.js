$(document).ready(function () {
    initFindMethod();
    initCalculateMethod();
});

function initCalculateMethod() {
    $("#btnCalculate").click(function () {
        let interest = $("#accountinterest").val();
        let period = $("#accountperiod").val();
        let balance = $("#accountbalance").val();
        let startdate = $("#accountstartdate").val();
        $.ajax({
            type: 'GET',
            method: 'GET',
            url: '../../../Accounts/Calculate',
            data: {
                interest,
                period,
                balance,
                startdate
            },
            success: function (result) {
                if (result === "-1") {
                    alert("khong du thong tin de tinh toan");
                }
                else {
                    showCalculateResult(result);
                }
            }
        });
    });
}
function showCalculateResult(json_string) {
    json_object = JSON.parse(json_string);
    let append = "";
    let i = 1;
    let nf = new Intl.NumberFormat();
    for (let pro in json_object) {
        append += "<tr>";
        append += "<td>" + i + "</td>";
        append += "<td>" + nf.format(pro) + "</td>";
        append += "<td>" + nf.format(json_object[pro]) + "</td>";
        append += "</tr>";
        ++i;
    }
    let tbody = $("#table-calculator").children("tbody");
    tbody.empty();
    tbody.append(append);
}
function initFindMethod() {
    $("#btnFind").click(function () {
        let accountnumber = $("#accountnumber").val();
        $.ajax({
            type: 'GET',
            method: 'GET',
            url: '../../../Accounts/findAccountInforMore',
            data: {
                accountnumber
            },
            success: function (result) {
                if (result === "-1") {
                    alert("khong tim thay tai khoan");
                }
                else {
                    showInformation(result);
                    //$("#accountstartdate").val(result);
                }
            }
        });
    });
}

function showInformation(json_data) {
    let json_object = JSON.parse(json_data);
    $("#accountbalance").val(parseInt(json_object["accountbalance"]));
    $("#accountinterest").val(parseFloat(json_object["accountinterest"]));
    $("#accountperiod").val(parseInt(json_object["accountperiod"]));
    $("#accountstartdate").val(json_object["accountstartdate"]);
}
(function () {
    "use strict";
    var plusButtons = document.querySelectorAll("[data-quantity-plus]");
    for (var plusIndex = 0; plusIndex < plusButtons.length; plusIndex++) {
        plusButtons[plusIndex].addEventListener("click", function () {
            var input = this.parentElement.querySelector("input");
            input.value = Math.min(99, (parseInt(input.value, 10) || 0) + 1);
        });
    }
    var minusButtons = document.querySelectorAll("[data-quantity-minus]");
    for (var minusIndex = 0; minusIndex < minusButtons.length; minusIndex++) {
        minusButtons[minusIndex].addEventListener("click", function () {
            var input = this.parentElement.querySelector("input");
            input.value = Math.max(0, (parseInt(input.value, 10) || 0) - 1);
        });
    }
    var paymentMethod = document.querySelector("[data-payment-method]");
    var cashReceived = document.querySelector("[data-cash-received]");
    var qrPayment = document.querySelector("[data-qr-payment]");
    if (paymentMethod && cashReceived && qrPayment) {
        var updatePaymentFields = function () {
            var usesQr = paymentMethod.value === "QR-Code";
            cashReceived.hidden = usesQr;
            qrPayment.hidden = !usesQr;
            var receivedInput = cashReceived.querySelector("input");
            if (receivedInput) receivedInput.required = !usesQr;
        };
        paymentMethod.addEventListener("change", updatePaymentFields);
        updatePaymentFields();
    }
})();

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
            if (receivedInput)
                receivedInput.required = !usesQr;
        };
        paymentMethod.addEventListener("change", updatePaymentFields);
        updatePaymentFields();
    }
})();

/* ======================================================================
   EXTERNAL IMAGE URL FIX 2026-07-12
   JSP đang ghép contextPath trước src. Đoạn này sửa /CafeWebhttps://... về https://...
   để ảnh từ database dạng URL online hiển thị đúng trên mọi máy.
   ====================================================================== */
(function () {
    "use strict";

    function fixExternalImageUrls(root) {
        var scope = root && root.querySelectorAll ? root : document;
        var images = scope.querySelectorAll("img[src]");
        for (var i = 0; i < images.length; i++) {
            var rawSrc = images[i].getAttribute("src") || "";
            var fullSrc = images[i].src || "";
            var match = rawSrc.match(/(https?:\/\/.+)$/) || fullSrc.match(/(https?:\/\/.+)$/);
            if (match && rawSrc.indexOf("http") > 0) {
                images[i].hidden = false;
                images[i].setAttribute("src", match[1]);
            }
        }
    }

    function startFixing() {
        fixExternalImageUrls(document);
        if (window.MutationObserver) {
            var observer = new MutationObserver(function (mutations) {
                for (var i = 0; i < mutations.length; i++) {
                    for (var j = 0; j < mutations[i].addedNodes.length; j++) {
                        fixExternalImageUrls(mutations[i].addedNodes[j]);
                    }
                }
            });
            observer.observe(document.documentElement, { childList: true, subtree: true });
        }
    }

    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", startFixing);
    } else {
        startFixing();
    }
}());
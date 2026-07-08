(function () {
    function formatVnd(value) {
        return Math.max(0, Math.round(Number(value) || 0)).toLocaleString("vi-VN") + "đ";
    }

    var cashForms = document.querySelectorAll(".cash-payment-form");
    for (var i = 0; i < cashForms.length; i++) {
        cashForms[i].addEventListener("input", function () {
            var orderCard = this.closest(".cashier-order");
            var total = Number(orderCard.getAttribute("data-order-total")) || 0;
            var received = Number(this.querySelector(".cash-received-input").value) || 0;
            var change = this.querySelector(".change-amount");
            if (change) {
                change.textContent = formatVnd(received - total);
            }
        });
    }

    var qrModal = document.getElementById("qrModal");
    var qrOrderId = document.getElementById("qrOrderId");
    var qrOrderLabel = document.getElementById("qrOrderLabel");
    var qrTotalLabel = document.getElementById("qrTotalLabel");
    var openQrButtons = document.querySelectorAll(".js-open-qr");
    var closeQrButtons = document.querySelectorAll(".js-close-qr");

    function setQrModal(open) {
        if (!qrModal) return;
        qrModal.classList.toggle("is-open", open);
        qrModal.setAttribute("aria-hidden", open ? "false" : "true");
        document.body.style.overflow = open ? "hidden" : "";
    }

    for (var openIndex = 0; openIndex < openQrButtons.length; openIndex++) {
        openQrButtons[openIndex].addEventListener("click", function () {
            var orderId = this.getAttribute("data-order-id");
            qrOrderId.value = orderId;
            qrOrderLabel.textContent = "#" + orderId;
            qrTotalLabel.textContent = formatVnd(this.getAttribute("data-order-total"));
            setQrModal(true);
        });
    }

    for (var closeIndex = 0; closeIndex < closeQrButtons.length; closeIndex++) {
        closeQrButtons[closeIndex].addEventListener("click", function () {
            setQrModal(false);
        });
    }

    document.addEventListener("keydown", function (event) {
        if (event.key === "Escape") {
            setQrModal(false);
        }
    });

    if (document.body.getAttribute("data-print-order-id")) {
        window.setTimeout(function () {
            window.print();
        }, 350);
    }
})();

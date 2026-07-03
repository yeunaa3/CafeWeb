(function () {
    var body = document.body;
    var contextPath = body ? body.getAttribute("data-context-path") || "" : "";
    var modal = document.getElementById("drinkModal");
    var addCartForm = document.getElementById("addCartForm");
    var toast = document.getElementById("toast");

    function formatVnd(value) {
        return Math.round(Number(value) || 0).toLocaleString("vi-VN");
    }

    function showToast(message) {
        if (!toast) return;
        toast.textContent = message;
        toast.classList.add("is-visible");
        window.setTimeout(function () {
            toast.classList.remove("is-visible");
        }, 1800);
    }

    function updateCartBadges(count) {
        var badges = document.querySelectorAll(".cart-count");
        for (var i = 0; i < badges.length; i++) {
            badges[i].textContent = count;
        }
    }

    function postCart(formData, callback) {
        fetch(contextPath + "/cart", {
            method: "POST",
            body: formData
        })
            .then(function (response) { return response.json(); })
            .then(function (data) {
                if (data && data.success) {
                    updateCartBadges(data.count);
                    if (callback) callback(data);
                }
            });
    }

    function openDrinkModal(button) {
        if (!modal || !addCartForm) return;
        document.getElementById("modalProductId").value = button.getAttribute("data-product-id");
        document.getElementById("modalProductName").textContent = button.getAttribute("data-product-name");
        document.getElementById("modalProductPrice").textContent = formatVnd(button.getAttribute("data-product-price")) + "đ";
        addCartForm.reset();
        addCartForm.querySelector("input[name='quantity']").value = 1;
        addCartForm.querySelector("input[name='selectedSize'][value='M']").checked = true;
        modal.classList.add("is-open");
        modal.setAttribute("aria-hidden", "false");
    }

    var addButtons = document.querySelectorAll(".add-product-btn");
    for (var i = 0; i < addButtons.length; i++) {
        addButtons[i].addEventListener("click", function () {
            openDrinkModal(this);
        });
    }

    if (modal) {
        modal.addEventListener("click", function (event) {
            if (event.target === modal || event.target.classList.contains("modal-close")) {
                modal.classList.remove("is-open");
                modal.setAttribute("aria-hidden", "true");
            }
        });
    }

    if (addCartForm) {
        addCartForm.addEventListener("submit", function (event) {
            event.preventDefault();
            postCart(new FormData(addCartForm), function () {
                modal.classList.remove("is-open");
                modal.setAttribute("aria-hidden", "true");
                showToast("Đã thêm vào giỏ hàng");
            });
        });
    }

    function updateCheckoutTotal() {
        var rows = document.querySelectorAll(".cart-item");
        var total = 0;
        for (var i = 0; i < rows.length; i++) {
            if (rows[i].style.display === "none") continue;
            var unit = Number(rows[i].getAttribute("data-unit-price")) || 0;
            var quantityInput = rows[i].querySelector("input[type='number']");
            var quantity = Number(quantityInput.value) || 1;
            var lineTotal = unit * quantity;
            total += lineTotal;
            var lineTotalEl = rows[i].querySelector(".line-total");
            if (lineTotalEl) lineTotalEl.textContent = formatVnd(lineTotal);
        }
        var totalEl = document.getElementById("cartTotal");
        if (totalEl) totalEl.textContent = formatVnd(total);
    }

    var qtyButtons = document.querySelectorAll(".qty-btn");
    for (var j = 0; j < qtyButtons.length; j++) {
        qtyButtons[j].addEventListener("click", function () {
            var row = this.closest(".cart-item");
            var input = row.querySelector("input[type='number']");
            var nextQuantity = Math.max(1, (Number(input.value) || 1) + Number(this.getAttribute("data-delta")));
            input.value = nextQuantity;
            var formData = new FormData();
            formData.append("action", "update");
            formData.append("ajax", "true");
            formData.append("cartKey", this.getAttribute("data-cart-key"));
            formData.append("quantity", nextQuantity);
            postCart(formData, function () {
                updateCheckoutTotal();
                showToast("Đã cập nhật giỏ hàng");
            });
        });
    }

    var removeButtons = document.querySelectorAll(".remove-btn");
    for (var k = 0; k < removeButtons.length; k++) {
        removeButtons[k].addEventListener("click", function () {
            var row = this.closest(".cart-item");
            var formData = new FormData();
            formData.append("action", "remove");
            formData.append("ajax", "true");
            formData.append("cartKey", this.getAttribute("data-cart-key"));
            postCart(formData, function () {
                row.style.display = "none";
                updateCheckoutTotal();
                showToast("Đã xóa món khỏi giỏ");
            });
        });
    }
})();

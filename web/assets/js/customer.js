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
        }, 2200);
    }

    function updateCartBadges(count) {
        var badges = document.querySelectorAll(".cart-count");
        for (var i = 0; i < badges.length; i++) {
            badges[i].textContent = count;
        }
    }

    function postCart(formData, callback, errorCallback) {
        fetch(contextPath + "/cart", {
            method: "POST",
            headers: {
                "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8"
            },
            body: new URLSearchParams(formData).toString()
        })
            .then(function (response) {
                return response.json().then(function (data) {
                    return { ok: response.ok, data: data };
                });
            })
            .then(function (result) {
                if (!result.ok || !result.data.success) {
                    throw new Error(result.data.message || "Không thể cập nhật giỏ hàng.");
                }
                updateCartBadges(result.data.count);
                if (callback) callback(result.data);
            })
            .catch(function (error) {
                showToast(error.message || "Kết nối bị gián đoạn. Vui lòng thử lại.");
                if (errorCallback) errorCallback(error);
            });
    }

    function updateModalTotal() {
        if (!addCartForm) return;
        var basePrice = Number(addCartForm.getAttribute("data-base-price")) || 0;
        var selectedSize = addCartForm.querySelector("input[name='selectedSize']:checked");
        var sizeExtra = 0;
        if (selectedSize && selectedSize.value === "L") sizeExtra = 5000;
        if (selectedSize && selectedSize.value === "S") sizeExtra = -3000;

        var toppingTotal = 0;
        var selectedToppings = addCartForm.querySelectorAll("input[name='toppingIds']:checked");
        for (var i = 0; i < selectedToppings.length; i++) {
            toppingTotal += Number(selectedToppings[i].getAttribute("data-topping-price")) || 0;
        }

        var quantity = Number(addCartForm.querySelector("input[name='quantity']").value) || 1;
        var totalElement = document.getElementById("modalTotal");
        if (totalElement) {
            totalElement.textContent = formatVnd((basePrice + sizeExtra + toppingTotal) * quantity) + "đ";
        }
    }

    function setDrinkModal(open) {
        if (!modal) return;
        modal.classList.toggle("is-open", open);
        modal.setAttribute("aria-hidden", open ? "false" : "true");
        document.body.style.overflow = open ? "hidden" : "";
    }

    function openDrinkModal(button) {
        if (!modal || !addCartForm) return;

        // Reset first so hidden product data is not cleared after assignment.
        addCartForm.reset();
        var productId = button.getAttribute("data-product-id");
        var productName = button.getAttribute("data-product-name");
        var productPrice = button.getAttribute("data-product-price");
        var productImage = document.getElementById("modalProductImage");

        document.getElementById("modalProductId").value = productId;
        document.getElementById("modalProductName").textContent = productName;
        document.getElementById("modalProductPrice").textContent = formatVnd(productPrice) + "đ";
        addCartForm.setAttribute("data-base-price", productPrice);
        addCartForm.querySelector("input[name='quantity']").value = 1;
        addCartForm.querySelector("input[name='selectedSize'][value='M']").checked = true;

        if (productImage) {
            var cardImage = button.closest(".product-card").querySelector("img");
            productImage.src = cardImage ? cardImage.src : contextPath + "/assets/images/" + button.getAttribute("data-product-image");
            productImage.alt = productName;
        }

        updateModalTotal();
        setDrinkModal(true);
    }

    var addButtons = document.querySelectorAll(".add-product-btn");
    for (var addIndex = 0; addIndex < addButtons.length; addIndex++) {
        addButtons[addIndex].addEventListener("click", function () {
            openDrinkModal(this);
        });
    }

    if (modal) {
        modal.addEventListener("click", function (event) {
            if (event.target === modal || event.target.classList.contains("modal-close")) {
                setDrinkModal(false);
            }
        });
    }

    if (addCartForm) {
        addCartForm.addEventListener("change", updateModalTotal);

        var modalQuantityButtons = addCartForm.querySelectorAll("[data-modal-quantity]");
        for (var quantityIndex = 0; quantityIndex < modalQuantityButtons.length; quantityIndex++) {
            modalQuantityButtons[quantityIndex].addEventListener("click", function () {
                var quantityInput = addCartForm.querySelector("input[name='quantity']");
                var nextValue = Number(quantityInput.value) + Number(this.getAttribute("data-modal-quantity"));
                quantityInput.value = Math.min(99, Math.max(1, nextValue));
                updateModalTotal();
            });
        }

        addCartForm.addEventListener("submit", function (event) {
            event.preventDefault();
            var submitButton = addCartForm.querySelector("button[type='submit']");
            var submitLabel = submitButton.querySelector("span");
            submitButton.disabled = true;
            submitLabel.textContent = "Đang thêm...";

            postCart(new FormData(addCartForm), function () {
                submitButton.disabled = false;
                submitLabel.textContent = "Thêm vào giỏ";
                setDrinkModal(false);
                showToast("Đã thêm vào giỏ hàng");
            }, function () {
                submitButton.disabled = false;
                submitLabel.textContent = "Thêm vào giỏ";
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
            var lineTotalElement = rows[i].querySelector(".line-total");
            if (lineTotalElement) lineTotalElement.textContent = formatVnd(lineTotal);
        }
        var totalElement = document.getElementById("cartTotal");
        if (totalElement) totalElement.textContent = formatVnd(total);
    }

    var quantityButtons = document.querySelectorAll(".qty-btn");
    for (var checkoutQuantityIndex = 0; checkoutQuantityIndex < quantityButtons.length; checkoutQuantityIndex++) {
        quantityButtons[checkoutQuantityIndex].addEventListener("click", function () {
            var row = this.closest(".cart-item");
            var input = row.querySelector("input[type='number']");
            var oldQuantity = Number(input.value) || 1;
            var nextQuantity = Math.max(1, oldQuantity + Number(this.getAttribute("data-delta")));
            if (nextQuantity === oldQuantity) return;
            input.value = nextQuantity;

            var formData = new FormData();
            formData.append("action", "update");
            formData.append("ajax", "true");
            formData.append("cartKey", this.getAttribute("data-cart-key"));
            formData.append("quantity", nextQuantity);
            postCart(formData, function () {
                updateCheckoutTotal();
                showToast("Đã cập nhật giỏ hàng");
            }, function () {
                input.value = oldQuantity;
            });
        });
    }

    var removeButtons = document.querySelectorAll(".remove-btn");
    for (var removeIndex = 0; removeIndex < removeButtons.length; removeIndex++) {
        removeButtons[removeIndex].addEventListener("click", function () {
            var row = this.closest(".cart-item");
            var formData = new FormData();
            formData.append("action", "remove");
            formData.append("ajax", "true");
            formData.append("cartKey", this.getAttribute("data-cart-key"));
            postCart(formData, function (data) {
                row.style.display = "none";
                updateCheckoutTotal();
                showToast("Đã xóa món khỏi giỏ");
                if (data.count === 0) window.location.reload();
            });
        });
    }

    var clearCartButton = document.getElementById("clearCartButton");
    if (clearCartButton) {
        clearCartButton.addEventListener("click", function () {
            if (!window.confirm("Xóa toàn bộ món trong giỏ hàng?")) return;
            var formData = new FormData();
            formData.append("action", "clear");
            formData.append("ajax", "true");
            clearCartButton.disabled = true;
            postCart(formData, function () {
                window.location.reload();
            }, function () {
                clearCartButton.disabled = false;
            });
        });
    }

    var orderModal = document.getElementById("orderModal");
    var orderOpeners = document.querySelectorAll("[data-open-orders]");
    var orderClosers = document.querySelectorAll("[data-close-orders]");

    function setOrderModal(open) {
        if (!orderModal) return;
        orderModal.classList.toggle("is-open", open);
        orderModal.setAttribute("aria-hidden", open ? "false" : "true");
        document.body.style.overflow = open ? "hidden" : "";
    }

    for (var orderOpenIndex = 0; orderOpenIndex < orderOpeners.length; orderOpenIndex++) {
        orderOpeners[orderOpenIndex].addEventListener("click", function () {
            setOrderModal(true);
        });
    }

    for (var orderCloseIndex = 0; orderCloseIndex < orderClosers.length; orderCloseIndex++) {
        orderClosers[orderCloseIndex].addEventListener("click", function () {
            setOrderModal(false);
        });
    }

    document.addEventListener("keydown", function (event) {
        if (event.key === "Escape") {
            setOrderModal(false);
            setDrinkModal(false);
        }
    });
})();

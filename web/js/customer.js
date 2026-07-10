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
        if (!toast)
            return;
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
                        return {ok: response.ok, data: data};
                    });
                })
                .then(function (result) {
                    if (!result.ok || !result.data.success) {
                        throw new Error(result.data.message || "Không thể cập nhật giỏ hàng.");
                    }
                    updateCartBadges(result.data.count);
                    if (callback)
                        callback(result.data);
                })
                .catch(function (error) {
                    showToast(error.message || "Kết nối bị gián đoạn. Vui lòng thử lại.");
                    if (errorCallback)
                        errorCallback(error);
                });
    }

    function updateModalTotal() {
        if (!addCartForm)
            return;
        var basePrice = Number(addCartForm.getAttribute("data-base-price")) || 0;
        var selectedSize = addCartForm.querySelector("input[name='selectedSize']:checked");
        var sizeExtra = 0;
        if (selectedSize && selectedSize.value === "L")
            sizeExtra = 5000;
        if (selectedSize && selectedSize.value === "S")
            sizeExtra = -3000;

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
        if (!modal)
            return;
        modal.classList.toggle("is-open", open);
        modal.setAttribute("aria-hidden", open ? "false" : "true");
        document.body.style.overflow = open ? "hidden" : "";
    }

    function openDrinkModal(button) {
        if (!modal || !addCartForm)
            return;

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
            productImage.src = cardImage ? cardImage.src : contextPath + "/" + button.getAttribute("data-product-image");
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
            if (rows[i].style.display === "none")
                continue;
            var unit = Number(rows[i].getAttribute("data-unit-price")) || 0;
            var quantityInput = rows[i].querySelector("input[type='number']");
            var quantity = Number(quantityInput.value) || 1;
            var lineTotal = unit * quantity;
            total += lineTotal;
            var lineTotalElement = rows[i].querySelector(".line-total");
            if (lineTotalElement)
                lineTotalElement.textContent = formatVnd(lineTotal);
        }
        var totalElement = document.getElementById("cartTotal");
        if (totalElement)
            totalElement.textContent = formatVnd(total);
    }

    var quantityButtons = document.querySelectorAll(".qty-btn");
    for (var checkoutQuantityIndex = 0; checkoutQuantityIndex < quantityButtons.length; checkoutQuantityIndex++) {
        quantityButtons[checkoutQuantityIndex].addEventListener("click", function () {
            var row = this.closest(".cart-item");
            var input = row.querySelector("input[type='number']");
            var oldQuantity = Number(input.value) || 1;
            var nextQuantity = Math.max(1, oldQuantity + Number(this.getAttribute("data-delta")));
            if (nextQuantity === oldQuantity)
                return;
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
                if (data.count === 0)
                    window.location.reload();
            });
        });
    }

    var clearCartButton = document.getElementById("clearCartButton");
    if (clearCartButton) {
        clearCartButton.addEventListener("click", function () {
            if (!window.confirm("Xóa toàn bộ món trong giỏ hàng?"))
                return;
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
        if (!orderModal)
            return;
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

    var passwordToggles = document.querySelectorAll("[data-toggle-password]");
    for (var passwordIndex = 0; passwordIndex < passwordToggles.length; passwordIndex++) {
        passwordToggles[passwordIndex].addEventListener("click", function () {
            var input = document.getElementById(this.getAttribute("data-toggle-password"));
            if (!input)
                return;
            var showPassword = input.type === "password";
            input.type = showPassword ? "text" : "password";
            this.textContent = showPassword ? "Ẩn" : "Hiện";
        });
    }

    function setupMenuPagination() {
        var sections = document.querySelectorAll(".product-section");
        var pageSize = 7;

        function renderPage(targetSection, targetCards, targetPagination, page) {
            for (var cardIndex = 0; cardIndex < targetCards.length; cardIndex++) {
                var firstIndex = page * pageSize;
                var lastIndex = firstIndex + pageSize;
                targetCards[cardIndex].style.display = cardIndex >= firstIndex && cardIndex < lastIndex ? "" : "none";
            }

            var buttons = targetPagination.querySelectorAll(".menu-page-btn");
            for (var buttonIndex = 0; buttonIndex < buttons.length; buttonIndex++) {
                buttons[buttonIndex].classList.toggle("is-active", Number(buttons[buttonIndex].getAttribute("data-page")) === page);
            }
        }

        function buildPagination(section, cards, totalPages, grid) {
            var pagination = document.createElement("div");
            pagination.className = "menu-pagination";
            pagination.setAttribute("aria-label", "Phan trang san pham");
            grid.insertAdjacentElement("afterend", pagination);

            for (var pageIndex = 0; pageIndex < totalPages; pageIndex++) {
                var button = document.createElement("button");
                button.type = "button";
                button.className = "menu-page-btn";
                button.textContent = String(pageIndex + 1);
                button.setAttribute("data-page", String(pageIndex));
                pagination.appendChild(button);

                button.addEventListener("click", function () {
                    var nextPage = Number(this.getAttribute("data-page")) || 0;
                    renderPage(section, cards, pagination, nextPage);
                    section.scrollIntoView({behavior: "smooth", block: "start"});
                });
            }

            renderPage(section, cards, pagination, 0);
        }

        for (var sectionIndex = 0; sectionIndex < sections.length; sectionIndex++) {
            var section = sections[sectionIndex];
            var grid = section.querySelector(".product-grid");

            if (!grid)
                continue;

            var cards = grid.querySelectorAll(".product-card");
            var totalPages = Math.ceil(cards.length / pageSize);

            if (totalPages <= 1)
                continue;

            buildPagination(section, cards, totalPages, grid);
        }
    }

    document.addEventListener("keydown", function (event) {
        if (event.key === "Escape") {
            setOrderModal(false);
            setDrinkModal(false);
        }
    });
})();

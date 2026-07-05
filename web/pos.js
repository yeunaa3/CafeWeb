(function () {
    var body = document.body;
    var contextPath = body ? body.getAttribute("data-context-path") || "" : "";
    var cartList = document.getElementById("cartList");
    var emptyCart = document.getElementById("emptyCart");
    var heldOrders = document.getElementById("heldOrders");
    var toast = document.getElementById("posToast");
    var discountCodeInput = document.getElementById("discountCode");
    var discountHint = document.getElementById("discountHint");
    var holdLabelInput = document.getElementById("holdLabel");

    var cartItems = [];
    var activeDiscount = { code: "", type: "none", value: 0 };

    function formatVnd(value) {
        return Math.round(Number(value) || 0).toLocaleString("vi-VN") + "đ";
    }

    function showToast(message) {
        if (!toast) return;
        toast.textContent = message;
        toast.classList.add("is-visible");
        window.setTimeout(function () {
            toast.classList.remove("is-visible");
        }, 1800);
    }

    function sizeExtra(size) {
        if (size === "L") return 5000;
        return 0;
    }

    function getUnitPrice(item) {
        return Number(item.price) + sizeExtra(item.size);
    }

    function findCartItem(id) {
        for (var i = 0; i < cartItems.length; i++) {
            if (cartItems[i].id === id) {
                return cartItems[i];
            }
        }
        return null;
    }

    function addProduct(button) {
        var id = button.getAttribute("data-id");
        var existing = findCartItem(id);
        if (existing && existing.size === "M" && !existing.note) {
            existing.quantity += 1;
        } else {
            cartItems.push({
                id: id,
                name: button.getAttribute("data-name"),
                size: "M",
                quantity: 1,
                price: Number(button.getAttribute("data-price")) || 0,
                note: "",
                image: button.getAttribute("data-image") || ""
            });
        }
        renderCart();
        showToast("Đã thêm món vào giỏ.");
    }

    function renderCart() {
        if (!cartList) return;
        var rows = cartList.querySelectorAll(".cart-row");
        for (var i = 0; i < rows.length; i++) {
            rows[i].remove();
        }

        if (emptyCart) {
            emptyCart.style.display = cartItems.length ? "none" : "grid";
        }

        for (var j = 0; j < cartItems.length; j++) {
            cartList.appendChild(createCartRow(cartItems[j], j));
        }
        updateCartTotal();
    }

    function createCartRow(item, index) {
        var article = document.createElement("article");
        article.className = "cart-row";
        article.setAttribute("data-index", index);

        var img = document.createElement("img");
        img.src = contextPath + "/assets/images/" + item.image;
        img.alt = item.name;
        img.onerror = function () {
            this.onerror = null;
            this.src = "https://images.unsplash.com/photo-1572490122747-3968b75cc699?auto=format&fit=crop&w=240&q=80";
        };

        var main = document.createElement("div");
        main.className = "cart-main";
        main.innerHTML =
            '<div class="cart-title">' +
            '<strong></strong>' +
            '<span data-line-total></span>' +
            '</div>' +
            '<div class="cart-options">' +
            '<select data-field="size" aria-label="Size">' +
            '<option value="M">Size M</option>' +
            '<option value="L">Size L +5.000đ</option>' +
            '</select>' +
            '<input data-field="note" type="text" placeholder="Ghi chú: ít đá, ít đường...">' +
            '</div>';
        main.querySelector("strong").textContent = item.name;
        main.querySelector("select").value = item.size;
        main.querySelector("input").value = item.note;

        var controls = document.createElement("div");
        controls.className = "quantity-box";
        controls.innerHTML =
            '<button type="button" data-qty="-1">-</button>' +
            '<input data-field="quantity" type="number" min="1" value="' + item.quantity + '">' +
            '<button type="button" data-qty="1">+</button>' +
            '<button class="remove-line" type="button" data-remove-line>Xóa món</button>';

        article.appendChild(img);
        article.appendChild(main);
        article.appendChild(controls);
        updateLineTotal(article, item);
        return article;
    }

    function updateLineTotal(row, item) {
        var lineTotal = row.querySelector("[data-line-total]");
        if (lineTotal) {
            lineTotal.textContent = formatVnd(getUnitPrice(item) * item.quantity);
        }
    }

    function applyDiscount(subtotal) {
        if (activeDiscount.type === "percent") {
            return subtotal * activeDiscount.value;
        }
        if (activeDiscount.type === "fixed") {
            return Math.min(subtotal, activeDiscount.value);
        }
        return 0;
    }

    function updateCartTotal() {
        var subtotal = 0;
        var itemCount = 0;

        for (var i = 0; i < cartItems.length; i++) {
            subtotal += getUnitPrice(cartItems[i]) * cartItems[i].quantity;
            itemCount += cartItems[i].quantity;
        }

        var discount = applyDiscount(subtotal);
        var taxable = Math.max(0, subtotal - discount);
        var vat = taxable * 0.1;
        var grandTotal = taxable + vat;
        var points = Math.floor(grandTotal / 1000);

        setText("itemCount", itemCount);
        setText("subtotalText", formatVnd(subtotal));
        setText("discountText", formatVnd(discount));
        setText("vatText", formatVnd(vat));
        setText("pointsText", points);
        setText("grandTotalText", formatVnd(grandTotal));

        return {
            subtotal: subtotal,
            discount: discount,
            vat: vat,
            points: points,
            grandTotal: grandTotal,
            discountCode: activeDiscount.code
        };
    }

    function setText(id, value) {
        var element = document.getElementById(id);
        if (element) {
            element.textContent = value;
        }
    }

    function handleCartEvent(event) {
        var row = event.target.closest(".cart-row");
        if (!row) return;

        var index = Number(row.getAttribute("data-index"));
        var item = cartItems[index];
        if (!item) return;

        if (event.target.hasAttribute("data-qty")) {
            item.quantity = Math.max(1, item.quantity + Number(event.target.getAttribute("data-qty")));
            renderCart();
            return;
        }

        if (event.target.hasAttribute("data-remove-line")) {
            cartItems.splice(index, 1);
            renderCart();
            return;
        }

        if (event.type === "input" || event.type === "change") {
            var field = event.target.getAttribute("data-field");
            if (field === "quantity") {
                item.quantity = Math.max(1, Number(event.target.value) || 1);
            }
            if (field === "size") {
                item.size = event.target.value;
            }
            if (field === "note") {
                item.note = event.target.value;
            }
            updateLineTotal(row, item);
            updateCartTotal();
        }
    }

    function applyDiscountCode() {
        var code = (discountCodeInput ? discountCodeInput.value : "").trim().toUpperCase();
        if (code === "CAFE10") {
            activeDiscount = { code: code, type: "percent", value: 0.1 };
            discountHint.textContent = "Đã áp dụng CAFE10: giảm 10%.";
            showToast("Đã áp dụng mã giảm giá.");
        } else if (code === "SALE20") {
            activeDiscount = { code: code, type: "fixed", value: 20000 };
            discountHint.textContent = "Đã áp dụng SALE20: giảm 20.000đ.";
            showToast("Đã áp dụng mã giảm giá.");
        } else if (!code) {
            activeDiscount = { code: "", type: "none", value: 0 };
            discountHint.textContent = "CAFE10 giảm 10%, SALE20 giảm 20.000đ.";
        } else {
            activeDiscount = { code: "", type: "none", value: 0 };
            discountHint.textContent = "Mã không hợp lệ hoặc đã hết hạn.";
            showToast("Mã giảm giá không hợp lệ.");
        }
        updateCartTotal();
    }

    function postHoldOrder(formData, callback) {
        fetch(contextPath + "/hold-order", {
            method: "POST",
            body: formData
        })
            .then(function (response) { return response.json(); })
            .then(callback)
            .catch(function () {
                showToast("Không thể xử lý đơn tạm.");
            });
    }

    function holdCurrentOrder() {
        if (!cartItems.length) {
            showToast("Giỏ hàng đang trống.");
            return;
        }

        var formData = new FormData();
        formData.append("action", "hold");
        formData.append("label", holdLabelInput && holdLabelInput.value ? holdLabelInput.value : "Khách lẻ");
        formData.append("cartJson", JSON.stringify(cartItems));
        formData.append("totalsJson", JSON.stringify(updateCartTotal()));

        postHoldOrder(formData, function (data) {
            if (!data || !data.success) {
                showToast("Không thể giữ đơn.");
                return;
            }
            addHeldOrderCard(data.order);
            cartItems = [];
            if (holdLabelInput) holdLabelInput.value = "";
            renderCart();
            showToast("Đã giữ đơn và làm trống màn hình.");
        });
    }

    function recallOrder(holdId) {
        var formData = new FormData();
        formData.append("action", "recall");
        formData.append("holdId", holdId);
        postHoldOrder(formData, function (data) {
            if (!data || !data.success) {
                showToast("Không tìm thấy đơn tạm.");
                return;
            }
            cartItems = data.order.cart || [];
            if (discountCodeInput) {
                discountCodeInput.value = data.order.totals && data.order.totals.discountCode ? data.order.totals.discountCode : "";
            }
            applyDiscountCode();
            renderCart();
            removeHeldOrder(holdId);
            showToast("Đã khôi phục đơn.");
        });
    }

    function removeHeldOrder(holdId) {
        var formData = new FormData();
        formData.append("action", "remove");
        formData.append("holdId", holdId);
        postHoldOrder(formData, function () {
            var card = heldOrders ? heldOrders.querySelector('[data-held-id="' + holdId + '"]') : null;
            if (card) card.remove();
            ensureHeldEmptyState();
        });
    }

    function addHeldOrderCard(order) {
        if (!heldOrders || !order) return;
        var empty = heldOrders.querySelector("[data-empty-held]");
        if (empty) empty.remove();

        var card = document.createElement("article");
        card.className = "held-card";
        card.setAttribute("data-held-id", order.holdId);
        card.innerHTML =
            '<span><strong></strong><small></small></span>' +
            '<button type="button" data-recall-order="' + order.holdId + '">Recall</button>';
        card.querySelector("strong").textContent = order.label;
        card.querySelector("small").textContent = order.createdTime;
        heldOrders.insertBefore(card, heldOrders.firstChild);
    }

    function ensureHeldEmptyState() {
        if (!heldOrders || heldOrders.querySelector(".held-card")) return;
        var empty = document.createElement("p");
        empty.className = "muted";
        empty.setAttribute("data-empty-held", "");
        empty.textContent = "Chưa có đơn tạm.";
        heldOrders.appendChild(empty);
    }

    function completePayment() {
        if (!cartItems.length) {
            showToast("Giỏ hàng đang trống.");
            return;
        }
        cartItems = [];
        activeDiscount = { code: "", type: "none", value: 0 };
        if (discountCodeInput) discountCodeInput.value = "";
        if (holdLabelInput) holdLabelInput.value = "";
        if (discountHint) discountHint.textContent = "CAFE10 giảm 10%, SALE20 giảm 20.000đ.";
        renderCart();
        showToast("Đã xác nhận thanh toán.");
    }

    document.addEventListener("click", function (event) {
        var productButton = event.target.closest("[data-add-product]");
        if (productButton) {
            addProduct(productButton);
            return;
        }

        var recallButton = event.target.closest("[data-recall-order]");
        if (recallButton) {
            recallOrder(recallButton.getAttribute("data-recall-order"));
            return;
        }

        handleCartEvent(event);
    });

    if (cartList) {
        cartList.addEventListener("input", handleCartEvent);
        cartList.addEventListener("change", handleCartEvent);
    }

    document.getElementById("applyDiscountBtn").addEventListener("click", applyDiscountCode);
    document.getElementById("holdOrderBtn").addEventListener("click", holdCurrentOrder);
    document.getElementById("confirmPaymentBtn").addEventListener("click", completePayment);
    document.getElementById("payButton").addEventListener("click", completePayment);

    if (discountCodeInput) {
        discountCodeInput.addEventListener("input", function () {
            if (!this.value.trim()) {
                applyDiscountCode();
            }
        });
    }

    window.cartItems = cartItems;
    renderCart();
})();

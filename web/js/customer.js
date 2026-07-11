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

(function () {
    "use strict";

    function ready(callback) {
        if (document.readyState === "loading") {
            document.addEventListener("DOMContentLoaded", callback);
        } else {
            callback();
        }
    }

    ready(function () {
        setupMenuCarousels();
    });

    function setupMenuCarousels() {
        var grids = document.querySelectorAll(".product-section .product-grid");

        for (var gridIndex = 0; gridIndex < grids.length; gridIndex++) {
            setupOneCarousel(grids[gridIndex], gridIndex);
        }
    }

    function setupOneCarousel(grid, index) {
        var cards = grid.querySelectorAll(".product-card");

        if (cards.length < 2) {
            return;
        }

        grid.classList.add("is-carousel-ready");
        grid.setAttribute("data-carousel-index", String(index));

        var isPointerDown = false;
        var isPaused = false;
        var startX = 0;
        var startScrollLeft = 0;
        var speed = 0.35 + (index % 3) * 0.04;
        var frameId = 0;
        var lastFrameTime = 0;

        grid.addEventListener("mouseenter", function () {
            isPaused = true;
        });

        grid.addEventListener("mouseleave", function () {
            isPaused = false;
            isPointerDown = false;
            grid.classList.remove("is-dragging");
        });

        grid.addEventListener("focusin", function () {
            isPaused = true;
        });

        grid.addEventListener("focusout", function () {
            isPaused = false;
        });

        grid.addEventListener("pointerdown", function (event) {
            isPointerDown = true;
            isPaused = true;
            startX = event.clientX;
            startScrollLeft = grid.scrollLeft;
            grid.classList.add("is-dragging");
            if (grid.setPointerCapture) {
                grid.setPointerCapture(event.pointerId);
            }
        });

        grid.addEventListener("pointermove", function (event) {
            if (!isPointerDown) {
                return;
            }
            var deltaX = event.clientX - startX;
            grid.scrollLeft = startScrollLeft - deltaX;
        });

        grid.addEventListener("pointerup", stopDragging);
        grid.addEventListener("pointercancel", stopDragging);

        grid.addEventListener("wheel", function (event) {
            if (Math.abs(event.deltaY) <= Math.abs(event.deltaX)) {
                return;
            }
            grid.scrollLeft += event.deltaY;
            event.preventDefault();
        }, { passive: false });

        function stopDragging() {
            isPointerDown = false;
            isPaused = false;
            grid.classList.remove("is-dragging");
        }

        function animate(timestamp) {
            if (!lastFrameTime) {
                lastFrameTime = timestamp;
            }

            var elapsed = Math.min(timestamp - lastFrameTime, 40);
            lastFrameTime = timestamp;

            if (!isPaused && !isPointerDown && grid.scrollWidth > grid.clientWidth + 4) {
                grid.scrollLeft += speed * elapsed;

                if (grid.scrollLeft >= grid.scrollWidth - grid.clientWidth - 2) {
                    grid.scrollLeft = 0;
                }
            }

            frameId = window.requestAnimationFrame(animate);
        }

        frameId = window.requestAnimationFrame(animate);

        window.addEventListener("beforeunload", function () {
            window.cancelAnimationFrame(frameId);
        });
    }
})();
(function () {
    "use strict";

    function ready(callback) {
        if (document.readyState === "loading") {
            document.addEventListener("DOMContentLoaded", callback);
        } else {
            callback();
        }
    }

    ready(function () {
        hardenMenuCarouselLayout();
        window.addEventListener("resize", hardenMenuCarouselLayout);
    });

    function hardenMenuCarouselLayout() {
        var grids = document.querySelectorAll(".product-section .product-grid");
        var smallScreen = window.matchMedia("(max-width: 980px)").matches;

        for (var i = 0; i < grids.length; i++) {
            var grid = grids[i];
            grid.style.display = "flex";
            grid.style.flexDirection = "row";
            grid.style.flexWrap = "nowrap";
            grid.style.overflowX = "auto";
            grid.style.overflowY = "hidden";
            grid.style.alignItems = "stretch";

            var cards = grid.querySelectorAll(".product-card");
            for (var c = 0; c < cards.length; c++) {
                var basis = smallScreen ? "74vw" : "224px";
                cards[c].style.flex = "0 0 " + basis;
                cards[c].style.width = basis;
                cards[c].style.minWidth = basis;
                cards[c].style.maxWidth = smallScreen ? "330px" : "224px";
            }
        }
    }
})();
(function () {
    "use strict";

    function markMenuPage() {
        if (!document.querySelector(".menu-heading")) {
            return;
        }
        document.body.classList.add("menu-page-enhanced");
    }

    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", markMenuPage);
    } else {
        markMenuPage();
    }
}());
(function () {
    "use strict";

    function stabilizeMenuInteractions() {
        var grids = document.querySelectorAll(".product-section .product-grid");
        var buttons = document.querySelectorAll(".add-product-btn");

        for (var i = 0; i < grids.length; i++) {
            grids[i].addEventListener("wheel", function (event) {
                event.stopImmediatePropagation();
            }, { capture: true, passive: true });
        }

        for (var b = 0; b < buttons.length; b++) {
            buttons[b].addEventListener("pointerdown", function (event) {
                event.stopPropagation();
            }, true);
            buttons[b].addEventListener("pointerup", function (event) {
                event.stopPropagation();
            }, true);
            buttons[b].addEventListener("click", function (event) {
                event.stopPropagation();
            }, true);
        }
    }

    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", stabilizeMenuInteractions);
    } else {
        stabilizeMenuInteractions();
    }
}());
(function () {
    "use strict";

    function formatVndFallback(value) {
        return Math.round(Number(value) || 0).toLocaleString("vi-VN");
    }

    function setText(id, value) {
        var element = document.getElementById(id);
        if (element) {
            element.textContent = value;
        }
    }

    function setValue(id, value) {
        var element = document.getElementById(id);
        if (element) {
            element.value = value;
        }
    }

    function openDrinkModalFallback(button) {
        var modal = document.getElementById("drinkModal");
        var form = document.getElementById("addCartForm");

        if (!modal || !form || !button) {
            return;
        }

        var productCard = button.closest(".product-card");
        var cardImage = productCard ? productCard.querySelector("img") : null;
        var productId = button.getAttribute("data-product-id") || "";
        var productName = button.getAttribute("data-product-name") || "Chọn món";
        var productPrice = Number(button.getAttribute("data-product-price")) || 0;
        var productImage = document.getElementById("modalProductImage");
        var quantityInput;
        var mediumSize;

        form.reset();
        form.setAttribute("data-base-price", String(productPrice));

        setValue("modalProductId", productId);
        setText("modalProductName", productName);
        setText("modalProductPrice", formatVndFallback(productPrice) + "đ");
        setText("modalTotal", formatVndFallback(productPrice) + "đ");

        quantityInput = form.querySelector("input[name='quantity']");
        if (quantityInput) {
            quantityInput.value = "1";
        }

        mediumSize = form.querySelector("input[name='selectedSize'][value='M']");
        if (mediumSize) {
            mediumSize.checked = true;
        }

        if (productImage) {
            productImage.src = cardImage && cardImage.currentSrc ? cardImage.currentSrc : (cardImage ? cardImage.src : "");
            productImage.alt = productName;
        }

        modal.classList.add("is-open");
        modal.setAttribute("aria-hidden", "false");
        document.body.style.overflow = "hidden";
    }

    document.addEventListener("click", function (event) {
        var button = event.target.closest(".add-product-btn");

        if (!button) {
            return;
        }

        openDrinkModalFallback(button);
    }, true);
}());
(function () {
    "use strict";

    function installProductScrollRails() {
        var grids = document.querySelectorAll(".product-section .product-grid");

        for (var i = 0; i < grids.length; i++) {
            installOneRail(grids[i]);
        }
    }

    function installOneRail(grid) {
        var rail = grid.parentElement.querySelector(".menu-scrollbar");
        var thumb;
        var dragging = false;
        var dragStartX = 0;
        var dragStartLeft = 0;

        if (!rail) {
            rail = document.createElement("div");
            rail.className = "menu-scrollbar";
            rail.setAttribute("aria-hidden", "true");
            thumb = document.createElement("span");
            thumb.className = "menu-scrollbar-thumb";
            rail.appendChild(thumb);
            grid.insertAdjacentElement("afterend", rail);
        } else {
            thumb = rail.querySelector(".menu-scrollbar-thumb");
        }

        if (!thumb) {
            return;
        }

        function getMaxScroll() {
            return Math.max(0, grid.scrollWidth - grid.clientWidth);
        }

        function getMaxThumbLeft() {
            return Math.max(0, rail.clientWidth - thumb.offsetWidth);
        }

        function updateThumb() {
            var maxScroll = getMaxScroll();
            var ratio = grid.scrollWidth > 0 ? grid.clientWidth / grid.scrollWidth : 1;
            var width = Math.max(54, Math.round(rail.clientWidth * Math.min(1, ratio)));
            var left = maxScroll > 0 ? Math.round((grid.scrollLeft / maxScroll) * Math.max(0, rail.clientWidth - width)) : 0;

            thumb.style.width = width + "px";
            thumb.style.transform = "translateX(" + left + "px)";
        }

        function moveFromPointer(clientX) {
            var delta = clientX - dragStartX;
            var nextLeft = Math.max(0, Math.min(getMaxThumbLeft(), dragStartLeft + delta));
            var maxScroll = getMaxScroll();
            grid.scrollLeft = getMaxThumbLeft() > 0 ? (nextLeft / getMaxThumbLeft()) * maxScroll : 0;
            updateThumb();
        }

        grid.addEventListener("scroll", updateThumb, { passive: true });
        window.addEventListener("resize", updateThumb);

        rail.addEventListener("pointerdown", function (event) {
            dragging = true;
            rail.classList.add("is-dragging");
            dragStartX = event.clientX;
            dragStartLeft = parseFloat((thumb.style.transform || "translateX(0px)").replace(/[^0-9.-]/g, "")) || 0;

            if (event.target === rail) {
                var rect = rail.getBoundingClientRect();
                dragStartLeft = Math.max(0, Math.min(getMaxThumbLeft(), event.clientX - rect.left - thumb.offsetWidth / 2));
                moveFromPointer(event.clientX);
            }

            if (rail.setPointerCapture) {
                rail.setPointerCapture(event.pointerId);
            }
        });

        rail.addEventListener("pointermove", function (event) {
            if (!dragging) {
                return;
            }
            moveFromPointer(event.clientX);
        });

        function stopDragging() {
            dragging = false;
            rail.classList.remove("is-dragging");
        }

        rail.addEventListener("pointerup", stopDragging);
        rail.addEventListener("pointercancel", stopDragging);

        var images = grid.querySelectorAll("img");
        for (var i = 0; i < images.length; i++) {
            images[i].addEventListener("load", updateThumb, { once: true });
        }

        window.setTimeout(updateThumb, 0);
        window.setTimeout(updateThumb, 300);
    }

    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", installProductScrollRails);
    } else {
        installProductScrollRails();
    }
}());
(function () {
    "use strict";

    function removeCustomMenuScrollRails() {
        var rails = document.querySelectorAll(".product-section .menu-scrollbar");
        for (var i = 0; i < rails.length; i++) {
            rails[i].remove();
        }
    }

    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", removeCustomMenuScrollRails);
    } else {
        removeCustomMenuScrollRails();
    }
}());
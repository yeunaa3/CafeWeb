<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>POS - Cafe & Bubble tea</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/pos.css">
    </head>
    <body data-context-path="${pageContext.request.contextPath}">
        <main class="pos-shell">
            <header class="pos-topbar">
                <div>
                    <span class="eyebrow">Cafe & Bubble tea</span>
                    <h1>POS Bán Hàng</h1>
                </div>
                <form class="pos-search" action="${pageContext.request.contextPath}/pos" method="get">
                    <input type="search" name="keyword" value="${keyword}" placeholder="Tìm món nhanh">
                    <button type="submit">Tìm</button>
                </form>
            </header>

            <section class="pos-layout">
                <aside class="menu-panel">
                    <div class="panel-heading">
                        <div>
                            <span class="eyebrow">Menu</span>
                            <h2>Chọn món</h2>
                        </div>
                    </div>

                    <div class="product-stack">
                        <c:forEach var="section" items="${sections}">
                            <c:if test="${not empty section.products}">
                                <div class="category-block">
                                    <h3>${section.category.categoryName}</h3>
                                    <div class="product-list">
                                        <c:forEach var="product" items="${section.products}">
                                            <button class="product-tile"
                                                    type="button"
                                                    data-add-product
                                                    data-id="${product.productId}"
                                                    data-name="${product.productName}"
                                                    data-price="${product.price}"
                                                    data-image="${product.imageUrl}">
                                                <img src="${pageContext.request.contextPath}/assets/images/${product.imageUrl}"
                                                     onerror="this.onerror=null;this.src='https://images.unsplash.com/photo-1551024601-bec78aea704b?auto=format&fit=crop&w=220&q=80';"
                                                     alt="${product.productName}">
                                                <span>
                                                    <strong>${product.productName}</strong>
                                                    <em><fmt:formatNumber value="${product.price}" pattern="#,##0"/>đ</em>
                                                </span>
                                            </button>
                                        </c:forEach>
                                    </div>
                                </div>
                            </c:if>
                        </c:forEach>
                    </div>

                    <div class="held-orders">
                        <div class="panel-heading compact">
                            <div>
                                <span class="eyebrow">Hold / Recall</span>
                                <h2>Đơn đang giữ</h2>
                            </div>
                        </div>
                        <div class="held-list" id="heldOrders">
                            <c:choose>
                                <c:when test="${empty heldOrders}">
                                    <p class="muted" data-empty-held>Chưa có đơn tạm.</p>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="order" items="${heldOrders}">
                                        <article class="held-card" data-held-id="${order.holdId}">
                                            <span>
                                                <strong>${order.label}</strong>
                                                <small>${order.createdTime}</small>
                                            </span>
                                            <button type="button" data-recall-order="${order.holdId}">Recall</button>
                                        </article>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </aside>

                <section class="cart-panel">
                    <div class="panel-heading">
                        <div>
                            <span class="eyebrow">Current Order</span>
                            <h2>Giỏ hàng hiện tại</h2>
                        </div>
                        <span class="item-counter"><strong id="itemCount">0</strong> món</span>
                    </div>

                    <div class="cart-list" id="cartList">
                        <div class="empty-cart" id="emptyCart">
                            <strong>Chưa có món nào</strong>
                            <span>Chọn món từ menu để bắt đầu đơn mới.</span>
                        </div>
                    </div>

                    <div class="cart-actions">
                        <input class="customer-label" id="holdLabel" type="text" placeholder="Tên khách / số bàn">
                        <button class="soft-action" id="holdOrderBtn" type="button">Giữ Đơn</button>
                        <button class="confirm-action" id="confirmPaymentBtn" type="button">Xác Nhận Thanh Toán</button>
                    </div>
                </section>

                <aside class="bill-panel">
                    <div class="panel-heading">
                        <div>
                            <span class="eyebrow">Thanh Toán</span>
                            <h2>Chi tiết hóa đơn</h2>
                        </div>
                    </div>

                    <div class="discount-box">
                        <label for="discountCode">Gift Card / Mã Giảm Giá</label>
                        <div>
                            <input id="discountCode" type="text" placeholder="VD: CAFE10">
                            <button id="applyDiscountBtn" type="button">Apply</button>
                        </div>
                        <small id="discountHint">CAFE10 giảm 10%, SALE20 giảm 20.000đ.</small>
                    </div>

                    <div class="bill-lines">
                        <div>
                            <span>Tổng đơn</span>
                            <strong id="subtotalText">0đ</strong>
                        </div>
                        <div>
                            <span>Giảm giá</span>
                            <strong id="discountText">0đ</strong>
                        </div>
                        <div>
                            <span>Thuế VAT 10%</span>
                            <strong id="vatText">0đ</strong>
                        </div>
                        <div>
                            <span>Điểm tích lũy</span>
                            <strong><span id="pointsText">0</span> điểm</strong>
                        </div>
                    </div>

                    <div class="grand-total">
                        <span>Tổng tiền chốt hạ</span>
                        <strong id="grandTotalText">0đ</strong>
                    </div>

                    <button class="pay-button" id="payButton" type="button">Thanh Toán</button>
                    <p class="muted center">JavaScript giúp nhảy số theo thời gian thực không gây lag.</p>
                </aside>
            </section>
        </main>

        <div class="pos-toast" id="posToast"></div>
        <script src="${pageContext.request.contextPath}/assets/js/pos.js"></script>
    </body>
</html>

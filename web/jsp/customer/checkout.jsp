<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Checkout - Cafe & Bubble tea</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer.css">
    </head>
    <body data-context-path="${pageContext.request.contextPath}">
        <main class="page-shell checkout-shell">
            <header class="site-header">
                <a class="brand" href="${pageContext.request.contextPath}/home">Cafe & Bubble tea</a>
                <nav class="site-nav">
                    <a href="${pageContext.request.contextPath}/menu">Menu</a>
                    <a class="cart-link" href="${pageContext.request.contextPath}/checkout">Giỏ Hàng <span class="cart-count">${cartCount}</span></a>
                    <a href="${pageContext.request.contextPath}/home#contact">Liên Hệ</a>
                    <c:choose>
                        <c:when test="${not empty sessionScope.user}"><a class="customer-nav-avatar" href="${pageContext.request.contextPath}/profile" title="Thông tin cá nhân" aria-label="Thông tin cá nhân">${fn:substring(sessionScope.user.fullName,0,1)}</a></c:when>
                        <c:otherwise><a class="login-button" href="${pageContext.request.contextPath}/login?returnUrl=/checkout">Đăng nhập</a></c:otherwise>
                    </c:choose>
                </nav>
            </header>

            <section class="checkout-grid">
                <div>
                    <h1>Giỏ hàng</h1>
                    <c:if test="${not empty error}">
                        <p class="alert error-alert">${error}</p>
                    </c:if>
                    <c:if test="${not empty successOrderId}">
                        <p class="alert success-alert">Đặt hàng thành công. Mã đơn của bạn là #${successOrderId}. Đơn đang chờ duyệt.</p>
                    </c:if>

                    <c:choose>
                        <c:when test="${empty cart}">
                            <p class="empty-state">Giỏ hàng đang trống.</p>
                            <a class="primary-button" href="${pageContext.request.contextPath}/menu">Xem menu</a>
                        </c:when>
                        <c:otherwise>
                            <div class="cart-list">
                                <c:forEach var="item" items="${cart}">
                                    <article class="cart-item" data-cart-row="${item.cartKey}" data-unit-price="${item.unitPrice}">
                                        <img src="${pageContext.request.contextPath}/assets/images/${item.imageUrl}"
                                             onerror="this.onerror=null;this.src='https://images.unsplash.com/photo-1572490122747-3968b75cc699?auto=format&fit=crop&w=300&q=80';"
                                             alt="${item.productName}">
                                        <div>
                                            <h3>${item.productName}</h3>
                                            <p>Size ${item.selectedSize} · Đá ${item.iceLevel} · Đường ${item.sugarLevel}</p>
                                            <c:if test="${not empty item.toppings}">
                                                <p>
                                                    <c:forEach var="topping" items="${item.toppings}" varStatus="loop">
                                                        ${topping.toppingName}<c:if test="${not loop.last}">, </c:if>
                                                    </c:forEach>
                                                </p>
                                            </c:if>
                                            <strong><span class="line-total"><fmt:formatNumber value="${item.lineTotal}" pattern="#,##0"/></span>đ</strong>
                                        </div>
                                        <div class="quantity-control">
                                            <button type="button" class="qty-btn" data-cart-key="${item.cartKey}" data-delta="-1">-</button>
                                            <input type="number" value="${item.quantity}" min="1" readonly>
                                            <button type="button" class="qty-btn" data-cart-key="${item.cartKey}" data-delta="1">+</button>
                                            <button type="button" class="remove-btn" data-cart-key="${item.cartKey}">Xóa</button>
                                        </div>
                                    </article>
                                </c:forEach>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

                <form class="checkout-form" action="${pageContext.request.contextPath}/checkout" method="post">
                    <h2>Xác nhận đơn hàng</h2>
                    <label>Địa chỉ giao hàng *</label>
                    <input type="text" name="shippingAddress" value="<c:out value='${param.shippingAddress}'/>" placeholder="Nhập địa chỉ nhận hàng" required>
                    <label>Số điện thoại *</label>
                    <input type="tel" name="phone" value="<c:out value='${param.phone}'/>" placeholder="VD: 0909090909" required pattern="0[0-9]{9,10}">
                    <label>Mã giảm giá</label>
                    <input type="text" name="voucherCode" value="<c:out value='${param.voucherCode}'/>" placeholder="Nhập mã voucher (nếu có)">
                    <small class="form-hint">Voucher được kiểm tra hạn dùng và giá trị đơn tối thiểu khi đặt hàng.</small>
                    <label>Ghi chú</label>
                    <textarea name="note" rows="4" placeholder="Ghi chú thêm cho quán"><c:out value="${param.note}"/></textarea>
                    <div class="checkout-total">
                        <span>Tổng tiền</span>
                        <strong><span id="cartTotal"><fmt:formatNumber value="${cartTotal}" pattern="#,##0"/></span>đ</strong>
                    </div>
                    <c:choose>
                        <c:when test="${empty cart}">
                            <button class="primary-button wide-button" type="submit" disabled>Đặt hàng</button>
                        </c:when>
                        <c:otherwise>
                            <button class="primary-button wide-button" type="submit">Đặt hàng</button>
                        </c:otherwise>
                    </c:choose>
                    <c:if test="${not empty cart}">
                        <button class="clear-cart-button" id="clearCartButton" type="button">Xóa toàn bộ giỏ hàng</button>
                    </c:if>
                </form>
            </section>
        </main>
        <div class="toast" id="toast">Đã cập nhật giỏ hàng</div>
        <script src="${pageContext.request.contextPath}/assets/js/customer.js"></script>
    </body>
</html>

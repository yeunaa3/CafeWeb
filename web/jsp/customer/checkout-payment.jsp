<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Thanh toán online - Cafe & Bubble tea</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer.css?v=20260709-orderflow1">
    </head>
    <body data-context-path="${pageContext.request.contextPath}">
        <main class="page-shell checkout-shell payment-shell">
            <header class="site-header">
                <a class="brand" href="${pageContext.request.contextPath}/home">Cafe & Bubble tea</a>
                <nav class="site-nav">
                    <a href="${pageContext.request.contextPath}/menu">Menu</a>
                    <a class="cart-link" href="${pageContext.request.contextPath}/checkout">Giỏ hàng <span class="cart-count">${cartCount}</span></a>
                    <a href="${pageContext.request.contextPath}/home#contact">Liên hệ</a>
                    <c:if test="${not empty sessionScope.user}">
                        <a class="customer-nav-avatar" href="${pageContext.request.contextPath}/profile" title="Thông tin cá nhân" aria-label="Thông tin cá nhân">
                            <c:choose>
                                <c:when test="${not empty sessionScope.user.avatarUrl}">
                                    <span class="avatar-fallback" hidden>${fn:substring(sessionScope.user.fullName,0,1)}</span>
                                    <img src="${pageContext.request.contextPath}/${sessionScope.user.avatarUrl}" alt="" onerror="this.hidden=true;this.previousElementSibling.hidden=false;">
                                </c:when>
                                <c:otherwise>${fn:substring(sessionScope.user.fullName,0,1)}</c:otherwise>
                            </c:choose>
                        </a>
                    </c:if>
                </nav>
            </header>

            <section class="payment-grid">
                <div class="payment-panel">
                    <span class="payment-eyebrow">Thanh toán online</span>
                    <h1>Quét mã QR để hoàn tất đơn hàng</h1>
                    <p>Đơn chỉ được gửi sang hệ thống thu ngân sau khi bạn xác nhận đã thanh toán.</p>

                    <c:if test="${not empty error}">
                        <p class="alert error-alert">${error}</p>
                    </c:if>

                    <div class="payment-qr-card">
                        <img src="${pageContext.request.contextPath}/assets/images/payment-qr.jpg"
                             onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/assets/images/payment-qr.png';"
                             alt="QR thanh toán">
                        <div>
                            <strong>Nội dung chuyển khoản</strong>
                            <span>CBMS ${sessionScope.user.username}</span>
                        </div>
                    </div>

                    <form method="post" action="${pageContext.request.contextPath}/checkout/payment" class="payment-confirm-form">
                        <button class="primary-button wide-button" type="submit">Tôi đã thanh toán</button>
                        <a class="secondary-link" href="${pageContext.request.contextPath}/checkout">Quay lại giỏ hàng</a>
                    </form>
                </div>

                <aside class="payment-summary checkout-form">
                    <h2>Chi tiết thanh toán</h2>
                    <div class="payment-summary-list">
                        <div>
                            <span>Tạm tính</span>
                            <strong><fmt:formatNumber value="${cartTotal}" pattern="#,##0"/>đ</strong>
                        </div>
                        <div class="discount-row">
                            <span>Giảm giá</span>
                            <strong>-<fmt:formatNumber value="${appliedDiscount}" pattern="#,##0"/>đ</strong>
                        </div>
                        <div class="payment-total-row">
                            <span>Cần thanh toán</span>
                            <strong><fmt:formatNumber value="${payableTotal}" pattern="#,##0"/>đ</strong>
                        </div>
                    </div>
                    <dl class="payment-info">
                        <div>
                            <dt>Địa chỉ</dt>
                            <dd><c:out value="${shippingAddress}"/></dd>
                        </div>
                        <div>
                            <dt>Số điện thoại</dt>
                            <dd><c:out value="${phone}"/></dd>
                        </div>
                        <c:if test="${not empty voucherCode}">
                            <div>
                                <dt>Mã giảm giá</dt>
                                <dd><c:out value="${voucherCode}"/></dd>
                            </div>
                        </c:if>
                        <c:if test="${not empty note}">
                            <div>
                                <dt>Ghi chú</dt>
                                <dd><c:out value="${note}"/></dd>
                            </div>
                        </c:if>
                    </dl>
                </aside>
            </section>
        </main>
    </body>
</html>

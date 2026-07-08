<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Thu ngân - Đơn online</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer.css">
    </head>
    <body class="cashier-page" data-print-order-id="${printOrderId}">
        <main class="cashier-shell">
            <header class="cashier-header">
                <div>
                    <span class="page-kicker">Thu ngân</span>
                    <h1>Tiếp nhận đơn Online</h1>
                </div>
                <a class="primary-button" href="${pageContext.request.contextPath}/menu">Menu khách hàng</a>
            </header>

            <c:if test="${not empty error}">
                <p class="alert error-alert"><c:out value="${error}"/></p>
            </c:if>
            <c:if test="${not empty success}">
                <p class="alert success-alert"><c:out value="${success}"/></p>
            </c:if>

            <section class="cashier-board">
                <c:choose>
                    <c:when test="${empty orders}">
                        <p class="empty-state">Chưa có đơn online cần xử lý.</p>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="order" items="${orders}">
                            <article class="cashier-order" data-order-total="${order.totalPrice}">
                                <div class="cashier-order-main">
                                    <div class="order-title-row">
                                        <div>
                                            <span class="page-kicker">Đơn #${order.orderId}</span>
                                            <h2><c:out value="${empty order.customerName ? 'Khách online' : order.customerName}"/></h2>
                                        </div>
                                        <span class="status-pill status-${fn:toLowerCase(order.status)}">${order.displayStatus}</span>
                                    </div>

                                    <dl class="order-meta">
                                        <div>
                                            <dt>Thời gian</dt>
                                            <dd><fmt:formatDate value="${order.orderDate}" pattern="dd/MM/yyyy HH:mm"/></dd>
                                        </div>
                                        <div>
                                            <dt>Số điện thoại</dt>
                                            <dd><c:out value="${empty order.customerPhone ? 'Theo ghi chú đơn' : order.customerPhone}"/></dd>
                                        </div>
                                        <div>
                                            <dt>Địa chỉ</dt>
                                            <dd><c:out value="${order.shippingAddress}"/></dd>
                                        </div>
                                        <div>
                                            <dt>Thanh toán</dt>
                                            <dd><c:out value="${order.paymentMethod}"/></dd>
                                        </div>
                                    </dl>

                                    <div class="order-items">
                                        <c:forEach var="item" items="${order.items}">
                                            <span><c:out value="${item}"/></span>
                                        </c:forEach>
                                    </div>

                                    <c:if test="${not empty order.note}">
                                        <p class="order-note"><c:out value="${order.note}"/></p>
                                    </c:if>
                                </div>

                                <aside class="cashier-payment">
                                    <div class="payment-total">
                                        <span>Tổng tiền</span>
                                        <strong><fmt:formatNumber value="${order.totalPrice}" pattern="#,##0"/>đ</strong>
                                    </div>
                                    <c:if test="${order.discountAmount > 0}">
                                        <small>Đã giảm <fmt:formatNumber value="${order.discountAmount}" pattern="#,##0"/>đ</small>
                                    </c:if>

                                    <c:choose>
                                        <c:when test="${order.status eq 'Pending'}">
                                            <form method="post" action="${pageContext.request.contextPath}/cashier/orders">
                                                <input type="hidden" name="orderId" value="${order.orderId}">
                                                <input type="hidden" name="action" value="approve">
                                                <button class="primary-button wide-button" type="submit">Duyệt đơn</button>
                                            </form>
                                            <form method="post" action="${pageContext.request.contextPath}/cashier/orders">
                                                <input type="hidden" name="orderId" value="${order.orderId}">
                                                <input type="hidden" name="action" value="reject">
                                                <button class="danger-button wide-button" type="submit">Từ chối đơn</button>
                                            </form>
                                        </c:when>
                                        <c:when test="${order.status eq 'Processing'}">
                                            <form class="cash-payment-form" method="post" action="${pageContext.request.contextPath}/cashier/orders">
                                                <input type="hidden" name="orderId" value="${order.orderId}">
                                                <input type="hidden" name="action" value="pay">
                                                <input type="hidden" name="paymentMethod" value="Cash">
                                                <label>Tiền khách đưa</label>
                                                <input class="cash-received-input" type="number" min="0" step="1000" name="amountReceived" placeholder="VD: 100000" required>
                                                <p class="change-box">Tiền thừa: <strong class="change-amount">0đ</strong></p>
                                                <button class="primary-button wide-button" type="submit">Xác nhận thanh toán</button>
                                            </form>
                                            <button class="secondary-button wide-button js-open-qr" type="button"
                                                    data-order-id="${order.orderId}"
                                                    data-order-total="${order.totalPrice}">
                                                Hiện mã QR
                                            </button>
                                        </c:when>
                                        <c:when test="${order.status eq 'Paid'}">
                                            <p class="paid-note">Đơn đã thanh toán, hóa đơn giấy đã được gọi in.</p>
                                        </c:when>
                                        <c:otherwise>
                                            <p class="paid-note">Đơn đã bị từ chối. Hoàn tiền cho khách nếu đã thu trước.</p>
                                        </c:otherwise>
                                    </c:choose>
                                </aside>
                            </article>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </section>
        </main>

        <div class="qr-modal" id="qrModal" aria-hidden="true">
            <div class="modal-backdrop js-close-qr"></div>
            <section class="qr-dialog" role="dialog" aria-modal="true" aria-labelledby="qrTitle">
                <button type="button" class="modal-close js-close-qr" aria-label="Đóng">&times;</button>
                <span class="page-kicker">Thanh toán trực tuyến</span>
                <h2 id="qrTitle">Quét mã QR tĩnh</h2>
                <img class="qr-image" src="${pageContext.request.contextPath}/assets/images/payment-qr.svg" alt="Mã QR thanh toán">
                <p>Đơn <strong id="qrOrderLabel">#</strong> · Số tiền <strong id="qrTotalLabel">0đ</strong></p>
                <form method="post" action="${pageContext.request.contextPath}/cashier/orders">
                    <input type="hidden" name="orderId" id="qrOrderId">
                    <input type="hidden" name="action" value="pay">
                    <input type="hidden" name="paymentMethod" value="QR-Code">
                    <input type="hidden" name="amountReceived" value="0">
                    <button class="primary-button wide-button" type="submit">Đã nhận tiền QR</button>
                </form>
            </section>
        </div>

        <script src="${pageContext.request.contextPath}/assets/js/cashier.js"></script>
    </body>
</html>

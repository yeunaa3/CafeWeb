<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Hồ sơ - Cafe & Bubble tea</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer.css">
    </head>
    <body class="account-page" data-context-path="${pageContext.request.contextPath}">
        <main class="account-shell">
            <header class="account-header">
                <a class="brand" href="${pageContext.request.contextPath}/home">Cafe & Bubble tea</a>
                <nav class="site-nav account-nav">
                    <a href="${pageContext.request.contextPath}/menu">Menu</a>
                    <a class="cart-link" href="${pageContext.request.contextPath}/checkout">Giỏ Hàng <span class="cart-count">${cartCount}</span></a>
                    <a href="${pageContext.request.contextPath}/home#contact">Liên Hệ</a>
                    <button class="notification-button" type="button" data-open-orders title="Thông báo đơn hàng">
                        Thông báo
                        <c:if test="${notificationCount > 0}"><span>${notificationCount}</span></c:if>
                    </button>
                    <a class="avatar-button" href="${pageContext.request.contextPath}/profile" title="Hồ sơ">${fn:substring(customer.fullName, 0, 1)}</a>
                </nav>
            </header>

            <div class="account-layout">
                <aside class="account-sidebar" aria-label="Tài khoản">
                    <a class="sidebar-link active" href="${pageContext.request.contextPath}/profile" title="Hồ sơ">P</a>
                    <a class="sidebar-link" href="${pageContext.request.contextPath}/redeem" title="Đổi voucher">V</a>
                    <button class="sidebar-link" type="button" data-open-orders title="Đơn hàng">O</button>
                    <a class="sidebar-link" href="${pageContext.request.contextPath}/logout" title="Đăng xuất" aria-label="Đăng xuất">X</a>
                </aside>

                <section class="account-content">
                    <div class="customer-summary">
                        <img class="profile-avatar" src="https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=160&q=80" alt="Ảnh đại diện">
                        <div>
                            <strong><c:out value="${customer.fullName}"/></strong>
                            <span><c:out value="${customer.email}"/></span>
                        </div>
                    </div>

                    <c:if test="${not empty error}"><p class="alert error-alert"><c:out value="${error}"/></p></c:if>
                    <c:if test="${not empty success}"><p class="alert success-alert"><c:out value="${success}"/></p></c:if>

                    <form class="profile-form ${editMode ? 'is-editing' : ''}" method="post" action="${pageContext.request.contextPath}/profile">
                        <div class="profile-form-heading">
                            <div>
                                <h1>Thông tin cá nhân</h1>
                                <p>Quản lý thông tin nhận hàng và liên hệ của bạn.</p>
                            </div>
                            <c:choose>
                                <c:when test="${editMode}">
                                    <button class="primary-button" type="submit">Lưu</button>
                                </c:when>
                                <c:otherwise>
                                    <a class="primary-button" href="${pageContext.request.contextPath}/profile?mode=edit">Chỉnh sửa</a>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <div class="profile-fields">
                            <label>Họ và Tên
                                <input name="fullName" value="<c:out value='${customer.fullName}'/>" ${editMode ? '' : 'readonly'} required>
                            </label>
                            <label>Số Điện Thoại
                                <input name="phone" value="<c:out value='${customer.phone}'/>" ${editMode ? '' : 'readonly'} pattern="0[0-9]{9,10}">
                            </label>
                            <label>Giới Tính
                                <select name="gender" disabled><option>Chưa cập nhật</option></select>
                            </label>
                            <label>Địa Chỉ
                                <input name="address" value="<c:out value='${customer.address}'/>" ${editMode ? '' : 'readonly'}>
                            </label>
                            <label>Username
                                <input value="<c:out value='${customer.username}'/>" readonly>
                            </label>
                            <label>Email
                                <input type="email" name="email" value="<c:out value='${customer.email}'/>" ${editMode ? '' : 'readonly'} required>
                            </label>
                        </div>
                    </form>
                </section>
            </div>
        </main>

        <div class="order-modal" id="orderModal" aria-hidden="true">
            <div class="modal-backdrop" data-close-orders></div>
            <section class="order-dialog" role="dialog" aria-modal="true" aria-labelledby="orderDialogTitle">
                <div class="order-dialog-heading">
                    <div><span>Thông báo</span><h2 id="orderDialogTitle">Đơn hàng của bạn</h2></div>
                    <button type="button" class="modal-close" data-close-orders aria-label="Đóng">&times;</button>
                </div>
                <c:choose>
                    <c:when test="${empty customerOrders}"><p class="empty-state">Bạn chưa có đơn hàng nào.</p></c:when>
                    <c:otherwise>
                        <div class="order-notification-list">
                            <c:forEach var="order" items="${customerOrders}">
                                <article class="order-notification">
                                    <div class="order-notification-top">
                                        <strong>Đơn #${order.orderId}</strong>
                                        <span class="status-pill status-${fn:toLowerCase(order.status)}">${order.displayStatus}</span>
                                    </div>
                                    <p><c:out value="${order.items}"/></p>
                                    <div><fmt:formatDate value="${order.orderDate}" pattern="dd/MM/yyyy HH:mm"/> <strong><fmt:formatNumber value="${order.totalPrice}" pattern="#,##0"/>đ</strong></div>
                                </article>
                            </c:forEach>
                        </div>
                    </c:otherwise>
                </c:choose>
            </section>
        </div>
        <script src="${pageContext.request.contextPath}/assets/js/customer.js"></script>
    </body>
</html>

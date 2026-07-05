<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hồ sơ - Cafe &amp; Bubble tea</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer.css">
</head>
<body class="account-page" data-context-path="${pageContext.request.contextPath}">
<main class="account-shell">
    <header class="account-header">
        <a class="brand" href="${pageContext.request.contextPath}/home">Cafe &amp; Bubble tea</a>
        <nav class="site-nav account-nav">
            <a href="${pageContext.request.contextPath}/menu">Menu</a>
            <a class="cart-link" href="${pageContext.request.contextPath}/checkout">Giỏ hàng <span class="cart-count">${cartCount}</span></a>
            <a href="${pageContext.request.contextPath}/home#contact">Liên hệ</a>
            <button class="notification-button" type="button" data-open-orders title="Thông báo đơn hàng" aria-label="Thông báo đơn hàng">
                <svg class="ui-icon" viewBox="0 0 24 24" aria-hidden="true"><path d="M10.268 21a2 2 0 0 0 3.464 0"/><path d="M3.262 15.326A1 1 0 0 0 4 17h16a1 1 0 0 0 .74-1.673C19.41 13.956 18 12.499 18 8A6 6 0 0 0 6 8c0 4.499-1.411 5.956-2.738 7.326"/></svg>
                <c:if test="${notificationCount > 0}"><span>${notificationCount}</span></c:if>
            </button>
            <a class="avatar-button" href="${pageContext.request.contextPath}/profile" title="Hồ sơ">${fn:substring(customer.fullName, 0, 1)}</a>
        </nav>
    </header>

    <div class="account-layout">
        <aside class="account-sidebar" aria-label="Tài khoản">
            <a class="sidebar-link active" href="${pageContext.request.contextPath}/profile" title="Hồ sơ" aria-label="Hồ sơ"><svg class="ui-icon" viewBox="0 0 24 24" aria-hidden="true"><rect width="7" height="7" x="3" y="3" rx="1"/><rect width="7" height="7" x="14" y="3" rx="1"/><rect width="7" height="7" x="14" y="14" rx="1"/><rect width="7" height="7" x="3" y="14" rx="1"/></svg></a>
            <a class="sidebar-link" href="${pageContext.request.contextPath}/redeem" title="Đổi voucher" aria-label="Đổi voucher"><svg class="ui-icon" viewBox="0 0 24 24" aria-hidden="true"><rect x="3" y="8" width="18" height="4" rx="1"/><path d="M12 8v13"/><path d="M19 12v9H5v-9"/><path d="M7.5 8C6.1 8 5 6.9 5 5.5S6.1 3 7.5 3C9.7 3 12 8 12 8Z"/><path d="M16.5 8C17.9 8 19 6.9 19 5.5S17.9 3 16.5 3C14.3 3 12 8 12 8Z"/></svg></a>
            <button class="sidebar-link" type="button" data-open-orders title="Đơn hàng" aria-label="Đơn hàng"><svg class="ui-icon" viewBox="0 0 24 24" aria-hidden="true"><path d="M21 15a4 4 0 0 1-4 4H8l-5 3V7a4 4 0 0 1 4-4h10a4 4 0 0 1 4 4Z"/><path d="M8 9h8"/><path d="M8 13h5"/></svg></button>
            <a class="sidebar-link" href="${pageContext.request.contextPath}/logout" title="Đăng xuất" aria-label="Đăng xuất"><svg class="ui-icon" viewBox="0 0 24 24" aria-hidden="true"><path d="M10 17l5-5-5-5"/><path d="M15 12H3"/><path d="M15 3h4a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-4"/></svg></a>
        </aside>

        <section class="account-content">
            <div class="customer-summary">
                <img class="profile-avatar" src="https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&amp;fit=crop&amp;w=160&amp;q=80" alt="Ảnh đại diện">
                <div><strong><c:out value="${customer.fullName}"/></strong><span><c:out value="${customer.email}"/></span></div>
            </div>

            <c:if test="${not empty error}"><p class="alert error-alert"><c:out value="${error}"/></p></c:if>
            <c:if test="${not empty success}"><p class="alert success-alert"><c:out value="${success}"/></p></c:if>

            <form class="profile-form ${editMode ? 'is-editing' : ''}" method="post" action="${pageContext.request.contextPath}/profile">
                <div class="profile-form-heading">
                    <div><h1>Thông tin cá nhân</h1><p>Quản lý thông tin nhận hàng và liên hệ của bạn.</p></div>
                    <c:choose><c:when test="${editMode}"><button class="primary-button" type="submit">Lưu</button></c:when><c:otherwise><a class="primary-button" href="${pageContext.request.contextPath}/profile?mode=edit">Chỉnh sửa</a></c:otherwise></c:choose>
                </div>

                <div class="profile-fields">
                    <label>Họ và tên<input name="fullName" value="<c:out value='${customer.fullName}'/>" ${editMode ? '' : 'readonly'} required></label>
                    <label>Số điện thoại<input name="phone" value="<c:out value='${customer.phone}'/>" ${editMode ? '' : 'readonly'} pattern="0[0-9]{9,10}"></label>
                    <label>Giới tính<select name="gender" ${editMode ? '' : 'disabled'}><option value="" ${empty customer.gender ? 'selected' : ''}>Chưa cập nhật</option><option value="Nam" ${customer.gender == 'Nam' ? 'selected' : ''}>Nam</option><option value="Nữ" ${customer.gender == 'Nữ' ? 'selected' : ''}>Nữ</option><option value="Khác" ${customer.gender == 'Khác' ? 'selected' : ''}>Khác</option></select></label>
                    <label>Địa chỉ<input name="address" value="<c:out value='${customer.address}'/>" ${editMode ? '' : 'readonly'}></label>
                    <label>Username<input name="username" value="<c:out value='${customer.username}'/>" ${editMode ? '' : 'readonly'} required pattern="[A-Za-z0-9_]{4,50}"></label>
                    <label>Email<input type="email" name="email" value="<c:out value='${customer.email}'/>" ${editMode ? '' : 'readonly'} required></label>
                </div>
            </form>
        </section>
    </div>
</main>

<div class="order-modal" id="orderModal" aria-hidden="true">
    <div class="modal-backdrop" data-close-orders></div>
    <section class="order-dialog" role="dialog" aria-modal="true" aria-labelledby="orderDialogTitle">
        <div class="order-dialog-heading"><div><span>Thông báo</span><h2 id="orderDialogTitle">Đơn hàng của bạn</h2></div><button type="button" class="modal-close" data-close-orders aria-label="Đóng">&times;</button></div>
        <c:choose>
            <c:when test="${empty customerOrders}"><p class="empty-state">Bạn chưa có đơn hàng nào.</p></c:when>
            <c:otherwise><div class="order-notification-list"><c:forEach var="order" items="${customerOrders}"><article class="order-notification"><div class="order-notification-top"><strong>Đơn #${order.orderId}</strong><span class="status-pill status-${fn:toLowerCase(order.status)}">${order.displayStatus}</span></div><p><c:out value="${order.items}"/></p><div><fmt:formatDate value="${order.orderDate}" pattern="dd/MM/yyyy HH:mm"/> <strong><fmt:formatNumber value="${order.totalPrice}" pattern="#,##0"/>đ</strong></div></article></c:forEach></div></c:otherwise>
        </c:choose>
    </section>
</div>
<script src="${pageContext.request.contextPath}/assets/js/customer.js"></script>
</body>
</html>

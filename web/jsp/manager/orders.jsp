<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width,initial-scale=1">
        <title>Quản lý đơn hàng - CBMS</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/manager.css?v=20260708-ui7">
    </head>
    <body class="manager-page">
        <div class="manager-shell">
            <%@include file="includes/sidebar.jspf"%>
            <div class="manager-main">
                <%@include file="includes/header.jspf"%>
                <main class="manager-content">
                    <c:if test="${not empty success}">
                        <div class="manager-alert success">
                            <c:out value="${success}"/>
                        </div>
                    </c:if>
                    <c:if test="${not empty error}">
                        <div class="manager-alert error">
                            <c:out value="${error}"/>
                        </div>
                    </c:if>
                    <nav class="status-tabs" aria-label="Lọc trạng thái">
                        <a class="${empty selectedStatus ? 'active' : ''}" href="${pageContext.request.contextPath}/manager/orders">Tất cả</a>
                        <a class="${selectedStatus == 'Pending' ? 'active' : ''}" href="${pageContext.request.contextPath}/manager/orders?status=Pending">Chờ duyệt</a>
                        <a class="${selectedStatus == 'Processing' ? 'active' : ''}" href="${pageContext.request.contextPath}/manager/orders?status=Processing">Đang xử lý</a>
                        <a class="${selectedStatus == 'Delivering' ? 'active' : ''}" href="${pageContext.request.contextPath}/manager/orders?status=Delivering">Đang giao</a>
                        <a class="${selectedStatus == 'Completed' ? 'active' : ''}" href="${pageContext.request.contextPath}/manager/orders?status=Completed">Hoàn thành</a>
                        <a class="${selectedStatus == 'Cancelled' ? 'active' : ''}" href="${pageContext.request.contextPath}/manager/orders?status=Cancelled">Đã hủy</a>
                    </nav>
                    <section class="toolbar-band">
                        <form method="get" action="${pageContext.request.contextPath}/manager/orders">
                            <input type="hidden" name="status" value="<c:out value='${selectedStatus}'/>">
                            <div class="search-box">
                                <svg viewBox="0 0 24 24">
                                <circle cx="11" cy="11" r="7"/>
                                <path d="m20 20-4-4"/>
                                </svg>
                                <input name="q" value="<c:out value='${param.q}'/>" placeholder="Tìm mã đơn hoặc tên khách">
                                <button type="submit">Tìm</button>
                            </div>
                        </form>
                        <span class="result-count">${fn:length(orderList)} đơn hàng</span>
                    </section>
                    <section class="data-panel">
                        <div class="table-scroll">
                            <table class="manager-table order-table">
                                <thead>
                                    <tr>
                                        <th>Mã đơn</th>
                                        <th>Thời gian tạo</th>
                                        <th>Khách hàng</th>
                                        <th>Món đã gọi</th>
                                        <th>Tổng tiền</th>
                                        <th>Loại</th>
                                        <th>Trạng thái</th>
                                        <th>
                                        </th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="order" items="${orderList}">
                                        <tr>
                                            <td>
                                                <strong>#${order.orderId}</strong>
                                            </td>
                                            <td>
                                                <fmt:formatDate value="${order.orderDate}" pattern="dd/MM/yyyy HH:mm"/>
                                            </td>
                                            <td>
                                                <c:out value="${order.customerName}"/>
                                            </td>
                                            <td class="order-items">
                                                <c:out value="${order.items}"/>
                                            </td>
                                            <td>
                                                <strong>
                                                    <fmt:formatNumber value="${order.totalPrice}" pattern="#,##0"/>đ</strong>
                                            </td>
                                            <td>${order.orderType == 'Online' ? 'Online' : 'Tại quầy'}</td>
                                            <td>
                                                <form class="status-form" method="post" action="${pageContext.request.contextPath}/manager/orders">
                                                    <input type="hidden" name="id" value="${order.orderId}">
                                                    <select name="status" class="order-state state-${fn:toLowerCase(order.status)}" data-submit-on-change>
                                                        <option value="Pending" ${order.status == 'Pending' ? 'selected' : ''}>Chờ duyệt</option>
                                                        <option value="Approved" ${order.status == 'Approved' ? 'selected' : ''}>Đã duyệt</option>
                                                        <option value="Processing" ${order.status == 'Processing' ? 'selected' : ''}>Đang xử lý</option>
                                                        <option value="Ready" ${order.status == 'Ready' ? 'selected' : ''}>Sẵn sàng</option>
                                                        <option value="Delivering" ${order.status == 'Delivering' ? 'selected' : ''}>Đang giao</option>
                                                        <option value="Completed" ${order.status == 'Completed' ? 'selected' : ''}>Hoàn thành</option>
                                                        <option value="Cancelled" ${order.status == 'Cancelled' ? 'selected' : ''}>Đã hủy</option>
                                                        <option value="Refunded" ${order.status == 'Refunded' ? 'selected' : ''}>Đã hoàn tiền</option>
                                                    </select>
                                                </form>
                                            </td>
                                            <td>
                                                <a class="detail-button" href="${pageContext.request.contextPath}/manager/orders?detail=${order.orderId}" title="Xem chi tiết" aria-label="Xem chi tiết">
                                                    <svg viewBox="0 0 24 24">
                                                    <circle cx="12" cy="12" r="9"/>
                                                    <path d="m9 12 2 2 4-4"/>
                                                    </svg>
                                                </a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty orderList}">
                                        <tr>
                                            <td colspan="8">
                                                <div class="empty-row">Không có đơn hàng phù hợp.</div>
                                            </td>
                                        </tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                        <footer class="table-footer">
                            <span>Hiển thị <strong>${fn:length(orderList)}</strong> đơn</span>
                            <div class="pagination">
                                <button disabled>‹</button>
                                <b>1</b>
                                <button disabled>›</button>
                            </div>
                        </footer>
                    </section>
                </main>
            </div>
        </div>
        <c:if test="${not empty selectedOrder}">
            <div class="manager-modal">
                <a class="modal-shade" href="${pageContext.request.contextPath}/manager/orders" aria-label="Đóng">
                </a>
                <section class="manager-dialog order-dialog" role="dialog" aria-modal="true">
                    <div class="dialog-heading">
                        <div>
                            <span>CHI TIẾT ĐƠN HÀNG</span>
                            <h2>#${selectedOrder.orderId}</h2>
                        </div>
                        <a href="${pageContext.request.contextPath}/manager/orders" aria-label="Đóng">×</a>
                    </div>
                    <div class="order-detail-body">
                        <div class="order-detail-grid">
                            <span>Khách hàng<strong>
                                    <c:out value="${selectedOrder.customerName}"/>
                                </strong>
                            </span>
                            <span>Thời gian<strong>
                                    <fmt:formatDate value="${selectedOrder.orderDate}" pattern="dd/MM/yyyy HH:mm"/>
                                </strong>
                            </span>
                            <span>Phương thức<strong>${selectedOrder.paymentMethod}</strong>
                            </span>
                            <span>Tổng tiền<strong>
                                    <fmt:formatNumber value="${selectedOrder.totalPrice}" pattern="#,##0"/>đ</strong>
                            </span>
                        </div>
                        <div class="detail-block">
                            <small>MÓN ĐÃ GỌI</small>
                            <p>
                                <c:out value="${selectedOrder.items}"/>
                            </p>
                        </div>
                        <c:if test="${not empty selectedOrder.shippingAddress}">
                            <div class="detail-block">
                                <small>GIAO HÀNG</small>
                                <p>
                                    <c:out value="${selectedOrder.shippingAddress}"/> · <c:out value="${selectedOrder.shippingPhone}"/>
                                </p>
                            </div>
                        </c:if>
                        <c:if test="${not empty selectedOrder.note}">
                            <div class="detail-block">
                                <small>GHI CHÚ</small>
                                <p>
                                    <c:out value="${selectedOrder.note}"/>
                                </p>
                            </div>
                        </c:if>
                    </div>
                </section>
            </div>
        </c:if>
        <script src="${pageContext.request.contextPath}/assets/js/manager.js?v=20260708-ui7">
        </script>
    </body>
</html>

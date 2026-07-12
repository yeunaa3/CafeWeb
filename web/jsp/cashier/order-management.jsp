<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width,initial-scale=1">
        <title>Quản lý đơn hàng - Thu ngân</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/manager.css?v=20260709-orderflow1">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/cashier.css?v=20260709-orderflow1">
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
                    <nav class="status-tabs">
                        <a class="${empty selectedStatus?'active':''}" href="${pageContext.request.contextPath}/cashier/order-management">Tất cả</a>
                        <a class="${selectedStatus=='Pending'?'active':''}" href="?status=Pending">Chờ duyệt</a>
                        <a class="${selectedStatus=='Approved'?'active':''}" href="?status=Approved">Đã duyệt</a>
                        <a class="${selectedStatus=='Completed'?'active':''}" href="?status=Completed">Hoàn thành</a>
                        <a class="${selectedStatus=='Cancelled'?'active':''}" href="?status=Cancelled">Đã hủy</a>
                    </nav>
                    <section class="toolbar-band">
                        <form method="get" action="${pageContext.request.contextPath}/cashier/order-management">
                            <input type="hidden" name="status" value="<c:out value='${selectedStatus}'/>">
                            <div class="search-box">
                                <svg viewBox="0 0 24 24">
                                <circle cx="11" cy="11" r="7"/>
                                <path d="m20 20-4-4"/>
                                </svg>
                                <input name="q" value="<c:out value='${param.q}'/>" placeholder="Tìm mã đơn hoặc khách hàng">
                                <button>Tìm</button>
                            </div>
                        </form>
                        <span class="result-count">${fn:length(orderList)} đơn</span>
                    </section>
                    <section class="data-panel">
                        <div class="table-scroll">
                            <table class="manager-table order-table cashier-workflow-table">
                                <thead>
                                    <tr>
                                        <th>Mã đơn</th>
                                        <th>Thời gian</th>
                                        <th>Khách hàng</th>
                                        <th>Loại đơn</th>
                                        <th>Tổng tiền</th>
                                        <th>Trạng thái</th>
                                        <th>Thao tác thu ngân</th>
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
                                                <fmt:formatDate value="${order.orderDate}" pattern="dd/MM HH:mm"/>
                                            </td>
                                            <td>
                                                <c:out value="${order.customerName}"/>
                                            </td>
                                            <td>
                                                <span class="order-type ${order.orderType=='Online'?'online':'counter'}">${order.orderType=='Online'?'Online':'Tại quầy'}</span>
                                            </td>
                                            <td>
                                                <strong>
                                                    <fmt:formatNumber value="${order.totalPrice}" pattern="#,##0"/>đ</strong>
                                            </td>
                                            <td>
                                                <span class="order-state state-${fn:toLowerCase(order.status)}">${order.displayStatus}</span>
                                            </td>
                                            <td>
                                                <div class="workflow-actions">
                                                    <c:choose>
                                                        <c:when test="${order.status=='Pending'}">
                                                            <form method="post" action="${pageContext.request.contextPath}/cashier/order-management">
                                                                <input type="hidden" name="id" value="${order.orderId}">
                                                                <input type="hidden" name="status" value="Approved">
                                                                <button class="approve-order" type="submit">Duyệt đơn</button>
                                                            </form>
                                                            <form method="post" action="${pageContext.request.contextPath}/cashier/order-management" data-confirm="Hủy đơn #${order.orderId}?">
                                                                <input type="hidden" name="id" value="${order.orderId}">
                                                                <input type="hidden" name="status" value="Cancelled">
                                                                <button class="cancel-order" type="submit">Hủy</button>
                                                            </form>
                                                        </c:when>
                                                        <c:when test="${order.status=='Approved'}">
                                                            <form method="post" action="${pageContext.request.contextPath}/cashier/order-management">
                                                                <input type="hidden" name="id" value="${order.orderId}">
                                                                <input type="hidden" name="status" value="Completed">
                                                                <button class="approve-order" type="submit">Hoàn thành</button>
                                                            </form>
                                                            <form method="post" action="${pageContext.request.contextPath}/cashier/order-management" data-confirm="Hủy đơn #${order.orderId}?">
                                                                <input type="hidden" name="id" value="${order.orderId}">
                                                                <input type="hidden" name="status" value="Cancelled">
                                                                <button class="cancel-order" type="submit">Hủy</button>
                                                            </form>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <small>Không còn thao tác</small>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </td>
                                            <td>
                                                <a class="detail-button" href="?detail=${order.orderId}" title="Xem chi tiết">
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
                                                <div class="empty-row">Không có đơn phù hợp.</div>
                                            </td>
                                        </tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                        <footer class="table-footer">
                            <span>Hiển thị <strong>${fn:length(orderList)}</strong> đơn</span>
                            <div class="pagination">
                                <button disabled>&lsaquo;</button>
                                <b>1</b>
                                <button disabled>&rsaquo;</button>
                            </div>
                        </footer>
                    </section>
                </main>
            </div>
        </div>
        <c:if test="${not empty selectedOrder}">
            <div class="manager-modal">
                <a class="modal-shade" href="${pageContext.request.contextPath}/cashier/order-management" aria-label="Đóng">
                </a>
                <section class="manager-dialog order-dialog">
                    <div class="dialog-heading">
                        <div>
                            <span>CHI TIẾT ĐƠN</span>
                            <h2>#${selectedOrder.orderId}</h2>
                        </div>
                        <a href="${pageContext.request.contextPath}/cashier/order-management">×</a>
                    </div>
                    <div class="order-detail-body">
                        <div class="order-detail-grid">
                            <span>Khách hàng<strong>
                                    <c:out value="${selectedOrder.customerName}"/>
                                </strong>
                            </span>
                            <span>Thanh toán<strong>${selectedOrder.paymentMethod}</strong>
                            </span>
                        </div>
                        <div class="detail-block">
                            <small>MồN Để GỌI</small>
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
                    </div>
                </section>
            </div>
        </c:if>
        <script src="${pageContext.request.contextPath}/js/manager.js?v=20260709-orderflow1">
        </script>
    </body>
</html>


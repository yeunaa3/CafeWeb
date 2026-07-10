<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width,initial-scale=1">
        <title>Dashboard - CBMS</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/manager.css?v=20260709-orderflow1">
    </head>
    <body class="manager-page">
        <div class="manager-shell">
            <%@include file="includes/sidebar.jspf"%>
            <div class="manager-main">
                <%@include file="includes/header.jspf"%>
                <main class="manager-content dashboard-content">
                    <div class="dashboard-toolbar">
                        <div class="dashboard-filter" aria-label="Khoảng thời gian">
                            <a class="${days == 7 ? 'active' : ''}" href="${pageContext.request.contextPath}/manager/dashboard?days=7">7 ngày</a>
                            <a class="${days == 30 ? 'active' : ''}" href="${pageContext.request.contextPath}/manager/dashboard?days=30">30 ngày</a>
                        </div>
                        <div class="dashboard-export-actions" aria-label="Xuất thống kê">
                            <a href="${pageContext.request.contextPath}/manager/dashboard?days=${days}&export=excel">Xuất Excel</a>
                            <a href="${pageContext.request.contextPath}/manager/dashboard?days=${days}&export=pdf">Xuất PDF</a>
                        </div>
                    </div>
                    <section class="metric-grid dashboard-metrics">
                        <article>
                            <span>Tổng đồ uống đang bán</span>
                            <strong>${dashboard.activeProductCount}</strong>
                            <small>Sản phẩm khả dụng</small>
                        </article>
                        <article>
                            <span>Đơn hôm nay</span>
                            <strong>${dashboard.todayOrderCount}</strong>
                            <small>Tất cả trạng thái</small>
                        </article>
                        <article>
                            <span>Doanh thu hôm nay</span>
                            <strong>
                                <fmt:formatNumber value="${dashboard.todayRevenue}" pattern="#,##0"/>đ</strong>
                            <small>Đơn hoàn thành</small>
                        </article>
                        <article>
                            <span>Tổng doanh thu</span>
                            <strong>
                                <fmt:formatNumber value="${dashboard.totalRevenue}" pattern="#,##0"/>đ</strong>
                            <small>${dashboard.customerCount} khách hàng hoạt động</small>
                        </article>
                    </section>

                    <section class="dashboard-grid">
                        <article class="dashboard-panel revenue-panel">
                            <div class="panel-heading">
                                <div>
                                    <span>DOANH THU</span>
                                    <h2>${days} ngày gần nhất</h2>
                                </div>
                                <strong>
                                    <fmt:formatNumber value="${dashboard.totalRevenue}" pattern="#,##0"/>đ</strong>
                            </div>
                            <div class="revenue-bars">
                                <c:forEach var="stat" items="${dashboard.revenueStats}">
                                    <fmt:formatNumber value="${stat.revenue}" pattern="#,##0" var="revenueLabel"/>
                                    <div class="revenue-column" title="${stat.orderCount} đơn - ${revenueLabel}đ">
                                        <span>
                                            <fmt:formatNumber value="${stat.revenue}" pattern="#,##0"/>
                                        </span>
                                        <i style="height:${stat.percentage}%">
                                        </i>
                                        <small>
                                            <fmt:formatDate value="${stat.revenueDate}" pattern="dd/MM"/>
                                        </small>
                                    </div>
                                </c:forEach>
                                <c:if test="${empty dashboard.revenueStats}">
                                    <div class="chart-empty">Chưa có doanh thu hoàn thành trong khoảng này.</div>
                                </c:if>
                            </div>
                        </article>

                        <article class="dashboard-panel top-products-panel">
                            <div class="panel-heading">
                                <div>
                                    <span>TOP SẢN PHẨM</span>
                                    <h2>Được mua nhiều</h2>
                                </div>
                            </div>
                            <div class="rank-list">
                                <c:forEach var="product" items="${dashboard.topProducts}" varStatus="loop">
                                    <div>
                                        <b>${loop.index + 1}</b>
                                        <span>
                                            <strong>
                                                <c:out value="${product.productName}"/>
                                            </strong>
                                            <small>${product.quantitySold} sản phẩm</small>
                                        </span>
                                        <em>
                                            <fmt:formatNumber value="${product.revenue}" pattern="#,##0"/>đ</em>
                                    </div>
                                </c:forEach>
                                <c:if test="${empty dashboard.topProducts}">
                                    <p class="chart-empty">Chưa có dữ liệu bán hàng.</p>
                                </c:if>
                            </div>
                        </article>

                        <article class="dashboard-panel recent-orders-panel">
                            <div class="panel-heading">
                                <div>
                                    <span>VẬN HÀNH</span>
                                    <h2>Đơn hàng gần đây</h2>
                                </div>
                                <a href="${pageContext.request.contextPath}/manager/orders">Xem tất cả</a>
                            </div>
                            <div class="compact-table">
                                <table>
                                    <thead>
                                        <tr>
                                            <th>Mã đơn</th>
                                            <th>Khách hàng</th>
                                            <th>Thời gian</th>
                                            <th>Tổng tiền</th>
                                            <th>Trạng thái</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="order" items="${dashboard.recentOrders}">
                                            <tr>
                                                <td>
                                                    <a href="${pageContext.request.contextPath}/manager/orders?detail=${order.orderId}">#${order.orderId}</a>
                                                </td>
                                                <td>
                                                    <c:out value="${order.customerName}"/>
                                                </td>
                                                <td>
                                                    <fmt:formatDate value="${order.orderDate}" pattern="dd/MM HH:mm"/>
                                                </td>
                                                <td>
                                                    <strong>
                                                        <fmt:formatNumber value="${order.totalPrice}" pattern="#,##0"/>đ</strong>
                                                </td>
                                                <td>
                                                    <span class="order-state state-${fn:toLowerCase(order.status)}">${order.displayStatus}</span>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </article>
                    </section>
                </main>
            </div>
        </div>
        <script src="${pageContext.request.contextPath}/js/manager.js?v=20260709-orderflow1">
        </script>
    </body>
</html>


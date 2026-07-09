<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width,initial-scale=1">
        <title>Hóa đơn tại quầy - CBMS</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/manager.css?v=20260709-orderflow1">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/cashier.css?v=20260709-orderflow1">
    </head>
    <body class="manager-page">
        <div class="manager-shell">
            <%@include file="includes/sidebar.jspf"%>
            <div class="manager-main">
                <%@include file="includes/header.jspf"%>
                <main class="manager-content">
                    <section class="toolbar-band">
                        <form method="get" action="${pageContext.request.contextPath}/cashier/invoices">
                            <div class="search-box">
                                <svg viewBox="0 0 24 24">
                                <circle cx="11" cy="11" r="7"/>
                                <path d="m20 20-4-4"/>
                                </svg>
                                <input name="q" value="<c:out value='${param.q}'/>" placeholder="Tìm mã hóa đơn">
                                <button>Tìm</button>
                            </div>
                        </form>
                    </section>
                    <section class="data-panel">
                        <div class="table-scroll">
                            <table class="manager-table">
                                <thead>
                                    <tr>
                                        <th>Mã hóa đơn</th>
                                        <th>Thời gian</th>
                                        <th>Món</th>
                                        <th>Tổng</th>
                                        <th>Phương thức</th>
                                        <th>Trạng thái</th>
                                        <th>
                                        </th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="invoice" items="${invoiceList}">
                                        <tr>
                                            <td>
                                                <strong>#${invoice.orderId}</strong>
                                            </td>
                                            <td>
                                                <fmt:formatDate value="${invoice.orderDate}" pattern="dd/MM/yyyy HH:mm"/>
                                            </td>
                                            <td class="order-items">
                                                <c:out value="${invoice.items}"/>
                                            </td>
                                            <td>
                                                <strong>
                                                    <fmt:formatNumber value="${invoice.totalPrice}" pattern="#,##0"/>đ</strong>
                                            </td>
                                            <td>${invoice.paymentMethod}</td>
                                            <td>
                                                <span class="order-state state-${fn:toLowerCase(invoice.status)}">${invoice.displayStatus}</span>
                                            </td>
                                            <td>
                                                <a class="detail-button" href="?detail=${invoice.orderId}" title="Xem hóa đơn">
                                                    <svg viewBox="0 0 24 24">
                                                    <path d="M6 2h9l5 5v15H6zM14 2v6h6M9 13h7M9 17h7"/>
                                                    </svg>
                                                </a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty invoiceList}">
                                        <tr>
                                            <td colspan="7">
                                                <div class="empty-row">Chưa có hóa đơn tại quầy.</div>
                                            </td>
                                        </tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                        <footer class="table-footer">
                            <span>${fn:length(invoiceList)} hóa đơn</span>
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
                <a class="modal-shade" href="${pageContext.request.contextPath}/cashier/invoices">
                </a>
                <section class="manager-dialog order-dialog">
                    <div class="dialog-heading">
                        <div>
                            <span>HÓA ĐƠN</span>
                            <h2>#${selectedOrder.orderId}</h2>
                        </div>
                        <a href="${pageContext.request.contextPath}/cashier/invoices">×</a>
                    </div>
                    <div class="order-detail-body">
                        <div class="order-detail-grid">
                            <span>Thời gian<strong>
                                    <fmt:formatDate value="${selectedOrder.orderDate}" pattern="dd/MM/yyyy HH:mm"/>
                                </strong>
                            </span>
                            <span>Tổng tiền<strong>
                                    <fmt:formatNumber value="${selectedOrder.totalPrice}" pattern="#,##0"/>đ</strong>
                            </span>
                        </div>
                        <div class="detail-block">
                            <small>CHI TIẾT</small>
                            <p>
                                <c:out value="${selectedOrder.items}"/>
                            </p>
                        </div>
                    </div>
                </section>
            </div>
        </c:if>
        <script src="${pageContext.request.contextPath}/assets/js/manager.js?v=20260709-orderflow1">
        </script>
    </body>
</html>


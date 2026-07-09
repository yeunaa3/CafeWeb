<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width,initial-scale=1">
        <title>Mã giảm giá - CBMS</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/manager.css?v=20260709-orderflow1">
    </head>
    <body class="manager-page">
        <div class="manager-shell">
            <%@include file="includes/sidebar.jspf"%>
            <div class="manager-main">
                <%@include file="includes/header.jspf"%>
                <main class="manager-content">
                    <c:if test="${not empty success}">
                        <div class="manager-alert success">${success}</div>
                    </c:if>
                    <c:if test="${not empty error}">
                        <div class="manager-alert error">${error}</div>
                    </c:if>

                    <section class="toolbar-band">
                        <form method="get" action="${pageContext.request.contextPath}/manager/vouchers">
                            <div class="search-box">
                                <svg viewBox="0 0 24 24">
                                <circle cx="11" cy="11" r="7"/>
                                <path d="m20 20-4-4"/>
                                </svg>
                                <input name="q" value="<c:out value='${param.q}'/>" placeholder="Tìm theo mã voucher">
                                <button type="submit">Tìm</button>
                            </div>
                        </form>
                        <div class="toolbar-actions">
                            <a class="primary-action" href="${pageContext.request.contextPath}/manager/vouchers?action=new">Thêm voucher <b>+</b>
                            </a>
                        </div>
                    </section>

                    <section class="data-panel">
                        <div class="table-scroll">
                            <table class="manager-table">
                                <thead>
                                    <tr>
                                        <th>Mã voucher</th>
                                        <th>Giá trị</th>
                                        <th>Đơn tối thiểu</th>
                                        <th>Hết hạn</th>
                                        <th>Loại</th>
                                        <th>Trạng thái</th>
                                        <th class="action-column">Thao tác</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="voucher" items="${voucherList}">
                                        <tr>
                                            <td>
                                                <div class="voucher-code">
                                                    <svg viewBox="0 0 24 24">
                                                    <path d="M2 9a3 3 0 0 0 0 6v4h20v-4a3 3 0 0 0 0-6V5H2Z"/>
                                                    <path d="M13 5v3m0 3v2m0 3v3"/>
                                                    </svg>
                                                    <code>
                                                        <c:out value="${voucher.voucherCode}"/>
                                                    </code>
                                                </div>
                                            </td>
                                            <td>
                                                <strong>
                                                    <fmt:formatNumber value="${voucher.discountValue}" pattern="#,##0"/>đ</strong>
                                            </td>
                                            <td>
                                                <fmt:formatNumber value="${voucher.minOrderValue}" pattern="#,##0"/>đ</td>
                                            <td>
                                                <fmt:formatDate value="${voucher.expiryDate}" pattern="dd/MM/yyyy HH:mm"/>
                                            </td>
                                            <td>${empty voucher.ownerUserId ? 'Công khai' : 'Ví cá nhân'}</td>
                                            <td>
                                                <span class="state-pill ${voucher.status && !voucher.expired ? 'active' : 'locked'}">${voucher.status && !voucher.expired ? 'Còn hạn' : 'Hết hạn/Khóa'}</span>
                                            </td>
                                            <td>
                                                <div class="row-actions">
                                                    <a href="${pageContext.request.contextPath}/manager/vouchers?action=edit&id=${voucher.voucherId}" title="Sửa" aria-label="Sửa">
                                                        <svg viewBox="0 0 24 24">
                                                        <path d="M12 20h9"/>
                                                        <path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L8 18l-4 1 1-4Z"/>
                                                        </svg>
                                                    </a>
                                                    <form method="post" action="${pageContext.request.contextPath}/manager/vouchers">
                                                        <input type="hidden" name="action" value="toggle">
                                                        <input type="hidden" name="id" value="${voucher.voucherId}">
                                                        <input type="hidden" name="active" value="${!voucher.status}">
                                                        <button type="submit" title="${voucher.status ? 'Khóa' : 'Mở'}" aria-label="${voucher.status ? 'Khóa' : 'Mở'}">
                                                            <svg viewBox="0 0 24 24">
                                                            <rect x="4" y="10" width="16" height="11" rx="2"/>
                                                            <path d="M8 10V7a4 4 0 0 1 8 0v3"/>
                                                            </svg>
                                                        </button>
                                                    </form>
                                                    <form method="post" action="${pageContext.request.contextPath}/manager/vouchers" data-confirm="Xóa voucher này?">
                                                        <input type="hidden" name="action" value="delete">
                                                        <input type="hidden" name="id" value="${voucher.voucherId}">
                                                        <button type="submit" title="Xóa" aria-label="Xóa">
                                                            <svg viewBox="0 0 24 24">
                                                            <path d="M3 6h18M8 6V4h8v2m3 0-1 15H6L5 6m5 4v7m4-7v7"/>
                                                            </svg>
                                                        </button>
                                                    </form>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty voucherList}">
                                        <tr>
                                            <td colspan="7">
                                                <div class="empty-row">Chưa có voucher phù hợp.</div>
                                            </td>
                                        </tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                        <footer class="table-footer">
                            <span>Hiển thị <strong>${fn:length(voucherList)}</strong> voucher</span>
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

        <c:if test="${not empty formMode}">
            <fmt:formatDate value="${editingVoucher.expiryDate}" pattern="yyyy-MM-dd'T'HH:mm" var="expiryValue"/>
            <div class="manager-modal">
                <a class="modal-shade" href="${pageContext.request.contextPath}/manager/vouchers" aria-label="Đóng">
                </a>
                <section class="manager-dialog compact" role="dialog" aria-modal="true">
                    <div class="dialog-heading">
                        <div>
                            <span>ƯU ĐÃI</span>
                            <h2>${formMode == 'edit' ? 'Sửa voucher' : 'Thêm voucher'}</h2>
                        </div>
                        <a href="${pageContext.request.contextPath}/manager/vouchers" aria-label="Đóng">×</a>
                    </div>
                    <form method="post" action="${pageContext.request.contextPath}/manager/vouchers" class="manager-form">
                        <input type="hidden" name="action" value="${formMode == 'edit' ? 'update' : 'create'}">
                        <input type="hidden" name="id" value="${editingVoucher.voucherId}">
                        <label>Mã voucher *<input name="voucherCode" value="<c:out value='${editingVoucher.voucherCode}'/>" pattern="[A-Za-z0-9_-]{4,50}" required>
                        </label>
                        <div class="form-grid">
                            <label>Giá trị giảm *<input type="number" name="discountValue" value="${editingVoucher.discountValue}" min="1000" step="1000" required>
                            </label>
                            <label>Đơn tối thiểu *<input type="number" name="minOrderValue" value="${editingVoucher.minOrderValue}" min="0" step="1000" required>
                            </label>
                        </div>
                        <label>Ngày hết hạn *<input type="datetime-local" name="expiryDate" value="${expiryValue}" required>
                        </label>
                        <label class="switch-field">
                            <input type="checkbox" name="status" ${formMode == 'create' || editingVoucher.status ? 'checked' : ''}>
                            <span>
                            </span>Kích hoạt voucher</label>
                        <button class="dialog-submit" type="submit">${formMode == 'edit' ? 'Lưu thay đổi' : 'Thêm voucher'}</button>
                    </form>
                </section>
            </div>
        </c:if>
        <script src="${pageContext.request.contextPath}/assets/js/manager.js?v=20260709-orderflow1">
        </script>
    </body>
</html>


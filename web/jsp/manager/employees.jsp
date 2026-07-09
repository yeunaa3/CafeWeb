<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width,initial-scale=1">
        <title>Nhân viên - CBMS</title>
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
                        <form method="get" action="${pageContext.request.contextPath}/manager/employees">
                            <div class="search-box">
                                <svg viewBox="0 0 24 24">
                                <circle cx="11" cy="11" r="7"/>
                                <path d="m20 20-4-4"/>
                                </svg>
                                <input name="q" value="<c:out value='${param.q}'/>" placeholder="Tìm tên, username hoặc email">
                                <button type="submit" aria-label="Tìm kiếm">Tìm</button>
                            </div>
                        </form>
                        <div class="toolbar-actions">
                            <a class="primary-action" href="${pageContext.request.contextPath}/manager/employees?action=new">Thêm nhân viên <b>+</b>
                            </a>
                        </div>
                    </section>
                    <section class="data-panel">
                        <div class="table-scroll">
                            <table class="manager-table">
                                <thead>
                                    <tr>
                                        <th>Họ và tên</th>
                                        <th>Số điện thoại</th>
                                        <th>Ngày tạo</th>
                                        <th>Vị trí</th>
                                        <th>Tài khoản</th>
                                        <th>Trạng thái</th>
                                        <th class="action-column">Thao tác</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="staff" items="${staffList}">
                                        <tr>
                                            <td>
                                                <div class="person-cell">
                                                    <span>${fn:substring(staff.fullName,0,1)}</span>
                                                    <div>
                                                        <strong>
                                                            <c:out value="${staff.fullName}"/>
                                                        </strong>
                                                        <small>
                                                            <c:out value="${staff.email}"/>
                                                        </small>
                                                    </div>
                                                </div>
                                            </td>
                                            <td>
                                                <c:out value="${staff.phone}"/>
                                            </td>
                                            <td>
                                                <fmt:formatDate value="${staff.createdAt}" pattern="dd/MM/yyyy"/>
                                            </td>
                                            <td>
                                                <c:out value="${staff.staffPosition}"/>
                                            </td>
                                            <td>
                                                <code>
                                                    <c:out value="${staff.username}"/>
                                                </code>
                                            </td>
                                            <td>
                                                <span class="state-pill ${staff.status ? 'active' : 'locked'}">${staff.status ? 'Đang làm' : 'Đã khóa'}</span>
                                            </td>
                                            <td>
                                                <div class="row-actions">
                                                    <a href="${pageContext.request.contextPath}/manager/employees?action=edit&id=${staff.userId}" title="Sửa" aria-label="Sửa">
                                                        <svg viewBox="0 0 24 24">
                                                        <path d="M12 20h9"/>
                                                        <path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L8 18l-4 1 1-4Z"/>
                                                        </svg>
                                                    </a>
                                                    <form method="post" action="${pageContext.request.contextPath}/manager/employees">
                                                        <input type="hidden" name="action" value="toggle">
                                                        <input type="hidden" name="id" value="${staff.userId}">
                                                        <input type="hidden" name="active" value="${!staff.status}">
                                                        <button type="submit" title="${staff.status ? 'Khóa tài khoản' : 'Mở tài khoản'}" aria-label="${staff.status ? 'Khóa tài khoản' : 'Mở tài khoản'}">
                                                            <svg viewBox="0 0 24 24">
                                                            <rect x="4" y="10" width="16" height="11" rx="2"/>
                                                            <path d="M8 10V7a4 4 0 0 1 8 0v3"/>
                                                            <c:if test="${!staff.status}">
                                                                <path d="M16 7a4 4 0 0 0-7.5-2"/>
                                                            </c:if>
                                                            </svg>
                                                        </button>
                                                    </form>
                                                    <form method="post" action="${pageContext.request.contextPath}/manager/employees" data-confirm="Xóa nhân viên này?">
                                                        <input type="hidden" name="action" value="delete">
                                                        <input type="hidden" name="id" value="${staff.userId}">
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
                                    <c:if test="${empty staffList}">
                                        <tr>
                                            <td colspan="7">
                                                <div class="empty-row">Không tìm thấy nhân viên phù hợp.</div>
                                            </td>
                                        </tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                        <footer class="table-footer">
                            <span>Hiển thị <strong>${fn:length(staffList)}</strong> nhân viên</span>
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
            <div class="manager-modal">
                <a class="modal-shade" href="${pageContext.request.contextPath}/manager/employees" aria-label="Đóng">
                </a>
                <section class="manager-dialog" role="dialog" aria-modal="true">
                    <div class="dialog-heading">
                        <div>
                            <span>QUẢN LÝ NHÂN SỰ</span>
                            <h2>${formMode == 'edit' ? 'Sửa thông tin' : 'Thêm nhân viên'}</h2>
                        </div>
                        <a href="${pageContext.request.contextPath}/manager/employees" aria-label="Đóng">×</a>
                    </div>
                    <form method="post" action="${pageContext.request.contextPath}/manager/employees" class="manager-form">
                        <input type="hidden" name="action" value="${formMode == 'edit' ? 'update' : 'create'}">
                        <input type="hidden" name="id" value="${editingStaff.userId}">
                        <label>Họ và tên *<input name="fullName" value="<c:out value='${editingStaff.fullName}'/>" required>
                        </label>
                        <div class="form-grid">
                            <label>Số điện thoại<input name="phone" value="<c:out value='${editingStaff.phone}'/>" pattern="0[0-9]{9,10}">
                            </label>
                            <label>Vị trí *<select name="staffPosition" required>
                                    <option value="">Chọn vị trí</option>
                                    <option ${editingStaff.staffPosition == 'Thu ngân' ? 'selected' : ''}>Thu ngân</option>
                                    <option ${editingStaff.staffPosition == 'Pha chế' ? 'selected' : ''}>Pha chế</option>
                                    <option ${editingStaff.staffPosition == 'Giao hàng' ? 'selected' : ''}>Giao hàng</option>
                                    <option ${editingStaff.staffPosition == 'Nhân viên' ? 'selected' : ''}>Nhân viên</option>
                                </select>
                            </label>
                        </div>
                        <label>Địa chỉ email *<input type="email" name="email" value="<c:out value='${editingStaff.email}'/>" required>
                        </label>
                        <label>Tài khoản *<input name="username" value="<c:out value='${editingStaff.username}'/>" pattern="[A-Za-z0-9_]{4,50}" required>
                        </label>
                        <label>Mật khẩu ${formMode == 'edit' ? '(để trống nếu giữ nguyên)' : '*'}<input type="password" name="password" ${formMode == 'create' ? 'required' : ''} minlength="6">
                        </label>
                        <button class="dialog-submit" type="submit">${formMode == 'edit' ? 'Lưu thay đổi' : 'Thêm nhân viên'}</button>
                    </form>
                </section>
            </div>
        </c:if>
        <script src="${pageContext.request.contextPath}/assets/js/manager.js?v=20260709-orderflow1">
        </script>
    </body>
</html>


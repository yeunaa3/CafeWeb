<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width,initial-scale=1">
        <title>Danh mục &amp; Topping - CBMS</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/manager.css?v=20260709-orderflow1">
    </head>
    <body class="manager-page">
        <div class="manager-shell">
            <%@include file="includes/sidebar.jspf"%>
            <div class="manager-main">
                <%@include file="includes/header.jspf"%>
                <main class="manager-content">
                    <c:if test="${not empty success}">
                        <div class="manager-alert success"><c:out value="${success}"/></div>
                    </c:if>
                    <c:if test="${not empty error}">
                        <div class="manager-alert error"><c:out value="${error}"/></div>
                    </c:if>

                    <section class="toolbar-band">
                        <form method="get" action="${pageContext.request.contextPath}/manager/catalog">
                            <div class="search-box">
                                <svg viewBox="0 0 24 24">
                                <circle cx="11" cy="11" r="7"/>
                                <path d="m20 20-4-4"/>
                                </svg>
                                <input name="q" value="<c:out value='${param.q}'/>" placeholder="Tìm danh mục hoặc topping">
                                <button type="submit">Tìm</button>
                            </div>
                        </form>
                        <div class="toolbar-actions">
                            <a class="primary-action" href="${pageContext.request.contextPath}/manager/catalog?action=new-category">Thêm danh mục <b>+</b></a>
                            <a class="primary-action" href="${pageContext.request.contextPath}/manager/catalog?action=new-topping">Thêm topping <b>+</b></a>
                        </div>
                    </section>

                    <section class="data-panel">
                        <div class="panel-title-row">
                            <div>
                                <span>THỰC ĐƠN</span>
                                <h2>Danh mục sản phẩm</h2>
                            </div>
                        </div>
                        <div class="table-scroll">
                            <table class="manager-table">
                                <thead>
                                    <tr>
                                        <th>Danh mục</th>
                                        <th>Mô tả</th>
                                        <th>Trạng thái</th>
                                        <th class="action-column">Thao tác</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="category" items="${categoryList}">
                                        <tr>
                                            <td>
                                                <div class="voucher-code">
                                                    <svg viewBox="0 0 24 24">
                                                    <path d="M4 4h16v16H4z"/>
                                                    <path d="M8 8h8M8 12h8M8 16h5"/>
                                                    </svg>
                                                    <div>
                                                        <strong><c:out value="${category.categoryName}"/></strong>
                                                        <small>#${category.categoryId}</small>
                                                    </div>
                                                </div>
                                            </td>
                                            <td><c:out value="${category.description}"/></td>
                                            <td>
                                                <span class="state-pill ${category.status ? 'active' : 'locked'}">${category.status ? 'Đang dùng' : 'Đã khóa'}</span>
                                            </td>
                                            <td>
                                                <div class="row-actions">
                                                    <a href="${pageContext.request.contextPath}/manager/catalog?action=edit-category&id=${category.categoryId}" title="Sửa" aria-label="Sửa">
                                                        <svg viewBox="0 0 24 24">
                                                        <path d="M12 20h9"/>
                                                        <path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L8 18l-4 1 1-4Z"/>
                                                        </svg>
                                                    </a>
                                                    <form method="post" action="${pageContext.request.contextPath}/manager/catalog">
                                                        <input type="hidden" name="action" value="toggle-category">
                                                        <input type="hidden" name="id" value="${category.categoryId}">
                                                        <input type="hidden" name="active" value="${!category.status}">
                                                        <button type="submit" title="${category.status ? 'Khóa' : 'Mở'}" aria-label="${category.status ? 'Khóa' : 'Mở'}">
                                                            <svg viewBox="0 0 24 24">
                                                            <rect x="4" y="10" width="16" height="11" rx="2"/>
                                                            <path d="M8 10V7a4 4 0 0 1 8 0v3"/>
                                                            </svg>
                                                        </button>
                                                    </form>
                                                    <form method="post" action="${pageContext.request.contextPath}/manager/catalog" data-confirm="Xóa danh mục này?">
                                                        <input type="hidden" name="action" value="delete-category">
                                                        <input type="hidden" name="id" value="${category.categoryId}">
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
                                    <c:if test="${empty categoryList}">
                                        <tr>
                                            <td colspan="4"><div class="empty-row">Chưa có danh mục phù hợp.</div></td>
                                        </tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                        <footer class="table-footer">
                            <span>Hiển thị <strong>${fn:length(categoryList)}</strong> danh mục</span>
                            <div class="pagination"><button disabled>&lsaquo;</button><b>1</b><button disabled>&rsaquo;</button></div>
                        </footer>
                    </section>

                    <section class="data-panel">
                        <div class="panel-title-row">
                            <div>
                                <span>TÙY CHỌN</span>
                                <h2>Topping</h2>
                            </div>
                        </div>
                        <div class="table-scroll">
                            <table class="manager-table">
                                <thead>
                                    <tr>
                                        <th>Topping</th>
                                        <th>Giá</th>
                                        <th>Trạng thái</th>
                                        <th class="action-column">Thao tác</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="topping" items="${toppingList}">
                                        <tr>
                                            <td>
                                                <div class="voucher-code">
                                                    <svg viewBox="0 0 24 24">
                                                    <circle cx="12" cy="12" r="8"/>
                                                    <path d="M8 12h8M12 8v8"/>
                                                    </svg>
                                                    <div>
                                                        <strong><c:out value="${topping.toppingName}"/></strong>
                                                        <small>#${topping.toppingId}</small>
                                                    </div>
                                                </div>
                                            </td>
                                            <td><strong><fmt:formatNumber value="${topping.price}" pattern="#,##0"/>đ</strong></td>
                                            <td>
                                                <span class="state-pill ${topping.status ? 'active' : 'locked'}">${topping.status ? 'Đang dùng' : 'Đã khóa'}</span>
                                            </td>
                                            <td>
                                                <div class="row-actions">
                                                    <a href="${pageContext.request.contextPath}/manager/catalog?action=edit-topping&id=${topping.toppingId}" title="Sửa" aria-label="Sửa">
                                                        <svg viewBox="0 0 24 24">
                                                        <path d="M12 20h9"/>
                                                        <path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L8 18l-4 1 1-4Z"/>
                                                        </svg>
                                                    </a>
                                                    <form method="post" action="${pageContext.request.contextPath}/manager/catalog">
                                                        <input type="hidden" name="action" value="toggle-topping">
                                                        <input type="hidden" name="id" value="${topping.toppingId}">
                                                        <input type="hidden" name="active" value="${!topping.status}">
                                                        <button type="submit" title="${topping.status ? 'Khóa' : 'Mở'}" aria-label="${topping.status ? 'Khóa' : 'Mở'}">
                                                            <svg viewBox="0 0 24 24">
                                                            <rect x="4" y="10" width="16" height="11" rx="2"/>
                                                            <path d="M8 10V7a4 4 0 0 1 8 0v3"/>
                                                            </svg>
                                                        </button>
                                                    </form>
                                                    <form method="post" action="${pageContext.request.contextPath}/manager/catalog" data-confirm="Xóa topping này?">
                                                        <input type="hidden" name="action" value="delete-topping">
                                                        <input type="hidden" name="id" value="${topping.toppingId}">
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
                                    <c:if test="${empty toppingList}">
                                        <tr>
                                            <td colspan="4"><div class="empty-row">Chưa có topping phù hợp.</div></td>
                                        </tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                        <footer class="table-footer">
                            <span>Hiển thị <strong>${fn:length(toppingList)}</strong> topping</span>
                            <div class="pagination"><button disabled>&lsaquo;</button><b>1</b><button disabled>&rsaquo;</button></div>
                        </footer>
                    </section>
                </main>
            </div>
        </div>

        <c:if test="${not empty categoryFormMode}">
            <div class="manager-modal">
                <a class="modal-shade" href="${pageContext.request.contextPath}/manager/catalog" aria-label="Đóng"></a>
                <section class="manager-dialog compact" role="dialog" aria-modal="true">
                    <div class="dialog-heading">
                        <div>
                            <span>DANH MỤC</span>
                            <h2>${categoryFormMode == 'edit' ? 'Sửa danh mục' : 'Thêm danh mục'}</h2>
                        </div>
                        <a href="${pageContext.request.contextPath}/manager/catalog" aria-label="Đóng">×</a>
                    </div>
                    <form method="post" action="${pageContext.request.contextPath}/manager/catalog" class="manager-form">
                        <input type="hidden" name="action" value="${categoryFormMode == 'edit' ? 'update-category' : 'create-category'}">
                        <input type="hidden" name="id" value="${editingCategory.categoryId}">
                        <label>Tên danh mục *<input name="categoryName" value="<c:out value='${editingCategory.categoryName}'/>" required maxlength="100"></label>
                        <label>Mô tả<textarea name="description" rows="3"><c:out value="${editingCategory.description}"/></textarea></label>
                        <label class="switch-field">
                            <input type="checkbox" name="status" ${categoryFormMode == 'create' || editingCategory.status ? 'checked' : ''}>
                            <span></span>Đang dùng
                        </label>
                        <button class="dialog-submit" type="submit">${categoryFormMode == 'edit' ? 'Lưu thay đổi' : 'Thêm danh mục'}</button>
                    </form>
                </section>
            </div>
        </c:if>

        <c:if test="${not empty toppingFormMode}">
            <div class="manager-modal">
                <a class="modal-shade" href="${pageContext.request.contextPath}/manager/catalog" aria-label="Đóng"></a>
                <section class="manager-dialog compact" role="dialog" aria-modal="true">
                    <div class="dialog-heading">
                        <div>
                            <span>TOPPING</span>
                            <h2>${toppingFormMode == 'edit' ? 'Sửa topping' : 'Thêm topping'}</h2>
                        </div>
                        <a href="${pageContext.request.contextPath}/manager/catalog" aria-label="Đóng">×</a>
                    </div>
                    <form method="post" action="${pageContext.request.contextPath}/manager/catalog" class="manager-form">
                        <input type="hidden" name="action" value="${toppingFormMode == 'edit' ? 'update-topping' : 'create-topping'}">
                        <input type="hidden" name="id" value="${editingTopping.toppingId}">
                        <label>Tên topping *<input name="toppingName" value="<c:out value='${editingTopping.toppingName}'/>" required maxlength="100"></label>
                        <label>Giá *<input type="number" name="price" value="${editingTopping.price}" min="0" step="1000" required></label>
                        <label class="switch-field">
                            <input type="checkbox" name="status" ${toppingFormMode == 'create' || editingTopping.status ? 'checked' : ''}>
                            <span></span>Đang dùng
                        </label>
                        <button class="dialog-submit" type="submit">${toppingFormMode == 'edit' ? 'Lưu thay đổi' : 'Thêm topping'}</button>
                    </form>
                </section>
            </div>
        </c:if>
        <script src="${pageContext.request.contextPath}/js/manager.js?v=20260709-orderflow1"></script>
    </body>
</html>

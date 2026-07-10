<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width,initial-scale=1">
        <title>Sản phẩm - CBMS</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/manager.css?v=20260709-orderflow1">
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
                    <section class="toolbar-band">
                        <form method="get" action="${pageContext.request.contextPath}/manager/products">
                            <div class="search-box">
                                <svg viewBox="0 0 24 24">
                                <circle cx="11" cy="11" r="7"/>
                                <path d="m20 20-4-4"/>
                                </svg>
                                <input name="q" value="<c:out value='${param.q}'/>" placeholder="Tìm tên món hoặc danh mục">
                                <button type="submit">Tìm</button>
                            </div>
                        </form>
                        <div class="toolbar-actions">
                            <a class="primary-action" href="${pageContext.request.contextPath}/manager/products?action=new">Thêm sản phẩm <b>+</b>
                            </a>
                        </div>
                    </section>
                    <section class="data-panel">
                        <div class="table-scroll">
                            <table class="manager-table product-table">
                                <thead>
                                    <tr>
                                        <th>Sản phẩm</th>
                                        <th>Danh mục</th>
                                        <th>Giá</th>
                                        <th>Ngày tạo</th>
                                        <th>Trạng thái</th>
                                        <th class="action-column">Thao tác</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="product" items="${productList}">
                                        <tr>
                                            <td>
                                                <div class="product-cell">
                                                    <span>
                                                        <c:choose>
                                                            <c:when test="${not empty product.displayImageUrl}">
                                                                <img src="${pageContext.request.contextPath}${product.displayImageUrl}" alt="" onerror="this.hidden=true;">
                                                            </c:when>
                                                            <c:otherwise>${fn:substring(product.productName,0,1)}</c:otherwise>
                                                        </c:choose>
                                                    </span>
                                                    <div>
                                                        <strong>
                                                            <c:out value="${product.productName}"/>
                                                        </strong>
                                                        <small>#${product.productId}</small>
                                                    </div>
                                                </div>
                                            </td>
                                            <td>
                                                <c:out value="${product.categoryName}"/>
                                            </td>
                                            <td>
                                                <strong>
                                                    <fmt:formatNumber value="${product.price}" pattern="#,##0"/>đ</strong>
                                            </td>
                                            <td>
                                                <fmt:formatDate value="${product.createdAt}" pattern="dd/MM/yyyy"/>
                                            </td>
                                            <td>
                                                <span class="state-pill ${product.status ? 'active' : 'locked'}">${product.status ? 'Còn hàng' : 'Hết hàng'}</span>
                                            </td>
                                            <td>
                                                <div class="row-actions">
                                                    <a href="${pageContext.request.contextPath}/manager/products?action=edit&id=${product.productId}" title="Sửa" aria-label="Sửa">
                                                        <svg viewBox="0 0 24 24">
                                                        <path d="M12 20h9"/>
                                                        <path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L8 18l-4 1 1-4Z"/>
                                                        </svg>
                                                    </a>
                                                    <form method="post" action="${pageContext.request.contextPath}/manager/products">
                                                        <input type="hidden" name="action" value="toggle">
                                                        <input type="hidden" name="id" value="${product.productId}">
                                                        <input type="hidden" name="active" value="${!product.status}">
                                                        <button type="submit" title="${product.status ? 'Đánh dấu hết hàng' : 'Mở bán'}" aria-label="${product.status ? 'Đánh dấu hết hàng' : 'Mở bán'}">
                                                            <svg viewBox="0 0 24 24">
                                                            <rect x="4" y="10" width="16" height="11" rx="2"/>
                                                            <path d="M8 10V7a4 4 0 0 1 8 0v3"/>
                                                            </svg>
                                                        </button>
                                                    </form>
                                                    <form method="post" action="${pageContext.request.contextPath}/manager/products" data-confirm="Xóa sản phẩm này?">
                                                        <input type="hidden" name="action" value="delete">
                                                        <input type="hidden" name="id" value="${product.productId}">
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
                                    <c:if test="${empty productList}">
                                        <tr>
                                            <td colspan="6">
                                                <div class="empty-row">Không tìm thấy sản phẩm phù hợp.</div>
                                            </td>
                                        </tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                        <footer class="table-footer">
                            <span>Hiển thị <strong>${fn:length(productList)}</strong> sản phẩm</span>
                            <div class="pagination">
                                <button disabled>â€¹</button>
                                <b>1</b>
                                <button disabled>â€º</button>
                            </div>
                        </footer>
                    </section>
                </main>
            </div>
        </div>
        <c:if test="${not empty formMode}">
            <div class="manager-modal">
                <a class="modal-shade" href="${pageContext.request.contextPath}/manager/products" aria-label="Đóng">
                </a>
                <section class="manager-dialog" role="dialog" aria-modal="true">
                    <div class="dialog-heading">
                        <div>
                            <span>QUẢN LÝ THỰC ĐƠN</span>
                            <h2>${formMode == 'edit' ? 'Sửa sản phẩm' : 'Thêm sản phẩm'}</h2>
                        </div>
                        <a href="${pageContext.request.contextPath}/manager/products" aria-label="Đóng">×</a>
                    </div>
                    <form method="post" action="${pageContext.request.contextPath}/manager/products" class="manager-form" enctype="multipart/form-data">
                        <input type="hidden" name="action" value="${formMode == 'edit' ? 'update' : 'create'}">
                        <input type="hidden" name="id" value="${editingProduct.productId}">
                        <input type="hidden" name="currentImageUrl" value="<c:out value='${editingProduct.imageUrl}'/>">
                        <label>Tên sản phẩm *<input name="productName" value="<c:out value='${editingProduct.productName}'/>" required>
                        </label>
                        <div class="form-grid">
                            <label>Danh mục *<select name="categoryId" required>
                                    <option value="">Chọn danh mục</option>
                                    <c:forEach var="category" items="${categoryList}">
                                        <option value="${category.categoryId}" ${editingProduct.categoryId == category.categoryId ? 'selected' : ''}>
                                            <c:out value="${category.categoryName}"/>
                                        </option>
                                    </c:forEach>
                                </select>
                            </label>
                            <label>Giá bán *<input type="number" name="price" value="${editingProduct.price}" min="0" step="1000" required>
                            </label>
                        </div>
                        <label class="file-upload-field">Ảnh sản phẩm
                            <input type="file" name="productImage" accept="image/png,image/jpeg,image/webp">
                            <c:if test="${not empty editingProduct.imageUrl}">
                                <small>Đang dùng: <c:out value="${editingProduct.imageUrl}"/></small>
                            </c:if>
                        </label>
                        <label>Mô tả<textarea name="description" rows="3">
                                <c:out value="${editingProduct.description}"/>
                            </textarea>
                        </label>
                        <label class="switch-field">
                            <input type="checkbox" name="status" ${formMode == 'create' || editingProduct.status ? 'checked' : ''}>
                            <span>
                            </span>Đang mở bán</label>
                        <button class="dialog-submit" type="submit">${formMode == 'edit' ? 'Lưu thay đổi' : 'Thêm sản phẩm'}</button>
                    </form>
                </section>
            </div>
        </c:if>
        <script src="${pageContext.request.contextPath}/js/manager.js?v=20260709-orderflow1">
        </script>
    </body>
</html>


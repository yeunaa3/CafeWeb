<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width,initial-scale=1">
        <title>Sản phẩm - Thu ngân</title>
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
                    <section class="toolbar-band">
                        <form method="get" action="${pageContext.request.contextPath}/cashier/products">
                            <div class="search-box">
                                <svg viewBox="0 0 24 24">
                                <circle cx="11" cy="11" r="7"/>
                                <path d="m20 20-4-4"/>
                                </svg>
                                <input name="q" value="<c:out value='${param.q}'/>" placeholder="Tìm sản phẩm">
                                <button>Tìm</button>
                            </div>
                        </form>
                    </section>
                    <section class="data-panel">
                        <div class="table-scroll">
                            <table class="manager-table">
                                <thead>
                                    <tr>
                                        <th>Sản phẩm</th>
                                        <th>Danh mục</th>
                                        <th>Giá</th>
                                        <th>Thời gian</th>
                                        <th>Trạng thái</th>
                                        <th>
                                        </th>
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
                                                <fmt:formatNumber value="${product.price}" pattern="#,##0"/>đ</td>
                                            <td>
                                                <fmt:formatDate value="${product.createdAt}" pattern="dd/MM/yyyy"/>
                                            </td>
                                            <td>
                                                <span class="state-pill ${product.status?'active':'locked'}">${product.status?'Còn hàng':'Hết hàng'}</span>
                                            </td>
                                            <td>
                                                <form method="post" action="${pageContext.request.contextPath}/cashier/products">
                                                    <input type="hidden" name="id" value="${product.productId}">
                                                    <input type="hidden" name="active" value="${!product.status}">
                                                    <button class="availability-button" type="submit">${product.status?'Đánh dấu hết':'Mở bán'}</button>
                                                </form>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                        <footer class="table-footer">
                            <span>${fn:length(productList)} sản phẩm</span>
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
        <script src="${pageContext.request.contextPath}/js/manager.js?v=20260709-orderflow1">
        </script>
    </body>
</html>


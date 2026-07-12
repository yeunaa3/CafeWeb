<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Menu - Cafe & Bubble tea</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/customer.css?v=20260709-orderflow1">
    </head>
    <body class="menu-page-enhanced" data-context-path="${pageContext.request.contextPath}">
        <main class="page-shell">
            <header class="site-header">
                <a class="brand" href="${pageContext.request.contextPath}/home">Cafe & Bubble tea</a>
                <nav class="site-nav">
                    <a class="active-nav" href="${pageContext.request.contextPath}/menu">Menu</a>
                    <a class="cart-link" href="${pageContext.request.contextPath}/checkout">Giỏ Hàng <span class="cart-count">${cartCount}</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/home#contact">Liên Hệ</a>
                    <c:choose>
                        <c:when test="${not empty sessionScope.user}">
                            <c:if test="${sessionScope.user.roleId == 3}">
                            <button class="notification-button" type="button" data-open-orders title="Thông báo đơn hàng" aria-label="Thông báo đơn hàng">
                                <svg class="ui-icon" viewBox="0 0 24 24" aria-hidden="true">
                                <path d="M10.268 21a2 2 0 0 0 3.464 0"/>
                                <path d="M3.262 15.326A1 1 0 0 0 4 17h16a1 1 0 0 0 .74-1.673C19.41 13.956 18 12.499 18 8A6 6 0 0 0 6 8c0 4.499-1.411 5.956-2.738 7.326"/>
                                </svg>
                                <c:if test="${notificationCount > 0}">
                                    <span>${notificationCount}</span>
                                </c:if>
                            </button>
                            </c:if>
                            <a class="customer-nav-avatar" href="${pageContext.request.contextPath}/profile" title="Thông tin cá nhân" aria-label="Thông tin cá nhân">
                                <c:choose>
                                    <c:when test="${not empty sessionScope.user.displayAvatarUrl}">
                                        <span class="avatar-fallback" hidden>${fn:substring(sessionScope.user.fullName,0,1)}</span>
                                        <img src="${pageContext.request.contextPath}${sessionScope.user.displayAvatarUrl}" alt="" onerror="this.hidden=true;this.previousElementSibling.hidden=false;">
                                    </c:when>
                                    <c:otherwise>${fn:substring(sessionScope.user.fullName,0,1)}</c:otherwise>
                                </c:choose>
                            </a>
                        </c:when>
                        <c:otherwise>
                            <a class="login-button" href="${pageContext.request.contextPath}/login?returnUrl=/menu">Đăng nhập</a>
                        </c:otherwise>
                    </c:choose>
                </nav>
            </header>

            <section class="menu-heading">
                <div>
                    <span class="page-kicker">Thực đơn hôm nay</span>
                    <h1>Menu</h1>
                </div>
                <form class="search-form" action="${pageContext.request.contextPath}/menu" method="get">
                    <input type="search" name="keyword" value="${keyword}" placeholder="Tìm món yêu thích">
                    <button type="submit" aria-label="Tìm kiếm">Tìm</button>
                </form>
            </section>


            <nav class="category-nav" aria-label="Danh mục thực đơn">
                <c:forEach var="section" items="${sections}">
                    <c:if test="${not empty section.products}">
                        <a href="#category-${section.category.categoryId}">${section.category.categoryName}</a>
                    </c:if>
                </c:forEach>
            </nav>

            <c:forEach var="section" items="${sections}">
                <c:if test="${not empty section.products}">
                    <section class="product-section" id="category-${section.category.categoryId}">
                        <h2>${section.category.categoryName}</h2>
                        <div class="product-grid">
                            <c:forEach var="product" items="${section.products}">
                                <article class="product-card">
                                    <img src="${pageContext.request.contextPath}${product.displayImageUrl}"
                                         loading="lazy"
                                         decoding="async"
                                         onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/images/products/uploads/menu-cafe-01.jpg';"
                                         alt="${product.productName}">
                                    <div class="product-info">
                                        <div>
                                            <h3>${product.productName}</h3>
                                            <p>
                                                <fmt:formatNumber value="${product.price}" pattern="#,##0"/>đ</p>
                                        </div>
                                        <button class="icon-button add-product-btn"
                                                type="button"
                                                aria-label="Thêm ${product.productName}"
                                                data-product-id="${product.productId}"
                                                data-product-name="${product.productName}"
                                                data-product-price="${product.price}"
                                                data-product-image="${product.displayImageUrl}">+</button>
                                    </div>
                                </article>
                            </c:forEach>
                        </div>
                    </section>
                </c:if>
            </c:forEach>

            <c:if test="${not hasProducts}">
                <div class="empty-state menu-empty">
                    <p>Không tìm thấy món phù hợp.</p>
                    <a href="${pageContext.request.contextPath}/menu">Xóa bộ lọc</a>
                </div>
            </c:if>

            <section class="cart-strip">
                <strong>Cafe & Bubble tea</strong>
                <a class="danger-button" href="${pageContext.request.contextPath}/checkout">Xem Giỏ Hàng <span class="cart-count">${cartCount}</span>
                </a>
            </section>

            <footer class="site-footer">
                <strong>Contact</strong>
                <div class="social-row">
                    <a href="https://www.facebook.com/n.khanh.290706" target="_blank" rel="noopener" aria-label="Facebook">F</a>
                    <a href="https://www.youtube.com/watch?v=8sVtL0o-v7U&list=RDgJAbDSse5WM&index=4" target="_blank" rel="noopener" aria-label="YouTube">YT</a>
                    <a href="https://instagram.com/" target="_blank" rel="noopener" aria-label="Instagram">Ins</a>
                </div>
            </footer>
        </main>

        <div class="modal-backdrop" id="drinkModal" aria-hidden="true">
            <form class="drink-modal" id="addCartForm">
                <input type="hidden" name="action" value="add">
                <input type="hidden" name="ajax" value="true">
                <input type="hidden" name="productId" id="modalProductId">
                <button class="modal-close" type="button" aria-label="Đóng">×</button>
                <div class="modal-product-summary">
                    <img id="modalProductImage" src="" alt="" onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/images/products/uploads/menu-cafe-01.jpg';">
                    <div>
                        <span>Tùy chỉnh món</span>
                        <h2 id="modalProductName">Chọn món</h2>
                        <p class="modal-price" id="modalProductPrice">
                        </p>
                    </div>
                </div>

                <label>Số lượng</label>
                <div class="modal-quantity">
                    <button type="button" data-modal-quantity="-1" aria-label="Giảm số lượng">−</button>
                    <input class="number-input" type="number" name="quantity" value="1" min="1" max="99" readonly>
                    <button type="button" data-modal-quantity="1" aria-label="Tăng số lượng">+</button>
                </div>

                <label>Size</label>
                <div class="choice-row">
                    <label>
                        <input type="radio" name="selectedSize" value="S"> S</label>
                    <label>
                        <input type="radio" name="selectedSize" value="M" checked> M</label>
                    <label>
                        <input type="radio" name="selectedSize" value="L"> L +5.000đ</label>
                </div>

                <label>Đá</label>
                <select name="iceLevel">
                    <option value="100%">100%</option>
                    <option value="50%">50%</option>
                    <option value="30%">30%</option>
                    <option value="0%">0%</option>
                </select>

                <label>Đường</label>
                <select name="sugarLevel">
                    <option value="100%">100%</option>
                    <option value="70%">70%</option>
                    <option value="50%">50%</option>
                    <option value="30%">30%</option>
                    <option value="0%">0%</option>
                </select>

                <label>Topping</label>
                <div class="topping-list">
                    <c:forEach var="topping" items="${toppings}">
                        <label>
                            <input type="checkbox" name="toppingIds" value="${topping.toppingId}" data-topping-price="${topping.price}">
                            <span>${topping.toppingName}</span>
                            <em>+<fmt:formatNumber value="${topping.price}" pattern="#,##0"/>đ</em>
                        </label>
                    </c:forEach>
                </div>

                <div class="modal-total">
                    <span>Tạm tính</span>
                    <strong id="modalTotal">0đ</strong>
                </div>
                <button class="primary-button wide-button" type="submit">
                    <span>Thêm vào giỏ</span>
                </button>
            </form>
        </div>

        <c:if test="${not empty sessionScope.user && sessionScope.user.roleId == 3}">
            <div class="order-modal" id="orderModal" aria-hidden="true">
                <div class="modal-backdrop" data-close-orders>
                </div>
                <section class="order-dialog" role="dialog" aria-modal="true" aria-labelledby="orderDialogTitle">
                    <div class="order-dialog-heading">
                        <div>
                            <span>Thông báo</span>
                            <h2 id="orderDialogTitle">Đơn hàng của bạn</h2>
                        </div>
                        <button type="button" class="modal-close" data-close-orders aria-label="Đóng">&times;</button>
                    </div>
                    <c:choose>
                        <c:when test="${empty customerOrders}">
                            <p class="empty-state">Bạn chưa có đơn hàng nào.</p>
                        </c:when>
                        <c:otherwise>
                            <div class="order-notification-list">
                                <c:forEach var="order" items="${customerOrders}">
                                    <article class="order-notification">
                                        <div class="order-notification-top">
                                            <strong>Đơn #${order.orderId}</strong>
                                            <span class="status-pill status-${fn:toLowerCase(order.status)}">${order.displayStatus}</span>
                                        </div>
                                        <p>
                                            <c:out value="${order.items}"/>
                                        </p>
                                        <div>
                                            <fmt:formatDate value="${order.orderDate}" pattern="dd/MM/yyyy HH:mm"/> <strong>
                                                <fmt:formatNumber value="${order.totalPrice}" pattern="#,##0"/>đ</strong>
                                        </div>
                                    </article>
                                </c:forEach>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </section>
            </div>
        </c:if>

        <div class="toast" id="toast">Đã thêm vào giỏ hàng</div>
        <script src="${pageContext.request.contextPath}/js/customer.js?v=20260709-orderflow1">
        </script>
    </body>
</html>


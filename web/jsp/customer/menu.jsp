<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Menu - Cafe & Bubble tea</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer.css">
    </head>
    <body data-context-path="${pageContext.request.contextPath}">
        <main class="page-shell">
            <header class="site-header">
                <a class="brand" href="${pageContext.request.contextPath}/home">Cafe & Bubble tea</a>
                <nav class="site-nav">
                    <a href="${pageContext.request.contextPath}/menu">Đặt Hàng</a>
                    <a class="cart-link" href="${pageContext.request.contextPath}/checkout">Giỏ Hàng <span class="cart-count">${cartCount}</span></a>
                    <a href="${pageContext.request.contextPath}/home#contact">Liên Hệ</a>
                    <a class="login-button" href="#">Đăng Nhập</a>
                </nav>
            </header>

            <section class="menu-heading">
                <h1>Menu</h1>
                <form class="search-form" action="${pageContext.request.contextPath}/menu" method="get">
                    <input type="search" name="keyword" value="${keyword}" placeholder="Search">
                    <button type="submit" aria-label="Search">⌕</button>
                </form>
            </section>

            <img class="menu-cover" src="https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?auto=format&fit=crop&w=1400&q=80" alt="Tea cover">

            <c:forEach var="section" items="${sections}">
                <c:if test="${not empty section.products}">
                    <section class="product-section">
                        <h2>${section.category.categoryName}</h2>
                        <div class="product-grid">
                            <c:forEach var="product" items="${section.products}">
                                <article class="product-card">
                                    <img src="${pageContext.request.contextPath}/assets/images/${product.imageUrl}"
                                         onerror="this.onerror=null;this.src='https://images.unsplash.com/photo-1551024601-bec78aea704b?auto=format&fit=crop&w=500&q=80';"
                                         alt="${product.productName}">
                                    <div class="product-info">
                                        <div>
                                            <h3>${product.productName}</h3>
                                            <p><fmt:formatNumber value="${product.price}" pattern="#,##0"/>đ</p>
                                        </div>
                                        <button class="icon-button add-product-btn"
                                                type="button"
                                                aria-label="Thêm ${product.productName}"
                                                data-product-id="${product.productId}"
                                                data-product-name="${product.productName}"
                                                data-product-price="${product.price}"
                                                data-product-image="${product.imageUrl}">+</button>
                                    </div>
                                </article>
                            </c:forEach>
                        </div>
                    </section>
                </c:if>
            </c:forEach>

            <c:if test="${empty sections}">
                <p class="empty-state">Không tìm thấy món phù hợp.</p>
            </c:if>

            <section class="cart-strip">
                <strong>Cafe & Bubble tea</strong>
                <a class="danger-button" href="${pageContext.request.contextPath}/checkout">Xem Giỏ Hàng <span class="cart-count">${cartCount}</span></a>
            </section>

            <footer class="site-footer">
                <strong>Cafe & Bubble tea</strong>
                <div class="social-row">
                    <span>f</span><span>in</span><span>yt</span><span>ig</span>
                </div>
            </footer>
        </main>

        <div class="modal-backdrop" id="drinkModal" aria-hidden="true">
            <form class="drink-modal" id="addCartForm">
                <input type="hidden" name="action" value="add">
                <input type="hidden" name="ajax" value="true">
                <input type="hidden" name="productId" id="modalProductId">
                <button class="modal-close" type="button" aria-label="Đóng">×</button>
                <h2 id="modalProductName">Chọn món</h2>
                <p class="modal-price" id="modalProductPrice"></p>

                <label>Số lượng</label>
                <input class="number-input" type="number" name="quantity" value="1" min="1">

                <label>Size</label>
                <div class="choice-row">
                    <label><input type="radio" name="selectedSize" value="S"> S</label>
                    <label><input type="radio" name="selectedSize" value="M" checked> M</label>
                    <label><input type="radio" name="selectedSize" value="L"> L +5.000đ</label>
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
                            <input type="checkbox" name="toppingIds" value="${topping.toppingId}">
                            <span>${topping.toppingName}</span>
                            <em>+<fmt:formatNumber value="${topping.price}" pattern="#,##0"/>đ</em>
                        </label>
                    </c:forEach>
                </div>

                <button class="primary-button wide-button" type="submit">Thêm vào giỏ</button>
            </form>
        </div>

        <div class="toast" id="toast">Đã thêm vào giỏ hàng</div>
        <script src="${pageContext.request.contextPath}/assets/js/customer.js"></script>
    </body>
</html>

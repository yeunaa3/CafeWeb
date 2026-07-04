<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Cafe & Bubble tea</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer.css">
    </head>
    <body>
        <main class="page-shell">
            <header class="site-header">
                <a class="brand" href="${pageContext.request.contextPath}/home">Cafe & Bubble tea</a>
                <nav class="site-nav">
                    <a href="${pageContext.request.contextPath}/menu">Menu</a>
                    <a class="cart-link" href="${pageContext.request.contextPath}/checkout">Giỏ Hàng <span class="cart-count">${cartCount}</span></a>
                    <a href="#contact">Liên Hệ</a>
                    <c:choose>
                        <c:when test="${not empty sessionScope.user}"><a class="login-button account-button" href="${pageContext.request.contextPath}/profile">Tài khoản</a></c:when>
                        <c:otherwise><a class="login-button" href="${pageContext.request.contextPath}/login">Đăng nhập</a></c:otherwise>
                    </c:choose>
                </nav>
            </header>

            <section class="hero">
                <div>
                    <h1>Cafe & Bubble tea</h1>
                    <a class="primary-button" href="${pageContext.request.contextPath}/menu">Xem Menu</a>
                </div>
                <img src="https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?auto=format&fit=crop&w=1400&q=80" alt="Coffee table">
            </section>

            <section class="section-block">
                <h2>Recommends</h2>
                <div class="recommend-grid">
                    <c:forEach var="product" items="${recommendedProducts}">
                        <a class="recommend-item" href="${pageContext.request.contextPath}/menu">
                            <img src="${pageContext.request.contextPath}/assets/images/${product.imageUrl}"
                                 onerror="this.onerror=null;this.src='https://images.unsplash.com/photo-1572490122747-3968b75cc699?auto=format&fit=crop&w=600&q=80';"
                                 alt="${product.productName}">
                            <span>${product.productName}</span>
                        </a>
                    </c:forEach>
                </div>
            </section>

            <section class="about-section" id="contact">
                <div>
                    <h2>Về chúng tôi</h2>
                    <p>Chúng tôi là một cửa hàng cà phê & trà sữa được tạo nên từ niềm đam mê với hương vị và trải nghiệm. Tại đây, mỗi ly đồ uống đều được chuẩn bị từ nguyên liệu chọn lọc, mang đến sự tươi mới và chút lắng đọng cho ngày của bạn.</p>
                    <a class="primary-button" href="mailto:contact@cbms.com">Liên hệ</a>
                </div>
                <img src="https://images.unsplash.com/photo-1527661591475-527312dd65f5?auto=format&fit=crop&w=900&q=80" alt="Cafe fruits">
            </section>

            <footer class="site-footer">
                <strong>Cafe & Bubble tea</strong>
                <div class="social-row">
                    <span>f</span><span>in</span><span>yt</span><span>ig</span>
                </div>
            </footer>
        </main>
    </body>
</html>

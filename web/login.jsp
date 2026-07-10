<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Đăng nhập - Cafe & Bubble tea</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/customer.css?v=20260709-orderflow1">
    </head>
    <body class="auth-simple-page">
        <div class="auth-frame-title">Sign In</div>
        <main class="auth-simple-shell">
            <header class="site-header auth-site-header">
                <a class="brand" href="${pageContext.request.contextPath}/home">Cafe & Bubble tea</a>
                <nav class="site-nav">
                    <a href="${pageContext.request.contextPath}/menu">Menu</a>
                    <a href="${pageContext.request.contextPath}/checkout">Giỏ Hàng</a>
                    <a href="${pageContext.request.contextPath}/home#contact">Liên Hệ</a>
                    <a class="login-button" href="${pageContext.request.contextPath}/login">Đăng Nhập</a>
                </nav>
            </header>

            <section class="auth-simple-content">
                <div class="auth-simple-form-wrap">
                    <h1>Đăng nhập</h1>

                    <c:if test="${param.registered == 'true'}">
                        <p class="alert success-alert">Tạo tài khoản thành công. Bạn có thể đăng nhập ngay.</p>
                    </c:if>
                    <c:if test="${not empty error}">
                        <p class="alert error-alert">
                            <c:out value="${error}"/>
                        </p>
                    </c:if>

                    <form class="auth-simple-form" action="${pageContext.request.contextPath}/login" method="post">
                        <input type="hidden" name="returnUrl" value="<c:out value='${returnUrl}'/>">

                        <label for="usernameOrEmail">Username or Email</label>
                        <input id="usernameOrEmail" type="text" name="usernameOrEmail"
                               value="<c:out value='${usernameOrEmail}'/>" placeholder="Enter your username or email"
                               autocomplete="username" required autofocus>

                        <label for="loginPassword">Password</label>
                        <input id="loginPassword" type="password" name="password"
                               placeholder="Enter your password" autocomplete="current-password" required>

                        <div class="auth-help-links">
                            <span>Bạn chưa có tài khoản? <a href="${pageContext.request.contextPath}/register">Đăng ký tại đây</a>
                            </span>
                            <span>Quên mật khẩu? <a href="${pageContext.request.contextPath}/forgot-password.jsp">Nhấn vào đây</a>
                            </span>
                        </div>

                        <button class="auth-simple-submit" type="submit">Đăng nhập</button>
                    </form>
                </div>
            </section>

            <footer class="site-footer auth-simple-footer">
                <strong>Cafe & Bubble tea</strong>
                <div class="social-row">
                    <a href="https://facebook.com/" target="_blank" rel="noopener" aria-label="Facebook">f</a>
                    <a href="https://youtube.com/" target="_blank" rel="noopener" aria-label="YouTube">yt</a>
                    <a href="https://instagram.com/" target="_blank" rel="noopener" aria-label="Instagram">ig</a>
                </div>
            </footer>
        </main>
    </body>
</html>


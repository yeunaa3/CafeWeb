<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Quên mật khẩu - Cafe & Bubble tea</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/customer.css?v=20260709-orderflow1">
    </head>
    <body class="auth-simple-page">
        <div class="auth-frame-title">Forgot Password</div>
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
                    <h1>Quên mật khẩu</h1>

                    <c:if test="${not empty error}">
                        <p class="alert error-alert">
                            <c:out value="${error}"/>
                        </p>
                    </c:if>
                    <c:if test="${not empty message}">
                        <p class="alert success-alert">
                            <c:out value="${message}"/>
                        </p>
                    </c:if>

                    <form class="auth-simple-form" action="${pageContext.request.contextPath}/forgot-password" method="post">
                        <label for="forgotEmail">Địa chỉ email</label>
                        <input id="forgotEmail" type="email" name="email" value="<c:out value='${email}'/>"
                               placeholder="email@example.com" autocomplete="email" required autofocus>

                        <div class="auth-help-links" style="display: flex; flex-direction: column; gap: 8px; margin-top: 12px; font-size: 14px; color: #333;">
                            <div>Quay lại trang <a href="${pageContext.request.contextPath}/login" style="color: #0056b3; text-decoration: underline;">Đăng nhập</a>
                            </div>
                        </div>

                        <button class="auth-simple-submit" type="submit" style="margin-top: 24px;">Gửi yêu cầu</button>
                    </form>
                </div>
            </section>

            <footer class="site-footer auth-simple-footer">
                <strong>Cafe & Bubble tea</strong>
                <div class="social-row">
                    <span>f</span>
                    <span>in</span>
                    <span>yt</span>
                    <span>ig</span>
                </div>
            </footer>
        </main>
    </body>
</html>

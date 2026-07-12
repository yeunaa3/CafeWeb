<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Đăng ký - Cafe & Bubble tea</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/customer.css?v=20260709-orderflow1">
    </head>
    <body class="auth-simple-page">
        <div class="auth-frame-title">SignUp</div>
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

            <section class="auth-simple-content register-simple-content">
                <div class="auth-simple-form-wrap">
                    <h1>Đăng Kí</h1>

                    <c:if test="${not empty error}">
                        <p class="alert error-alert">
                            <c:out value="${error}"/>
                        </p>
                    </c:if>

                    <form class="auth-simple-form" action="${pageContext.request.contextPath}/register" method="post">
                        <label for="fullName">Họ và Tên</label>
                        <input id="fullName" name="fullName" value="<c:out value='${fullName}'/>"
                               placeholder="Nguyễn Văn A" autocomplete="name" required>

                        <label for="username">Tên đăng nhập</label>
                        <input id="username" name="username" value="<c:out value='${username}'/>"
                               placeholder="Nhập tên của bạn" autocomplete="username" required>

                        <label for="email">Địa chỉ email</label>
                        <input id="email" type="email" name="email" value="<c:out value='${email}'/>"
                               placeholder="email@example.com" autocomplete="email" required>

                        <label for="phone">Số điện thoại</label>
                        <input id="phone" type="tel" name="phone" value="<c:out value='${phone}'/>"
                               placeholder="Nhập số điện thoại của bạn" autocomplete="tel" pattern="0[0-9]{9,10}">

                        <label for="registerPassword">Mật khẩu</label>
                        <input id="registerPassword" type="password" name="password" minlength="6"
                               placeholder="Nhập mật khẩu của bạn" autocomplete="new-password" required>

                        <button class="auth-simple-submit" type="submit">Đăng Kí</button>
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


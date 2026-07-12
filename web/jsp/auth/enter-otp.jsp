<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Xác thực OTP - Cafe & Bubble tea</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/customer.css?v=20260709-orderflow1">
    </head>
    <body class="auth-simple-page">
        <div class="auth-frame-title">Verify OTP</div>
        <main class="auth-simple-shell">
            <header class="site-header auth-site-header">
                <a class="brand" href="${pageContext.request.contextPath}/home">Cafe & Bubble tea</a>
            </header>

            <section class="auth-simple-content" style="margin-top: 40px;">
                <div class="auth-simple-form-wrap">
                    <h1>Xác thực mã OTP</h1>

                    <c:if test="${not empty message}">
                        <p class="alert success-alert" style="color: green; background: #e6f4ea; padding: 10px; border-radius: 4px;">
                            <c:out value="${message}"/>
                        </p>
                    </c:if>
                    <c:if test="${not empty error}">
                        <p class="alert error-alert" style="color: red; background: #fce8e6; padding: 10px; border-radius: 4px;">
                            <c:out value="${error}"/>
                        </p>
                    </c:if>

                    <form class="auth-simple-form" action="${pageContext.request.contextPath}/verify-otp" method="post">
                        <label for="otpInput">Nhập mã OTP (6 số) đã gửi đến email của bạn</label>
                        <input id="otpInput" type="text" name="otp_input" placeholder="******" 
                               required autofocus maxlength="6" pattern="\d{6}" 
                               style="letter-spacing: 5px; text-align: center; font-size: 18px; padding: 10px;">

                        <button class="auth-simple-submit" type="submit" style="margin-top: 24px;">Xác nhận</button>
                    </form>
                </div>
            </section>
        </main>
    </body>
</html>

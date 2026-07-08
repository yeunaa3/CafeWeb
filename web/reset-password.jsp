<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Đặt lại mật khẩu - Cafe & Bubble tea</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer.css?v=20260708-ui7">
    </head>
    <body class="auth-simple-page">
        <div class="auth-frame-title">Reset Password</div>
        <main class="auth-simple-shell">
            <section class="auth-simple-content" style="margin-top: 40px;">
                <div class="auth-simple-form-wrap">
                    <h1>Đặt lại mật khẩu</h1>

                    <c:if test="${not empty error}">
                        <p class="alert error-alert" style="color: red; background: #fce8e6; padding: 10px; border-radius: 4px;">
<c:out value="${error}"/>
</p>
                    </c:if>

                    <form class="auth-simple-form" action="${pageContext.request.contextPath}/verify-otp" method="post">
                        <input type="hidden" name="action" value="resetPassword">

                        <label for="newPassword">Mật khẩu mới</label>
                        <input id="newPassword" type="password" name="new_password" required autofocus style="padding: 10px; font-size: 16px;">

                        <label for="confirmPassword" style="margin-top: 12px;">Xác nhận mật khẩu mới</label>
                        <input id="confirmPassword" type="password" name="confirm_password" required style="padding: 10px; font-size: 16px;">

                        <button class="auth-simple-submit" type="submit" style="margin-top: 24px;">Cập nhật mật khẩu</button>
                    </form>
                </div>
            </section>
        </main>
    </body>
</html>
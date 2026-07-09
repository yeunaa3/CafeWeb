<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width,initial-scale=1">
        <title>Tài khoản của tôi - CBMS</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/manager.css?v=20260708-ui7">
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
                    <section class="account-panel">
                        <div class="account-summary">
                            <form class="avatar-upload-form" method="post" action="${pageContext.request.contextPath}/avatar/upload" enctype="multipart/form-data">
                                <label class="account-avatar-picker" title="Đổi ảnh đại diện">
                                    <c:choose>
                                        <c:when test="${not empty manager.avatarUrl}">
                                            <img src="${pageContext.request.contextPath}/${manager.avatarUrl}" alt="Ảnh đại diện">
                                        </c:when>
                                        <c:otherwise>${fn:substring(manager.fullName,0,1)}</c:otherwise>
                                    </c:choose>
                                    <span>Đổi ảnh</span>
                                    <input type="file" name="avatar" accept="image/png,image/jpeg,image/webp" onchange="this.form.submit()">
                                </label>
                            </form>
                            <div>
                                <strong>
                                    <c:out value="${manager.fullName}"/>
                                </strong>
                                <small>
                                    <c:out value="${manager.email}"/>
                                </small>
                                <em>Manager</em>
                            </div>
                            <c:if test="${!editing}">
                                <a class="primary-action" href="${pageContext.request.contextPath}/manager/account?mode=edit">Chỉnh sửa</a>
                            </c:if>
                        </div>
                        <form method="post" action="${pageContext.request.contextPath}/manager/account" class="account-form">
                            <div class="form-grid">
                                <label>Họ và tên *<input name="fullName" value="<c:out value='${manager.fullName}'/>" ${editing ? '' : 'readonly'} required>
                                </label>
                                <label>Số điện thoại<input name="phone" value="<c:out value='${manager.phone}'/>" ${editing ? '' : 'readonly'} pattern="0[0-9]{9,10}">
                                </label>
                                <label>Giới tính<select name="gender" ${editing ? '' : 'disabled'}>
                                        <option value="">Chưa cập nhật</option>
                                        <option ${manager.gender == 'Nam' ? 'selected' : ''}>Nam</option>
                                        <option ${manager.gender == 'Nữ' ? 'selected' : ''}>Nữ</option>
                                        <option ${manager.gender == 'Khác' ? 'selected' : ''}>Khác</option>
                                    </select>
                                </label>
                                <label>Địa chỉ<input name="address" value="<c:out value='${manager.address}'/>" ${editing ? '' : 'readonly'}>
                                </label>
                                <label>Username *<input name="username" value="<c:out value='${manager.username}'/>" ${editing ? '' : 'readonly'} pattern="[A-Za-z0-9_]{4,50}" required>
                                </label>
                                <label>Email *<input type="email" name="email" value="<c:out value='${manager.email}'/>" ${editing ? '' : 'readonly'} required>
                                </label>
                            </div>
                            <c:if test="${editing}">
                                <div class="account-actions">
                                    <a class="secondary-action" href="${pageContext.request.contextPath}/manager/account">Hủy</a>
                                    <button class="primary-action" type="submit">Lưu thay đổi</button>
                                </div>
                            </c:if>
                        </form>
                    </section>
                </main>
            </div>
        </div>
        <script src="${pageContext.request.contextPath}/assets/js/manager.js?v=20260708-ui7">
        </script>
    </body>
</html>

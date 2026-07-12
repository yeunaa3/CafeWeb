<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width,initial-scale=1">
        <title>Kết quả thanh toán - CBMS</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/manager.css?v=20260709-orderflow1">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/cashier.css?v=20260709-orderflow1">
    </head>
    <body class="payment-result-page">
        <main class="payment-result-card ${paymentSuccess?'success':'failed'}">
            <div class="result-symbol">
                <c:choose>
                    <c:when test="${paymentSuccess}">&#10003;</c:when>
                    <c:otherwise>×</c:otherwise>
                </c:choose>
            </div>
            <h1>${paymentSuccess?'Thanh toán thành công':'Thanh toán không thành công'}</h1>
            <p>
                <c:out value="${paymentMessage}"/>
            </p>
            <c:if test="${paymentSuccess}">
                <div class="result-receipt">
                    <span>Đơn #${orderId}</span>
                    <strong>
                        <fmt:formatNumber value="${paymentTotal}" pattern="#,##0"/>đ</strong>
                    <small>Tiền thừa: <fmt:formatNumber value="${changeAmount}" pattern="#,##0"/>đ</small>
                </div>
            </c:if>
            <a href="${pageContext.request.contextPath}/cashier/order">Quay về POS</a>
        </main>
    </body>
</html>


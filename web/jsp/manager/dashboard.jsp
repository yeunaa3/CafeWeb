<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html><html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Dashboard - CBMS</title><link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/manager.css"></head>
<body class="manager-page"><div class="manager-shell"><%@include file="includes/sidebar.jspf"%><div class="manager-main"><%@include file="includes/header.jspf"%><main class="manager-content">
    <section class="metric-grid">
        <article><span>Nhân viên</span><strong>${staffCount}</strong><small>Tài khoản nhân sự</small></article>
        <article><span>Mã giảm giá</span><strong>${voucherCount}</strong><small>Voucher trong hệ thống</small></article>
        <article><span>Đơn hôm nay</span><strong>--</strong><small>Sẽ hoàn thiện ở Task đơn hàng</small></article>
        <article><span>Doanh thu</span><strong>--</strong><small>Sẽ hoàn thiện ở Task báo cáo</small></article>
    </section>
    <section class="manager-band"><div><span>Tổng quan vận hành</span><h2>Khu vực quản trị Cafe &amp; Bubble tea</h2><p>Nhân viên và mã giảm giá đã có chức năng đầy đủ. Những phân hệ còn lại được giữ sẵn trong thanh điều hướng để nhóm tiếp tục ghép code.</p></div></section>
</main></div></div><script src="${pageContext.request.contextPath}/assets/js/manager.js"></script></body></html>

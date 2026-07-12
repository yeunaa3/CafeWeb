package controller.manager;

import dao.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.text.DecimalFormat;
import java.text.Normalizer;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;
import model.DashboardSummary;
import model.ManagerOrderSummary;
import model.ProductSalesStat;
import model.RevenueStat;

@WebServlet(name = "ManagerDashboardController", urlPatterns = {"/manager", "/manager/dashboard"})
public class ManagerDashboardController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (ManagerPageSupport.requireManager(request, response) == null) return;
        int days = "7".equals(request.getParameter("days")) ? 7 : 30;
        DashboardSummary dashboard = new OrderDAO().getDashboardSummary(days);
        String export = request.getParameter("export");
        if ("excel".equalsIgnoreCase(export)) {
            exportExcel(response, dashboard, days);
            return;
        }
        if ("pdf".equalsIgnoreCase(export)) {
            exportPdf(response, dashboard, days);
            return;
        }
        ManagerPageSupport.prepare(request, "dashboard", "Dashboard");
        request.setAttribute("days", days);
        request.setAttribute("dashboard", dashboard);
        request.getRequestDispatcher("/jsp/manager/dashboard.jsp").forward(request, response);
    }

    private void exportExcel(HttpServletResponse response, DashboardSummary dashboard, int days)
            throws IOException {
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/vnd.ms-excel; charset=UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=cbms-dashboard-" + days + "-days.xls");
        response.getWriter().write("\uFEFF");
        response.getWriter().println("<html><head><meta charset='UTF-8'></head><body>");
        response.getWriter().println("<h2>CBMS Dashboard - " + days + " ngay gan nhat</h2>");
        response.getWriter().println("<table border='1'>");
        response.getWriter().println("<tr><th>Chi so</th><th>Gia tri</th></tr>");
        response.getWriter().println("<tr><td>Tong do uong dang ban</td><td>" + dashboard.getActiveProductCount() + "</td></tr>");
        response.getWriter().println("<tr><td>Don hom nay</td><td>" + dashboard.getTodayOrderCount() + "</td></tr>");
        response.getWriter().println("<tr><td>Doanh thu hom nay</td><td>" + money(dashboard.getTodayRevenue()) + "</td></tr>");
        response.getWriter().println("<tr><td>Tong doanh thu</td><td>" + money(dashboard.getTotalRevenue()) + "</td></tr>");
        response.getWriter().println("<tr><td>Khach hang hoat dong</td><td>" + dashboard.getCustomerCount() + "</td></tr>");
        response.getWriter().println("</table>");

        response.getWriter().println("<h3>Doanh thu theo ngay</h3><table border='1'><tr><th>Ngay</th><th>So don</th><th>Doanh thu</th></tr>");
        SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");
        for (RevenueStat stat : dashboard.getRevenueStats()) {
            response.getWriter().println("<tr><td>" + dateFormat.format(stat.getRevenueDate()) + "</td><td>"
                    + stat.getOrderCount() + "</td><td>" + money(stat.getRevenue()) + "</td></tr>");
        }
        response.getWriter().println("</table>");

        response.getWriter().println("<h3>Top san pham</h3><table border='1'><tr><th>San pham</th><th>So luong</th><th>Doanh thu</th></tr>");
        for (ProductSalesStat product : dashboard.getTopProducts()) {
            response.getWriter().println("<tr><td>" + html(product.getProductName()) + "</td><td>"
                    + product.getQuantitySold() + "</td><td>" + money(product.getRevenue()) + "</td></tr>");
        }
        response.getWriter().println("</table>");

        response.getWriter().println("<h3>Don hang gan day</h3><table border='1'><tr><th>Ma don</th><th>Khach hang</th><th>Thoi gian</th><th>Tong tien</th><th>Trang thai</th></tr>");
        SimpleDateFormat timeFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");
        for (ManagerOrderSummary order : dashboard.getRecentOrders()) {
            response.getWriter().println("<tr><td>#" + order.getOrderId() + "</td><td>" + html(order.getCustomerName())
                    + "</td><td>" + timeFormat.format(order.getOrderDate()) + "</td><td>"
                    + money(order.getTotalPrice()) + "</td><td>" + html(order.getDisplayStatus()) + "</td></tr>");
        }
        response.getWriter().println("</table></body></html>");
    }

    private void exportPdf(HttpServletResponse response, DashboardSummary dashboard, int days)
            throws IOException {
        List<String> lines = new ArrayList<String>();
        lines.add("CBMS Dashboard Report - " + days + " days");
        lines.add("Active products: " + dashboard.getActiveProductCount());
        lines.add("Today orders: " + dashboard.getTodayOrderCount());
        lines.add("Today revenue: " + money(dashboard.getTodayRevenue()));
        lines.add("Total revenue: " + money(dashboard.getTotalRevenue()));
        lines.add("Active customers: " + dashboard.getCustomerCount());
        lines.add("");
        lines.add("Top products");
        for (ProductSalesStat product : dashboard.getTopProducts()) {
            lines.add("- " + ascii(product.getProductName()) + ": " + product.getQuantitySold()
                    + " items, " + money(product.getRevenue()));
        }
        lines.add("");
        lines.add("Recent orders");
        SimpleDateFormat timeFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");
        for (ManagerOrderSummary order : dashboard.getRecentOrders()) {
            lines.add("#" + order.getOrderId() + " | " + ascii(order.getCustomerName()) + " | "
                    + timeFormat.format(order.getOrderDate()) + " | " + money(order.getTotalPrice())
                    + " | " + ascii(order.getDisplayStatus()));
        }
        byte[] pdf = simplePdf(lines).getBytes(StandardCharsets.ISO_8859_1);
        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "attachment; filename=cbms-dashboard-" + days + "-days.pdf");
        response.setContentLength(pdf.length);
        response.getOutputStream().write(pdf);
    }

    private String simplePdf(List<String> lines) {
        StringBuilder content = new StringBuilder();
        content.append("BT\n/F1 12 Tf\n50 790 Td\n14 TL\n");
        int maxLines = Math.min(lines.size(), 48);
        for (int i = 0; i < maxLines; i++) {
            content.append("(").append(pdf(lines.get(i), 96)).append(") Tj\n");
            if (i < maxLines - 1) {
                content.append("T*\n");
            }
        }
        content.append("ET");

        List<String> objects = new ArrayList<String>();
        objects.add("1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n");
        objects.add("2 0 obj\n<< /Type /Pages /Kids [3 0 R] /Count 1 >>\nendobj\n");
        objects.add("3 0 obj\n<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Resources << /Font << /F1 4 0 R >> >> /Contents 5 0 R >>\nendobj\n");
        objects.add("4 0 obj\n<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>\nendobj\n");
        objects.add("5 0 obj\n<< /Length " + content.length() + " >>\nstream\n" + content + "\nendstream\nendobj\n");

        StringBuilder pdf = new StringBuilder("%PDF-1.4\n");
        List<Integer> offsets = new ArrayList<Integer>();
        for (String object : objects) {
            offsets.add(pdf.toString().getBytes(StandardCharsets.ISO_8859_1).length);
            pdf.append(object);
        }
        int xrefOffset = pdf.toString().getBytes(StandardCharsets.ISO_8859_1).length;
        pdf.append("xref\n0 6\n0000000000 65535 f \n");
        for (Integer offset : offsets) {
            pdf.append(String.format("%010d 00000 n \n", offset));
        }
        pdf.append("trailer\n<< /Size 6 /Root 1 0 R >>\nstartxref\n")
                .append(xrefOffset).append("\n%%EOF");
        return pdf.toString();
    }

    private String money(double value) {
        return new DecimalFormat("#,##0").format(value) + " VND";
    }

    private String html(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
                .replace("\"", "&quot;");
    }
    private String ascii(String value) {
        if (value == null) return "";
        return Normalizer.normalize(value, Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "")
                .replace('\u0111', 'd')
                .replace('\u0110', 'D');
    }
    private String pdf(String value, int maxLength) {
        String text = ascii(value);
        if (text.length() > maxLength) {
            text = text.substring(0, maxLength - 3) + "...";
        }
        return text.replace("\\", "\\\\").replace("(", "\\(").replace(")", "\\)");
    }
}

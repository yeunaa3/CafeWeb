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

    private static final DecimalFormat MONEY_FORMAT = new DecimalFormat("#,##0");
    private static final SimpleDateFormat DATE_FORMAT = new SimpleDateFormat("dd/MM/yyyy");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (ManagerPageSupport.requireManager(request, response) == null) {
            return;
        }
        int days = "7".equals(request.getParameter("days")) ? 7 : 30;
        OrderDAO orderDAO = new OrderDAO();

        String export = request.getParameter("export");
        if ("excel".equalsIgnoreCase(export)) {
            exportExcel(response, orderDAO.getDashboardSummary(7), orderDAO.getDashboardSummary(30));
            return;
        }
        if ("pdf".equalsIgnoreCase(export)) {
            exportPdf(response, orderDAO.getDashboardSummary(7), orderDAO.getDashboardSummary(30));
            return;
        }

        DashboardSummary dashboard = orderDAO.getDashboardSummary(days);
        request.setAttribute("dashboard", dashboard);
        request.setAttribute("days", days);
        request.setAttribute("activePage", "dashboard");
        request.getRequestDispatcher("/jsp/manager/dashboard.jsp").forward(request, response);
    }

    private void exportExcel(HttpServletResponse response, DashboardSummary sevenDays, DashboardSummary thirtyDays)
            throws IOException {
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/vnd.ms-excel; charset=UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=cbms-dashboard-7-and-30-days.xls");
        response.getWriter().write('\uFEFF');
        response.getWriter().println("<html><head><meta charset='UTF-8'></head><body>");
        response.getWriter().println("<h1>CBMS Dashboard Report</h1>");
        writeExcelSection(response, sevenDays, 7);
        response.getWriter().println("<br><br>");
        writeExcelSection(response, thirtyDays, 30);
        response.getWriter().println("</body></html>");
    }

    private void writeExcelSection(HttpServletResponse response, DashboardSummary dashboard, int days)
            throws IOException {
        response.getWriter().println("<h2>Report " + days + " days</h2>");
        response.getWriter().println("<table border='1'>");
        response.getWriter().println("<tr><th>Metric</th><th>Value</th></tr>");
        response.getWriter().println("<tr><td>Available products</td><td>" + dashboard.getActiveProductCount() + "</td></tr>");
        response.getWriter().println("<tr><td>Orders today</td><td>" + dashboard.getTodayOrderCount() + "</td></tr>");
        response.getWriter().println("<tr><td>Revenue today</td><td>" + money(dashboard.getTodayRevenue()) + "</td></tr>");
        response.getWriter().println("<tr><td>Revenue in selected range</td><td>" + money(dashboard.getTotalRevenue()) + "</td></tr>");
        response.getWriter().println("<tr><td>Active customers</td><td>" + dashboard.getCustomerCount() + "</td></tr>");
        response.getWriter().println("</table>");

        response.getWriter().println("<h3>Revenue by day</h3>");
        response.getWriter().println("<table border='1'><tr><th>Date</th><th>Orders</th><th>Revenue</th></tr>");
        for (RevenueStat stat : dashboard.getRevenueStats()) {
            response.getWriter().println("<tr><td>" + DATE_FORMAT.format(stat.getRevenueDate()) + "</td><td>"
                    + stat.getOrderCount() + "</td><td>" + money(stat.getRevenue()) + "</td></tr>");
        }
        response.getWriter().println("</table>");

        response.getWriter().println("<h3>Top products</h3>");
        response.getWriter().println("<table border='1'><tr><th>Product</th><th>Quantity</th><th>Revenue</th></tr>");
        for (ProductSalesStat product : dashboard.getTopProducts()) {
            response.getWriter().println("<tr><td>" + html(product.getProductName()) + "</td><td>"
                    + product.getQuantitySold() + "</td><td>" + money(product.getRevenue()) + "</td></tr>");
        }
        response.getWriter().println("</table>");

        response.getWriter().println("<h3>Recent orders in range</h3>");
        response.getWriter().println("<table border='1'><tr><th>ID</th><th>Customer</th><th>Date</th><th>Total</th><th>Status</th></tr>");
        for (ManagerOrderSummary order : dashboard.getRecentOrders()) {
            response.getWriter().println("<tr><td>#" + order.getOrderId() + "</td><td>" + html(order.getCustomerName())
                    + "</td><td>" + DATE_FORMAT.format(order.getOrderDate()) + "</td><td>"
                    + money(order.getTotalPrice()) + "</td><td>" + html(order.getStatus()) + "</td></tr>");
        }
        response.getWriter().println("</table>");
    }

    private void exportPdf(HttpServletResponse response, DashboardSummary sevenDays, DashboardSummary thirtyDays)
            throws IOException {
        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "attachment; filename=cbms-dashboard-7-and-30-days.pdf");
        List<String> lines = new ArrayList<String>();
        lines.add("CBMS Dashboard Report");
        lines.add("");
        appendPdfSection(lines, sevenDays, 7);
        lines.add("---PAGE---");
        appendPdfSection(lines, thirtyDays, 30);
        byte[] pdf = simplePdf(lines).getBytes(StandardCharsets.ISO_8859_1);
        response.setContentLength(pdf.length);
        response.getOutputStream().write(pdf);
    }

    private void appendPdfSection(List<String> lines, DashboardSummary dashboard, int days) {
        lines.add("REPORT " + days + " DAYS");
        lines.add("Available products: " + dashboard.getActiveProductCount());
        lines.add("Orders today: " + dashboard.getTodayOrderCount());
        lines.add("Revenue today: " + money(dashboard.getTodayRevenue()));
        lines.add("Revenue in selected range: " + money(dashboard.getTotalRevenue()));
        lines.add("Active customers: " + dashboard.getCustomerCount());
        lines.add("");
        lines.add("Revenue by day:");
        for (RevenueStat stat : dashboard.getRevenueStats()) {
            lines.add(DATE_FORMAT.format(stat.getRevenueDate()) + " | " + stat.getOrderCount()
                    + " orders | " + money(stat.getRevenue()));
        }
        lines.add("");
        lines.add("Top products:");
        for (ProductSalesStat product : dashboard.getTopProducts()) {
            lines.add(product.getProductName() + " | " + product.getQuantitySold()
                    + " sold | " + money(product.getRevenue()));
        }
        lines.add("");
        lines.add("Recent orders in range:");
        for (ManagerOrderSummary order : dashboard.getRecentOrders()) {
            lines.add("#" + order.getOrderId() + " | " + order.getCustomerName() + " | "
                    + DATE_FORMAT.format(order.getOrderDate()) + " | " + money(order.getTotalPrice())
                    + " | " + order.getStatus());
        }
    }

    private String simplePdf(List<String> lines) {
        List<List<String>> pages = new ArrayList<List<String>>();
        List<String> page = new ArrayList<String>();
        for (String line : lines) {
            if ("---PAGE---".equals(line)) {
                pages.add(page);
                page = new ArrayList<String>();
                continue;
            }
            page.add(line);
            if (page.size() >= 42) {
                pages.add(page);
                page = new ArrayList<String>();
            }
        }
        if (!page.isEmpty() || pages.isEmpty()) {
            pages.add(page);
        }

        StringBuilder objects = new StringBuilder();
        List<Integer> offsets = new ArrayList<Integer>();
        StringBuilder pdf = new StringBuilder();
        pdf.append("%PDF-1.4\n");
        int objectCount = 2 + pages.size() * 2;

        appendObject(objects, offsets, "1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n");
        StringBuilder kids = new StringBuilder();
        for (int i = 0; i < pages.size(); i++) {
            kids.append(3 + i * 2).append(" 0 R ");
        }
        appendObject(objects, offsets, "2 0 obj\n<< /Type /Pages /Kids [" + kids + "] /Count " + pages.size() + " >>\nendobj\n");

        for (int i = 0; i < pages.size(); i++) {
            int pageObject = 3 + i * 2;
            int contentObject = pageObject + 1;
            appendObject(objects, offsets, pageObject + " 0 obj\n<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] "
                    + "/Resources << /Font << /F1 << /Type /Font /Subtype /Type1 /BaseFont /Helvetica >> >> >> "
                    + "/Contents " + contentObject + " 0 R >>\nendobj\n");

            StringBuilder content = new StringBuilder();
            content.append("BT /F1 12 Tf 50 790 Td 16 TL\n");
            for (String line : pages.get(i)) {
                content.append("(").append(pdf(ascii(line))).append(") Tj T*\n");
            }
            content.append("ET");
            appendObject(objects, offsets, contentObject + " 0 obj\n<< /Length " + content.length()
                    + " >>\nstream\n" + content + "\nendstream\nendobj\n");
        }

        int base = pdf.length();
        pdf.append(objects);
        int xref = pdf.length();
        pdf.append("xref\n0 ").append(objectCount + 1).append("\n");
        pdf.append("0000000000 65535 f \n");
        for (Integer offset : offsets) {
            pdf.append(String.format("%010d 00000 n \n", base + offset));
        }
        pdf.append("trailer\n<< /Size ").append(objectCount + 1).append(" /Root 1 0 R >>\n");
        pdf.append("startxref\n").append(xref).append("\n%%EOF");
        return pdf.toString();
    }

    private void appendObject(StringBuilder objects, List<Integer> offsets, String object) {
        offsets.add(objects.length());
        objects.append(object);
    }

    private String money(double value) {
        return MONEY_FORMAT.format(value) + "d";
    }

    private String html(String value) {
        if (value == null) {
            return "";
        }
        return value.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;");
    }

    private String ascii(String value) {
        if (value == null) {
            return "";
        }
        String normalized = Normalizer.normalize(value, Normalizer.Form.NFD).replaceAll("\\p{M}", "");
        return normalized.replace('đ', 'd').replace('Đ', 'D').replaceAll("[^\\x20-\\x7E]", "?");
    }

    private String pdf(String text) {
        return text.replace("\\", "\\\\").replace("(", "\\(").replace(")", "\\)");
    }
}
package controller.cashier;

import dao.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import model.ManagerOrderSummary;

@WebServlet(name = "CashierInvoiceController", urlPatterns = {"/cashier/invoices"})
public class CashierInvoiceController extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (CashierPageSupport.requireCashier(request, response) == null) return;
        CashierPageSupport.prepare(request, "invoices", "Hóa đơn tại quầy");
        OrderDAO orderDAO = new OrderDAO();
        List<ManagerOrderSummary> invoices = new ArrayList<ManagerOrderSummary>();
        for (ManagerOrderSummary order : orderDAO.getManagerOrders(request.getParameter("q"), "", 100)) {
            if ("At-Counter".equals(order.getOrderType())
                    && ("Completed".equals(order.getStatus()) || "Refunded".equals(order.getStatus()))) {
                invoices.add(order);
            }
        }
        request.setAttribute("invoiceList", invoices);
        int detailId = parseId(request.getParameter("detail"));
        if (detailId > 0) request.setAttribute("selectedOrder", orderDAO.getManagerOrderById(detailId));
        request.getRequestDispatcher("/jsp/cashier/invoices.jsp").forward(request, response);
    }
    private int parseId(String value) { try { return Integer.parseInt(value); } catch (Exception ex) { return -1; } }
}

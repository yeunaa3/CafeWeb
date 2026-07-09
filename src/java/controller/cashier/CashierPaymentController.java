package controller.cashier;

import dal.OrderDAO;
import dal.VoucherDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import model.CartItem;
import model.User;
import model.VoucherValidationResult;

@WebServlet(name = "CashierPaymentController", urlPatterns = {"/cashier/payment"})
public class CashierPaymentController extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        User cashier = CashierPageSupport.requireCashier(request, response);
        if (cashier == null) return;
        CashierPageSupport.prepare(request, "order", "Thanh toán");
        List<CartItem> cart = CashierOrderController.getCart(request);
        double originalTotal = CashierOrderController.getTotal(cart);
        String voucherCode = value(request.getParameter("voucherCode"));
        String method = "QR-Code".equals(request.getParameter("paymentMethod")) ? "QR-Code" : "Cash";
        VoucherValidationResult voucher = new VoucherDAO().validateVoucher(voucherCode, originalTotal, null);
        if (cart.isEmpty()) {
            showResult(request, response, false, "Đơn hàng đang trống.", 0, 0, -1);
            return;
        }
        if (!voucher.isValid()) {
            showResult(request, response, false, voucher.getMessage(), 0, 0, -1);
            return;
        }
        double total = originalTotal - voucher.getDiscountAmount();
        double received = "Cash".equals(method) ? parseDouble(request.getParameter("amountReceived")) : total;
        if ("Cash".equals(method) && received < total) {
            showResult(request, response, false, "Tiền khách đưa chưa đủ.", total, 0, -1);
            return;
        }
        try {
            Integer voucherId = voucher.getVoucher() == null ? null : voucher.getVoucher().getVoucherId();
            int orderId = new OrderDAO().createCounterOrder(cashier.getUserId(), cart, method,
                    voucherId, voucher.getDiscountAmount(), received);
            request.getSession().removeAttribute(CashierOrderController.CART_KEY);
            showResult(request, response, true, "Thanh toán thành công.", total,
                    Math.max(0, received - total), orderId);
        } catch (SQLException ex) {
            ex.printStackTrace();
            showResult(request, response, false, "Không thể lưu thanh toán. Vui lòng thử lại.", total, 0, -1);
        }
    }

    private void showResult(HttpServletRequest request, HttpServletResponse response, boolean success,
            String message, double total, double change, int orderId) throws ServletException, IOException {
        request.setAttribute("paymentSuccess", success);
        request.setAttribute("paymentMessage", message);
        request.setAttribute("paymentTotal", total);
        request.setAttribute("changeAmount", change);
        request.setAttribute("orderId", orderId);
        request.getRequestDispatcher("/jsp/cashier/payment-result.jsp").forward(request, response);
    }
    private String value(String value) { return value == null ? "" : value.trim(); }
    private double parseDouble(String value) { try { return Double.parseDouble(value); } catch (Exception ex) { return -1; } }
}

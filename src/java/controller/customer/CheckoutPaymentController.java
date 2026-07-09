package controller.customer;

import dal.OrderDAO;
import dal.VoucherDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import model.CartItem;
import model.User;
import model.VoucherValidationResult;

@WebServlet(name = "CheckoutPaymentController", urlPatterns = {"/checkout/payment"})
public class CheckoutPaymentController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        preparePayment(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        Integer userId = getCurrentUserId(request);
        if (session == null || userId == null) {
            response.sendRedirect(request.getContextPath() + "/login?returnUrl=/checkout");
            return;
        }
        List<CartItem> cart = CartController.getCart(request);
        String shippingAddress = value(session.getAttribute("checkoutShippingAddress"));
        String phone = value(session.getAttribute("checkoutPhone"));
        String note = value(session.getAttribute("checkoutNote"));
        String voucherCode = value(session.getAttribute("checkoutVoucherCode"));

        if (cart.isEmpty() || shippingAddress.isEmpty() || phone.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/checkout");
            return;
        }

        double cartTotal = CartController.getCartTotal(request);
        VoucherValidationResult voucher = new VoucherDAO().validateVoucher(voucherCode, cartTotal, userId);
        if (!voucher.isValid()) {
            request.setAttribute("error", voucher.getMessage());
            preparePaymentAttributes(request, shippingAddress, phone, note, voucherCode, cartTotal, 0);
            request.getRequestDispatcher("/jsp/customer/checkout-payment.jsp").forward(request, response);
            return;
        }

        try {
            Integer voucherId = voucher.getVoucher() == null ? null : voucher.getVoucher().getVoucherId();
            int orderId = new OrderDAO().createOnlineOrder(userId, cart, shippingAddress, phone, note,
                    voucherId, voucher.getDiscountAmount());
            session.removeAttribute(CartController.CART_SESSION_KEY);
            clearPendingCheckout(session);
            response.sendRedirect(request.getContextPath() + "/checkout?successOrderId=" + orderId);
        } catch (SQLException ex) {
            request.setAttribute("error", "Không thể xác nhận thanh toán. Vui lòng thử lại.");
            preparePaymentAttributes(request, shippingAddress, phone, note, voucherCode, cartTotal,
                    voucher.getDiscountAmount());
            request.getRequestDispatcher("/jsp/customer/checkout-payment.jsp").forward(request, response);
        }
    }

    private void preparePayment(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("checkoutShippingAddress") == null) {
            response.sendRedirect(request.getContextPath() + "/checkout");
            return;
        }
        double cartTotal = CartController.getCartTotal(request);
        String voucherCode = value(session.getAttribute("checkoutVoucherCode"));
        Integer userId = getCurrentUserId(request);
        VoucherValidationResult voucher = new VoucherDAO().validateVoucher(voucherCode, cartTotal, userId);
        preparePaymentAttributes(request, value(session.getAttribute("checkoutShippingAddress")),
                value(session.getAttribute("checkoutPhone")), value(session.getAttribute("checkoutNote")),
                voucherCode, cartTotal, voucher.isValid() ? voucher.getDiscountAmount() : 0);
        request.getRequestDispatcher("/jsp/customer/checkout-payment.jsp").forward(request, response);
    }

    private void preparePaymentAttributes(HttpServletRequest request, String shippingAddress, String phone,
            String note, String voucherCode, double cartTotal, double discount) {
        request.setAttribute("cart", CartController.getCart(request));
        request.setAttribute("cartCount", CartController.getCartCount(request));
        request.setAttribute("shippingAddress", shippingAddress);
        request.setAttribute("phone", phone);
        request.setAttribute("note", note);
        request.setAttribute("voucherCode", voucherCode);
        request.setAttribute("cartTotal", cartTotal);
        request.setAttribute("appliedDiscount", Math.max(0, discount));
        request.setAttribute("payableTotal", Math.max(0, cartTotal - Math.max(0, discount)));
    }

    private Integer getCurrentUserId(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return null;
        Object user = session.getAttribute("user");
        if (user instanceof User) return ((User) user).getUserId();
        Object userId = session.getAttribute("userId");
        return userId instanceof Integer ? (Integer) userId : null;
    }

    private void clearPendingCheckout(HttpSession session) {
        session.removeAttribute("checkoutShippingAddress");
        session.removeAttribute("checkoutPhone");
        session.removeAttribute("checkoutNote");
        session.removeAttribute("checkoutVoucherCode");
    }

    private String value(Object value) {
        return value == null ? "" : String.valueOf(value).trim();
    }
}

package controller.cashier;

import dal.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import model.CartItem;
import model.HeldOrder;
import model.Product;

@WebServlet(name = "CashierOrderController", urlPatterns = {"/cashier/order"})
public class CashierOrderController extends HttpServlet {
    public static final String CART_KEY = "cashierCart";
    public static final String HOLD_KEY = "cashierHeldOrders";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (CashierPageSupport.requireCashier(request, response) == null) return;
        prepare(request);
        request.getRequestDispatcher("/jsp/cashier/order.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        if (CashierPageSupport.requireCashier(request, response) == null) return;
        String action = value(request.getParameter("action"));
        List<CartItem> cart = getCart(request);
        if ("remove".equals(action)) {
            String key = value(request.getParameter("cartKey"));
            cart.removeIf(item -> item.getCartKey().equals(key));
        } else if ("update".equals(action)) {
            updateItem(request, cart);
        } else if ("clear".equals(action)) {
            cart.clear();
        } else if ("hold".equals(action) && !cart.isEmpty()) {
            getHeldOrders(request).add(0, new HeldOrder(cart));
            request.getSession().setAttribute(CART_KEY, new ArrayList<CartItem>());
            request.getSession().setAttribute("cashierSuccess", "Đã giữ đơn. Có thể gọi lại từ danh sách đơn chờ.");
        } else if ("recall".equals(action)) {
            recall(request, value(request.getParameter("holdId")));
        }
        response.sendRedirect(request.getContextPath() + "/cashier/order");
    }

    private void prepare(HttpServletRequest request) {
        CashierPageSupport.prepare(request, "order", "Đặt hàng tại quầy");
        request.setAttribute("cart", getCart(request));
        request.setAttribute("cartTotal", getTotal(getCart(request)));
        request.setAttribute("heldOrders", getHeldOrders(request));
    }

    private void updateItem(HttpServletRequest request, List<CartItem> cart) {
        String key = value(request.getParameter("cartKey"));
        for (CartItem item : cart) {
            if (!item.getCartKey().equals(key)) continue;
            item.setQuantity(Math.max(1, parseInt(request.getParameter("quantity"), 1)));
            item.setSelectedSize(valueOr(request.getParameter("selectedSize"), "M"));
            item.setNote(emptyToNull(request.getParameter("note")));
            Product product = new ProductDAO().getProductById(item.getProductId());
            if (product != null) item.setDrinkPrice(product.getPrice() + sizeExtra(item.getSelectedSize()));
            return;
        }
    }

    private void recall(HttpServletRequest request, String holdId) {
        List<HeldOrder> heldOrders = getHeldOrders(request);
        for (int index = 0; index < heldOrders.size(); index++) {
            HeldOrder held = heldOrders.get(index);
            if (held.getHoldId().equals(holdId)) {
                request.getSession().setAttribute(CART_KEY, held.getItems());
                heldOrders.remove(index);
                return;
            }
        }
    }

    @SuppressWarnings("unchecked")
    public static List<CartItem> getCart(HttpServletRequest request) {
        HttpSession session = request.getSession();
        Object value = session.getAttribute(CART_KEY);
        if (value instanceof List) return (List<CartItem>) value;
        List<CartItem> cart = new ArrayList<CartItem>();
        session.setAttribute(CART_KEY, cart);
        return cart;
    }

    @SuppressWarnings("unchecked")
    public static List<HeldOrder> getHeldOrders(HttpServletRequest request) {
        HttpSession session = request.getSession();
        Object value = session.getAttribute(HOLD_KEY);
        if (value instanceof List) return (List<HeldOrder>) value;
        List<HeldOrder> orders = new ArrayList<HeldOrder>();
        session.setAttribute(HOLD_KEY, orders);
        return orders;
    }

    public static double getTotal(List<CartItem> cart) {
        double total = 0;
        for (CartItem item : cart) total += item.getLineTotal();
        return total;
    }

    public static double sizeExtra(String size) {
        if ("L".equalsIgnoreCase(size)) return 5000;
        if ("S".equalsIgnoreCase(size)) return -3000;
        return 0;
    }

    private int parseInt(String value, int fallback) {
        try { return Integer.parseInt(value); } catch (NumberFormatException ex) { return fallback; }
    }
    private String value(String value) { return value == null ? "" : value.trim(); }
    private String valueOr(String value, String fallback) { String result=value(value); return result.isEmpty()?fallback:result; }
    private String emptyToNull(String value) { String result=value(value); return result.isEmpty()?null:result; }
}

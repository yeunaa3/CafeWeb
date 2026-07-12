package controller.cashier;

import dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import model.CartItem;
import model.Product;

@WebServlet(name = "CashierAddOrderController", urlPatterns = {"/cashier/order/add"})
public class CashierAddOrderController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (CashierPageSupport.requireCashier(request, response) == null) return;
        ProductDAO productDAO = new ProductDAO();
        CashierPageSupport.prepare(request, "order", "Thêm món");
        request.setAttribute("productList", productDAO.getAdminProducts(request.getParameter("q")));
        request.setAttribute("toppingList", productDAO.getActiveToppings());
        request.getRequestDispatcher("/jsp/cashier/add-order.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        if (CashierPageSupport.requireCashier(request, response) == null) return;
        ProductDAO productDAO = new ProductDAO();
        List<CartItem> cart = CashierOrderController.getCart(request);
        int added = 0;
        for (Product product : productDAO.getAdminProducts("")) {
            if (!product.isStatus()) continue;
            int quantity = parseInt(request.getParameter("quantity_" + product.getProductId()));
            if (quantity < 1) continue;
            CartItem item = new CartItem();
            item.setProductId(product.getProductId());
            item.setProductName(product.getProductName());
            item.setImageUrl(product.getImageUrl());
            item.setQuantity(quantity);
            String size = valueOr(request.getParameter("size_" + product.getProductId()), "M");
            item.setSelectedSize(size);
            item.setIceLevel("100%");
            item.setSugarLevel("100%");
            item.setDrinkPrice(product.getPrice() + CashierOrderController.sizeExtra(size));
            item.setNote(emptyToNull(request.getParameter("note_" + product.getProductId())));
            String toppingId = request.getParameter("topping_" + product.getProductId());
            if (toppingId != null && !toppingId.isEmpty()) {
                item.setToppings(productDAO.getToppingsByIds(new String[]{toppingId}));
            }
            merge(cart, item);
            added += quantity;
        }
        request.getSession().setAttribute(added > 0 ? "cashierSuccess" : "cashierError",
                added > 0 ? "Đã thêm " + added + " món vào đơn." : "Vui lòng chọn ít nhất một món.");
        response.sendRedirect(request.getContextPath() + (added > 0 ? "/cashier/order" : "/cashier/order/add"));
    }

    private void merge(List<CartItem> cart, CartItem incoming) {
        for (CartItem item : cart) {
            if (item.hasSameOptions(incoming)) {
                item.setQuantity(item.getQuantity() + incoming.getQuantity());
                return;
            }
        }
        cart.add(incoming);
    }
    private int parseInt(String value) { try { return Integer.parseInt(value); } catch (Exception ex) { return 0; } }
    private String value(String value) { return value == null ? "" : value.trim(); }
    private String valueOr(String value, String fallback) { String result=value(value); return result.isEmpty()?fallback:result; }
    private String emptyToNull(String value) { String result=value(value); return result.isEmpty()?null:result; }
}

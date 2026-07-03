package controller.customer;

import dal.ProductDAO;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.CartItem;
import model.Product;
import model.Topping;

@WebServlet(name = "CartController", urlPatterns = {"/cart"})
public class CartController extends HttpServlet {

    public static final String CART_SESSION_KEY = "customerCart";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        if ("add".equals(action)) {
            addToCart(request);
        } else if ("update".equals(action)) {
            updateQuantity(request);
        } else if ("remove".equals(action)) {
            removeItem(request);
        } else if ("clear".equals(action)) {
            request.getSession().removeAttribute(CART_SESSION_KEY);
        }

        if ("true".equals(request.getParameter("ajax"))) {
            writeCartJson(request, response);
            return;
        }
        response.sendRedirect(request.getContextPath() + "/menu");
    }

    @SuppressWarnings("unchecked")
    public static List<CartItem> getCart(HttpServletRequest request) {
        HttpSession session = request.getSession();
        Object value = session.getAttribute(CART_SESSION_KEY);
        if (value instanceof List) {
            return (List<CartItem>) value;
        }
        List<CartItem> cart = new ArrayList<CartItem>();
        session.setAttribute(CART_SESSION_KEY, cart);
        return cart;
    }

    public static int getCartCount(HttpServletRequest request) {
        int count = 0;
        for (CartItem item : getCart(request)) {
            count += item.getQuantity();
        }
        return count;
    }

    public static double getCartTotal(HttpServletRequest request) {
        double total = 0;
        for (CartItem item : getCart(request)) {
            total += item.getLineTotal();
        }
        return total;
    }

    private void addToCart(HttpServletRequest request) {
        int productId = parseInt(request.getParameter("productId"), -1);
        int quantity = parseInt(request.getParameter("quantity"), 1);
        ProductDAO productDAO = new ProductDAO();
        Product product = productDAO.getProductById(productId);
        if (product == null) {
            return;
        }

        CartItem newItem = new CartItem();
        newItem.setProductId(product.getProductId());
        newItem.setProductName(product.getProductName());
        newItem.setImageUrl(product.getImageUrl());
        newItem.setQuantity(quantity < 1 ? 1 : quantity);
        newItem.setSelectedSize(defaultValue(request.getParameter("selectedSize"), "M"));
        newItem.setIceLevel(defaultValue(request.getParameter("iceLevel"), "100%"));
        newItem.setSugarLevel(defaultValue(request.getParameter("sugarLevel"), "100%"));
        newItem.setDrinkPrice(product.getPrice() + getSizeExtra(newItem.getSelectedSize()));
        newItem.setToppings(productDAO.getToppingsByIds(request.getParameterValues("toppingIds")));

        List<CartItem> cart = getCart(request);
        for (CartItem item : cart) {
            if (item.hasSameOptions(newItem)) {
                item.setQuantity(item.getQuantity() + newItem.getQuantity());
                return;
            }
        }
        cart.add(newItem);
    }

    private void updateQuantity(HttpServletRequest request) {
        String cartKey = request.getParameter("cartKey");
        int quantity = parseInt(request.getParameter("quantity"), 1);
        for (CartItem item : getCart(request)) {
            if (item.getCartKey().equals(cartKey)) {
                item.setQuantity(quantity < 1 ? 1 : quantity);
                return;
            }
        }
    }

    private void removeItem(HttpServletRequest request) {
        String cartKey = request.getParameter("cartKey");
        List<CartItem> cart = getCart(request);
        for (int i = 0; i < cart.size(); i++) {
            if (cart.get(i).getCartKey().equals(cartKey)) {
                cart.remove(i);
                return;
            }
        }
    }

    private double getSizeExtra(String size) {
        if ("L".equalsIgnoreCase(size)) {
            return 5000;
        }
        if ("S".equalsIgnoreCase(size)) {
            return -3000;
        }
        return 0;
    }

    private void writeCartJson(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write("{\"success\":true,\"count\":" + getCartCount(request)
                + ",\"total\":" + getCartTotal(request) + "}");
    }

    private int parseInt(String value, int defaultValue) {
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException ex) {
            return defaultValue;
        }
    }

    private String defaultValue(String value, String defaultValue) {
        if (value == null || value.trim().isEmpty()) {
            return defaultValue;
        }
        return value.trim();
    }
}

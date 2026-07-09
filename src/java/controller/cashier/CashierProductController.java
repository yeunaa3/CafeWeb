package controller.cashier;

import dal.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "CashierProductController", urlPatterns = {"/cashier/products"})
public class CashierProductController extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (CashierPageSupport.requireCashier(request, response) == null) return;
        CashierPageSupport.prepare(request, "products", "Sản phẩm");
        request.setAttribute("productList", new ProductDAO().getAdminProducts(request.getParameter("q")));
        request.getRequestDispatcher("/jsp/cashier/products.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (CashierPageSupport.requireCashier(request, response) == null) return;
        int id = parseId(request.getParameter("id"));
        boolean success = new ProductDAO().setProductStatus(id,
                Boolean.parseBoolean(request.getParameter("active")));
        request.getSession().setAttribute(success ? "cashierSuccess" : "cashierError",
                success ? "Đã cập nhật tình trạng món." : "Không thể cập nhật sản phẩm.");
        response.sendRedirect(request.getContextPath() + "/cashier/products");
    }
    private int parseId(String value) { try { return Integer.parseInt(value); } catch (Exception ex) { return -1; } }
}

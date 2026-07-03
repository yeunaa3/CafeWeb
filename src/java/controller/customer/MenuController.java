package controller.customer;

import dal.ProductDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "MenuController", urlPatterns = {"/menu"})
public class MenuController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String keyword = request.getParameter("keyword");
        ProductDAO productDAO = new ProductDAO();
        request.setAttribute("sections", productDAO.getMenuSections(keyword));
        request.setAttribute("toppings", productDAO.getActiveToppings());
        request.setAttribute("keyword", keyword == null ? "" : keyword);
        request.setAttribute("cartCount", CartController.getCartCount(request));
        request.getRequestDispatcher("/jsp/customer/menu.jsp").forward(request, response);
    }
}

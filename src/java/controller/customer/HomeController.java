package controller.customer;

import dao.ProductDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "HomeController", urlPatterns = {"/home", "/landing"})
public class HomeController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        ProductDAO productDAO = new ProductDAO();
        request.setAttribute("recommendedProducts", productDAO.getRecommendedProducts(3));
        request.setAttribute("cartCount", CartController.getCartCount(request));
        request.getRequestDispatcher("/jsp/customer/landing.jsp").forward(request, response);
    }
}

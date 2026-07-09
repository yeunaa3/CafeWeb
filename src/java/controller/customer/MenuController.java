package controller.customer;

import dal.ProductDAO;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.MenuSection;

@WebServlet(name = "MenuController", urlPatterns = {"/menu"})
public class MenuController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String keyword = request.getParameter("keyword");
        ProductDAO productDAO = new ProductDAO();
        List<MenuSection> sections = productDAO.getMenuSections(keyword);
        boolean hasProducts = false;
        for (MenuSection section : sections) {
            if (section.getProducts() != null && !section.getProducts().isEmpty()) {
                hasProducts = true;
                break;
            }
        }
        request.setAttribute("sections", sections);
        request.setAttribute("hasProducts", hasProducts);
        request.setAttribute("toppings", productDAO.getActiveToppings());
        request.setAttribute("keyword", keyword == null ? "" : keyword);
        request.setAttribute("cartCount", CartController.getCartCount(request));
        request.getRequestDispatcher("/jsp/customer/menu.jsp").forward(request, response);
    }
}

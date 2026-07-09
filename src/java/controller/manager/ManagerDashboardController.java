package controller.manager;

import dal.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "ManagerDashboardController", urlPatterns = {"/manager", "/manager/dashboard"})
public class ManagerDashboardController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (ManagerPageSupport.requireManager(request, response) == null) return;
        ManagerPageSupport.prepare(request, "dashboard", "Dashboard");
        int days = "7".equals(request.getParameter("days")) ? 7 : 30;
        request.setAttribute("days", days);
        request.setAttribute("dashboard", new OrderDAO().getDashboardSummary(days));
        request.getRequestDispatcher("/jsp/manager/dashboard.jsp").forward(request, response);
    }
}

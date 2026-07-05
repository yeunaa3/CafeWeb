package controller.manager;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet(name = "ManagerPlaceholderController", urlPatterns = {
    "/manager/orders", "/manager/invoices", "/manager/products",
    "/manager/reports", "/manager/admins"
})
public class ManagerPlaceholderController extends HttpServlet {

    private static final Map<String, String> TITLES = new HashMap<String, String>();
    static {
        TITLES.put("orders", "Quản lý đơn hàng");
        TITLES.put("invoices", "Hóa đơn");
        TITLES.put("products", "Sản phẩm");
        TITLES.put("reports", "Báo cáo");
        TITLES.put("admins", "Quản trị viên");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (ManagerPageSupport.requireManager(request, response) == null) return;
        String path = request.getServletPath();
        String key = path.substring(path.lastIndexOf('/') + 1);
        String title = TITLES.get(key);
        ManagerPageSupport.prepare(request, key, title == null ? "Quản lý" : title);
        request.getRequestDispatcher("/jsp/manager/placeholder.jsp").forward(request, response);
    }
}

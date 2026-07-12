package controller.manager;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import model.User;

@WebServlet(name = "ManagerProfileController", urlPatterns = {"/manager/account"})
public class ManagerProfileController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User manager = ManagerPageSupport.requireManager(request, response);
        if (manager == null) return;
        ManagerPageSupport.prepare(request, "account", "Tài khoản của tôi");
        request.setAttribute("editing", "edit".equals(request.getParameter("mode")));
        request.getRequestDispatcher("/jsp/manager/account.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        User manager = ManagerPageSupport.requireManager(request, response);
        if (manager == null) return;
        String username = trim(request.getParameter("username"));
        String fullName = trim(request.getParameter("fullName"));
        String email = trim(request.getParameter("email"));
        String phone = trim(request.getParameter("phone"));
        String address = trim(request.getParameter("address"));
        String gender = trim(request.getParameter("gender"));

        String error = validate(username, fullName, email, phone, gender);
        UserDAO userDAO = new UserDAO();
        if (error == null && userDAO.isUsernameOrEmailTakenByOther(manager.getUserId(), username, email)) {
            error = "Username hoặc email đã được sử dụng.";
        }
        if (error == null) {
            manager.setUsername(username);
            manager.setFullName(fullName);
            manager.setEmail(email);
            manager.setPhone(phone);
            manager.setAddress(address);
            manager.setGender(gender.isEmpty() ? null : gender);
            if (userDAO.updateProfile(manager)) {
                request.getSession().setAttribute("user", manager);
                request.getSession().setAttribute("managerSuccess", "Đã cập nhật thông tin tài khoản.");
                response.sendRedirect(request.getContextPath() + "/manager/account");
                return;
            }
            error = "Không thể cập nhật tài khoản.";
        }
        ManagerPageSupport.prepare(request, "account", "Tài khoản của tôi");
        request.setAttribute("editing", true);
        request.setAttribute("error", error);
        request.getRequestDispatcher("/jsp/manager/account.jsp").forward(request, response);
    }

    private String validate(String username, String fullName, String email, String phone, String gender) {
        if (username.isEmpty() || fullName.isEmpty() || email.isEmpty()) return "Vui lòng nhập đầy đủ trường bắt buộc.";
        if (!username.matches("[A-Za-z0-9_]{4,50}")) return "Username không hợp lệ.";
        if (!email.matches("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$")) return "Email không hợp lệ.";
        if (!phone.isEmpty() && !phone.matches("0[0-9]{9,10}")) return "Số điện thoại không hợp lệ.";
        if (!gender.isEmpty() && !gender.matches("Nam|Nữ|Khác")) return "Giới tính không hợp lệ.";
        return null;
    }
    private String trim(String value) { return value == null ? "" : value.trim(); }
}

package controller.customer;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import model.User;

@WebServlet(name = "RegisterController", urlPatterns = {"/register"})
public class RegisterController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/jsp/auth/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String fullName = trim(request.getParameter("fullName"));
        String username = trim(request.getParameter("username"));
        String email = trim(request.getParameter("email"));
        String phone = trim(request.getParameter("phone"));
        String password = request.getParameter("password");

        preserveForm(request, fullName, username, email, phone);
        String error = validate(fullName, username, email, phone, password);
        UserDAO userDAO = new UserDAO();
        if (error == null && userDAO.isUsernameOrEmailTaken(username, email)) {
            error = "Tên đăng nhập hoặc email đã được sử dụng.";
        }
        if (error != null) {
            request.setAttribute("error", error);
            request.getRequestDispatcher("/jsp/auth/register.jsp").forward(request, response);
            return;
        }

        User user = new User();
        user.setFullName(fullName);
        user.setUsername(username);
        user.setEmail(email);
        user.setPhone(phone);
        user.setAddress("");
        user.setPassword(password);
        if (!userDAO.createCustomer(user)) {
            request.setAttribute("error", "Không thể tạo tài khoản. Vui lòng thử lại.");
            request.getRequestDispatcher("/jsp/auth/register.jsp").forward(request, response);
            return;
        }
        response.sendRedirect(request.getContextPath() + "/login?registered=true");
    }

    private String validate(String fullName, String username, String email, String phone, String password) {
        if (fullName.isEmpty() || username.isEmpty() || email.isEmpty() || password == null || password.isEmpty()) {
            return "Vui lòng nhập đầy đủ các trường bắt buộc.";
        }
        if (!username.matches("[A-Za-z0-9_]{4,50}")) {
            return "Tên đăng nhập cần 4-50 ký tự, chỉ gồm chữ, số và dấu gạch dưới.";
        }
        if (!email.matches("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$")) {
            return "Email không hợp lệ.";
        }
        if (!phone.isEmpty() && !phone.matches("0[0-9]{9,10}")) {
            return "Số điện thoại không hợp lệ.";
        }
        if (password.length() < 6) {
            return "Mật khẩu phải có ít nhất 6 ký tự.";
        }
        return null;
    }

    private void preserveForm(HttpServletRequest request, String fullName, String username,
            String email, String phone) {
        request.setAttribute("fullName", fullName);
        request.setAttribute("username", username);
        request.setAttribute("email", email);
        request.setAttribute("phone", phone);
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }
}

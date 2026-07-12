package controller.cashier;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import model.User;

@WebServlet(name = "CashierProfileController", urlPatterns = {"/cashier/account"})
public class CashierProfileController extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (CashierPageSupport.requireCashier(request, response) == null) return;
        CashierPageSupport.prepare(request, "account", "Tài khoản thu ngân");
        request.setAttribute("editing", "edit".equals(request.getParameter("mode")));
        request.getRequestDispatcher("/jsp/cashier/account.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        User cashier = CashierPageSupport.requireCashier(request, response);
        if (cashier == null) return;
        String username=value(request.getParameter("username")), fullName=value(request.getParameter("fullName"));
        String email=value(request.getParameter("email")), phone=value(request.getParameter("phone"));
        String address=value(request.getParameter("address")), gender=value(request.getParameter("gender"));
        String error = validate(username, fullName, email, phone, gender);
        UserDAO userDAO = new UserDAO();
        if (error == null && userDAO.isUsernameOrEmailTakenByOther(cashier.getUserId(), username, email)) {
            error = "Username hoặc email đã được sử dụng.";
        }
        if (error == null) {
            cashier.setUsername(username); cashier.setFullName(fullName); cashier.setEmail(email);
            cashier.setPhone(phone); cashier.setAddress(address); cashier.setGender(gender.isEmpty()?null:gender);
            if (userDAO.updateProfile(cashier)) {
                request.getSession().setAttribute("user", cashier);
                request.getSession().setAttribute("cashierSuccess", "Đã cập nhật tài khoản.");
                response.sendRedirect(request.getContextPath()+"/cashier/account");
                return;
            }
            error = "Không thể cập nhật tài khoản.";
        }
        CashierPageSupport.prepare(request, "account", "Tài khoản thu ngân");
        request.setAttribute("editing", true); request.setAttribute("error", error);
        request.getRequestDispatcher("/jsp/cashier/account.jsp").forward(request,response);
    }

    private String validate(String username,String fullName,String email,String phone,String gender) {
        if(username.isEmpty()||fullName.isEmpty()||email.isEmpty()) return "Vui lòng nhập đầy đủ trường bắt buộc.";
        if(!username.matches("[A-Za-z0-9_]{4,50}")) return "Username không hợp lệ.";
        if(!email.matches("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$")) return "Email không hợp lệ.";
        if(!phone.isEmpty()&&!phone.matches("0[0-9]{9,10}")) return "Số điện thoại không hợp lệ.";
        if(!gender.isEmpty()&&!gender.matches("Nam|Nữ|Khác")) return "Giới tính không hợp lệ.";
        return null;
    }
    private String value(String value) { return value==null?"":value.trim(); }
}

package controller.customer;

import dal.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import model.User;

@WebServlet(name = "ProfileController", urlPatterns = {"/profile"})
public class ProfileController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User customer = CustomerPageSupport.resolveCustomer(request);
        if (customer == null) {
            response.sendRedirect(request.getContextPath() + "/login?returnUrl=/profile");
            return;
        }
        CustomerPageSupport.prepareCommonData(request, customer);
        request.setAttribute("editMode", "edit".equals(request.getParameter("mode")));
        request.getRequestDispatcher("/jsp/customer/profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        User customer = CustomerPageSupport.resolveCustomer(request);
        if (customer == null) {
            response.sendRedirect(request.getContextPath() + "/login?returnUrl=/profile");
            return;
        }
        String fullName = trim(request.getParameter("fullName"));
        String email = trim(request.getParameter("email"));
        String phone = trim(request.getParameter("phone"));
        String address = trim(request.getParameter("address"));

        if (fullName.isEmpty() || email.isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập họ tên và email.");
        } else if (!email.matches("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$")) {
            request.setAttribute("error", "Email không hợp lệ.");
        } else if (!phone.isEmpty() && !phone.matches("0[0-9]{9,10}")) {
            request.setAttribute("error", "Số điện thoại không hợp lệ.");
        } else {
            customer.setFullName(fullName);
            customer.setEmail(email);
            customer.setPhone(phone);
            customer.setAddress(address);
            if (new UserDAO().updateProfile(customer)) {
                request.getSession().setAttribute("user", customer);
                request.setAttribute("success", "Đã cập nhật thông tin cá nhân.");
            } else {
                request.setAttribute("error", "Không thể cập nhật thông tin. Email có thể đã được sử dụng.");
            }
        }

        CustomerPageSupport.prepareCommonData(request, customer);
        request.setAttribute("editMode", request.getAttribute("error") != null);
        request.getRequestDispatcher("/jsp/customer/profile.jsp").forward(request, response);
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }
}

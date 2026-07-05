package controller.manager;

import dal.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import model.User;

@WebServlet(name = "ManagerEmployeeController", urlPatterns = {"/manager/employees"})
public class ManagerEmployeeController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (ManagerPageSupport.requireManager(request, response) == null) return;
        String action = trim(request.getParameter("action"));
        if ("new".equals(action)) {
            request.setAttribute("formMode", "create");
        } else if ("edit".equals(action)) {
            User staff = new UserDAO().getUserById(parseId(request.getParameter("id")));
            if (staff != null && staff.getRoleId() == 2) {
                request.setAttribute("editingStaff", staff);
                request.setAttribute("formMode", "edit");
            }
        }
        render(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        if (ManagerPageSupport.requireManager(request, response) == null) return;
        UserDAO userDAO = new UserDAO();
        String action = trim(request.getParameter("action"));

        if ("toggle".equals(action)) {
            boolean success = userDAO.setStaffStatus(parseId(request.getParameter("id")),
                    Boolean.parseBoolean(request.getParameter("active")));
            redirectResult(request, response, success, "Đã cập nhật trạng thái nhân viên.");
            return;
        }

        boolean editing = "update".equals(action);
        User staff = editing ? userDAO.getUserById(parseId(request.getParameter("id"))) : new User();
        if (staff == null || (editing && staff.getRoleId() != 2)) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String fullName = trim(request.getParameter("fullName"));
        String phone = trim(request.getParameter("phone"));
        String email = trim(request.getParameter("email"));
        String position = trim(request.getParameter("staffPosition"));
        String username = trim(request.getParameter("username"));
        String password = request.getParameter("password");
        password = password == null ? "" : password;

        staff.setFullName(fullName);
        staff.setPhone(phone);
        staff.setEmail(email);
        staff.setStaffPosition(position);
        staff.setUsername(username);
        staff.setPassword(password);
        staff.setRoleId(2);

        String error = validate(staff, editing);
        if (error == null) {
            boolean taken = editing
                    ? userDAO.isUsernameOrEmailTakenByOther(staff.getUserId(), username, email)
                    : userDAO.isUsernameOrEmailTaken(username, email);
            if (taken) error = "Username hoặc email đã được sử dụng.";
        }
        if (error == null) {
            boolean success = editing
                    ? userDAO.updateStaff(staff, !password.isEmpty())
                    : userDAO.createStaff(staff);
            if (success) {
                redirectResult(request, response, true, editing ? "Đã sửa nhân viên." : "Đã thêm nhân viên.");
                return;
            }
            error = "Không thể lưu nhân viên. Vui lòng thử lại.";
        }

        request.setAttribute("error", error);
        request.setAttribute("editingStaff", staff);
        request.setAttribute("formMode", editing ? "edit" : "create");
        render(request, response);
    }

    private void render(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        ManagerPageSupport.prepare(request, "employees", "Nhân viên");
        request.setAttribute("staffList", new UserDAO().getStaff(request.getParameter("q")));
        request.getRequestDispatcher("/jsp/manager/employees.jsp").forward(request, response);
    }

    private String validate(User staff, boolean editing) {
        if (staff.getFullName().isEmpty() || staff.getEmail().isEmpty()
                || staff.getUsername().isEmpty() || staff.getStaffPosition().isEmpty()) {
            return "Vui lòng nhập đầy đủ các trường bắt buộc.";
        }
        if (!staff.getUsername().matches("[A-Za-z0-9_]{4,50}")) return "Username không hợp lệ.";
        if (!staff.getEmail().matches("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$")) return "Email không hợp lệ.";
        if (!staff.getPhone().isEmpty() && !staff.getPhone().matches("0[0-9]{9,10}")) return "Số điện thoại không hợp lệ.";
        if (!editing && staff.getPassword().length() < 6) return "Mật khẩu phải có ít nhất 6 ký tự.";
        if (editing && !staff.getPassword().isEmpty() && staff.getPassword().length() < 6) return "Mật khẩu mới phải có ít nhất 6 ký tự.";
        return null;
    }

    private void redirectResult(HttpServletRequest request, HttpServletResponse response,
            boolean success, String message) throws IOException {
        request.getSession().setAttribute(success ? "managerSuccess" : "managerError",
                success ? message : "Không thể cập nhật dữ liệu.");
        response.sendRedirect(request.getContextPath() + "/manager/employees");
    }

    private int parseId(String value) {
        try { return Integer.parseInt(value); } catch (NumberFormatException ex) { return -1; }
    }

    private String trim(String value) { return value == null ? "" : value.trim(); }
}

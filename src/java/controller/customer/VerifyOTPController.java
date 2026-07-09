package controller.customer;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "VerifyOTPController", urlPatterns = {"/verify-otp"})
public class VerifyOTPController extends HttpServlet {

    private static final String DB_URL = "jdbc:sqlserver://localhost:1433;databaseName=CBMS;encrypt=false;trustServerCertificate=true";
    private static final String DB_USER = "sa"; 
    private static final String DB_PASS = "123456"; 

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/enter-otp.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        String action = request.getParameter("action");

        // XỬ LÝ BƯỚC 2: Người dùng nhấn nút đổi mật khẩu mới từ file reset-password.jsp
        if (action != null && action.equals("resetPassword")) {
            String newPassword = request.getParameter("new_password");
            String confirmPassword = request.getParameter("confirm_password");
            String email = (String) session.getAttribute("email");

            if (email == null) {
                request.setAttribute("error", "Phiên làm việc hết hạn. Vui lòng thử lại từ đầu!");
                request.getRequestDispatcher("/forgot-password.jsp").forward(request, response);
                return;
            }

            if (newPassword == null || !newPassword.equals(confirmPassword)) {
                request.setAttribute("error", "Mật khẩu xác nhận không trùng khớp!");
                request.getRequestDispatcher("/reset-password.jsp").forward(request, response);
                return;
            }

            Connection conn = null;
            PreparedStatement ps = null;
            try {
                Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
                conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
                
                String updateSql = "UPDATE dbo.Users SET password = ? WHERE LOWER(email) = LOWER(?)";
                ps = conn.prepareStatement(updateSql);
                ps.setString(1, newPassword); // Nếu hệ thống dùng mã hóa MD5/Bcrypt thì xử lý ở đây
                ps.setString(2, email.trim());
                
                int rows = ps.executeUpdate();
                if (rows > 0) {
                    // Xóa thông tin OTP và Email trong session sau khi đổi thành công
                    session.removeAttribute("otp");
                    session.removeAttribute("email");
                    
                    request.setAttribute("message", "Đổi mật khẩu thành công! Vui lòng đăng nhập lại.");
                    request.getRequestDispatcher("/login").forward(request, response); 
                    // Hoặc đổi thành đường dẫn trang đăng nhập của bạn (ví dụ: /login.jsp)
                    return;
                }
            } catch (Exception e) {
                request.setAttribute("error", "Lỗi cập nhật mật khẩu: " + e.getMessage());
                request.getRequestDispatcher("/reset-password.jsp").forward(request, response);
                return;
            } finally {
                try { if (ps != null) ps.close(); } catch (Exception e) {}
                try { if (conn != null) conn.close(); } catch (Exception e) {}
            }
        }

        // XỬ LÝ BƯỚC 1: Kiểm tra mã OTP gửi từ trang enter-otp.jsp
        String otpInput = request.getParameter("otp_input");
        Integer otpSystem = (Integer) session.getAttribute("otp");
        String email = (String) session.getAttribute("email");

        if (otpSystem == null || email == null) {
            request.setAttribute("error", "Phiên làm việc đã hết hạn hoặc không hợp lệ. Vui lòng thử lại!");
            request.getRequestDispatcher("/forgot-password.jsp").forward(request, response);
            return;
        }

        try {
            int inputValues = Integer.parseInt(otpInput.trim());

            if (inputValues == otpSystem) {
                // ĐÚNG OTP -> Chuyển tiếp sang giao diện nhập mật khẩu mới reset-password.jsp
                request.getRequestDispatcher("/reset-password.jsp").forward(request, response);
            } else {
                request.setAttribute("error", "Mã OTP không chính xác. Vui lòng kiểm tra lại!");
                request.getRequestDispatcher("/enter-otp.jsp").forward(request, response);
            }
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Mã OTP phải là chuỗi gồm 6 chữ số!");
            request.getRequestDispatcher("/enter-otp.jsp").forward(request, response);
        }
    }
}

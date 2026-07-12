package controller.customer;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "VerifyOTPController", urlPatterns = {"/verify-otp"})
public class VerifyOTPController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/jsp/auth/enter-otp.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        String action = request.getParameter("action");

        if ("resetPassword".equals(action)) {
            resetPassword(request, response, session);
            return;
        }

        verifyOtp(request, response, session);
    }

    private void verifyOtp(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {
        String otpInput = request.getParameter("otp_input");
        Integer otpSystem = (Integer) session.getAttribute(ForgotPasswordController.OTP_SESSION_KEY);
        String email = (String) session.getAttribute(ForgotPasswordController.OTP_EMAIL_SESSION_KEY);

        if (otpSystem == null || email == null) {
            expireOtp(session);
            request.setAttribute("error", "Phiên làm việc đã hết hạn hoặc không hợp lệ. Vui lòng thử lại!");
            request.getRequestDispatcher("/jsp/auth/forgot-password.jsp").forward(request, response);
            return;
        }

        if (isOtpExpired(session)) {
            expireOtp(session);
            request.setAttribute("error", "Mã OTP đã hết hạn sau 5 phút. Vui lòng yêu cầu mã mới!");
            request.getRequestDispatcher("/jsp/auth/forgot-password.jsp").forward(request, response);
            return;
        }

        try {
            int inputValue = Integer.parseInt(otpInput == null ? "" : otpInput.trim());
            if (inputValue == otpSystem) {
                session.setAttribute("otpVerified", Boolean.TRUE);
                request.getRequestDispatcher("/jsp/auth/reset-password.jsp").forward(request, response);
            } else {
                request.setAttribute("error", "Mã OTP không chính xác. Vui lòng kiểm tra lại!");
                request.getRequestDispatcher("/jsp/auth/enter-otp.jsp").forward(request, response);
            }
        } catch (NumberFormatException ex) {
            request.setAttribute("error", "Mã OTP phải là chuỗi gồm 6 chữ số!");
            request.getRequestDispatcher("/jsp/auth/enter-otp.jsp").forward(request, response);
        }
    }

    private void resetPassword(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {
        String newPassword = request.getParameter("new_password");
        String confirmPassword = request.getParameter("confirm_password");
        String email = (String) session.getAttribute(ForgotPasswordController.OTP_EMAIL_SESSION_KEY);
        Boolean verified = (Boolean) session.getAttribute("otpVerified");

        if (email == null || !Boolean.TRUE.equals(verified) || isOtpExpired(session)) {
            expireOtp(session);
            request.setAttribute("error", "Phiên đặt lại mật khẩu đã hết hạn. Vui lòng thử lại từ đầu!");
            request.getRequestDispatcher("/jsp/auth/forgot-password.jsp").forward(request, response);
            return;
        }

        if (newPassword == null || !newPassword.equals(confirmPassword)) {
            request.setAttribute("error", "Mật khẩu xác nhận không trùng khớp!");
            request.getRequestDispatcher("/jsp/auth/reset-password.jsp").forward(request, response);
            return;
        }

        if (new UserDAO().resetPasswordByEmail(email, newPassword)) {
            expireOtp(session);
            request.setAttribute("message", "Đổi mật khẩu thành công! Vui lòng đăng nhập lại.");
            request.getRequestDispatcher("/login").forward(request, response);
        } else {
            request.setAttribute("error", "Không thể cập nhật mật khẩu. Vui lòng thử lại!");
            request.getRequestDispatcher("/jsp/auth/reset-password.jsp").forward(request, response);
        }
    }

    private boolean isOtpExpired(HttpSession session) {
        Object createdAt = session.getAttribute(ForgotPasswordController.OTP_CREATED_AT_SESSION_KEY);
        if (!(createdAt instanceof Long)) {
            return true;
        }
        return System.currentTimeMillis() - ((Long) createdAt) > ForgotPasswordController.OTP_TTL_MILLIS;
    }

    private void expireOtp(HttpSession session) {
        session.removeAttribute(ForgotPasswordController.OTP_SESSION_KEY);
        session.removeAttribute(ForgotPasswordController.OTP_EMAIL_SESSION_KEY);
        session.removeAttribute(ForgotPasswordController.OTP_CREATED_AT_SESSION_KEY);
        session.removeAttribute("otpVerified");
    }
}

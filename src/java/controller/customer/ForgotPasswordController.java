package controller.customer;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Properties;
import java.util.Random;
import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "ForgotPasswordController", urlPatterns = {"/forgot-password"})
public class ForgotPasswordController extends HttpServlet {

    private static final String DB_URL = "jdbc:sqlserver://localhost:1433;databaseName=CBMS;encrypt=false;trustServerCertificate=true";
    private static final String DB_USER = "sa"; 
    private static final String DB_PASS = "123456"; 

    private static final String FROM_EMAIL = "Ngocdai0411@gmail.com"; 
    private static final String APP_PASSWORD = "tsxfczhgsgiqgaxb"; // Đã xóa toàn bộ khoảng trắng

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/forgot-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");
        
        String email = request.getParameter("email");
        
        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập địa chỉ email!");
            request.getRequestDispatcher("/forgot-password.jsp").forward(request, response);
            return;
        }

        Connection conn = null;
        PreparedStatement checkStmt = null;
        ResultSet rs = null;

        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

            // Dùng LOWER để tránh lỗi phân biệt chữ hoa / chữ thường từ giao diện nhập vào
            String checkSql = "SELECT user_id FROM dbo.Users WHERE LOWER(email) = LOWER(?) AND status = 1";
            checkStmt = conn.prepareStatement(checkSql);
            checkStmt.setString(1, email.trim());
            rs = checkStmt.executeQuery();

            if (rs.next()) {
                Random rand = new Random();
                int otpValue = 100000 + rand.nextInt(900000);
                
                HttpSession mySession = request.getSession();
                mySession.setAttribute("otp", otpValue);
                mySession.setAttribute("email", email);

                Properties props = new Properties();
                props.put("mail.smtp.host", "smtp.gmail.com");
                props.put("mail.smtp.port", "587");
                props.put("mail.smtp.auth", "true");
                props.put("mail.smtp.starttls.enable", "true");

                Session session = Session.getInstance(props, new Authenticator() {
                    @Override
                    protected PasswordAuthentication getPasswordAuthentication() {
                        return new PasswordAuthentication(FROM_EMAIL, APP_PASSWORD);
                    }
                });

                MimeMessage message = new MimeMessage(session);
                message.setFrom(new InternetAddress(FROM_EMAIL));
                message.addRecipient(Message.RecipientType.TO, new InternetAddress(email.trim()));
                message.setSubject("CBMS - Mã xác thực đặt lại mật khẩu", "UTF-8");
                message.setText("Mã xác thực (OTP) của bạn là: " + otpValue + "\nMã này có hiệu lực trong vòng 5 phút.", "UTF-8");

                Transport.send(message);

                request.setAttribute("message", "Mã OTP đã được gửi đến email của bạn thành công!");
                
                // CHUYỂN HƯỚNG SANG TRANG NHẬP OTP LUÔN KHÔNG QUAY LẠI TRANG CŨ NỮA
                request.getRequestDispatcher("/enter-otp.jsp").forward(request, response);
                return;

            } else {
                request.setAttribute("error", "Email không tồn tại trong hệ thống hoặc tài khoản đã bị khóa!");
                request.setAttribute("email", email);
            }

        } catch (Exception e) {
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            request.setAttribute("email", email);
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (checkStmt != null) checkStmt.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }

        request.getRequestDispatcher("/forgot-password.jsp").forward(request, response);
    }
}

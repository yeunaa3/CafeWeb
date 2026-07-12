package controller.customer;

import dao.UserDAO;
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
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.security.SecureRandom;
import java.util.Properties;
import model.User;

@WebServlet(name = "ForgotPasswordController", urlPatterns = {"/forgot-password"})
public class ForgotPasswordController extends HttpServlet {

    static final String OTP_SESSION_KEY = "otp";
    static final String OTP_EMAIL_SESSION_KEY = "email";
    static final String OTP_CREATED_AT_SESSION_KEY = "otpCreatedAt";
    static final long OTP_TTL_MILLIS = 5L * 60L * 1000L;

    private static final SecureRandom RANDOM = new SecureRandom();

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

        String email = trim(request.getParameter("email"));
        if (email.isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập địa chỉ email!");
            request.getRequestDispatcher("/forgot-password.jsp").forward(request, response);
            return;
        }

        User user = new UserDAO().getActiveUserByEmail(email);
        if (user == null) {
            request.setAttribute("error", "Email không tồn tại trong hệ thống hoặc tài khoản đã bị khóa!");
            request.setAttribute("email", email);
            request.getRequestDispatcher("/forgot-password.jsp").forward(request, response);
            return;
        }

        int otpValue = 100000 + RANDOM.nextInt(900000);
        try {
            sendOtpEmail(email, otpValue);
        } catch (Exception ex) {
            request.setAttribute("error", "Không thể gửi OTP. Vui lòng kiểm tra cấu hình Gmail SMTP.");
            request.setAttribute("email", email);
            request.getRequestDispatcher("/forgot-password.jsp").forward(request, response);
            return;
        }

        HttpSession session = request.getSession();
        session.setAttribute(OTP_SESSION_KEY, otpValue);
        session.setAttribute(OTP_EMAIL_SESSION_KEY, email);
        session.setAttribute(OTP_CREATED_AT_SESSION_KEY, System.currentTimeMillis());
        request.setAttribute("message", "Mã OTP đã được gửi đến email của bạn thành công!");
        request.getRequestDispatcher("/enter-otp.jsp").forward(request, response);
    }

    private void sendOtpEmail(String toEmail, int otpValue) throws Exception {
        MailSettings settings = MailSettings.load(this);
        Properties props = new Properties();
        props.put("mail.smtp.host", settings.host);
        props.put("mail.smtp.port", settings.port);
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");

        Session mailSession = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(settings.username, settings.password);
            }
        });

        MimeMessage message = new MimeMessage(mailSession);
        message.setFrom(new InternetAddress(settings.fromEmail));
        message.addRecipient(Message.RecipientType.TO, new InternetAddress(toEmail));
        message.setSubject("CBMS - Mã xác thực đặt lại mật khẩu", "UTF-8");
        message.setText("Mã xác thực (OTP) của bạn là: " + otpValue
                + "\nMã này có hiệu lực trong vòng 5 phút.", "UTF-8");
        Transport.send(message);
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }

    private static final class MailSettings {
        private final String host;
        private final String port;
        private final String fromEmail;
        private final String username;
        private final String password;

        private MailSettings(String host, String port, String fromEmail, String username, String password) {
            this.host = host;
            this.port = port;
            this.fromEmail = fromEmail;
            this.username = username;
            this.password = password;
        }

        private static MailSettings load(HttpServlet servlet) throws IOException {
            Properties fileProps = loadFileProperties(servlet);
            String host = value("CBMS_MAIL_HOST", fileProps, "mail.smtp.host", "smtp.gmail.com");
            String port = value("CBMS_MAIL_PORT", fileProps, "mail.smtp.port", "587");
            String fromEmail = value("CBMS_MAIL_FROM", fileProps, "mail.from", "");
            String username = value("CBMS_MAIL_USERNAME", fileProps, "mail.username", fromEmail);
            String password = value("CBMS_MAIL_PASSWORD", fileProps, "mail.password", "");
            if (fromEmail.isEmpty() || username.isEmpty() || password.isEmpty()
                    || password.contains("YOUR_GMAIL_APP_PASSWORD")) {
                throw new IOException("Missing Gmail SMTP configuration");
            }
            return new MailSettings(host, port, fromEmail, username, password);
        }

        private static Properties loadFileProperties(HttpServlet servlet) throws IOException {
            Properties properties = new Properties();
            String path = servlet.getServletContext().getRealPath("/WEB-INF/Mail.properties");
            if (path == null) {
                return properties;
            }
            try (InputStream input = new FileInputStream(path)) {
                properties.load(input);
            } catch (IOException ex) {
                return properties;
            }
            return properties;
        }

        private static String value(String envName, Properties properties, String key, String defaultValue) {
            String envValue = System.getenv(envName);
            if (envValue != null && !envValue.trim().isEmpty()) {
                return envValue.trim();
            }
            String propertyValue = properties.getProperty(key);
            if (propertyValue != null && !propertyValue.trim().isEmpty()) {
                return propertyValue.trim();
            }
            return defaultValue;
        }
    }
}

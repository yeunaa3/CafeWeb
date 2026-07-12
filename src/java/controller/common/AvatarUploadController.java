package controller.common;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.util.Locale;
import model.User;

@WebServlet(name = "AvatarUploadController", urlPatterns = {"/avatar/upload"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 20 * 1024 * 1024,
        maxRequestSize = 22 * 1024 * 1024
)
public class AvatarUploadController extends HttpServlet {

    private static final String AVATAR_UPLOAD_PATH = "/images/avatars/uploads";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.sendRedirect(request.getContextPath() + "/profile");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        Object value = session == null ? null : session.getAttribute("user");
        if (!(value instanceof User)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) value;
        String target = accountPath(user);
        try {
            Part avatar = request.getPart("avatar");
            String submitted = avatar == null ? "" : avatar.getSubmittedFileName();
            String extension = extensionOf(submitted);
            if (avatar == null || avatar.getSize() <= 0 || extension == null) {
                putMessage(session, user, false, "Vui lòng chọn ảnh PNG, JPG, JPEG hoặc WEBP.");
                response.sendRedirect(request.getContextPath() + target);
                return;
            }

            String uploadPath = getServletContext().getRealPath(AVATAR_UPLOAD_PATH);
            if (uploadPath == null) {
                putMessage(session, user, false, "Không tìm thấy thư mục upload của server.");
                response.sendRedirect(request.getContextPath() + target);
                return;
            }

            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists() && !uploadDir.mkdirs()) {
                putMessage(session, user, false, "Không thể tạo thư mục lưu ảnh đại diện.");
                response.sendRedirect(request.getContextPath() + target);
                return;
            }

            String fileName = "avatar-" + user.getUserId() + "-" + System.currentTimeMillis() + extension;
            File savedFile = new File(uploadDir, fileName);
            avatar.write(savedFile.getAbsolutePath());
            copyToProjectAssetFolder(savedFile, AVATAR_UPLOAD_PATH);

            String avatarUrl = AVATAR_UPLOAD_PATH + "/" + fileName;
            if (new UserDAO().updateAvatar(user.getUserId(), avatarUrl)) {
                user.setAvatarUrl(avatarUrl);
                session.setAttribute("user", user);
                putMessage(session, user, true, "Đã cập nhật ảnh đại diện.");
            } else {
                putMessage(session, user, false, "Không thể lưu ảnh đại diện vào database.");
            }
        } catch (IllegalStateException ex) {
            putMessage(session, user, false, "Ảnh quá lớn. Vui lòng chọn ảnh dưới 20MB.");
        } catch (ServletException ex) {
            putMessage(session, user, false, "Không thể đọc file ảnh. Vui lòng chọn ảnh PNG, JPG, JPEG hoặc WEBP.");
        } catch (IOException ex) {
            putMessage(session, user, false, "Không thể lưu file ảnh. Vui lòng thử ảnh khác.");
        } catch (RuntimeException ex) {
            putMessage(session, user, false, "Không thể cập nhật ảnh đại diện. Vui lòng thử lại.");
        }

        response.sendRedirect(request.getContextPath() + target);
    }

    private String extensionOf(String fileName) {
        int dot = fileName == null ? -1 : fileName.lastIndexOf('.');
        if (dot < 0) {
            return null;
        }
        String extension = fileName.substring(dot).toLowerCase(Locale.ROOT);
        return extension.matches("\\.(png|jpg|jpeg|webp)") ? extension : null;
    }

    private void copyToProjectAssetFolder(File savedFile, String assetPath) {
        try {
            String realRoot = getServletContext().getRealPath("/");
            if (realRoot == null) return;
            File runtimeRoot = new File(realRoot).getCanonicalFile();
            File projectRoot = runtimeRoot.getParentFile() == null ? null : runtimeRoot.getParentFile().getParentFile();
            if (projectRoot == null || !new File(projectRoot, "nbproject").isDirectory()) return;

            String relativeAssetPath = assetPath.startsWith("/") ? assetPath.substring(1) : assetPath;
            File sourceDir = new File(projectRoot, "web" + File.separator + relativeAssetPath.replace('/', File.separatorChar));
            if (!sourceDir.exists() && !sourceDir.mkdirs()) return;
            File sourceFile = new File(sourceDir, savedFile.getName()).getCanonicalFile();
            if (!sourceFile.equals(savedFile.getCanonicalFile())) {
                Files.copy(savedFile.toPath(), sourceFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
            }
        } catch (IOException ignored) {
        }
    }

    private String accountPath(User user) {
        if (user.getRoleId() == 1) {
            return "/manager/account";
        }
        if (user.getRoleId() == 2) {
            return "/cashier/account";
        }
        return "/profile";
    }

    private void putMessage(HttpSession session, User user, boolean success, String message) {
        if (user.getRoleId() == 1) {
            session.setAttribute(success ? "managerSuccess" : "managerError", message);
        } else if (user.getRoleId() == 2) {
            session.setAttribute(success ? "cashierSuccess" : "cashierError", message);
        } else {
            session.setAttribute(success ? "profileSuccess" : "profileError", message);
        }
    }
}

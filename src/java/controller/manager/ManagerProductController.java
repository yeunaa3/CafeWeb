package controller.manager;

import dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.util.Locale;
import model.Product;

@WebServlet(name = "ManagerProductController", urlPatterns = {"/manager/products"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 8 * 1024 * 1024,
        maxRequestSize = 10 * 1024 * 1024
)
public class ManagerProductController extends HttpServlet {

    private static final String PRODUCT_UPLOAD_PATH = "/images/products/uploads";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (ManagerPageSupport.requireManager(request, response) == null) return;
        ProductDAO productDAO = new ProductDAO();
        String action = trim(request.getParameter("action"));
        if ("new".equals(action)) {
            request.setAttribute("formMode", "create");
        } else if ("edit".equals(action)) {
            Product product = productDAO.getProductForAdmin(parseId(request.getParameter("id")));
            if (product != null) {
                request.setAttribute("editingProduct", product);
                request.setAttribute("formMode", "edit");
            }
        }
        render(request, response, productDAO);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        if (ManagerPageSupport.requireManager(request, response) == null) return;
        ProductDAO productDAO = new ProductDAO();
        String action = trim(request.getParameter("action"));
        int productId = parseId(request.getParameter("id"));

        if ("toggle".equals(action)) {
            finish(request, response, productDAO.setProductStatus(productId,
                    Boolean.parseBoolean(request.getParameter("active"))), "Đã cập nhật trạng thái sản phẩm.");
            return;
        }
        if ("delete".equals(action)) {
            finish(request, response, productDAO.deleteProduct(productId), "Đã xóa sản phẩm.",
                    "Không thể xóa sản phẩm đã xuất hiện trong đơn hoặc combo. Hãy chuyển sang hết hàng.");
            return;
        }

        boolean editing = "update".equals(action);
        Product product = new Product();
        product.setProductId(productId);
        product.setProductName(trim(request.getParameter("productName")));
        product.setCategoryId(parseId(request.getParameter("categoryId")));
        product.setPrice(parseDouble(request.getParameter("price")));
        product.setImageUrl(trimToNull(request.getParameter("currentImageUrl")));
        product.setDescription(trimToNull(request.getParameter("description")));
        product.setStatus(request.getParameter("status") != null);

        String error = validate(product);
        if (error == null) {
            try {
                String uploadedImage = saveProductImage(request);
                if (uploadedImage != null) {
                    product.setImageUrl(uploadedImage);
                }
            } catch (IllegalStateException ex) {
                error = "Anh qua lon. Vui long chon anh duoi 8MB.";
            } catch (ServletException ex) {
                error = ex.getMessage();
            } catch (IOException ex) {
                error = "Khong the luu file anh. Vui long thu anh khac.";
            }
        }
        if (error == null) {
            boolean success = editing ? productDAO.updateProduct(product) : productDAO.createProduct(product);
            if (success) {
                finish(request, response, true, editing ? "Đã sửa sản phẩm." : "Đã thêm sản phẩm.");
                return;
            }
            error = "Không thể lưu sản phẩm. Tên món có thể đã tồn tại.";
        }
        request.setAttribute("error", error);
        request.setAttribute("editingProduct", product);
        request.setAttribute("formMode", editing ? "edit" : "create");
        render(request, response, productDAO);
    }

    private void render(HttpServletRequest request, HttpServletResponse response, ProductDAO productDAO)
            throws ServletException, IOException {
        ManagerPageSupport.prepare(request, "products", "Sản phẩm");
        request.setAttribute("productList", productDAO.getAdminProducts(request.getParameter("q")));
        request.setAttribute("categoryList", productDAO.getAllCategories());
        request.getRequestDispatcher("/jsp/manager/products.jsp").forward(request, response);
    }

    private String validate(Product product) {
        if (product.getProductName().isEmpty()) return "Vui lòng nhập tên sản phẩm.";
        if (product.getCategoryId() < 1) return "Vui lòng chọn danh mục.";
        if (product.getPrice() < 0) return "Giá sản phẩm không được âm.";
        return null;
    }

    private String saveProductImage(HttpServletRequest request) throws IOException, ServletException {
        Part image = request.getPart("productImage");
        if (image == null || image.getSize() <= 0) {
            return null;
        }

        String extension = extensionOf(image.getSubmittedFileName());
        if (extension == null) {
            throw new ServletException("Vui long chon anh PNG, JPG, JPEG hoac WEBP.");
        }

        String uploadPath = getServletContext().getRealPath(PRODUCT_UPLOAD_PATH);
        if (uploadPath == null) {
            throw new IOException("Khong tim thay thu muc upload cua server.");
        }

        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists() && !uploadDir.mkdirs()) {
            throw new IOException("Khong the tao thu muc luu anh san pham.");
        }

        String fileName = "product-" + System.currentTimeMillis() + extension;
        File savedFile = new File(uploadDir, fileName);
        image.write(savedFile.getAbsolutePath());
        copyToProjectAssetFolder(savedFile, PRODUCT_UPLOAD_PATH);
        return PRODUCT_UPLOAD_PATH + "/" + fileName;
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

    private String extensionOf(String fileName) {
        int dot = fileName == null ? -1 : fileName.lastIndexOf('.');
        if (dot < 0) {
            return null;
        }
        String extension = fileName.substring(dot).toLowerCase(Locale.ROOT);
        return extension.matches("\\.(png|jpg|jpeg|webp)") ? extension : null;
    }

    private void finish(HttpServletRequest request, HttpServletResponse response,
            boolean success, String successMessage) throws IOException {
        finish(request, response, success, successMessage, "Không thể cập nhật sản phẩm.");
    }
    private void finish(HttpServletRequest request, HttpServletResponse response,
            boolean success, String successMessage, String errorMessage) throws IOException {
        request.getSession().setAttribute(success ? "managerSuccess" : "managerError",
                success ? successMessage : errorMessage);
        response.sendRedirect(request.getContextPath() + "/manager/products");
    }
    private int parseId(String value) {
        try { return Integer.parseInt(value); } catch (NumberFormatException ex) { return -1; }
    }
    private double parseDouble(String value) {
        try { return Double.parseDouble(value); } catch (NumberFormatException ex) { return -1; }
    }
    private String trim(String value) { return value == null ? "" : value.trim(); }
    private String trimToNull(String value) {
        String result = trim(value);
        return result.isEmpty() ? null : result;
    }
}

package controller.manager;

import dal.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import model.Product;

@WebServlet(name = "ManagerProductController", urlPatterns = {"/manager/products"})
public class ManagerProductController extends HttpServlet {

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
        product.setImageUrl(trimToNull(request.getParameter("imageUrl")));
        product.setDescription(trimToNull(request.getParameter("description")));
        product.setStatus(request.getParameter("status") != null);

        String error = validate(product);
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

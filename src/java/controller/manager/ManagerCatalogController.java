package controller.manager;

import dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import model.Category;
import model.Topping;

@WebServlet(name = "ManagerCatalogController", urlPatterns = {"/manager/catalog"})
public class ManagerCatalogController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (ManagerPageSupport.requireManager(request, response) == null) return;
        ProductDAO productDAO = new ProductDAO();
        String action = trim(request.getParameter("action"));
        int id = parseId(request.getParameter("id"));

        if ("new-category".equals(action)) {
            request.setAttribute("categoryFormMode", "create");
        } else if ("edit-category".equals(action)) {
            Category category = productDAO.getCategoryForAdmin(id);
            if (category != null) {
                request.setAttribute("editingCategory", category);
                request.setAttribute("categoryFormMode", "edit");
            }
        } else if ("new-topping".equals(action)) {
            request.setAttribute("toppingFormMode", "create");
        } else if ("edit-topping".equals(action)) {
            Topping topping = productDAO.getToppingForAdmin(id);
            if (topping != null) {
                request.setAttribute("editingTopping", topping);
                request.setAttribute("toppingFormMode", "edit");
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
        int id = parseId(request.getParameter("id"));

        if ("toggle-category".equals(action)) {
            finish(request, response, productDAO.setCategoryStatus(id,
                    Boolean.parseBoolean(request.getParameter("active"))),
                    "Da cap nhat trang thai danh muc.");
            return;
        }
        if ("delete-category".equals(action)) {
            finish(request, response, productDAO.deleteCategory(id),
                    "Da xoa danh muc.",
                    "Khong the xoa danh muc dang co san pham. Hay khoa danh muc neu can an tam thoi.");
            return;
        }
        if ("toggle-topping".equals(action)) {
            finish(request, response, productDAO.setToppingStatus(id,
                    Boolean.parseBoolean(request.getParameter("active"))),
                    "Da cap nhat trang thai topping.");
            return;
        }
        if ("delete-topping".equals(action)) {
            finish(request, response, productDAO.deleteTopping(id),
                    "Da xoa topping.",
                    "Khong the xoa topping da gan voi mon hoac don hang. Hay khoa topping neu can an tam thoi.");
            return;
        }

        if ("create-category".equals(action) || "update-category".equals(action)) {
            saveCategory(request, response, productDAO, "update-category".equals(action));
            return;
        }
        if ("create-topping".equals(action) || "update-topping".equals(action)) {
            saveTopping(request, response, productDAO, "update-topping".equals(action));
            return;
        }

        response.sendRedirect(request.getContextPath() + "/manager/catalog");
    }

    private void saveCategory(HttpServletRequest request, HttpServletResponse response,
            ProductDAO productDAO, boolean editing) throws ServletException, IOException {
        Category category = new Category();
        category.setCategoryId(parseId(request.getParameter("id")));
        category.setCategoryName(trim(request.getParameter("categoryName")));
        category.setDescription(trimToNull(request.getParameter("description")));
        category.setStatus(request.getParameter("status") != null);

        String error = validateCategory(category);
        if (error == null) {
            boolean success = editing ? productDAO.updateCategory(category) : productDAO.createCategory(category);
            if (success) {
                finish(request, response, true, editing ? "Da sua danh muc." : "Da them danh muc.");
                return;
            }
            error = "Khong the luu danh muc. Ten danh muc co the da ton tai.";
        }

        request.setAttribute("error", error);
        request.setAttribute("editingCategory", category);
        request.setAttribute("categoryFormMode", editing ? "edit" : "create");
        render(request, response, productDAO);
    }

    private void saveTopping(HttpServletRequest request, HttpServletResponse response,
            ProductDAO productDAO, boolean editing) throws ServletException, IOException {
        Topping topping = new Topping();
        topping.setToppingId(parseId(request.getParameter("id")));
        topping.setToppingName(trim(request.getParameter("toppingName")));
        topping.setPrice(parseDouble(request.getParameter("price")));
        topping.setStatus(request.getParameter("status") != null);

        String error = validateTopping(topping);
        if (error == null) {
            boolean success = editing ? productDAO.updateTopping(topping) : productDAO.createTopping(topping);
            if (success) {
                finish(request, response, true, editing ? "Da sua topping." : "Da them topping.");
                return;
            }
            error = "Khong the luu topping. Ten topping co the da ton tai.";
        }

        request.setAttribute("error", error);
        request.setAttribute("editingTopping", topping);
        request.setAttribute("toppingFormMode", editing ? "edit" : "create");
        render(request, response, productDAO);
    }

    private void render(HttpServletRequest request, HttpServletResponse response, ProductDAO productDAO)
            throws ServletException, IOException {
        ManagerPageSupport.prepare(request, "catalog", "Danh muc & Topping");
        request.setAttribute("categoryList", productDAO.getCategoriesForAdmin(request.getParameter("q")));
        request.setAttribute("toppingList", productDAO.getToppingsForAdmin(request.getParameter("q")));
        request.getRequestDispatcher("/jsp/manager/catalog.jsp").forward(request, response);
    }

    private String validateCategory(Category category) {
        if (category.getCategoryName().isEmpty()) return "Vui long nhap ten danh muc.";
        if (category.getCategoryName().length() > 100) return "Ten danh muc toi da 100 ky tu.";
        return null;
    }

    private String validateTopping(Topping topping) {
        if (topping.getToppingName().isEmpty()) return "Vui long nhap ten topping.";
        if (topping.getToppingName().length() > 100) return "Ten topping toi da 100 ky tu.";
        if (topping.getPrice() < 0) return "Gia topping khong duoc am.";
        return null;
    }

    private void finish(HttpServletRequest request, HttpServletResponse response,
            boolean success, String successMessage) throws IOException {
        finish(request, response, success, successMessage, "Khong the cap nhat du lieu.");
    }

    private void finish(HttpServletRequest request, HttpServletResponse response,
            boolean success, String successMessage, String errorMessage) throws IOException {
        request.getSession().setAttribute(success ? "managerSuccess" : "managerError",
                success ? successMessage : errorMessage);
        response.sendRedirect(request.getContextPath() + "/manager/catalog");
    }

    private int parseId(String value) {
        try { return Integer.parseInt(value); } catch (NumberFormatException ex) { return -1; }
    }

    private double parseDouble(String value) {
        try { return Double.parseDouble(value); } catch (NumberFormatException ex) { return -1; }
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }

    private String trimToNull(String value) {
        String result = trim(value);
        return result.isEmpty() ? null : result;
    }
}

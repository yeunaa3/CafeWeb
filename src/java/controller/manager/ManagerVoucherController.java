package controller.manager;

import dal.VoucherDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Timestamp;
import model.Voucher;

@WebServlet(name = "ManagerVoucherController", urlPatterns = {"/manager/vouchers"})
public class ManagerVoucherController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (ManagerPageSupport.requireManager(request, response) == null) return;
        String action = trim(request.getParameter("action"));
        if ("new".equals(action)) {
            request.setAttribute("formMode", "create");
        } else if ("edit".equals(action)) {
            Voucher voucher = new VoucherDAO().getVoucherById(parseId(request.getParameter("id")));
            if (voucher != null) {
                request.setAttribute("editingVoucher", voucher);
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
        VoucherDAO voucherDAO = new VoucherDAO();
        String action = trim(request.getParameter("action"));
        int voucherId = parseId(request.getParameter("id"));

        if ("toggle".equals(action)) {
            finish(request, response, voucherDAO.setVoucherStatus(voucherId,
                    Boolean.parseBoolean(request.getParameter("active"))), "Đã cập nhật trạng thái voucher.");
            return;
        }
        if ("delete".equals(action)) {
            finish(request, response, voucherDAO.deleteVoucher(voucherId),
                    "Đã xóa voucher.", "Không thể xóa voucher đã được dùng trong đơn hàng.");
            return;
        }

        boolean editing = "update".equals(action);
        Voucher voucher = new Voucher();
        voucher.setVoucherId(voucherId);
        voucher.setVoucherCode(trim(request.getParameter("voucherCode")).toUpperCase());
        voucher.setDiscountValue(parseDouble(request.getParameter("discountValue")));
        voucher.setMinOrderValue(parseDouble(request.getParameter("minOrderValue")));
        voucher.setExpiryDate(parseTimestamp(request.getParameter("expiryDate")));
        voucher.setStatus(request.getParameter("status") != null);

        String error = validate(voucher);
        if (error == null) {
            boolean success = editing ? voucherDAO.updateVoucher(voucher) : voucherDAO.createVoucher(voucher);
            if (success) {
                finish(request, response, true, editing ? "Đã sửa voucher." : "Đã thêm voucher.");
                return;
            }
            error = "Không thể lưu voucher. Mã có thể đã tồn tại.";
        }

        request.setAttribute("error", error);
        request.setAttribute("editingVoucher", voucher);
        request.setAttribute("formMode", editing ? "edit" : "create");
        render(request, response);
    }

    private void render(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        ManagerPageSupport.prepare(request, "vouchers", "Mã giảm giá");
        request.setAttribute("voucherList", new VoucherDAO().getAllVouchers(request.getParameter("q")));
        request.getRequestDispatcher("/jsp/manager/vouchers.jsp").forward(request, response);
    }

    private String validate(Voucher voucher) {
        if (!voucher.getVoucherCode().matches("[A-Z0-9_-]{4,50}")) return "Mã voucher phải có 4-50 ký tự hợp lệ.";
        if (voucher.getDiscountValue() <= 0) return "Giá trị giảm phải lớn hơn 0.";
        if (voucher.getMinOrderValue() < 0) return "Đơn tối thiểu không được âm.";
        if (voucher.getExpiryDate() == null) return "Ngày hết hạn không hợp lệ.";
        return null;
    }

    private Timestamp parseTimestamp(String value) {
        try {
            String normalized = trim(value).replace('T', ' ');
            if (normalized.length() == 16) normalized += ":00";
            return Timestamp.valueOf(normalized);
        } catch (IllegalArgumentException ex) {
            return null;
        }
    }

    private double parseDouble(String value) {
        try { return Double.parseDouble(value); } catch (NumberFormatException ex) { return -1; }
    }

    private int parseId(String value) {
        try { return Integer.parseInt(value); } catch (NumberFormatException ex) { return -1; }
    }

    private void finish(HttpServletRequest request, HttpServletResponse response,
            boolean success, String successMessage) throws IOException {
        finish(request, response, success, successMessage, "Không thể cập nhật voucher.");
    }

    private void finish(HttpServletRequest request, HttpServletResponse response,
            boolean success, String successMessage, String errorMessage) throws IOException {
        request.getSession().setAttribute(success ? "managerSuccess" : "managerError",
                success ? successMessage : errorMessage);
        response.sendRedirect(request.getContextPath() + "/manager/vouchers");
    }

    private String trim(String value) { return value == null ? "" : value.trim(); }
}

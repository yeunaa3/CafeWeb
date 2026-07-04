package controller.customer;

import dal.UserDAO;
import dal.VoucherDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import model.RedeemOption;
import model.User;
import model.Voucher;

@WebServlet(name = "RedeemController", urlPatterns = {"/redeem"})
public class RedeemController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        preparePage(request);
        request.getRequestDispatcher("/jsp/customer/redeem.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        User customer = CustomerPageSupport.resolveCustomer(request);
        VoucherDAO voucherDAO = new VoucherDAO();
        RedeemOption selectedOption = findOption(voucherDAO, request.getParameter("pointsCost"));

        if (selectedOption == null) {
            request.setAttribute("error", "Gói đổi voucher không hợp lệ.");
        } else {
            try {
                Voucher voucher = voucherDAO.redeemPointsForVoucher(customer.getUserId(), selectedOption);
                request.setAttribute("success", "Đổi điểm thành công. Mã của bạn: " + voucher.getVoucherCode());
            } catch (SQLException ex) {
                String message = "Not enough points".equals(ex.getMessage())
                        ? "Bạn chưa đủ điểm để đổi voucher này."
                        : "Không thể đổi voucher lúc này. Vui lòng thử lại.";
                request.setAttribute("error", message);
            }
        }

        User refreshedCustomer = new UserDAO().getUserById(customer.getUserId());
        if (refreshedCustomer != null) {
            request.getSession().setAttribute("user", refreshedCustomer);
        }
        preparePage(request);
        request.getRequestDispatcher("/jsp/customer/redeem.jsp").forward(request, response);
    }

    private void preparePage(HttpServletRequest request) {
        User customer = CustomerPageSupport.resolveCustomer(request);
        VoucherDAO voucherDAO = new VoucherDAO();
        CustomerPageSupport.prepareCommonData(request, customer);
        request.setAttribute("availableVouchers", voucherDAO.getActiveVouchers(3));
        request.setAttribute("redeemOptions", voucherDAO.getRedeemOptions());
    }

    private RedeemOption findOption(VoucherDAO voucherDAO, String pointsCostValue) {
        try {
            int pointsCost = Integer.parseInt(pointsCostValue);
            for (RedeemOption option : voucherDAO.getRedeemOptions()) {
                if (option.getPointsCost() == pointsCost) {
                    return option;
                }
            }
        } catch (NumberFormatException ex) {
            return null;
        }
        return null;
    }
}

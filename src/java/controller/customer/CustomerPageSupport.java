package controller.customer;

import dal.OrderDAO;
import dal.UserDAO;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import java.util.List;
import model.CustomerOrderSummary;
import model.User;

final class CustomerPageSupport {

    private CustomerPageSupport() {
    }

    static User resolveCustomer(HttpServletRequest request) {
        HttpSession session = request.getSession();
        Object sessionUser = session.getAttribute("user");
        if (sessionUser instanceof User) {
            User freshUser = new UserDAO().getUserById(((User) sessionUser).getUserId());
            if (freshUser != null) {
                session.setAttribute("user", freshUser);
                return freshUser;
            }
        }

        Object sessionUserId = session.getAttribute("userId");
        if (sessionUserId instanceof Integer) {
            User user = new UserDAO().getUserById((Integer) sessionUserId);
            if (user != null) {
                session.setAttribute("user", user);
                return user;
            }
        }

        User demoCustomer = new UserDAO().getDefaultCustomer();
        session.setAttribute("user", demoCustomer);
        session.setAttribute("userId", demoCustomer.getUserId());
        return demoCustomer;
    }

    static void prepareCommonData(HttpServletRequest request, User customer) {
        List<CustomerOrderSummary> orders = new OrderDAO().getCustomerOrders(customer.getUserId());
        request.setAttribute("customer", customer);
        request.setAttribute("customerOrders", orders);
        request.setAttribute("notificationCount", countActiveOrders(orders));
        request.setAttribute("cartCount", CartController.getCartCount(request));
    }

    private static int countActiveOrders(List<CustomerOrderSummary> orders) {
        int count = 0;
        for (CustomerOrderSummary order : orders) {
            if (!"Completed".equalsIgnoreCase(order.getStatus())
                    && !"Paid".equalsIgnoreCase(order.getStatus())
                    && !"Cancelled".equalsIgnoreCase(order.getStatus())) {
                count++;
            }
        }
        return count;
    }
}

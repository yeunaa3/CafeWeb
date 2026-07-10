package filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import model.User;

@WebFilter(urlPatterns = {
    "/manager",
    "/manager/*",
    "/cashier/*",
    "/profile",
    "/redeem",
    "/checkout",
    "/checkout/payment",
    "/avatar/upload"
})
public class AuthorizationFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        User user = getUser(httpRequest);
        if (user == null) {
            redirectToLogin(httpRequest, httpResponse);
            return;
        }

        String path = httpRequest.getRequestURI().substring(httpRequest.getContextPath().length());
        if (path.startsWith("/manager/") && user.getRoleId() != 1) {
            httpResponse.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        if (path.startsWith("/cashier/") && user.getRoleId() != 2) {
            httpResponse.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        if (isCustomerOnly(path) && user.getRoleId() != 3) {
            httpResponse.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        chain.doFilter(request, response);
    }

    private User getUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        Object value = session == null ? null : session.getAttribute("user");
        return value instanceof User ? (User) value : null;
    }

    private boolean isCustomerOnly(String path) {
        return "/profile".equals(path)
                || "/redeem".equals(path)
                || "/checkout".equals(path)
                || "/checkout/payment".equals(path);
    }

    private void redirectToLogin(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String path = request.getRequestURI().substring(request.getContextPath().length());
        String query = request.getQueryString();
        String returnUrl = query == null || query.isEmpty() ? path : path + "?" + query;
        response.sendRedirect(request.getContextPath() + "/login?returnUrl="
                + URLEncoder.encode(returnUrl, StandardCharsets.UTF_8.name()));
    }
}

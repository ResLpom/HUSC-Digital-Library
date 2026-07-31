package vn.edu.husc.library.filter;

import vn.edu.husc.library.model.User;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

public class RoleAuthorizationFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        String contextPath = req.getContextPath();
        String uri = req.getRequestURI();
        String path = uri.substring(contextPath.length());

        HttpSession session = req.getSession(false);

        User currentUser = null;

        if (session != null) {
            currentUser = (User) session.getAttribute("currentUser");

            if (currentUser == null) {
                currentUser = (User) session.getAttribute("user");
            }
        }

        if (currentUser == null) {
            resp.sendRedirect(contextPath + "/login.jsp");
            return;
        }

        String roleCode = currentUser.getRoleCode();

        if (roleCode == null || roleCode.trim().isEmpty()) {
            Object sessionRole = session.getAttribute("roleCode");

            if (sessionRole != null) {
                roleCode = String.valueOf(sessionRole);
            }
        }

        if (roleCode == null) {
            resp.sendRedirect(contextPath + "/login.jsp");
            return;
        }

        roleCode = roleCode.trim().toUpperCase();

        if (path.startsWith("/admin")) {
            if (!"ADMIN".equals(roleCode)) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập khu vực Admin.");
                return;
            }
        }

        if (path.startsWith("/manager")) {
            if (!"MANAGER".equals(roleCode) && !"ADMIN".equals(roleCode)) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập khu vực Manager.");
                return;
            }
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
    }
}
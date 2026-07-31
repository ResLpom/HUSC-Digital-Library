package vn.edu.husc.library.filter;

import vn.edu.husc.library.dao.UserDAO;
import vn.edu.husc.library.model.User;

import java.io.IOException;
import javax.servlet.*;
import javax.servlet.http.*;

public class AuthenticationFilter implements Filter {

    private UserDAO userDAO;

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        userDAO = new UserDAO();
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        HttpSession session = req.getSession(false);

        User user = null;

        if (session != null) {
            user = (User) session.getAttribute("currentUser");

            if (user == null) {
                user = (User) session.getAttribute("user");
            }
        }

        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        boolean active = userDAO.isUserAllowedToAccess(user.getUserId());

        if (!active) {
            session.invalidate();
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
    }
}
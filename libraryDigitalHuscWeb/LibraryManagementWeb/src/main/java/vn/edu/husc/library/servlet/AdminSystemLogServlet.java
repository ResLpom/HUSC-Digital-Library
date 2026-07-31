package vn.edu.husc.library.servlet;

import vn.edu.husc.library.dao.SystemLogDAO;
import vn.edu.husc.library.model.SystemLog;
import vn.edu.husc.library.model.User;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

public class AdminSystemLogServlet extends HttpServlet {

    private SystemLogDAO systemLogDAO;

    @Override
    public void init() throws ServletException {
        systemLogDAO = new SystemLogDAO();
    }

    private User getCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);

        if (session == null) {
            return null;
        }

        return (User) session.getAttribute("currentUser");
    }

    private boolean isAdmin(User user) {
        if (user == null) {
            return false;
        }

        return "ADMIN".equalsIgnoreCase(user.getRoleCode());
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        User currentUser = getCurrentUser(request);

        if (!isAdmin(currentUser)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        List<SystemLog> logs = systemLogDAO.getAllLogs();

        request.setAttribute("logs", logs);
        request.getRequestDispatcher("/admin/system-logs.jsp").forward(request, response);
    }
}
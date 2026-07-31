package vn.edu.husc.library.servlet;

import vn.edu.husc.library.dao.ReportDAO;
import vn.edu.husc.library.model.ReportSummary;
import vn.edu.husc.library.model.User;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.io.IOException;

public class AdminReportServlet extends HttpServlet {

    private ReportDAO reportDAO;

    @Override
    public void init() throws ServletException {
        reportDAO = new ReportDAO();
    }

    private User getCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);

        if (session == null) {
            return null;
        }

        return (User) session.getAttribute("currentUser");
    }

    private boolean isManagerOrAdmin(User user) {
        if (user == null) {
            return false;
        }

        String roleCode = user.getRoleCode();

        return "MANAGER".equalsIgnoreCase(roleCode) || "ADMIN".equalsIgnoreCase(roleCode);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        User currentUser = getCurrentUser(request);

        if (!isManagerOrAdmin(currentUser)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        ReportSummary summary = reportDAO.getReportSummary();

        request.setAttribute("summary", summary);
        request.getRequestDispatcher("/admin/reports.jsp").forward(request, response);
    }
}
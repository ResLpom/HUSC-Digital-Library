package vn.edu.husc.library.servlet;

import vn.edu.husc.library.dao.RegistrationRequestDAO;
import vn.edu.husc.library.model.RegistrationRequest;
import vn.edu.husc.library.model.User;

import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

public class AdminRegistrationServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private RegistrationRequestDAO registrationDAO;

    @Override
    public void init() throws ServletException {
        registrationDAO = new RegistrationRequestDAO();
    }

    private User getCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);

        if (session == null) return null;

        User user = (User) session.getAttribute("currentUser");

        if (user == null) {
            user = (User) session.getAttribute("user");
        }

        return user;
    }

    private boolean isAdmin(User user) {
        return user != null
                && user.getRoleCode() != null
                && "ADMIN".equalsIgnoreCase(user.getRoleCode());
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

        String action = request.getParameter("action");

        if ("detail".equalsIgnoreCase(action)
                || "view".equalsIgnoreCase(action)) {
            showDetail(request, response);
            return;
        }

        showList(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        User currentUser = getCurrentUser(request);

        if (!isAdmin(currentUser)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String action = request.getParameter("action");

        if ("approve".equalsIgnoreCase(action)) {
            approve(request, response, currentUser);
            return;
        }

        if ("reject".equalsIgnoreCase(action)) {
            reject(request, response, currentUser);
            return;
        }

        response.sendRedirect(request.getContextPath() + "/admin/registrations");
    }

    private void showList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        String success = (String) session.getAttribute("adminRegistrationSuccess");
        String error = (String) session.getAttribute("adminRegistrationError");

        session.removeAttribute("adminRegistrationSuccess");
        session.removeAttribute("adminRegistrationError");

        List<RegistrationRequest> pendingRequests = registrationDAO.getPendingRequests();
        List<RegistrationRequest> recentRequests = registrationDAO.getRecentRequests();

        request.setAttribute("success", success);
        request.setAttribute("error", error);
        request.setAttribute("pendingRequests", pendingRequests);
        request.setAttribute("recentRequests", recentRequests);
        request.setAttribute("pendingCount", pendingRequests == null ? 0 : pendingRequests.size());

        request.getRequestDispatcher("/admin/registrations.jsp").forward(request, response);
    }

    private void showDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int userId = parseInt(request.getParameter("id"), 0);

        if (userId <= 0) {
            request.getSession().setAttribute("adminRegistrationError", "Mã đăng ký không hợp lệ.");
            response.sendRedirect(request.getContextPath() + "/admin/registrations");
            return;
        }

        RegistrationRequest registration = registrationDAO.getRequestById(userId);

        if (registration == null) {
            request.getSession().setAttribute("adminRegistrationError", "Không tìm thấy thông tin đăng ký.");
            response.sendRedirect(request.getContextPath() + "/admin/registrations");
            return;
        }

        request.setAttribute("registration", registration);
        request.getRequestDispatcher("/admin/registration-detail.jsp").forward(request, response);
    }

    private void approve(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws IOException {

        int userId = parseInt(request.getParameter("id"), 0);

        boolean success = registrationDAO.approveRequest(userId, currentUser.getUserId());

        request.getSession().setAttribute(
                success ? "adminRegistrationSuccess" : "adminRegistrationError",
                success ? "Đã duyệt tài khoản sinh viên." : "Duyệt tài khoản thất bại."
        );

        response.sendRedirect(request.getContextPath() + "/admin/registrations");
    }

    private void reject(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws IOException {

        int userId = parseInt(request.getParameter("id"), 0);
        String reason = request.getParameter("rejectReason");

        boolean success = registrationDAO.rejectRequest(userId, currentUser.getUserId(), reason);

        request.getSession().setAttribute(
                success ? "adminRegistrationSuccess" : "adminRegistrationError",
                success ? "Đã từ chối tài khoản và lưu lý do." : "Từ chối tài khoản thất bại."
        );

        response.sendRedirect(request.getContextPath() + "/admin/registrations");
    }

    private int parseInt(String value, int defaultValue) {
        try {
            if (value == null || value.trim().isEmpty()) return defaultValue;
            return Integer.parseInt(value.trim());
        } catch (Exception e) {
            return defaultValue;
        }
    }
}
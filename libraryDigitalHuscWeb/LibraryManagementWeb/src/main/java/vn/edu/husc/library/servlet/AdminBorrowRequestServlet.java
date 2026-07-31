package vn.edu.husc.library.servlet;

import vn.edu.husc.library.dao.BorrowRequestDAO;
import vn.edu.husc.library.model.BorrowRequest;
import vn.edu.husc.library.model.User;
import vn.edu.husc.library.dao.SystemLogDAO;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

public class AdminBorrowRequestServlet extends HttpServlet {

    private BorrowRequestDAO borrowRequestDAO;
    private SystemLogDAO systemLogDAO;
    @Override
    public void init() throws ServletException {
        borrowRequestDAO = new BorrowRequestDAO();
        systemLogDAO = new SystemLogDAO();
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

        List<BorrowRequest> requests = borrowRequestDAO.getAllRequests();

        request.setAttribute("requests", requests);
        request.getRequestDispatcher("/admin/borrow-requests.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        User currentUser = getCurrentUser(request);

        if (!isManagerOrAdmin(currentUser)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String action = request.getParameter("action");
        String requestIdParam = request.getParameter("requestId");
        String managerNote = request.getParameter("managerNote");

        if (managerNote == null) {
            managerNote = "";
        }

        try {
            int requestId = Integer.parseInt(requestIdParam);

            if ("approve".equalsIgnoreCase(action)) {
                borrowRequestDAO.approveRequest(requestId, managerNote);

                systemLogDAO.insertLog(
                        currentUser.getUserId(),
                        "APPROVE_BORROW_REQUEST",
                        "Duyệt yêu cầu mượn thiết bị ID: " + requestId,
                        request.getRemoteAddr()
                );

            } else if ("reject".equalsIgnoreCase(action)) {
                borrowRequestDAO.rejectRequest(requestId, managerNote);

                systemLogDAO.insertLog(
                        currentUser.getUserId(),
                        "REJECT_BORROW_REQUEST",
                        "Từ chối yêu cầu mượn thiết bị ID: " + requestId,
                        request.getRemoteAddr()
                );

            } else if ("handover".equalsIgnoreCase(action)) {
                borrowRequestDAO.handoverRequest(requestId);

                systemLogDAO.insertLog(
                        currentUser.getUserId(),
                        "HANDOVER_EQUIPMENT",
                        "Bàn giao thiết bị cho yêu cầu ID: " + requestId,
                        request.getRemoteAddr()
                );
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect(request.getContextPath() + "/admin/borrow-requests");
    }
}
package vn.edu.husc.library.servlet;

import vn.edu.husc.library.dao.MaintenanceDAO;
import vn.edu.husc.library.model.User;

import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.IOException;

public class ManagerMaintenanceServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private MaintenanceDAO maintenanceDAO;

    @Override
    public void init() throws ServletException {
        maintenanceDAO = new MaintenanceDAO();
    }

    private User getCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);

        if (session == null) {
            return null;
        }

        User user = (User) session.getAttribute("currentUser");

        if (user == null) {
            user = (User) session.getAttribute("user");
        }

        return user;
    }

    private boolean isManagerOrAdmin(User user) {
        if (user == null || user.getRoleCode() == null) {
            return false;
        }

        return "MANAGER".equalsIgnoreCase(user.getRoleCode())
                || "ADMIN".equalsIgnoreCase(user.getRoleCode());
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

        loadPage(request, response);
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

        if ("complete".equalsIgnoreCase(action)) {
            completeMaintenance(request, response, currentUser);
            return;
        }

        createMaintenance(request, response, currentUser);
    }

    private void loadPage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        String success = (String) session.getAttribute("managerMaintenanceSuccess");
        String error = (String) session.getAttribute("managerMaintenanceError");

        session.removeAttribute("managerMaintenanceSuccess");
        session.removeAttribute("managerMaintenanceError");

        request.setAttribute("success", success);
        request.setAttribute("error", error);

        request.setAttribute("equipments", maintenanceDAO.getEquipmentsForMaintenance());
        request.setAttribute("maintenanceRecords", maintenanceDAO.getAllMaintenanceRecords());
        request.setAttribute("records", maintenanceDAO.getAllMaintenanceRecords());

        request.getRequestDispatcher("/manager/maintenance-records.jsp").forward(request, response);
    }

    private void createMaintenance(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws IOException {

        int equipmentId = parseInt(request.getParameter("equipmentId"), 0);
        String issueDescription = request.getParameter("issueDescription");
        String managerNote = request.getParameter("managerNote");

        if (equipmentId <= 0) {
            request.getSession().setAttribute("managerMaintenanceError", "Vui lòng chọn thiết bị cần bảo trì.");
            response.sendRedirect(request.getContextPath() + "/manager/maintenance-records");
            return;
        }

        if (issueDescription == null || issueDescription.trim().isEmpty()) {
            request.getSession().setAttribute("managerMaintenanceError", "Vui lòng nhập tình trạng cần bảo trì.");
            response.sendRedirect(request.getContextPath() + "/manager/maintenance-records");
            return;
        }

        boolean success = maintenanceDAO.addMaintenanceRecord(
                equipmentId,
                issueDescription,
                managerNote,
                currentUser.getUserId()
        );

        request.getSession().setAttribute(
                success ? "managerMaintenanceSuccess" : "managerMaintenanceError",
                success ? "Đã thêm ghi nhận bảo trì." : "Thêm ghi nhận bảo trì thất bại."
        );

        response.sendRedirect(request.getContextPath() + "/manager/maintenance-records");
    }

    private void completeMaintenance(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws IOException {

        int maintenanceId = parseInt(request.getParameter("maintenanceId"), 0);

        if (maintenanceId == 0) {
            maintenanceId = parseInt(request.getParameter("id"), 0);
        }

        if (maintenanceId <= 0) {
            request.getSession().setAttribute("managerMaintenanceError", "Mã bảo trì không hợp lệ.");
            response.sendRedirect(request.getContextPath() + "/manager/maintenance-records");
            return;
        }

        boolean success = maintenanceDAO.completeMaintenanceRecord(maintenanceId, currentUser.getUserId());

        request.getSession().setAttribute(
                success ? "managerMaintenanceSuccess" : "managerMaintenanceError",
                success ? "Đã hoàn tất bảo trì." : "Hoàn tất bảo trì thất bại."
        );

        response.sendRedirect(request.getContextPath() + "/manager/maintenance-records");
    }

    private int parseInt(String value, int defaultValue) {
        try {
            if (value == null || value.trim().isEmpty()) {
                return defaultValue;
            }

            return Integer.parseInt(value.trim());

        } catch (Exception e) {
            return defaultValue;
        }
    }
}
package vn.edu.husc.library.servlet;

import vn.edu.husc.library.dao.MaintenanceDAO;
import vn.edu.husc.library.model.MaintenanceRecord;
import vn.edu.husc.library.model.User;

import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

public class AdminMaintenanceServlet extends HttpServlet {

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

    private boolean isAdminOrManager(User user) {
        if (user == null || user.getRoleCode() == null) {
            return false;
        }

        return "ADMIN".equalsIgnoreCase(user.getRoleCode())
                || "MANAGER".equalsIgnoreCase(user.getRoleCode());
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        User currentUser = getCurrentUser(request);

        if (!isAdminOrManager(currentUser)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String action = request.getParameter("action");

        if ("form".equalsIgnoreCase(action)
                || "add".equalsIgnoreCase(action)
                || "create".equalsIgnoreCase(action)) {
            showForm(request, response);
            return;
        }

        if ("detail".equalsIgnoreCase(action)
                || "view".equalsIgnoreCase(action)) {
            showDetail(request, response);
            return;
        }

        if ("complete".equalsIgnoreCase(action)
                || "done".equalsIgnoreCase(action)) {
            completeMaintenance(request, response, currentUser);
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

        if (!isAdminOrManager(currentUser)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String action = request.getParameter("action");

        if ("create".equalsIgnoreCase(action)
                || "insert".equalsIgnoreCase(action)) {
            createMaintenance(request, response, currentUser);
            return;
        }

        if ("complete".equalsIgnoreCase(action)
                || "done".equalsIgnoreCase(action)) {
            completeMaintenance(request, response, currentUser);
            return;
        }

        response.sendRedirect(request.getContextPath() + "/admin/maintenance-records");
    }

    private void showList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        String success = (String) session.getAttribute("adminMaintenanceSuccess");
        String error = (String) session.getAttribute("adminMaintenanceError");

        session.removeAttribute("adminMaintenanceSuccess");
        session.removeAttribute("adminMaintenanceError");

        List<MaintenanceRecord> records = maintenanceDAO.getAllMaintenanceRecords();

        request.setAttribute("success", success);
        request.setAttribute("error", error);
        request.setAttribute("equipments", maintenanceDAO.getEquipmentsForMaintenance());
        request.setAttribute("records", records);
        request.setAttribute("maintenanceRecords", records);

        request.getRequestDispatcher("/admin/maintenance-records.jsp").forward(request, response);
    }

    private void showForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int selectedEquipmentId = parseInt(request.getParameter("equipmentId"), 0);

        request.setAttribute("selectedEquipmentId", selectedEquipmentId);
        request.setAttribute("equipments", maintenanceDAO.getEquipmentsForMaintenance());

        request.getRequestDispatcher("/admin/maintenance-record-form.jsp").forward(request, response);
    }

    private void showDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int maintenanceId = parseInt(request.getParameter("id"), 0);

        if (maintenanceId == 0) {
            maintenanceId = parseInt(request.getParameter("maintenanceId"), 0);
        }

        if (maintenanceId <= 0) {
            request.getSession().setAttribute("adminMaintenanceError", "Mã bảo trì không hợp lệ.");
            response.sendRedirect(request.getContextPath() + "/admin/maintenance-records");
            return;
        }

        MaintenanceRecord selectedRecord = null;

        List<MaintenanceRecord> records = maintenanceDAO.getAllMaintenanceRecords();

        if (records != null) {
            for (MaintenanceRecord record : records) {
                if (record != null && record.getMaintenanceId() == maintenanceId) {
                    selectedRecord = record;
                    break;
                }
            }
        }

        if (selectedRecord == null) {
            request.getSession().setAttribute("adminMaintenanceError", "Không tìm thấy bản ghi bảo trì.");
            response.sendRedirect(request.getContextPath() + "/admin/maintenance-records");
            return;
        }

        request.setAttribute("record", selectedRecord);
        request.setAttribute("maintenanceRecord", selectedRecord);

        request.getRequestDispatcher("/admin/maintenance-record-detail.jsp").forward(request, response);
    }

    private void createMaintenance(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws IOException {

        int equipmentId = parseInt(request.getParameter("equipmentId"), 0);
        String issueDescription = request.getParameter("issueDescription");
        String managerNote = request.getParameter("managerNote");

        if (equipmentId <= 0) {
            request.getSession().setAttribute("adminMaintenanceError", "Vui lòng chọn thiết bị cần bảo trì.");
            response.sendRedirect(request.getContextPath() + "/admin/maintenance-records?action=form");
            return;
        }

        if (issueDescription == null || issueDescription.trim().isEmpty()) {
            request.getSession().setAttribute("adminMaintenanceError", "Vui lòng nhập tình trạng cần bảo trì.");
            response.sendRedirect(request.getContextPath() + "/admin/maintenance-records?action=form&equipmentId=" + equipmentId);
            return;
        }

        boolean success = maintenanceDAO.addMaintenanceRecord(
                equipmentId,
                issueDescription,
                managerNote,
                currentUser.getUserId()
        );

        request.getSession().setAttribute(
                success ? "adminMaintenanceSuccess" : "adminMaintenanceError",
                success ? "Đã thêm ghi nhận bảo trì." : "Thêm ghi nhận bảo trì thất bại."
        );

        response.sendRedirect(request.getContextPath() + "/admin/maintenance-records");
    }

    private void completeMaintenance(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws IOException {

        int maintenanceId = parseInt(request.getParameter("maintenanceId"), 0);

        if (maintenanceId == 0) {
            maintenanceId = parseInt(request.getParameter("id"), 0);
        }

        if (maintenanceId <= 0) {
            request.getSession().setAttribute("adminMaintenanceError", "Mã bảo trì không hợp lệ.");
            response.sendRedirect(request.getContextPath() + "/admin/maintenance-records");
            return;
        }

        boolean success = maintenanceDAO.completeMaintenanceRecord(maintenanceId, currentUser.getUserId());

        request.getSession().setAttribute(
                success ? "adminMaintenanceSuccess" : "adminMaintenanceError",
                success ? "Đã hoàn tất bảo trì." : "Hoàn tất bảo trì thất bại."
        );

        response.sendRedirect(request.getContextPath() + "/admin/maintenance-records");
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
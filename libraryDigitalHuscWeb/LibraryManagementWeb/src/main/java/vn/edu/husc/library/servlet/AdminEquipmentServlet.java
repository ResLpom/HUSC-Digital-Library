package vn.edu.husc.library.servlet;

import vn.edu.husc.library.dao.AdminEquipmentDAO;
import vn.edu.husc.library.model.Equipment;
import vn.edu.husc.library.model.User;

import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

public class AdminEquipmentServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private AdminEquipmentDAO adminEquipmentDAO;

    @Override
    public void init() throws ServletException {
        adminEquipmentDAO = new AdminEquipmentDAO();
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

        if (action == null || action.trim().isEmpty()) {
            action = "list";
        }

        if ("view".equalsIgnoreCase(action)
                || "detail".equalsIgnoreCase(action)) {
            viewEquipment(request, response);
            return;
        }

        if ("add".equalsIgnoreCase(action)
                || "form".equalsIgnoreCase(action)
                || "edit".equalsIgnoreCase(action)) {
            showForm(request, response);
            return;
        }

        if ("delete".equalsIgnoreCase(action)
                || "hide".equalsIgnoreCase(action)) {
            deleteEquipment(request, response);
            return;
        }

        listEquipments(request, response);
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

        if ("delete".equalsIgnoreCase(action)
                || "hide".equalsIgnoreCase(action)) {
            deleteEquipment(request, response);
            return;
        }

        saveEquipment(request, response);
    }

    private void listEquipments(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        String success = (String) session.getAttribute("adminEquipmentSuccess");
        String error = (String) session.getAttribute("adminEquipmentError");

        session.removeAttribute("adminEquipmentSuccess");
        session.removeAttribute("adminEquipmentError");

        request.setAttribute("success", success);
        request.setAttribute("error", error);
        request.setAttribute("equipments", adminEquipmentDAO.getAllEquipments());

        request.getRequestDispatcher("/admin/equipments.jsp").forward(request, response);
    }

    private void viewEquipment(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int equipmentId = parseInt(request.getParameter("id"), 0);

        if (equipmentId <= 0) {
            request.getSession().setAttribute("adminEquipmentError", "Mã thiết bị không hợp lệ.");
            response.sendRedirect(request.getContextPath() + "/admin/equipments");
            return;
        }

        Equipment equipment = adminEquipmentDAO.getEquipmentById(equipmentId);

        if (equipment == null) {
            request.getSession().setAttribute("adminEquipmentError", "Không tìm thấy thiết bị.");
            response.sendRedirect(request.getContextPath() + "/admin/equipments");
            return;
        }

        request.setAttribute("equipment", equipment);
        request.getRequestDispatcher("/admin/equipment-detail.jsp").forward(request, response);
    }

    private void showForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int equipmentId = parseInt(request.getParameter("id"), 0);

        if (equipmentId > 0) {
            Equipment equipment = adminEquipmentDAO.getEquipmentById(equipmentId);

            if (equipment == null) {
                request.getSession().setAttribute("adminEquipmentError", "Không tìm thấy thiết bị.");
                response.sendRedirect(request.getContextPath() + "/admin/equipments");
                return;
            }

            request.setAttribute("equipment", equipment);
        }

        request.setAttribute("equipmentTypes", adminEquipmentDAO.getEquipmentTypes());
        request.setAttribute("types", adminEquipmentDAO.getEquipmentTypes());

        request.getRequestDispatcher("/admin/equipment-form.jsp").forward(request, response);
    }

    private void saveEquipment(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        int equipmentId = parseInt(request.getParameter("equipmentId"), 0);

        if (equipmentId == 0) {
            equipmentId = parseInt(request.getParameter("id"), 0);
        }

        int equipmentTypeId = parseInt(request.getParameter("equipmentTypeId"), 0);

        if (equipmentTypeId == 0) {
            equipmentTypeId = parseInt(request.getParameter("typeId"), 0);
        }

        Equipment equipment = new Equipment();

        equipment.setEquipmentId(equipmentId);
        equipment.setEquipmentTypeId(equipmentTypeId);
        equipment.setEquipmentName(request.getParameter("equipmentName"));
        equipment.setCode(request.getParameter("code"));
        equipment.setDescription(request.getParameter("description"));
        equipment.setLocation(request.getParameter("location"));
        equipment.setImagePath(request.getParameter("imagePath"));
        equipment.setValueMoney(parseDouble(request.getParameter("valueMoney"), 0));

        String status = request.getParameter("status");

        if (status == null || status.trim().isEmpty()) {
            status = "AVAILABLE";
        }

        equipment.setStatus(status.trim());

        boolean success;

        if (equipmentId > 0) {
            success = adminEquipmentDAO.updateEquipment(equipment);

            request.getSession().setAttribute(
                    success ? "adminEquipmentSuccess" : "adminEquipmentError",
                    success ? "Đã cập nhật thiết bị." : "Cập nhật thiết bị thất bại."
            );

        } else {
            success = adminEquipmentDAO.insertEquipment(equipment);

            request.getSession().setAttribute(
                    success ? "adminEquipmentSuccess" : "adminEquipmentError",
                    success ? "Đã thêm thiết bị mới." : "Thêm thiết bị thất bại."
            );
        }

        response.sendRedirect(request.getContextPath() + "/admin/equipments");
    }

    private void deleteEquipment(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        int equipmentId = parseInt(request.getParameter("id"), 0);

        if (equipmentId == 0) {
            equipmentId = parseInt(request.getParameter("equipmentId"), 0);
        }

        if (equipmentId <= 0) {
            request.getSession().setAttribute("adminEquipmentError", "Mã thiết bị không hợp lệ.");
            response.sendRedirect(request.getContextPath() + "/admin/equipments");
            return;
        }

        boolean success = adminEquipmentDAO.hideEquipment(equipmentId);

        request.getSession().setAttribute(
                success ? "adminEquipmentSuccess" : "adminEquipmentError",
                success ? "Đã xóa thiết bị khỏi danh sách hiển thị." : "Không thể xóa thiết bị."
        );

        response.sendRedirect(request.getContextPath() + "/admin/equipments");
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

    private double parseDouble(String value, double defaultValue) {
        try {
            if (value == null || value.trim().isEmpty()) {
                return defaultValue;
            }

            return Double.parseDouble(value.trim());
        } catch (Exception e) {
            return defaultValue;
        }
    }
}
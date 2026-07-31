package vn.edu.husc.library.servlet;

import vn.edu.husc.library.dao.BorrowRequestDAO;
import vn.edu.husc.library.dao.EquipmentDAO;
import vn.edu.husc.library.dao.MaintenanceDAO;
import vn.edu.husc.library.model.BorrowRequest;
import vn.edu.husc.library.model.Equipment;
import vn.edu.husc.library.model.MaintenanceRecord;

import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class ManagerServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private EquipmentDAO equipmentDAO;
    private BorrowRequestDAO borrowRequestDAO;
    private MaintenanceDAO maintenanceDAO;

    @Override
    public void init() throws ServletException {
        equipmentDAO = new EquipmentDAO();
        borrowRequestDAO = new BorrowRequestDAO();
        maintenanceDAO = new MaintenanceDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String path = request.getServletPath();

        if ("/manager/dashboard".equals(path)) {
            showDashboard(request, response);
            return;
        }

        if ("/manager/equipments".equals(path)) {
            showEquipments(request, response);
            return;
        }

        if ("/manager/borrow-requests".equals(path)) {
            showBorrowRequests(request, response);
            return;
        }

        if ("/manager/return-equipment".equals(path)) {
            showReturnEquipment(request, response);
            return;
        }

        if ("/manager/maintenance-records".equals(path)) {
            showMaintenance(request, response);
            return;
        }

        if ("/manager/reports".equals(path)) {
            showReports(request, response);
            return;
        }

        response.sendRedirect(request.getContextPath() + "/manager/dashboard");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");

        if ("updateEquipmentStatus".equalsIgnoreCase(action)) {
            updateEquipmentStatus(request, response);
            return;
        }

        if ("approve".equalsIgnoreCase(action)
                || "reject".equalsIgnoreCase(action)
                || "handover".equalsIgnoreCase(action)) {
            processBorrowRequest(request, response);
            return;
        }

        if ("return".equalsIgnoreCase(action)) {
            processReturnEquipment(request, response);
            return;
        }

        if ("createMaintenance".equalsIgnoreCase(action)) {
            createMaintenance(request, response);
            return;
        }

        if ("completeMaintenance".equalsIgnoreCase(action)) {
            completeMaintenance(request, response);
            return;
        }

        request.getSession().setAttribute("managerError", "Thao tác không hợp lệ.");
        response.sendRedirect(request.getContextPath() + "/manager/dashboard");
    }

    private void showDashboard(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Equipment> equipments = equipmentDAO.getAllEquipments();
        List<BorrowRequest> requests = borrowRequestDAO.getAllRequests();

        request.setAttribute("totalEquipments", equipments.size());
        request.setAttribute("totalRequests", requests.size());
        request.setAttribute("pendingRequests", countByStatus(requests, "PENDING"));
        request.setAttribute("borrowingRequests", countBorrowing(requests));

        request.getRequestDispatcher("/manager/dashboard.jsp").forward(request, response);
    }

    private void showEquipments(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String keyword = request.getParameter("keyword");

        if (keyword == null) {
            keyword = "";
        }

        List<Equipment> equipments = equipmentDAO.searchEquipments(keyword);

        request.setAttribute("equipments", equipments);
        request.setAttribute("keyword", keyword);

        request.getRequestDispatcher("/manager/equipments.jsp").forward(request, response);
    }

    private void showBorrowRequests(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        String success = (String) session.getAttribute("managerSuccess");
        String error = (String) session.getAttribute("managerError");

        session.removeAttribute("managerSuccess");
        session.removeAttribute("managerError");

        List<BorrowRequest> requests = borrowRequestDAO.getAllRequests();

        request.setAttribute("success", success);
        request.setAttribute("error", error);
        request.setAttribute("requests", requests);
        request.setAttribute("borrowRequests", requests);

        request.getRequestDispatcher("/manager/borrow-requests.jsp").forward(request, response);
    }

    private void showReturnEquipment(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        String success = (String) session.getAttribute("managerSuccess");
        String error = (String) session.getAttribute("managerError");

        session.removeAttribute("managerSuccess");
        session.removeAttribute("managerError");

        List<BorrowRequest> requests = borrowRequestDAO.getAllRequests();
        List<BorrowRequest> borrowingList = new ArrayList<BorrowRequest>();

        for (BorrowRequest item : requests) {
            String status = item.getStatus();

            if ("APPROVED".equalsIgnoreCase(status)
                    || "BORROWING".equalsIgnoreCase(status)
                    || "BORROWED".equalsIgnoreCase(status)) {
                borrowingList.add(item);
            }
        }

        request.setAttribute("success", success);
        request.setAttribute("error", error);
        request.setAttribute("requests", borrowingList);

        request.getRequestDispatcher("/manager/return-equipment.jsp").forward(request, response);
    }

    private void showMaintenance(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        String success = (String) session.getAttribute("managerSuccess");
        String error = (String) session.getAttribute("managerError");

        session.removeAttribute("managerSuccess");
        session.removeAttribute("managerError");

        List<Equipment> equipments = equipmentDAO.getAllEquipments();
        List<MaintenanceRecord> records = maintenanceDAO.getAllMaintenanceRecords();

        request.setAttribute("success", success);
        request.setAttribute("error", error);
        request.setAttribute("equipments", equipments);
        request.setAttribute("records", records);

        request.getRequestDispatcher("/manager/maintenance-records.jsp").forward(request, response);
    }

    private void showReports(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Equipment> equipments = equipmentDAO.getAllEquipments();
        List<BorrowRequest> requests = borrowRequestDAO.getAllRequests();

        request.setAttribute("totalEquipments", equipments.size());
        request.setAttribute("totalRequests", requests.size());
        request.setAttribute("pendingRequests", countByStatus(requests, "PENDING"));
        request.setAttribute("approvedRequests", countByStatus(requests, "APPROVED"));
        request.setAttribute("borrowingRequests", countBorrowing(requests));
        request.setAttribute("rejectedRequests", countByStatus(requests, "REJECTED"));
        request.setAttribute("returnedRequests", countByStatus(requests, "RETURNED"));

        request.getRequestDispatcher("/manager/reports.jsp").forward(request, response);
    }

    private void updateEquipmentStatus(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        int equipmentId;

        try {
            equipmentId = Integer.parseInt(request.getParameter("equipmentId"));
        } catch (Exception e) {
            request.getSession().setAttribute("managerError", "Mã thiết bị không hợp lệ.");
            response.sendRedirect(request.getContextPath() + "/manager/equipments");
            return;
        }

        String status = request.getParameter("status");

        boolean success = equipmentDAO.updateEquipmentStatus(equipmentId, status);

        request.getSession().setAttribute(
                success ? "managerSuccess" : "managerError",
                success ? "Đã cập nhật trạng thái thiết bị." : "Cập nhật trạng thái thiết bị thất bại."
        );

        response.sendRedirect(request.getContextPath() + "/manager/equipments");
    }

    private void processBorrowRequest(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String action = request.getParameter("action");
        String managerNote = request.getParameter("managerNote");

        if (managerNote == null) {
            managerNote = "";
        }

        int requestId;

        try {
            requestId = Integer.parseInt(request.getParameter("requestId"));
        } catch (Exception e) {
            request.getSession().setAttribute("managerError", "Mã yêu cầu không hợp lệ.");
            response.sendRedirect(request.getContextPath() + "/manager/borrow-requests");
            return;
        }

        boolean success = false;

        if ("approve".equalsIgnoreCase(action)) {
            success = borrowRequestDAO.approveRequest(requestId, managerNote);
            request.getSession().setAttribute(
                    success ? "managerSuccess" : "managerError",
                    success ? "Đã duyệt yêu cầu mượn." : "Duyệt yêu cầu thất bại."
            );
        } else if ("reject".equalsIgnoreCase(action)) {
            success = borrowRequestDAO.rejectRequest(requestId, managerNote);
            request.getSession().setAttribute(
                    success ? "managerSuccess" : "managerError",
                    success ? "Đã từ chối yêu cầu mượn." : "Từ chối yêu cầu thất bại."
            );
        } else if ("handover".equalsIgnoreCase(action)) {
            success = borrowRequestDAO.handoverRequest(requestId);
            request.getSession().setAttribute(
                    success ? "managerSuccess" : "managerError",
                    success ? "Đã bàn giao thiết bị cho người mượn." : "Bàn giao thiết bị thất bại."
            );
        }

        response.sendRedirect(request.getContextPath() + "/manager/borrow-requests");
    }

    private void processReturnEquipment(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String managerNote = request.getParameter("managerNote");

        if (managerNote == null || managerNote.trim().isEmpty()) {
            managerNote = "Manager đã xác nhận trả thiết bị.";
        }

        int requestId;

        try {
            requestId = Integer.parseInt(request.getParameter("requestId"));
        } catch (Exception e) {
            request.getSession().setAttribute("managerError", "Mã yêu cầu không hợp lệ.");
            response.sendRedirect(request.getContextPath() + "/manager/return-equipment");
            return;
        }

        boolean success = borrowRequestDAO.returnRequest(requestId, managerNote);

        request.getSession().setAttribute(
                success ? "managerSuccess" : "managerError",
                success ? "Đã xác nhận trả thiết bị." : "Xác nhận trả thiết bị thất bại."
        );

        response.sendRedirect(request.getContextPath() + "/manager/return-equipment");
    }

    private void createMaintenance(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        int equipmentId;

        try {
            equipmentId = Integer.parseInt(request.getParameter("equipmentId"));
        } catch (Exception e) {
            request.getSession().setAttribute("managerError", "Mã thiết bị không hợp lệ.");
            response.sendRedirect(request.getContextPath() + "/manager/maintenance-records");
            return;
        }

        String issueDescription = request.getParameter("issueDescription");
        String managerNote = request.getParameter("managerNote");

        if (issueDescription == null || issueDescription.trim().isEmpty()) {
            request.getSession().setAttribute("managerError", "Vui lòng nhập tình trạng cần bảo trì.");
            response.sendRedirect(request.getContextPath() + "/manager/maintenance-records");
            return;
        }

        if (managerNote == null) {
            managerNote = "";
        }

        boolean success = maintenanceDAO.createMaintenanceRecord(
                equipmentId,
                issueDescription.trim(),
                managerNote.trim()
        );

        request.getSession().setAttribute(
                success ? "managerSuccess" : "managerError",
                success ? "Đã thêm ghi nhận bảo trì." : "Thêm ghi nhận bảo trì thất bại."
        );

        response.sendRedirect(request.getContextPath() + "/manager/maintenance-records");
    }

    private void completeMaintenance(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        int maintenanceId;

        try {
            maintenanceId = Integer.parseInt(request.getParameter("maintenanceId"));
        } catch (Exception e) {
            request.getSession().setAttribute("managerError", "Mã bảo trì không hợp lệ.");
            response.sendRedirect(request.getContextPath() + "/manager/maintenance-records");
            return;
        }

        boolean success = maintenanceDAO.finishMaintenance(maintenanceId);

        request.getSession().setAttribute(
                success ? "managerSuccess" : "managerError",
                success ? "Đã hoàn tất bảo trì và chuyển thiết bị về sẵn sàng." : "Hoàn tất bảo trì thất bại."
        );

        response.sendRedirect(request.getContextPath() + "/manager/maintenance-records");
    }

    private int countByStatus(List<BorrowRequest> list, String status) {
        int count = 0;

        if (list == null) {
            return 0;
        }

        for (BorrowRequest item : list) {
            if (item.getStatus() != null && status.equalsIgnoreCase(item.getStatus())) {
                count++;
            }
        }

        return count;
    }

    private int countBorrowing(List<BorrowRequest> list) {
        int count = 0;

        if (list == null) {
            return 0;
        }

        for (BorrowRequest item : list) {
            String status = item.getStatus();

            if ("APPROVED".equalsIgnoreCase(status)
                    || "BORROWING".equalsIgnoreCase(status)
                    || "BORROWED".equalsIgnoreCase(status)) {
                count++;
            }
        }

        return count;
    }
}
package vn.edu.husc.library.servlet;

import vn.edu.husc.library.config.DBConnection;
import vn.edu.husc.library.dao.ReturnDAO;
import vn.edu.husc.library.model.BorrowRequest;
import vn.edu.husc.library.model.User;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class AdminReturnServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private ReturnDAO returnDAO;

    @Override
    public void init() throws ServletException {
        returnDAO = new ReturnDAO();
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
        if (user == null) {
            return false;
        }

        String roleCode = user.getRoleCode();

        return "MANAGER".equalsIgnoreCase(roleCode)
                || "ADMIN".equalsIgnoreCase(roleCode);
    }

    private List<BorrowRequest> getBorrowingRequests() {
        List<BorrowRequest> list = new ArrayList<>();

        String sql =
                "SELECT br.request_id, br.user_id, br.equipment_id, " +
                "       br.borrow_date, br.expected_return_date, br.purpose, " +
                "       br.status, br.manager_note, br.created_at, " +
                "       u.full_name, " +
                "       e.code AS equipment_code, e.equipment_name, " +
                "       et.type_name " +
                "FROM borrow_requests br " +
                "JOIN users u ON br.user_id = u.user_id " +
                "JOIN equipment e ON br.equipment_id = e.equipment_id " +
                "LEFT JOIN equipment_types et ON e.equipment_type_id = et.equipment_type_id " +
                "WHERE br.status = 'BORROWING' " +
                "ORDER BY br.borrow_date DESC, br.request_id DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                BorrowRequest br = new BorrowRequest();

                br.setRequestId(rs.getInt("request_id"));
                br.setUserId(rs.getInt("user_id"));
                br.setEquipmentId(rs.getInt("equipment_id"));

                br.setBorrowDate(rs.getDate("borrow_date"));
                br.setExpectedReturnDate(rs.getDate("expected_return_date"));

                br.setPurpose(rs.getString("purpose"));
                br.setStatus(rs.getString("status"));
                br.setStatus("Đang mượn");
                br.setManagerNote(rs.getString("manager_note"));
                br.setCreatedAt(rs.getTimestamp("created_at"));

                br.setFullName(rs.getString("full_name"));
                br.setEquipmentCode(rs.getString("equipment_code"));
                br.setEquipmentName(rs.getString("equipment_name"));
                br.setTypeName(rs.getString("type_name"));

                list.add(br);
            }

        } catch (Exception e) {
            System.out.println("Lỗi lấy danh sách yêu cầu đang mượn!");
            e.printStackTrace();
        }

        return list;
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

        List<BorrowRequest> borrowings = getBorrowingRequests();

        request.setAttribute("borrowings", borrowings);

        request.getRequestDispatcher("/admin/return-equipment.jsp").forward(request, response);
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

        try {
            String requestIdParam = request.getParameter("requestId");

            if (requestIdParam == null || requestIdParam.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/admin/return-equipment");
                return;
            }

            int requestId = Integer.parseInt(requestIdParam);
            int managerId = currentUser.getUserId();

            String conditionAfter = request.getParameter("conditionAfter");
            String note = request.getParameter("note");
            String resultStatus = request.getParameter("resultStatus");
            String issueDescription = request.getParameter("issueDescription");

            if (conditionAfter == null) {
                conditionAfter = "";
            }

            if (note == null) {
                note = "";
            }

            if (issueDescription == null) {
                issueDescription = "";
            }

            if (resultStatus == null) {
                resultStatus = "";
            }

            resultStatus = resultStatus.trim();

            if (!"AVAILABLE".equalsIgnoreCase(resultStatus)
                    && !"MAINTENANCE".equalsIgnoreCase(resultStatus)
                    && !"LOST".equalsIgnoreCase(resultStatus)) {

                response.sendRedirect(request.getContextPath() + "/admin/return-equipment");
                return;
            }

            returnDAO.confirmReturn(
                    requestId,
                    managerId,
                    conditionAfter.trim(),
                    note.trim(),
                    resultStatus,
                    issueDescription.trim()
            );

        } catch (Exception e) {
            System.out.println("Lỗi xác nhận trả thiết bị!");
            e.printStackTrace();
        }

        response.sendRedirect(request.getContextPath() + "/admin/return-equipment");
    }
}
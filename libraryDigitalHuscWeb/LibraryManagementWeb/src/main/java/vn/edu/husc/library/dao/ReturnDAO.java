package vn.edu.husc.library.dao;
import vn.edu.husc.library.config.DBConnection;
import vn.edu.husc.library.model.BorrowRequest;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class ReturnDAO {

    public boolean confirmReturn(int requestId, int managerId, String conditionAfter,
                                 String note, String resultStatus, String issueDescription) {

        String getRequestSql = "SELECT equipment_id, expected_return_date "
                + "FROM borrow_requests "
                + "WHERE request_id = ? AND status = 'BORROWING'";

        String insertReturnSql = "INSERT INTO return_records "
                + "(request_id, manager_id, return_date, condition_after, late_days, note) "
                + "VALUES (?, ?, GETDATE(), ?, "
                + "CASE WHEN DATEDIFF(day, ?, GETDATE()) > 0 THEN DATEDIFF(day, ?, GETDATE()) ELSE 0 END, ?)";

        String updateRequestSql = "UPDATE borrow_requests "
                + "SET status = 'RETURNED' "
                + "WHERE request_id = ? AND status = 'BORROWING'";

        String updateEquipmentSql = "UPDATE equipment "
                + "SET status = ? "
                + "WHERE equipment_id = ?";

        String insertMaintenanceSql = "INSERT INTO maintenance_records "
                + "(equipment_id, request_id, manager_id, issue_description, maintenance_status) "
                + "VALUES (?, ?, ?, ?, 'PENDING')";

        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            int equipmentId = -1;
            java.sql.Date expectedReturnDate = null;

            try (PreparedStatement ps = conn.prepareStatement(getRequestSql)) {
                ps.setInt(1, requestId);

                ResultSet rs = ps.executeQuery();

                if (rs.next()) {
                    equipmentId = rs.getInt("equipment_id");
                    expectedReturnDate = rs.getDate("expected_return_date");
                } else {
                    conn.rollback();
                    return false;
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(insertReturnSql)) {
                ps.setInt(1, requestId);
                ps.setInt(2, managerId);
                ps.setString(3, conditionAfter);
                ps.setDate(4, expectedReturnDate);
                ps.setDate(5, expectedReturnDate);
                ps.setString(6, note);

                if (ps.executeUpdate() <= 0) {
                    conn.rollback();
                    return false;
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(updateRequestSql)) {
                ps.setInt(1, requestId);

                if (ps.executeUpdate() <= 0) {
                    conn.rollback();
                    return false;
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(updateEquipmentSql)) {
                ps.setString(1, resultStatus);
                ps.setInt(2, equipmentId);

                if (ps.executeUpdate() <= 0) {
                    conn.rollback();
                    return false;
                }
            }

            if ("MAINTENANCE".equalsIgnoreCase(resultStatus)) {
                try (PreparedStatement ps = conn.prepareStatement(insertMaintenanceSql)) {
                    ps.setInt(1, equipmentId);
                    ps.setInt(2, requestId);
                    ps.setInt(3, managerId);
                    ps.setString(4, issueDescription);

                    if (ps.executeUpdate() <= 0) {
                        conn.rollback();
                        return false;
                    }
                }
            }

            conn.commit();
            return true;

        } catch (Exception e) {
            System.out.println("Lỗi xác nhận trả thiết bị!");
            e.printStackTrace();

            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (Exception ex) {
                ex.printStackTrace();
            }

        } finally {
            try {
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        return false;
    }
    public List<BorrowRequest> getBorrowingRequests() {
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
                "JOIN equipments e ON br.equipment_id = e.equipment_id " +
                "LEFT JOIN equipment_types et ON e.type_id = et.type_id " +
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
                br.setManagerNote(rs.getString("manager_note"));
                br.setCreatedAt(rs.getTimestamp("created_at"));

                br.setFullName(rs.getString("full_name"));
                br.setEquipmentCode(rs.getString("equipment_code"));
                br.setEquipmentName(rs.getString("equipment_name"));
                br.setTypeName(rs.getString("type_name"));

                br.setStatus("Đang mượn");

                list.add(br);
            }

        } catch (Exception e) {
            System.out.println("Lỗi lấy danh sách thiết bị đang mượn!");
            e.printStackTrace();
        }

        return list;
    }
}
package vn.edu.husc.library.dao;

import vn.edu.husc.library.config.DBConnection;
import vn.edu.husc.library.model.BorrowRequest;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Date;
import java.util.ArrayList;
import java.util.List;

public class BorrowRequestDAO {

    public boolean createRequest(int userId, int equipmentId, Date borrowDate,
                                 Date expectedReturnDate, String purpose) {

        String sql = "INSERT INTO borrow_requests "
                + "(user_id, equipment_id, borrow_date, expected_return_date, purpose, status) "
                + "VALUES (?, ?, ?, ?, ?, 'PENDING')";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setInt(1, userId);
            ps.setInt(2, equipmentId);
            ps.setDate(3, borrowDate);
            ps.setDate(4, expectedReturnDate);
            ps.setString(5, purpose);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            System.out.println("Lỗi tạo yêu cầu mượn thiết bị!");
            e.printStackTrace();
        }

        return false;
    }

    public boolean hasPendingRequest(int userId, int equipmentId) {
        String sql = "SELECT COUNT(*) AS total "
                + "FROM borrow_requests "
                + "WHERE user_id = ? "
                + "AND equipment_id = ? "
                + "AND status IN ('PENDING', 'APPROVED', 'BORROWING', 'BORROWED')";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setInt(1, userId);
            ps.setInt(2, equipmentId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt("total") > 0;
            }

        } catch (Exception e) {
            System.out.println("Lỗi kiểm tra yêu cầu mượn tồn tại!");
            e.printStackTrace();
        }

        return false;
    }

    public List<BorrowRequest> getRequestsByUserId(int userId) {
        List<BorrowRequest> list = new ArrayList<BorrowRequest>();

        String sql = "SELECT "
                + "br.request_id, "
                + "br.user_id, "
                + "br.equipment_id, "
                + "br.borrow_date, "
                + "br.expected_return_date, "
                + "br.purpose, "
                + "br.status, "
                + "br.manager_note, "
                + "br.created_at, "
                + "u.full_name, "
                + "e.equipment_name, "
                + "e.code, "
                + "et.type_name "
                + "FROM borrow_requests br "
                + "JOIN users u ON br.user_id = u.user_id "
                + "JOIN equipment e ON br.equipment_id = e.equipment_id "
                + "JOIN equipment_types et ON e.equipment_type_id = et.equipment_type_id "
                + "WHERE br.user_id = ? "
                + "ORDER BY br.request_id DESC";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setInt(1, userId);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                BorrowRequest br = mapBorrowRequest(rs);
                list.add(br);
            }

        } catch (Exception e) {
            System.out.println("Lỗi lấy lịch sử yêu cầu mượn!");
            e.printStackTrace();
        }

        return list;
    }

    public List<BorrowRequest> getAllRequests() {
        List<BorrowRequest> list = new ArrayList<BorrowRequest>();

        String sql = "SELECT "
                + "br.request_id, "
                + "br.user_id, "
                + "br.equipment_id, "
                + "br.borrow_date, "
                + "br.expected_return_date, "
                + "br.purpose, "
                + "br.status, "
                + "br.manager_note, "
                + "br.created_at, "
                + "u.full_name, "
                + "e.equipment_name, "
                + "e.code, "
                + "et.type_name "
                + "FROM borrow_requests br "
                + "JOIN users u ON br.user_id = u.user_id "
                + "JOIN equipment e ON br.equipment_id = e.equipment_id "
                + "JOIN equipment_types et ON e.equipment_type_id = et.equipment_type_id "
                + "ORDER BY br.request_id DESC";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                BorrowRequest br = mapBorrowRequest(rs);
                list.add(br);
            }

        } catch (Exception e) {
            System.out.println("Lỗi lấy danh sách yêu cầu mượn!");
            e.printStackTrace();
        }

        return list;
    }

    private BorrowRequest mapBorrowRequest(ResultSet rs) throws Exception {
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
        br.setEquipmentName(rs.getString("equipment_name"));
        br.setEquipmentCode(rs.getString("code"));
        br.setTypeName(rs.getString("type_name"));

        return br;
    }

    public boolean approveRequest(int requestId, String managerNote) {
        String sql = "UPDATE borrow_requests "
                + "SET status = 'APPROVED', manager_note = ? "
                + "WHERE request_id = ? AND status = 'PENDING'";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setString(1, managerNote);
            ps.setInt(2, requestId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            System.out.println("Lỗi duyệt yêu cầu mượn!");
            e.printStackTrace();
        }

        return false;
    }

    public boolean rejectRequest(int requestId, String managerNote) {
        String sql = "UPDATE borrow_requests "
                + "SET status = 'REJECTED', manager_note = ? "
                + "WHERE request_id = ? AND status = 'PENDING'";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setString(1, managerNote);
            ps.setInt(2, requestId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            System.out.println("Lỗi từ chối yêu cầu mượn!");
            e.printStackTrace();
        }

        return false;
    }

    public boolean handoverRequest(int requestId) {
        String getEquipmentSql = "SELECT equipment_id FROM borrow_requests "
                + "WHERE request_id = ? AND status = 'APPROVED'";

        String updateRequestSql = "UPDATE borrow_requests "
                + "SET status = 'BORROWING' "
                + "WHERE request_id = ? AND status = 'APPROVED'";

        String updateEquipmentSql = "UPDATE equipment "
                + "SET status = 'BORROWED' "
                + "WHERE equipment_id = ? AND status = 'AVAILABLE'";

        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            int equipmentId = -1;

            try (PreparedStatement ps = conn.prepareStatement(getEquipmentSql)) {
                ps.setInt(1, requestId);

                ResultSet rs = ps.executeQuery();

                if (rs.next()) {
                    equipmentId = rs.getInt("equipment_id");
                } else {
                    conn.rollback();
                    return false;
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(updateEquipmentSql)) {
                ps.setInt(1, equipmentId);

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

            conn.commit();
            return true;

        } catch (Exception e) {
            System.out.println("Lỗi bàn giao thiết bị!");
            e.printStackTrace();

            try {
                if (conn != null) conn.rollback();
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

    public boolean returnRequest(int requestId, String managerNote) {
        String getEquipmentSql = "SELECT equipment_id FROM borrow_requests "
                + "WHERE request_id = ? "
                + "AND status IN ('BORROWING', 'BORROWED')";

        String updateRequestSql = "UPDATE borrow_requests "
                + "SET status = 'RETURNED', manager_note = ? "
                + "WHERE request_id = ? "
                + "AND status IN ('BORROWING', 'BORROWED')";

        String updateEquipmentSql = "UPDATE equipment "
                + "SET status = 'AVAILABLE' "
                + "WHERE equipment_id = ?";

        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            int equipmentId = -1;

            try (PreparedStatement ps = conn.prepareStatement(getEquipmentSql)) {
                ps.setInt(1, requestId);

                ResultSet rs = ps.executeQuery();

                if (rs.next()) {
                    equipmentId = rs.getInt("equipment_id");
                } else {
                    conn.rollback();
                    return false;
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(updateRequestSql)) {
                ps.setString(1, managerNote);
                ps.setInt(2, requestId);

                if (ps.executeUpdate() <= 0) {
                    conn.rollback();
                    return false;
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(updateEquipmentSql)) {
                ps.setInt(1, equipmentId);

                if (ps.executeUpdate() <= 0) {
                    conn.rollback();
                    return false;
                }
            }

            conn.commit();
            return true;

        } catch (Exception e) {
            System.out.println("Lỗi xác nhận trả thiết bị!");
            e.printStackTrace();

            try {
                if (conn != null) conn.rollback();
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
}
package vn.edu.husc.library.dao;

import vn.edu.husc.library.config.DBConnection;
import vn.edu.husc.library.model.RegistrationRequest;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class RegistrationRequestDAO {

    public int countPendingRequests() {
        String sql = "SELECT COUNT(*) AS total "
                + "FROM users "
                + "WHERE status = 'PENDING' "
                + "AND deleted_at IS NULL";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()
        ) {
            if (rs.next()) {
                return rs.getInt("total");
            }

        } catch (Exception e) {
            System.out.println("Lỗi đếm tài khoản chờ duyệt!");
            e.printStackTrace();
        }

        return 0;
    }

    public List<RegistrationRequest> getPendingRequests() {
        List<RegistrationRequest> list = new ArrayList<>();

        String sql = "SELECT "
                + "user_id, username, full_name, email, student_code, phone, "
                + "status, reject_reason, registration_note, created_at, verified_at, verified_by "
                + "FROM users "
                + "WHERE status = 'PENDING' "
                + "AND deleted_at IS NULL "
                + "ORDER BY created_at DESC, user_id DESC";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()
        ) {
            while (rs.next()) {
                list.add(map(rs));
            }

        } catch (Exception e) {
            System.out.println("Lỗi lấy danh sách đăng ký chờ duyệt!");
            e.printStackTrace();
        }

        return list;
    }

    public List<RegistrationRequest> getRecentRequests() {
        List<RegistrationRequest> list = new ArrayList<>();

        String sql = "SELECT TOP 50 "
                + "user_id, username, full_name, email, student_code, phone, "
                + "status, reject_reason, registration_note, created_at, verified_at, verified_by "
                + "FROM users "
                + "WHERE status IN ('PENDING', 'ACTIVE', 'REJECTED') "
                + "AND deleted_at IS NULL "
                + "ORDER BY created_at DESC, user_id DESC";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()
        ) {
            while (rs.next()) {
                list.add(map(rs));
            }

        } catch (Exception e) {
            System.out.println("Lỗi lấy đăng ký gần đây!");
            e.printStackTrace();
        }

        return list;
    }

    public RegistrationRequest getRequestById(int userId) {
        String sql = "SELECT "
                + "user_id, username, full_name, email, student_code, phone, "
                + "status, reject_reason, registration_note, created_at, verified_at, verified_by "
                + "FROM users "
                + "WHERE user_id = ? "
                + "AND deleted_at IS NULL";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return map(rs);
                }
            }

        } catch (Exception e) {
            System.out.println("Lỗi lấy chi tiết đăng ký!");
            e.printStackTrace();
        }

        return null;
    }

    public boolean existsEmailOrStudentCode(String email, String studentCode) {
        String sql = "SELECT TOP 1 user_id "
                + "FROM users "
                + "WHERE deleted_at IS NULL "
                + "AND (email = ? OR student_code = ?)";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setString(1, email);
            ps.setString(2, studentCode);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }

        } catch (Exception e) {
            System.out.println("Lỗi kiểm tra email/mã sinh viên!");
            e.printStackTrace();
        }

        return false;
    }

    public int getMemberRoleId() {
        String sql = "SELECT TOP 1 role_id "
                + "FROM roles "
                + "WHERE role_code IN ('MEMBER', 'STUDENT', 'USER') "
                + "ORDER BY CASE "
                + "WHEN role_code = 'MEMBER' THEN 1 "
                + "WHEN role_code = 'STUDENT' THEN 2 "
                + "ELSE 3 END";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()
        ) {
            if (rs.next()) {
                return rs.getInt("role_id");
            }

        } catch (Exception e) {
            System.out.println("Không lấy được role thành viên, dùng role_id = 3.");
            e.printStackTrace();
        }

        return 3;
    }

    public boolean createPendingUser(String fullName,
            String studentCode,
            String email,
            String password,
            String phone,
            String address,
            String registrationNote) {

int roleId = getMemberRoleId();
String username = studentCode;

String sql = "INSERT INTO users "
+ "(role_id, full_name, email, password, phone, address, status, created_at, "
+ "username, student_code, registration_note) "
+ "VALUES (?, ?, ?, ?, ?, ?, 'PENDING', GETDATE(), ?, ?, ?)";

try (
Connection conn = DBConnection.getConnection();
PreparedStatement ps = conn.prepareStatement(sql)
) {
ps.setInt(1, roleId);
ps.setString(2, fullName);
ps.setString(3, email);
ps.setString(4, password);
ps.setString(5, phone);
ps.setString(6, address);
ps.setString(7, username);
ps.setString(8, studentCode);
ps.setString(9, registrationNote);

return ps.executeUpdate() > 0;

} catch (Exception e) {
System.out.println("Lỗi tạo tài khoản chờ duyệt!");
e.printStackTrace();
}

return false;
}

    public boolean approveRequest(int userId, int adminId) {
        String sql = "UPDATE users "
                + "SET status = 'ACTIVE', "
                + "reject_reason = NULL, "
                + "verified_at = GETDATE(), "
                + "verified_by = ? "
                + "WHERE user_id = ? "
                + "AND status = 'PENDING'";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setInt(1, adminId);
            ps.setInt(2, userId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            System.out.println("Lỗi duyệt tài khoản!");
            e.printStackTrace();
        }

        return false;
    }

    public boolean rejectRequest(int userId, int adminId, String reason) {
        if (reason == null || reason.trim().isEmpty()) {
            reason = "Thông tin đăng ký không hợp lệ hoặc chưa đủ cơ sở xác thực.";
        }

        String sql = "UPDATE users "
                + "SET status = 'REJECTED', "
                + "reject_reason = ?, "
                + "verified_at = GETDATE(), "
                + "verified_by = ? "
                + "WHERE user_id = ? "
                + "AND status = 'PENDING'";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setString(1, reason.trim());
            ps.setInt(2, adminId);
            ps.setInt(3, userId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            System.out.println("Lỗi từ chối tài khoản!");
            e.printStackTrace();
        }

        return false;
    }

    private RegistrationRequest map(ResultSet rs) throws Exception {
        RegistrationRequest request = new RegistrationRequest();

        request.setUserId(rs.getInt("user_id"));
        request.setUsername(rs.getString("username"));
        request.setFullName(rs.getString("full_name"));
        request.setEmail(rs.getString("email"));
        request.setStudentCode(rs.getString("student_code"));
        request.setPhone(rs.getString("phone"));
        request.setStatus(rs.getString("status"));
        request.setRejectReason(rs.getString("reject_reason"));
        request.setRegistrationNote(rs.getString("registration_note"));
        request.setCreatedAt(rs.getTimestamp("created_at"));
        request.setVerifiedAt(rs.getTimestamp("verified_at"));
        request.setVerifiedBy(rs.getInt("verified_by"));

        return request;
    }
}
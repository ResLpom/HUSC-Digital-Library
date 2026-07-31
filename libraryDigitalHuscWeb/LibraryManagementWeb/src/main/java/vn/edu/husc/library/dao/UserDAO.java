package vn.edu.husc.library.dao;

import vn.edu.husc.library.config.DBConnection;
import vn.edu.husc.library.model.User;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class UserDAO {

    private boolean columnExists(Connection conn, String tableName, String columnName) {
        String sql = "SELECT COUNT(*) AS total "
                + "FROM INFORMATION_SCHEMA.COLUMNS "
                + "WHERE TABLE_NAME = ? AND COLUMN_NAME = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, tableName);
            ps.setString(2, columnName);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt("total") > 0;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    private String getPasswordColumn(Connection conn) {
        if (columnExists(conn, "users", "password")) {
            return "password";
        }

        if (columnExists(conn, "users", "password_hash")) {
            return "password_hash";
        }

        return "password";
    }

    private User mapUser(ResultSet rs) throws Exception {
        User user = new User();

        user.setUserId(rs.getInt("user_id"));
        user.setRoleId(rs.getInt("role_id"));
        user.setUsername(rs.getString("username"));
        user.setFullName(rs.getString("full_name"));
        user.setEmail(rs.getString("email"));
        user.setPhone(rs.getString("phone"));
        user.setStatus(rs.getString("status"));
        user.setCreatedAt(rs.getTimestamp("created_at"));
        user.setRoleCode(rs.getString("role_code"));
        user.setRoleName(rs.getString("role_name"));

        return user;
    }

    public User login(String account, String password) {
        if (account == null || password == null) {
            return null;
        }

        account = account.trim();
        password = password.trim();

        if (account.isEmpty() || password.isEmpty()) {
            return null;
        }

        try (Connection conn = DBConnection.getConnection()) {
            String passwordColumn = getPasswordColumn(conn);

            String sql = "SELECT "
                    + "u.user_id, "
                    + "u.role_id, "
                    + "ISNULL(u.username, u.email) AS username, "
                    + "u.full_name, "
                    + "u.email, "
                    + "u.phone, "
                    + "ISNULL(u.status, 'ACTIVE') AS status, "
                    + "u.created_at, "
                    + "ISNULL(r.role_code, 'MEMBER') AS role_code, "
                    + "ISNULL(r.role_name, N'Thành viên') AS role_name "
                    + "FROM users u "
                    + "LEFT JOIN roles r ON u.role_id = r.role_id "
                    + "WHERE u.deleted_at IS NULL "
                    + "AND (u.username = ? OR u.email = ? OR u.student_code = ?) "
                    + "AND u." + passwordColumn + " = ?";

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, account);
                ps.setString(2, account);
                ps.setString(3, account);
                ps.setString(4, password);

                ResultSet rs = ps.executeQuery();

                if (rs.next()) {
                    return mapUser(rs);
                }
            }

        } catch (Exception e) {
            System.out.println("Lỗi đăng nhập!");
            e.printStackTrace();
        }

        return null;
    }

    public boolean isUserAllowedToAccess(int userId) {
        String sql = "SELECT COUNT(*) AS total "
                + "FROM users "
                + "WHERE user_id = ? "
                + "AND deleted_at IS NULL "
                + "AND status = 'ACTIVE'";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setInt(1, userId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt("total") > 0;
            }

        } catch (Exception e) {
            System.out.println("Lỗi kiểm tra trạng thái tài khoản!");
            e.printStackTrace();
        }

        return false;
    }

    public boolean studentExists(String studentCode, String email) {
        String sql = "SELECT COUNT(*) AS total "
                + "FROM users "
                + "WHERE deleted_at IS NULL "
                + "AND (username = ? OR email = ? OR student_code = ?)";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setString(1, studentCode);
            ps.setString(2, email);
            ps.setString(3, studentCode);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt("total") > 0;
            }

        } catch (Exception e) {
            System.out.println("Lỗi kiểm tra sinh viên tồn tại!");
            e.printStackTrace();
        }

        return false;
    }

    private int getMemberRoleId(Connection conn) {
        String sql = "SELECT role_id FROM roles WHERE role_code = 'MEMBER'";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt("role_id");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return 3;
    }

    public boolean registerStudent(String studentCode, String fullName, String password) {
        if (studentCode == null || fullName == null || password == null) {
            return false;
        }

        studentCode = studentCode.trim();
        fullName = fullName.trim();
        password = password.trim();

        if (studentCode.isEmpty() || fullName.isEmpty() || password.isEmpty()) {
            return false;
        }

        String email = studentCode.toLowerCase() + "@husc.edu.vn";

        if (studentExists(studentCode, email)) {
            return false;
        }

        try (Connection conn = DBConnection.getConnection()) {
            String passwordColumn = getPasswordColumn(conn);
            int memberRoleId = getMemberRoleId(conn);

            String sql = "INSERT INTO users "
                    + "(role_id, username, " + passwordColumn + ", full_name, email, phone, status, student_code, created_at, deleted_at) "
                    + "VALUES (?, ?, ?, ?, ?, '', 'PENDING', ?, GETDATE(), NULL)";

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, memberRoleId);
                ps.setString(2, studentCode);
                ps.setString(3, password);
                ps.setString(4, fullName);
                ps.setString(5, email);
                ps.setString(6, studentCode);

                return ps.executeUpdate() > 0;
            }

        } catch (Exception e) {
            System.out.println("Lỗi đăng ký sinh viên!");
            e.printStackTrace();
        }

        return false;
    }
}
package vn.edu.husc.library.dao;

import vn.edu.husc.library.config.DBConnection;
import vn.edu.husc.library.model.OptionItem;
import vn.edu.husc.library.model.User;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class AdminUserDAO {

    public List<User> getAllUsers() {
        List<User> users = new ArrayList<>();

        String sql = "SELECT u.user_id, u.role_id, u.full_name, u.email, u.password, "
                + "u.phone, u.status, u.created_at, u.username, u.student_code, "
                + "r.role_code, r.role_name "
                + "FROM users u "
                + "LEFT JOIN roles r ON u.role_id = r.role_id "
                + "WHERE u.deleted_at IS NULL "
                + "ORDER BY u.user_id DESC";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()
        ) {
            while (rs.next()) {
                users.add(mapUser(rs));
            }

        } catch (Exception e) {
            System.out.println("Lỗi lấy danh sách người dùng!");
            e.printStackTrace();
        }

        return users;
    }

    public User getUserById(int userId) {
        String sql = "SELECT u.user_id, u.role_id, u.full_name, u.email, u.password, "
                + "u.phone, u.status, u.created_at, u.username, u.student_code, "
                + "r.role_code, r.role_name "
                + "FROM users u "
                + "LEFT JOIN roles r ON u.role_id = r.role_id "
                + "WHERE u.user_id = ? "
                + "AND u.deleted_at IS NULL";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }

        } catch (Exception e) {
            System.out.println("Lỗi lấy thông tin người dùng!");
            e.printStackTrace();
        }

        return null;
    }

    public List<OptionItem> getRoles() {
        List<OptionItem> roles = new ArrayList<>();

        String sql = "SELECT role_id, role_name "
                + "FROM roles "
                + "ORDER BY role_id";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()
        ) {
            while (rs.next()) {
                roles.add(new OptionItem(
                        rs.getInt("role_id"),
                        rs.getString("role_name")
                ));
            }

        } catch (Exception e) {
            System.out.println("Lỗi lấy danh sách vai trò!");
            e.printStackTrace();
        }

        return roles;
    }

    public boolean insertUser(User user) {
        String sql = "INSERT INTO users "
                + "(role_id, full_name, email, password, phone, status, username, student_code, created_at) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, GETDATE())";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            String status = user.getStatus();

            if (status == null || status.trim().isEmpty()) {
                status = "ACTIVE";
            }

            String username = user.getUsername();

            if (username == null || username.trim().isEmpty()) {
                username = user.getEmail();
            }

            String studentCode = user.getStudentCode();

            if (studentCode == null || studentCode.trim().isEmpty()) {
                studentCode = username;
            }

            int roleId = user.getRoleId();

            if (roleId <= 0) {
                roleId = 3;
            }

            ps.setInt(1, roleId);
            ps.setString(2, user.getFullName());
            ps.setString(3, user.getEmail());
            ps.setString(4, user.getPassword());
            ps.setString(5, user.getPhone());
            ps.setString(6, status);
            ps.setString(7, username);
            ps.setString(8, studentCode);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            System.out.println("Lỗi thêm người dùng!");
            e.printStackTrace();
        }

        return false;
    }

    public boolean updateUser(User user) {
        return updateUser(user, null);
    }

    public boolean updateUser(User user, String newPassword) {
        String sql;

        boolean updatePassword = newPassword != null && !newPassword.trim().isEmpty();

        if (updatePassword) {
            sql = "UPDATE users "
                    + "SET role_id = ?, full_name = ?, email = ?, phone = ?, "
                    + "status = ?, username = ?, student_code = ?, password = ? "
                    + "WHERE user_id = ? "
                    + "AND deleted_at IS NULL";
        } else {
            sql = "UPDATE users "
                    + "SET role_id = ?, full_name = ?, email = ?, phone = ?, "
                    + "status = ?, username = ?, student_code = ? "
                    + "WHERE user_id = ? "
                    + "AND deleted_at IS NULL";
        }

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            String status = user.getStatus();

            if (status == null || status.trim().isEmpty()) {
                status = "ACTIVE";
            }

            String username = user.getUsername();

            if (username == null || username.trim().isEmpty()) {
                username = user.getEmail();
            }

            String studentCode = user.getStudentCode();

            if (studentCode == null || studentCode.trim().isEmpty()) {
                studentCode = username;
            }

            int roleId = user.getRoleId();

            if (roleId <= 0) {
                roleId = 3;
            }

            ps.setInt(1, roleId);
            ps.setString(2, user.getFullName());
            ps.setString(3, user.getEmail());
            ps.setString(4, user.getPhone());
            ps.setString(5, status);
            ps.setString(6, username);
            ps.setString(7, studentCode);

            if (updatePassword) {
                ps.setString(8, newPassword.trim());
                ps.setInt(9, user.getUserId());
            } else {
                ps.setInt(8, user.getUserId());
            }

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            System.out.println("Lỗi cập nhật người dùng!");
            e.printStackTrace();
        }

        return false;
    }

    public boolean lockUser(int userId) {
        String sql = "UPDATE users "
                + "SET status = 'LOCKED' "
                + "WHERE user_id = ? "
                + "AND deleted_at IS NULL";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            System.out.println("Lỗi khóa người dùng!");
            e.printStackTrace();
        }

        return false;
    }

    public boolean lockUser(int userId, int currentUserId) {
        if (userId == currentUserId) {
            return false;
        }

        return lockUser(userId);
    }

    public boolean unlockUser(int userId) {
        String sql = "UPDATE users "
                + "SET status = 'ACTIVE' "
                + "WHERE user_id = ? "
                + "AND deleted_at IS NULL";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            System.out.println("Lỗi mở khóa người dùng!");
            e.printStackTrace();
        }

        return false;
    }

    public boolean deleteUser(int userId) {
        String sql = "UPDATE users "
                + "SET deleted_at = GETDATE(), status = 'DELETED' "
                + "WHERE user_id = ? "
                + "AND deleted_at IS NULL";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            System.out.println("Lỗi xóa người dùng!");
            e.printStackTrace();
        }

        return false;
    }

    public boolean isLastAdmin(int userId) {
        String sql = "SELECT COUNT(*) AS total_admin "
                + "FROM users u "
                + "INNER JOIN roles r ON u.role_id = r.role_id "
                + "WHERE r.role_code = 'ADMIN' "
                + "AND u.status = 'ACTIVE' "
                + "AND u.deleted_at IS NULL "
                + "AND u.user_id <> ?";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("total_admin") == 0;
                }
            }

        } catch (Exception e) {
            System.out.println("Lỗi kiểm tra admin cuối cùng!");
            e.printStackTrace();
        }

        return false;
    }

    private User mapUser(ResultSet rs) throws Exception {
        User user = new User();

        user.setUserId(rs.getInt("user_id"));
        user.setRoleId(rs.getInt("role_id"));
        user.setFullName(rs.getString("full_name"));
        user.setEmail(rs.getString("email"));
        user.setPassword(rs.getString("password"));
        user.setPhone(rs.getString("phone"));
        user.setStatus(rs.getString("status"));
        user.setCreatedAt(rs.getTimestamp("created_at"));
        user.setUsername(rs.getString("username"));
        user.setStudentCode(rs.getString("student_code"));
        user.setRoleCode(rs.getString("role_code"));
        user.setRoleName(rs.getString("role_name"));

        return user;
    }
}
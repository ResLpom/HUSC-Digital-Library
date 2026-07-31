package vn.edu.husc.library.dao;

import vn.edu.husc.library.config.DBConnection;
import vn.edu.husc.library.model.SystemLog;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

public class SystemLogDAO {

    public boolean insertLog(Integer userId, String action, String description, String ipAddress) {
        String sql = "INSERT INTO system_logs "
                + "(user_id, action, description, ip_address) "
                + "VALUES (?, ?, ?, ?)";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            if (userId == null) {
                ps.setNull(1, Types.INTEGER);
            } else {
                ps.setInt(1, userId);
            }

            ps.setString(2, action);
            ps.setString(3, description);
            ps.setString(4, ipAddress);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            System.out.println("Lỗi ghi nhật ký hệ thống!");
            e.printStackTrace();
        }

        return false;
    }

    public List<SystemLog> getAllLogs() {
        List<SystemLog> list = new ArrayList<SystemLog>();

        String sql = "SELECT "
                + "sl.log_id, "
                + "sl.user_id, "
                + "sl.action, "
                + "sl.description, "
                + "sl.ip_address, "
                + "sl.created_at, "
                + "u.full_name, "
                + "u.email, "
                + "r.role_name "
                + "FROM system_logs sl "
                + "LEFT JOIN users u ON sl.user_id = u.user_id "
                + "LEFT JOIN roles r ON u.role_id = r.role_id "
                + "ORDER BY sl.log_id DESC";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                SystemLog log = new SystemLog();

                log.setLogId(rs.getInt("log_id"));

                int userId = rs.getInt("user_id");
                if (rs.wasNull()) {
                    log.setUserId(null);
                } else {
                    log.setUserId(userId);
                }

                log.setAction(rs.getString("action"));
                log.setDescription(rs.getString("description"));
                log.setIpAddress(rs.getString("ip_address"));
                log.setCreatedAt(rs.getTimestamp("created_at"));

                log.setFullName(rs.getString("full_name"));
                log.setEmail(rs.getString("email"));
                log.setRoleName(rs.getString("role_name"));

                list.add(log);
            }

        } catch (Exception e) {
            System.out.println("Lỗi lấy nhật ký hệ thống!");
            e.printStackTrace();
        }

        return list;
    }
}
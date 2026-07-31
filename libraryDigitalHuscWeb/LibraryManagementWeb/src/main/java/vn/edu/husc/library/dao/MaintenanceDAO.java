package vn.edu.husc.library.dao;

import vn.edu.husc.library.config.DBConnection;
import vn.edu.husc.library.model.Equipment;
import vn.edu.husc.library.model.MaintenanceRecord;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class MaintenanceDAO {

    public List<Equipment> getEquipmentsForMaintenance() {
        List<Equipment> list = new ArrayList<Equipment>();

        String sql = "SELECT "
                + "equipment_id, "
                + "equipment_name, "
                + "code, "
                + "location, "
                + "status "
                + "FROM equipment "
                + "WHERE status IS NULL OR status <> 'INACTIVE' "
                + "ORDER BY equipment_name ASC";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()
        ) {
            while (rs.next()) {
                Equipment equipment = new Equipment();

                equipment.setEquipmentId(rs.getInt("equipment_id"));
                equipment.setEquipmentName(rs.getString("equipment_name"));
                equipment.setCode(rs.getString("code"));
                equipment.setLocation(rs.getString("location"));
                equipment.setStatus(rs.getString("status"));

                list.add(equipment);
            }

        } catch (Exception e) {
            System.out.println("Lỗi lấy danh sách thiết bị bảo trì!");
            e.printStackTrace();
        }

        return list;
    }

    public List<MaintenanceRecord> getAllMaintenanceRecords() {
        List<MaintenanceRecord> list = new ArrayList<MaintenanceRecord>();

        String sql = "SELECT "
                + "mr.maintenance_id, "
                + "mr.equipment_id, "
                + "ISNULL(mr.request_id, 0) AS request_id, "
                + "mr.manager_id, "
                + "ISNULL(mr.created_by, 0) AS created_by, "
                + "ISNULL(mr.completed_by, 0) AS completed_by, "
                + "mr.issue_description, "
                + "mr.maintenance_status, "
                + "ISNULL(mr.manager_note, '') AS manager_note, "
                + "mr.created_at, "
                + "mr.updated_at, "
                + "mr.completed_at, "
                + "e.equipment_name, "
                + "e.code AS equipment_code, "
                + "e.location AS equipment_location, "
                + "managerUser.full_name AS manager_name, "
                + "createdUser.full_name AS created_by_name, "
                + "completedUser.full_name AS completed_by_name "
                + "FROM maintenance_records mr "
                + "LEFT JOIN equipment e ON mr.equipment_id = e.equipment_id "
                + "LEFT JOIN users managerUser ON mr.manager_id = managerUser.user_id "
                + "LEFT JOIN users createdUser ON mr.created_by = createdUser.user_id "
                + "LEFT JOIN users completedUser ON mr.completed_by = completedUser.user_id "
                + "ORDER BY mr.created_at DESC, mr.maintenance_id DESC";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()
        ) {
            while (rs.next()) {
                MaintenanceRecord record = new MaintenanceRecord();

                record.setMaintenanceId(rs.getInt("maintenance_id"));
                record.setEquipmentId(rs.getInt("equipment_id"));
                record.setRequestId(rs.getInt("request_id"));
                record.setManagerId(rs.getInt("manager_id"));
                record.setCreatedBy(rs.getInt("created_by"));
                record.setCompletedBy(rs.getInt("completed_by"));

                record.setIssueDescription(rs.getString("issue_description"));
                record.setMaintenanceStatus(rs.getString("maintenance_status"));
                record.setManagerNote(rs.getString("manager_note"));

                record.setCreatedAt(rs.getTimestamp("created_at"));
                record.setUpdatedAt(rs.getTimestamp("updated_at"));
                record.setCompletedAt(rs.getTimestamp("completed_at"));

                record.setEquipmentName(rs.getString("equipment_name"));
                record.setEquipmentCode(rs.getString("equipment_code"));
                record.setEquipmentLocation(rs.getString("equipment_location"));

                record.setManagerName(rs.getString("manager_name"));
                record.setCreatedByName(rs.getString("created_by_name"));
                record.setCompletedByName(rs.getString("completed_by_name"));

                list.add(record);
            }

        } catch (Exception e) {
            System.out.println("Lỗi lấy danh sách bảo trì!");
            e.printStackTrace();
        }

        return list;
    }

    public List<MaintenanceRecord> getAllRecords() {
        return getAllMaintenanceRecords();
    }

    public boolean createMaintenanceRecord(int equipmentId, String issueDescription, String managerNote) {
        int managerId = getDefaultManagerId();

        return createMaintenanceRecord(equipmentId, managerId, issueDescription, managerNote);
    }

    public boolean createMaintenanceRecord(int equipmentId, int managerId, String issueDescription) {
        return createMaintenanceRecord(equipmentId, managerId, issueDescription, "");
    }

    public boolean createMaintenanceRecord(int equipmentId, int managerId, String issueDescription, String managerNote) {
        if (equipmentId <= 0) {
            return false;
        }

        if (issueDescription == null || issueDescription.trim().isEmpty()) {
            return false;
        }

        if (managerId <= 0) {
            managerId = getDefaultManagerId();
        }

        if (managerNote == null) {
            managerNote = "";
        }

        String insertSql = "INSERT INTO maintenance_records "
                + "(equipment_id, request_id, manager_id, issue_description, maintenance_status, "
                + "created_at, manager_note, created_by, completed_by, completed_at, updated_at) "
                + "VALUES (?, NULL, ?, ?, 'PENDING', GETDATE(), ?, ?, NULL, NULL, GETDATE())";

        String updateEquipmentSql = "UPDATE equipment "
                + "SET status = 'MAINTENANCE' "
                + "WHERE equipment_id = ?";

        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                ps.setInt(1, equipmentId);
                ps.setInt(2, managerId);
                ps.setString(3, issueDescription.trim());
                ps.setString(4, managerNote.trim());
                ps.setInt(5, managerId);

                int rows = ps.executeUpdate();

                if (rows <= 0) {
                    conn.rollback();
                    return false;
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(updateEquipmentSql)) {
                ps.setInt(1, equipmentId);
                ps.executeUpdate();
            }

            conn.commit();
            return true;

        } catch (Exception e) {
            System.out.println("Lỗi tạo ghi nhận bảo trì!");
            e.printStackTrace();

            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (Exception rollbackException) {
                rollbackException.printStackTrace();
            }

        } finally {
            try {
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (Exception closeException) {
                closeException.printStackTrace();
            }
        }

        return false;
    }

    public boolean addMaintenanceRecord(int equipmentId, String issueDescription, String managerNote, int userId) {
        return createMaintenanceRecord(equipmentId, userId, issueDescription, managerNote);
    }

    public boolean insertMaintenanceRecord(int equipmentId, String issueDescription, String managerNote, int userId) {
        return createMaintenanceRecord(equipmentId, userId, issueDescription, managerNote);
    }

    public boolean updateMaintenanceStatus(int maintenanceId, String status) {
        if (maintenanceId <= 0 || status == null || status.trim().isEmpty()) {
            return false;
        }

        String sql = "UPDATE maintenance_records "
                + "SET maintenance_status = ?, updated_at = GETDATE() "
                + "WHERE maintenance_id = ?";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setString(1, status.trim());
            ps.setInt(2, maintenanceId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            System.out.println("Lỗi cập nhật trạng thái bảo trì!");
            e.printStackTrace();
        }

        return false;
    }

    public boolean finishMaintenance(int maintenanceId) {
        if (maintenanceId <= 0) {
            return false;
        }

        String getEquipmentSql = "SELECT equipment_id "
                + "FROM maintenance_records "
                + "WHERE maintenance_id = ?";

        String updateMaintenanceSql = "UPDATE maintenance_records "
                + "SET maintenance_status = 'DONE', "
                + "completed_at = GETDATE(), "
                + "updated_at = GETDATE() "
                + "WHERE maintenance_id = ?";

        String updateEquipmentSql = "UPDATE equipment "
                + "SET status = 'AVAILABLE' "
                + "WHERE equipment_id = ?";

        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            int equipmentId = 0;

            try (PreparedStatement ps = conn.prepareStatement(getEquipmentSql)) {
                ps.setInt(1, maintenanceId);

                ResultSet rs = ps.executeQuery();

                if (rs.next()) {
                    equipmentId = rs.getInt("equipment_id");
                }
            }

            if (equipmentId <= 0) {
                conn.rollback();
                return false;
            }

            try (PreparedStatement ps = conn.prepareStatement(updateMaintenanceSql)) {
                ps.setInt(1, maintenanceId);

                int rows = ps.executeUpdate();

                if (rows <= 0) {
                    conn.rollback();
                    return false;
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(updateEquipmentSql)) {
                ps.setInt(1, equipmentId);
                ps.executeUpdate();
            }

            conn.commit();
            return true;

        } catch (Exception e) {
            System.out.println("Lỗi hoàn tất bảo trì!");
            e.printStackTrace();

            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (Exception rollbackException) {
                rollbackException.printStackTrace();
            }

        } finally {
            try {
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (Exception closeException) {
                closeException.printStackTrace();
            }
        }

        return false;
    }

    public boolean completeMaintenanceRecord(int maintenanceId, int userId) {
        return finishMaintenance(maintenanceId);
    }

    private int getDefaultManagerId() {
        String sql = "SELECT TOP 1 u.user_id "
                + "FROM users u "
                + "LEFT JOIN roles r ON u.role_id = r.role_id "
                + "WHERE ISNULL(u.status, 'ACTIVE') = 'ACTIVE' "
                + "AND ISNULL(r.role_code, '') IN ('MANAGER', 'ADMIN') "
                + "ORDER BY CASE WHEN r.role_code = 'MANAGER' THEN 1 ELSE 2 END, u.user_id ASC";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()
        ) {
            if (rs.next()) {
                return rs.getInt("user_id");
            }

        } catch (Exception e) {
            System.out.println("Lỗi lấy manager mặc định!");
            e.printStackTrace();
        }

        return 1;
    }
}
package vn.edu.husc.library.dao;

import vn.edu.husc.library.config.DBConnection;
import vn.edu.husc.library.model.Equipment;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class EquipmentDAO {

    public List<Equipment> searchEquipments(String keyword) {
        List<Equipment> list = new ArrayList<Equipment>();

        if (keyword == null) {
            keyword = "";
        }

        String sql = "SELECT "
                + "e.equipment_id, "
                + "e.equipment_type_id, "
                + "e.equipment_name, "
                + "e.code, "
                + "e.description, "
                + "e.location, "
                + "e.image_path, "
                + "e.value_money, "
                + "e.status, "
                + "e.created_at, "
                + "et.type_name "
                + "FROM equipment e "
                + "JOIN equipment_types et ON e.equipment_type_id = et.equipment_type_id "
                + "WHERE e.status <> 'INACTIVE' "
                + "AND (e.equipment_name LIKE ? "
                + "OR e.code LIKE ? "
                + "OR e.location LIKE ? "
                + "OR e.status LIKE ? "
                + "OR et.type_name LIKE ?) "
                + "ORDER BY e.equipment_id DESC";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            String searchValue = "%" + keyword.trim() + "%";

            ps.setString(1, searchValue);
            ps.setString(2, searchValue);
            ps.setString(3, searchValue);
            ps.setString(4, searchValue);
            ps.setString(5, searchValue);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Equipment equipment = new Equipment();

                equipment.setEquipmentId(rs.getInt("equipment_id"));
                equipment.setEquipmentTypeId(rs.getInt("equipment_type_id"));
                equipment.setEquipmentName(rs.getString("equipment_name"));
                equipment.setCode(rs.getString("code"));
                equipment.setDescription(rs.getString("description"));
                equipment.setLocation(rs.getString("location"));
                equipment.setImagePath(rs.getString("image_path"));
                equipment.setValueMoney(rs.getDouble("value_money"));
                equipment.setStatus(rs.getString("status"));
                equipment.setCreatedAt(rs.getTimestamp("created_at"));
                equipment.setTypeName(rs.getString("type_name"));

                list.add(equipment);
            }

        } catch (Exception e) {
            System.out.println("Lỗi tìm kiếm thiết bị!");
            e.printStackTrace();
        }

        return list;
    }

    public List<Equipment> getAllEquipments() {
        return searchEquipments("");
    }

    public Equipment getEquipmentById(int equipmentId) {
        String sql = "SELECT "
                + "e.equipment_id, "
                + "e.equipment_type_id, "
                + "e.equipment_name, "
                + "e.code, "
                + "e.description, "
                + "e.location, "
                + "e.image_path, "
                + "e.value_money, "
                + "e.status, "
                + "e.created_at, "
                + "et.type_name "
                + "FROM equipment e "
                + "JOIN equipment_types et ON e.equipment_type_id = et.equipment_type_id "
                + "WHERE e.equipment_id = ?";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setInt(1, equipmentId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                Equipment equipment = new Equipment();

                equipment.setEquipmentId(rs.getInt("equipment_id"));
                equipment.setEquipmentTypeId(rs.getInt("equipment_type_id"));
                equipment.setEquipmentName(rs.getString("equipment_name"));
                equipment.setCode(rs.getString("code"));
                equipment.setDescription(rs.getString("description"));
                equipment.setLocation(rs.getString("location"));
                equipment.setImagePath(rs.getString("image_path"));
                equipment.setValueMoney(rs.getDouble("value_money"));
                equipment.setStatus(rs.getString("status"));
                equipment.setCreatedAt(rs.getTimestamp("created_at"));
                equipment.setTypeName(rs.getString("type_name"));

                return equipment;
            }

        } catch (Exception e) {
            System.out.println("Lỗi lấy chi tiết thiết bị!");
            e.printStackTrace();
        }

        return null;
    }

    public boolean updateEquipmentStatus(int equipmentId, String status) {
        if (status == null) {
            return false;
        }

        status = status.trim().toUpperCase();

        if (!"AVAILABLE".equals(status)
                && !"MAINTENANCE".equals(status)
                && !"BROKEN".equals(status)) {
            return false;
        }

        String sql = "UPDATE equipment "
                + "SET status = ? "
                + "WHERE equipment_id = ? "
                + "AND status <> 'INACTIVE'";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setString(1, status);
            ps.setInt(2, equipmentId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            System.out.println("Lỗi cập nhật trạng thái thiết bị!");
            e.printStackTrace();
        }

        return false;
    }
}
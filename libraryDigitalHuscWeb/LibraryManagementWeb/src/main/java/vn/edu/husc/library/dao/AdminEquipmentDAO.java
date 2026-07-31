package vn.edu.husc.library.dao;

import vn.edu.husc.library.config.DBConnection;
import vn.edu.husc.library.model.Equipment;
import vn.edu.husc.library.model.OptionItem;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class AdminEquipmentDAO {

    public List<Equipment> getAllEquipments() {
        List<Equipment> list = new ArrayList<Equipment>();

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
                + "ORDER BY e.equipment_id DESC";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Equipment equipment = mapEquipment(rs);
                list.add(equipment);
            }

        } catch (Exception e) {
            System.out.println("Lỗi lấy danh sách thiết bị quản trị!");
            e.printStackTrace();
        }

        return list;
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
                return mapEquipment(rs);
            }

        } catch (Exception e) {
            System.out.println("Lỗi lấy thiết bị theo ID!");
            e.printStackTrace();
        }

        return null;
    }

    public boolean insertEquipment(Equipment equipment) {
        String sql = "INSERT INTO equipment "
                + "(equipment_type_id, equipment_name, code, description, location, image_path, value_money, status) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            setEquipmentParams(ps, equipment, false);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            System.out.println("Lỗi thêm thiết bị!");
            e.printStackTrace();
        }

        return false;
    }

    public boolean updateEquipment(Equipment equipment) {
        String sql = "UPDATE equipment SET "
                + "equipment_type_id = ?, "
                + "equipment_name = ?, "
                + "code = ?, "
                + "description = ?, "
                + "location = ?, "
                + "image_path = ?, "
                + "value_money = ?, "
                + "status = ? "
                + "WHERE equipment_id = ?";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            setEquipmentParams(ps, equipment, true);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            System.out.println("Lỗi cập nhật thiết bị!");
            e.printStackTrace();
        }

        return false;
    }

    public boolean hideEquipment(int equipmentId) {
        String sql = "UPDATE equipment SET status = 'INACTIVE' WHERE equipment_id = ?";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setInt(1, equipmentId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            System.out.println("Lỗi ẩn thiết bị!");
            e.printStackTrace();
        }

        return false;
    }

    public List<OptionItem> getEquipmentTypes() {
        List<OptionItem> list = new ArrayList<OptionItem>();

        String sql = "SELECT equipment_type_id, type_name "
                + "FROM equipment_types "
                + "ORDER BY type_name";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                list.add(new OptionItem(
                        rs.getInt("equipment_type_id"),
                        rs.getString("type_name")
                ));
            }

        } catch (Exception e) {
            System.out.println("Lỗi lấy loại thiết bị!");
            e.printStackTrace();
        }

        return list;
    }

    private void setEquipmentParams(PreparedStatement ps, Equipment equipment, boolean isUpdate) throws Exception {
        ps.setInt(1, equipment.getEquipmentTypeId());
        ps.setString(2, equipment.getEquipmentName());
        ps.setString(3, equipment.getCode());
        ps.setString(4, equipment.getDescription());
        ps.setString(5, equipment.getLocation());
        ps.setString(6, equipment.getImagePath());
        ps.setDouble(7, equipment.getValueMoney());
        ps.setString(8, equipment.getStatus());

        if (isUpdate) {
            ps.setInt(9, equipment.getEquipmentId());
        }
    }

    private Equipment mapEquipment(ResultSet rs) throws Exception {
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
}
package vn.edu.husc.library.model;

import java.util.Date;

public class Equipment {

    private int equipmentId;
    private int equipmentTypeId;

    private String equipmentName;
    private String code;
    private String description;
    private String location;
    private String imagePath;
    private double valueMoney;
    private String status;
    private Date createdAt;

    private String typeName;

    public Equipment() {
    }

    public int getEquipmentId() {
        return equipmentId;
    }

    public void setEquipmentId(int equipmentId) {
        this.equipmentId = equipmentId;
    }

    public int getEquipmentTypeId() {
        return equipmentTypeId;
    }

    public void setEquipmentTypeId(int equipmentTypeId) {
        this.equipmentTypeId = equipmentTypeId;
    }

    public String getEquipmentName() {
        return equipmentName;
    }

    public void setEquipmentName(String equipmentName) {
        this.equipmentName = equipmentName;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }    

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public String getImagePath() {
        return imagePath;
    }

    public void setImagePath(String imagePath) {
        this.imagePath = imagePath;
    }

    public double getValueMoney() {
        return valueMoney;
    }

    public void setValueMoney(double valueMoney) {
        this.valueMoney = valueMoney;
    }

    public String getStatus() {
        return status;
    }

    public String getStatusName() {
        if ("AVAILABLE".equalsIgnoreCase(status)) {
            return "Sẵn sàng";
        } else if ("BORROWED".equalsIgnoreCase(status)) {
            return "Đang mượn";
        } else if ("MAINTENANCE".equalsIgnoreCase(status)) {
            return "Đang bảo trì";
        } else if ("BROKEN".equalsIgnoreCase(status)) {
            return "Bị hỏng";
        } else if ("LOST".equalsIgnoreCase(status)) {
            return "Bị mất";
        } else if ("INACTIVE".equalsIgnoreCase(status)) {
            return "Ngừng sử dụng";
        }
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }    

    public String getTypeName() {
        return typeName;
    }

    public void setTypeName(String typeName) {
        this.typeName = typeName;
    }
}
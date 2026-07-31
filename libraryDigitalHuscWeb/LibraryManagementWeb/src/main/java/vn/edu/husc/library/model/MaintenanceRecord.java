package vn.edu.husc.library.model;

import java.sql.Timestamp;

public class MaintenanceRecord {

    private int maintenanceId;
    private int equipmentId;
    private int requestId;
    private int managerId;
    private int createdBy;
    private int completedBy;

    private String issueDescription;
    private String maintenanceStatus;
    private String managerNote;

    private Timestamp createdAt;
    private Timestamp updatedAt;
    private Timestamp completedAt;

    private String equipmentName;
    private String equipmentCode;
    private String equipmentLocation;
    private String typeName;

    private String managerName;
    private String createdByName;
    private String completedByName;

    public int getMaintenanceId() {
        return maintenanceId;
    }

    public void setMaintenanceId(int maintenanceId) {
        this.maintenanceId = maintenanceId;
    }

    public int getMaintenanceRecordId() {
        return maintenanceId;
    }

    public void setMaintenanceRecordId(int maintenanceId) {
        this.maintenanceId = maintenanceId;
    }

    public int getEquipmentId() {
        return equipmentId;
    }

    public void setEquipmentId(int equipmentId) {
        this.equipmentId = equipmentId;
    }

    public int getRequestId() {
        return requestId;
    }

    public void setRequestId(int requestId) {
        this.requestId = requestId;
    }

    public int getManagerId() {
        return managerId;
    }

    public void setManagerId(int managerId) {
        this.managerId = managerId;
    }

    public int getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(int createdBy) {
        this.createdBy = createdBy;
    }

    public int getCompletedBy() {
        return completedBy;
    }

    public void setCompletedBy(int completedBy) {
        this.completedBy = completedBy;
    }

    public String getIssueDescription() {
        return issueDescription;
    }

    public void setIssueDescription(String issueDescription) {
        this.issueDescription = issueDescription;
    }

    public String getMaintenanceStatus() {
        return maintenanceStatus;
    }

    public void setMaintenanceStatus(String maintenanceStatus) {
        this.maintenanceStatus = maintenanceStatus;
    }

    public String getStatus() {
        return maintenanceStatus;
    }

    public void setStatus(String status) {
        this.maintenanceStatus = status;
    }

    public String getStatusText() {
        if ("PENDING".equalsIgnoreCase(maintenanceStatus)) {
            return "Chờ bảo trì";
        }

        if ("PROCESSING".equalsIgnoreCase(maintenanceStatus)) {
            return "Đang xử lý";
        }

        if ("DONE".equalsIgnoreCase(maintenanceStatus)
                || "COMPLETED".equalsIgnoreCase(maintenanceStatus)) {
            return "Đã hoàn tất";
        }

        if ("CANCELED".equalsIgnoreCase(maintenanceStatus)
                || "CANCELLED".equalsIgnoreCase(maintenanceStatus)) {
            return "Đã hủy";
        }

        if (maintenanceStatus == null || maintenanceStatus.trim().isEmpty()) {
            return "Chưa rõ";
        }

        return maintenanceStatus;
    }

    public String getManagerNote() {
        return managerNote;
    }

    public void setManagerNote(String managerNote) {
        this.managerNote = managerNote;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    public Timestamp getCompletedAt() {
        return completedAt;
    }

    public void setCompletedAt(Timestamp completedAt) {
        this.completedAt = completedAt;
    }

    public String getEquipmentName() {
        return equipmentName;
    }

    public void setEquipmentName(String equipmentName) {
        this.equipmentName = equipmentName;
    }

    public String getEquipmentCode() {
        return equipmentCode;
    }

    public void setEquipmentCode(String equipmentCode) {
        this.equipmentCode = equipmentCode;
    }

    public String getCode() {
        return equipmentCode;
    }

    public void setCode(String code) {
        this.equipmentCode = code;
    }

    public String getEquipmentLocation() {
        return equipmentLocation;
    }

    public void setEquipmentLocation(String equipmentLocation) {
        this.equipmentLocation = equipmentLocation;
    }

    public String getLocation() {
        return equipmentLocation;
    }

    public void setLocation(String location) {
        this.equipmentLocation = location;
    }

    public String getTypeName() {
        if (typeName == null || typeName.trim().isEmpty()) {
            return "Thiết bị";
        }

        return typeName;
    }

    public void setTypeName(String typeName) {
        this.typeName = typeName;
    }

    public String getEquipmentTypeName() {
        return getTypeName();
    }

    public void setEquipmentTypeName(String typeName) {
        this.typeName = typeName;
    }

    public String getManagerName() {
        return managerName;
    }

    public void setManagerName(String managerName) {
        this.managerName = managerName;
    }

    public String getCreatedByName() {
        return createdByName;
    }

    public void setCreatedByName(String createdByName) {
        this.createdByName = createdByName;
    }

    public String getCompletedByName() {
        return completedByName;
    }

    public void setCompletedByName(String completedByName) {
        this.completedByName = completedByName;
    }
}
package vn.edu.husc.library.model;

import java.util.Date;

public class BorrowRequest {

    private int requestId;
    private int userId;
    private int equipmentId;

    private Date borrowDate;
    private Date expectedReturnDate;
    private String purpose;
    private String status;
    private String managerNote;
    private Date createdAt;

    private String fullName;
    private String equipmentName;
    private String equipmentCode;
    private String typeName;

    public BorrowRequest() {
    }

    public int getRequestId() {
        return requestId;
    }

    public void setRequestId(int requestId) {
        this.requestId = requestId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public int getEquipmentId() {
        return equipmentId;
    }

    public void setEquipmentId(int equipmentId) {
        this.equipmentId = equipmentId;
    }

    public Date getBorrowDate() {
        return borrowDate;
    }

    public void setBorrowDate(Date borrowDate) {
        this.borrowDate = borrowDate;
    }

    public Date getExpectedReturnDate() {
        return expectedReturnDate;
    }

    public void setExpectedReturnDate(Date expectedReturnDate) {
        this.expectedReturnDate = expectedReturnDate;
    }

    public String getPurpose() {
        return purpose;
    }

    public void setPurpose(String purpose) {
        this.purpose = purpose;
    }

    public String getStatus() {
        return status;
    }

    public String getStatusName() {
        if ("PENDING".equalsIgnoreCase(status)) {
            return "Chờ duyệt";
        } else if ("APPROVED".equalsIgnoreCase(status)) {
            return "Đã duyệt";
        } else if ("REJECTED".equalsIgnoreCase(status)) {
            return "Bị từ chối";
        } else if ("BORROWING".equalsIgnoreCase(status)) {
            return "Đang mượn";
        } else if ("RETURNED".equalsIgnoreCase(status)) {
            return "Đã trả";
        } else if ("CANCELED".equalsIgnoreCase(status)) {
            return "Đã hủy";
        }
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getManagerNote() {
        return managerNote;
    }

    public void setManagerNote(String managerNote) {
        this.managerNote = managerNote;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
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

    public String getTypeName() {
        return typeName;
    }

    public void setTypeName(String typeName) {
        this.typeName = typeName;
    }
}
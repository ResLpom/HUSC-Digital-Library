package vn.edu.husc.library.model;

import java.sql.Timestamp;

public class RegistrationRequest {

    private int userId;
    private String username;
    private String fullName;
    private String email;
    private String studentCode;
    private String phone;
    private String address;
    private String status;
    private String rejectReason;
    private String registrationNote;
    private Timestamp createdAt;
    private Timestamp verifiedAt;
    private int verifiedBy;

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }
    
    public String getStudentCode() {
        return studentCode;
    }

    public void setStudentCode(String studentCode) {
        this.studentCode = studentCode;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }
    
    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getStatus() {
        return status;
    }

    public String getStatusText() {
        if ("PENDING".equalsIgnoreCase(status)) return "Chờ xác thực";
        if ("ACTIVE".equalsIgnoreCase(status)) return "Đã duyệt";
        if ("REJECTED".equalsIgnoreCase(status)) return "Đã từ chối";
        if ("LOCKED".equalsIgnoreCase(status)) return "Đã khóa";

        return status == null ? "Chưa rõ" : status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getRejectReason() {
        return rejectReason;
    }

    public void setRejectReason(String rejectReason) {
        this.rejectReason = rejectReason;
    }

    public String getRegistrationNote() {
        return registrationNote;
    }

    public void setRegistrationNote(String registrationNote) {
        this.registrationNote = registrationNote;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getVerifiedAt() {
        return verifiedAt;
    }

    public void setVerifiedAt(Timestamp verifiedAt) {
        this.verifiedAt = verifiedAt;
    }

    public int getVerifiedBy() {
        return verifiedBy;
    }

    public void setVerifiedBy(int verifiedBy) {
        this.verifiedBy = verifiedBy;
    }
}
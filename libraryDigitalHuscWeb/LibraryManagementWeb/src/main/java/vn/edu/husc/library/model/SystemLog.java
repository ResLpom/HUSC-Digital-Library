package vn.edu.husc.library.model;

import java.util.Date;

public class SystemLog {

    private int logId;
    private Integer userId;
    private String action;
    private String description;
    private String ipAddress;
    private Date createdAt;

    private String fullName;
    private String email;
    private String roleName;

    public SystemLog() {
    }

    public int getLogId() {
        return logId;
    }

    public void setLogId(int logId) {
        this.logId = logId;
    }

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public String getAction() {
        return action;
    }

    public void setAction(String action) {
        this.action = action;
    }

    public String getDescription() {
        return description;
    }

    public String getDescriptionSafe() {
        return description == null ? "" : description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getIpAddress() {
        return ipAddress;
    }

    public String getIpAddressSafe() {
        return ipAddress == null ? "" : ipAddress;
    }

    public void setIpAddress(String ipAddress) {
        this.ipAddress = ipAddress;
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

    public String getFullNameSafe() {
        return fullName == null ? "Khách/Không xác định" : fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getEmail() {
        return email;
    }

    public String getEmailSafe() {
        return email == null ? "" : email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getRoleName() {
        return roleName;
    }

    public String getRoleNameSafe() {
        return roleName == null ? "" : roleName;
    }

    public void setRoleName(String roleName) {
        this.roleName = roleName;
    }
}
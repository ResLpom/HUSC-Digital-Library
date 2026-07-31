package vn.edu.husc.library.model;

public class ReportSummary {

    private int totalDocuments;
    private int activeDocuments;
    private int inactiveDocuments;

    private int totalEquipments;
    private int availableEquipments;
    private int borrowedEquipments;
    private int maintenanceEquipments;
    private int lostEquipments;
    private int inactiveEquipments;

    private int totalBorrowRequests;
    private int pendingRequests;
    private int approvedRequests;
    private int borrowingRequests;
    private int returnedRequests;
    private int rejectedRequests;

    private int totalMaintenanceRecords;
    private int pendingMaintenance;
    private int processingMaintenance;
    private int doneMaintenance;

    public int getTotalDocuments() {
        return totalDocuments;
    }

    public void setTotalDocuments(int totalDocuments) {
        this.totalDocuments = totalDocuments;
    }

    public int getActiveDocuments() {
        return activeDocuments;
    }

    public void setActiveDocuments(int activeDocuments) {
        this.activeDocuments = activeDocuments;
    }

    public int getInactiveDocuments() {
        return inactiveDocuments;
    }

    public void setInactiveDocuments(int inactiveDocuments) {
        this.inactiveDocuments = inactiveDocuments;
    }

    public int getTotalEquipments() {
        return totalEquipments;
    }

    public void setTotalEquipments(int totalEquipments) {
        this.totalEquipments = totalEquipments;
    }

    public int getAvailableEquipments() {
        return availableEquipments;
    }

    public void setAvailableEquipments(int availableEquipments) {
        this.availableEquipments = availableEquipments;
    }

    public int getBorrowedEquipments() {
        return borrowedEquipments;
    }

    public void setBorrowedEquipments(int borrowedEquipments) {
        this.borrowedEquipments = borrowedEquipments;
    }

    public int getMaintenanceEquipments() {
        return maintenanceEquipments;
    }

    public void setMaintenanceEquipments(int maintenanceEquipments) {
        this.maintenanceEquipments = maintenanceEquipments;
    }

    public int getLostEquipments() {
        return lostEquipments;
    }

    public void setLostEquipments(int lostEquipments) {
        this.lostEquipments = lostEquipments;
    }

    public int getInactiveEquipments() {
        return inactiveEquipments;
    }

    public void setInactiveEquipments(int inactiveEquipments) {
        this.inactiveEquipments = inactiveEquipments;
    }

    public int getTotalBorrowRequests() {
        return totalBorrowRequests;
    }

    public void setTotalBorrowRequests(int totalBorrowRequests) {
        this.totalBorrowRequests = totalBorrowRequests;
    }

    public int getPendingRequests() {
        return pendingRequests;
    }

    public void setPendingRequests(int pendingRequests) {
        this.pendingRequests = pendingRequests;
    }

    public int getApprovedRequests() {
        return approvedRequests;
    }

    public void setApprovedRequests(int approvedRequests) {
        this.approvedRequests = approvedRequests;
    }

    public int getBorrowingRequests() {
        return borrowingRequests;
    }

    public void setBorrowingRequests(int borrowingRequests) {
        this.borrowingRequests = borrowingRequests;
    }

    public int getReturnedRequests() {
        return returnedRequests;
    }

    public void setReturnedRequests(int returnedRequests) {
        this.returnedRequests = returnedRequests;
    }

    public int getRejectedRequests() {
        return rejectedRequests;
    }

    public void setRejectedRequests(int rejectedRequests) {
        this.rejectedRequests = rejectedRequests;
    }

    public int getTotalMaintenanceRecords() {
        return totalMaintenanceRecords;
    }

    public void setTotalMaintenanceRecords(int totalMaintenanceRecords) {
        this.totalMaintenanceRecords = totalMaintenanceRecords;
    }

    public int getPendingMaintenance() {
        return pendingMaintenance;
    }

    public void setPendingMaintenance(int pendingMaintenance) {
        this.pendingMaintenance = pendingMaintenance;
    }

    public int getProcessingMaintenance() {
        return processingMaintenance;
    }

    public void setProcessingMaintenance(int processingMaintenance) {
        this.processingMaintenance = processingMaintenance;
    }

    public int getDoneMaintenance() {
        return doneMaintenance;
    }

    public void setDoneMaintenance(int doneMaintenance) {
        this.doneMaintenance = doneMaintenance;
    }
}
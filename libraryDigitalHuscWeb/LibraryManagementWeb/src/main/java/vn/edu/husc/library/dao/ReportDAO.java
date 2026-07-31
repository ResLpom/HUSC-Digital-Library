package vn.edu.husc.library.dao;

import vn.edu.husc.library.config.DBConnection;
import vn.edu.husc.library.model.ReportSummary;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class ReportDAO {

    public ReportSummary getReportSummary() {
        ReportSummary summary = new ReportSummary();

        summary.setTotalDocuments(count("SELECT COUNT(*) FROM documents"));
        summary.setActiveDocuments(count("SELECT COUNT(*) FROM documents WHERE status = 'ACTIVE'"));
        summary.setInactiveDocuments(count("SELECT COUNT(*) FROM documents WHERE status = 'INACTIVE'"));

        summary.setTotalEquipments(count("SELECT COUNT(*) FROM equipment"));
        summary.setAvailableEquipments(count("SELECT COUNT(*) FROM equipment WHERE status = 'AVAILABLE'"));
        summary.setBorrowedEquipments(count("SELECT COUNT(*) FROM equipment WHERE status = 'BORROWED'"));
        summary.setMaintenanceEquipments(count("SELECT COUNT(*) FROM equipment WHERE status = 'MAINTENANCE'"));
        summary.setLostEquipments(count("SELECT COUNT(*) FROM equipment WHERE status = 'LOST'"));
        summary.setInactiveEquipments(count("SELECT COUNT(*) FROM equipment WHERE status = 'INACTIVE'"));

        summary.setTotalBorrowRequests(count("SELECT COUNT(*) FROM borrow_requests"));
        summary.setPendingRequests(count("SELECT COUNT(*) FROM borrow_requests WHERE status = 'PENDING'"));
        summary.setApprovedRequests(count("SELECT COUNT(*) FROM borrow_requests WHERE status = 'APPROVED'"));
        summary.setBorrowingRequests(count("SELECT COUNT(*) FROM borrow_requests WHERE status = 'BORROWING'"));
        summary.setReturnedRequests(count("SELECT COUNT(*) FROM borrow_requests WHERE status = 'RETURNED'"));
        summary.setRejectedRequests(count("SELECT COUNT(*) FROM borrow_requests WHERE status = 'REJECTED'"));

        summary.setTotalMaintenanceRecords(count("SELECT COUNT(*) FROM maintenance_records"));
        summary.setPendingMaintenance(count("SELECT COUNT(*) FROM maintenance_records WHERE maintenance_status = 'PENDING'"));
        summary.setProcessingMaintenance(count("SELECT COUNT(*) FROM maintenance_records WHERE maintenance_status = 'PROCESSING'"));
        summary.setDoneMaintenance(count("SELECT COUNT(*) FROM maintenance_records WHERE maintenance_status = 'DONE'"));

        return summary;
    }

    private int count(String sql) {
        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt(1);
            }

        } catch (Exception e) {
            System.out.println("Lỗi thống kê dữ liệu!");
            e.printStackTrace();
        }

        return 0;
    }
}
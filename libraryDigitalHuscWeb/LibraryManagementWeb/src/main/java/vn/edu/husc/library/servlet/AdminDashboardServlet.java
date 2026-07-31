package vn.edu.husc.library.servlet;

import vn.edu.husc.library.config.DBConnection;

import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class AdminDashboardServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final String DE_CUONG_PATH = "D:/upLoad/de-cuong/exam-bank";
    private static final String NGAN_HANG_DE_PATH = "D:/upLoad/ngan-hang-de/exam-bank";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        int totalDocuments = countTable("documents");
        int totalEquipments = countTable("equipment");
        int totalBorrowRequests = countTable("borrow_requests");
        int totalUsers = countTable("users");
        int totalMaintenance = countTable("maintenance_records");

        int deCuongFiles = countFiles(new File(DE_CUONG_PATH));
        int nganHangDeFiles = countFiles(new File(NGAN_HANG_DE_PATH));
        int totalExamFiles = deCuongFiles + nganHangDeFiles;

        request.setAttribute("totalDocuments", totalDocuments);
        request.setAttribute("totalEquipments", totalEquipments);
        request.setAttribute("totalBorrowRequests", totalBorrowRequests);
        request.setAttribute("totalUsers", totalUsers);
        request.setAttribute("totalMaintenance", totalMaintenance);

        request.setAttribute("deCuongFiles", deCuongFiles);
        request.setAttribute("nganHangDeFiles", nganHangDeFiles);
        request.setAttribute("totalExamFiles", totalExamFiles);

        request.getRequestDispatcher("/admin/dashboard.jsp").forward(request, response);
    }

    private int countTable(String tableName) {
        String sql = "SELECT COUNT(*) AS total FROM " + tableName;

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt("total");
            }

        } catch (Exception e) {
            System.out.println("Lỗi đếm bảng: " + tableName);
            e.printStackTrace();
        }

        return 0;
    }

    private int countFiles(File file) {
        if (file == null || !file.exists()) {
            return 0;
        }

        if (file.isFile()) {
            return 1;
        }

        File[] children = file.listFiles();

        if (children == null) {
            return 0;
        }

        int count = 0;

        for (File child : children) {
            count += countFiles(child);
        }

        return count;
    }
}
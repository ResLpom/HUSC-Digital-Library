package vn.edu.husc.library.servlet;

import vn.edu.husc.library.config.DBConnection;
import vn.edu.husc.library.model.User;

import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DocumentHistoryServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    public static class HistoryItem {
        private int documentId;
        private String title;
        private String description;
        private String coverImage;
        private String fileType;
        private String actionType;
        private String actionTime;

        public int getDocumentId() {
            return documentId;
        }

        public void setDocumentId(int documentId) {
            this.documentId = documentId;
        }

        public String getTitle() {
            return title;
        }

        public void setTitle(String title) {
            this.title = title;
        }

        public String getDescription() {
            return description;
        }

        public void setDescription(String description) {
            this.description = description;
        }

        public String getCoverImage() {
            return coverImage;
        }

        public void setCoverImage(String coverImage) {
            this.coverImage = coverImage;
        }

        public String getFileType() {
            return fileType;
        }

        public void setFileType(String fileType) {
            this.fileType = fileType;
        }

        public String getActionType() {
            return actionType;
        }

        public void setActionType(String actionType) {
            this.actionType = actionType;
        }

        public String getActionTime() {
            return actionTime;
        }

        public void setActionTime(String actionTime) {
            this.actionTime = actionTime;
        }
    }

    private User getCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);

        if (session == null) {
            return null;
        }

        User user = (User) session.getAttribute("currentUser");

        if (user == null) {
            user = (User) session.getAttribute("user");
        }

        return user;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        User currentUser = getCurrentUser(request);

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        List<HistoryItem> histories = getDocumentHistories(currentUser.getUserId());

        request.setAttribute("histories", histories);
        request.getRequestDispatcher("/document-history.jsp").forward(request, response);
    }

    private List<HistoryItem> getDocumentHistories(int userId) {
        List<HistoryItem> list = new ArrayList<>();

        String sql =
                "SELECT TOP 100 * FROM ( " +
                "    SELECT d.document_id, d.title, d.description, d.cover_image, d.file_type, " +
                "           N'VIEW' AS action_type, vh.viewed_at AS action_time " +
                "    FROM document_view_history vh " +
                "    JOIN documents d ON vh.document_id = d.document_id " +
                "    WHERE vh.user_id = ? " +
                "    UNION ALL " +
                "    SELECT d.document_id, d.title, d.description, d.cover_image, d.file_type, " +
                "           N'DOWNLOAD' AS action_type, dh.downloaded_at AS action_time " +
                "    FROM document_download_history dh " +
                "    JOIN documents d ON dh.document_id = d.document_id " +
                "    WHERE dh.user_id = ? " +
                ") x " +
                "ORDER BY x.action_time DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setInt(2, userId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    HistoryItem item = new HistoryItem();

                    item.setDocumentId(rs.getInt("document_id"));
                    item.setTitle(rs.getString("title"));
                    item.setDescription(rs.getString("description"));
                    item.setCoverImage(rs.getString("cover_image"));
                    item.setFileType(rs.getString("file_type"));
                    item.setActionType(rs.getString("action_type"));

                    Timestamp time = rs.getTimestamp("action_time");
                    item.setActionTime(time != null ? time.toString() : "");

                    list.add(item);
                }
            }

        } catch (Exception e) {
            System.out.println("Lỗi lấy lịch sử tài liệu!");
            e.printStackTrace();
        }

        return list;
    }
}
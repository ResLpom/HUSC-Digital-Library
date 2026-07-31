package vn.edu.husc.library.servlet;

import vn.edu.husc.library.config.DBConnection;
import vn.edu.husc.library.model.Document;
import vn.edu.husc.library.model.User;

import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.IOException;
import java.lang.reflect.Method;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class FavoriteDocumentServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

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

        List<Document> favoriteDocuments = getFavoriteDocuments(currentUser.getUserId());

        request.setAttribute("favoriteDocuments", favoriteDocuments);
        request.getRequestDispatcher("/favorite-documents.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        User currentUser = getCurrentUser(request);

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String action = request.getParameter("action");

        if ("remove".equalsIgnoreCase(action)) {
            int documentId = parseInt(request.getParameter("documentId"), 0);

            if (documentId > 0) {
                removeFavorite(currentUser.getUserId(), documentId);
            }
        }

        response.sendRedirect(request.getContextPath() + "/favorite-documents");
    }

    private List<Document> getFavoriteDocuments(int userId) {
        List<Document> list = new ArrayList<>();

        String sql =
                "SELECT d.* " +
                "FROM document_favorites df " +
                "JOIN documents d ON df.document_id = d.document_id " +
                "WHERE df.user_id = ? " +
                "ORDER BY df.created_at DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Document doc = mapDocument(rs);
                    list.add(doc);
                }
            }

        } catch (Exception e) {
            System.out.println("Lỗi lấy danh sách tài liệu yêu thích!");
            e.printStackTrace();
        }

        return list;
    }

    private void removeFavorite(int userId, int documentId) {
        String sql = "DELETE FROM document_favorites WHERE user_id = ? AND document_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setInt(2, documentId);
            ps.executeUpdate();

        } catch (Exception e) {
            System.out.println("Lỗi xóa tài liệu yêu thích!");
            e.printStackTrace();
        }
    }

    private Document mapDocument(ResultSet rs) throws SQLException {
        Document doc = new Document();

        setValue(doc, "setDocumentId", getIntSafe(rs, "document_id"));
        setValue(doc, "setTitle", getStringSafe(rs, "title"));
        setValue(doc, "setDescription", getStringSafe(rs, "description"));
        setValue(doc, "setPublishYear", getIntSafe(rs, "publish_year"));
        setValue(doc, "setFilePath", getStringSafe(rs, "file_path"));
        setValue(doc, "setCoverImage", getStringSafe(rs, "cover_image"));
        setValue(doc, "setStatus", getStringSafe(rs, "status"));

        setValue(doc, "setSourceName", getStringSafe(rs, "source_name"));
        setValue(doc, "setSourceUrl", getStringSafe(rs, "source_url"));
        setValue(doc, "setSubjectName", getStringSafe(rs, "subject_name"));
        setValue(doc, "setDepartmentName", getStringSafe(rs, "department_name"));
        setValue(doc, "setSummary", getStringSafe(rs, "summary"));
        setValue(doc, "setKeywords", getStringSafe(rs, "keywords"));
        setValue(doc, "setFileType", getStringSafe(rs, "file_type"));
        setValue(doc, "setFileSize", getLongSafe(rs, "file_size"));
        setValue(doc, "setViewCount", getIntSafe(rs, "view_count"));
        setValue(doc, "setDownloadCount", getIntSafe(rs, "download_count"));
        setValue(doc, "setFeatured", getBooleanSafe(rs, "is_featured"));
        setValue(doc, "setCreatedAt", getTimestampSafe(rs, "created_at"));
        setValue(doc, "setUpdatedAt", getTimestampSafe(rs, "updated_at"));

        return doc;
    }

    private boolean hasColumn(ResultSet rs, String columnName) throws SQLException {
        ResultSetMetaData metaData = rs.getMetaData();
        int count = metaData.getColumnCount();

        for (int i = 1; i <= count; i++) {
            if (columnName.equalsIgnoreCase(metaData.getColumnLabel(i))) {
                return true;
            }
        }

        return false;
    }

    private String getStringSafe(ResultSet rs, String columnName) throws SQLException {
        if (!hasColumn(rs, columnName)) {
            return null;
        }

        return rs.getString(columnName);
    }

    private Integer getIntSafe(ResultSet rs, String columnName) throws SQLException {
        if (!hasColumn(rs, columnName)) {
            return null;
        }

        int value = rs.getInt(columnName);
        return rs.wasNull() ? null : value;
    }

    private Long getLongSafe(ResultSet rs, String columnName) throws SQLException {
        if (!hasColumn(rs, columnName)) {
            return null;
        }

        long value = rs.getLong(columnName);
        return rs.wasNull() ? null : value;
    }

    private Boolean getBooleanSafe(ResultSet rs, String columnName) throws SQLException {
        if (!hasColumn(rs, columnName)) {
            return null;
        }

        boolean value = rs.getBoolean(columnName);
        return rs.wasNull() ? null : value;
    }

    private Timestamp getTimestampSafe(ResultSet rs, String columnName) throws SQLException {
        if (!hasColumn(rs, columnName)) {
            return null;
        }

        return rs.getTimestamp(columnName);
    }

    private void setValue(Object target, String methodName, Object value) {
        if (target == null || value == null) {
            return;
        }

        Method[] methods = target.getClass().getMethods();

        for (Method method : methods) {
            if (!method.getName().equals(methodName)) {
                continue;
            }

            if (method.getParameterCount() != 1) {
                continue;
            }

            try {
                Class<?> type = method.getParameterTypes()[0];
                Object convertedValue = convertValue(value, type);

                if (convertedValue != null) {
                    method.invoke(target, convertedValue);
                    return;
                }

            } catch (Exception e) {
                // ignore
            }
        }
    }

    private Object convertValue(Object value, Class<?> type) {
        if (value == null) {
            return null;
        }

        if (type.isAssignableFrom(value.getClass())) {
            return value;
        }

        String text = value.toString();

        try {
            if (type == String.class) {
                return text;
            }

            if (type == int.class || type == Integer.class) {
                if (value instanceof Number) {
                    return ((Number) value).intValue();
                }

                return Integer.parseInt(text);
            }

            if (type == long.class || type == Long.class) {
                if (value instanceof Number) {
                    return ((Number) value).longValue();
                }

                return Long.parseLong(text);
            }

            if (type == double.class || type == Double.class) {
                if (value instanceof Number) {
                    return ((Number) value).doubleValue();
                }

                return Double.parseDouble(text);
            }

            if (type == boolean.class || type == Boolean.class) {
                if (value instanceof Boolean) {
                    return value;
                }

                return "true".equalsIgnoreCase(text) || "1".equals(text);
            }

            if (type == Timestamp.class && value instanceof Timestamp) {
                return value;
            }

        } catch (Exception e) {
            return null;
        }

        return null;
    }

    private int parseInt(String value, int defaultValue) {
        try {
            if (value == null || value.trim().isEmpty()) {
                return defaultValue;
            }

            return Integer.parseInt(value.trim());

        } catch (Exception e) {
            return defaultValue;
        }
    }
}
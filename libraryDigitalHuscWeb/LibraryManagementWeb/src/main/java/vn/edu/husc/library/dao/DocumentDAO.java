package vn.edu.husc.library.dao;

import vn.edu.husc.library.config.DBConnection;
import vn.edu.husc.library.model.Document;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class DocumentDAO {

    public List<Document> getAllDocuments() {
        List<Document> list = new ArrayList<Document>();

        String sql = "SELECT "
                + "d.document_id, "
                + "d.category_id, "
                + "d.type_id, "
                + "d.author_id, "
                + "d.publisher_id, "
                + "d.title, "
                + "d.description, "
                + "d.publish_year, "
                + "d.file_path, "
                + "d.cover_image, "
                + "d.status, "
                + "d.created_at, "
                + "d.source_name, "
                + "d.source_url, "
                + "d.subject_name, "
                + "d.department_name, "
                + "d.summary, "
                + "d.keywords, "
                + "d.file_type, "
                + "d.file_size, "
                + "d.view_count, "
                + "d.download_count, "
                + "d.is_featured, "
                + "d.updated_at, "
                + "c.category_name, "
                + "t.type_name, "
                + "a.author_name, "
                + "p.publisher_name "
                + "FROM documents d "
                + "JOIN document_categories c ON d.category_id = c.category_id "
                + "JOIN document_types t ON d.type_id = t.type_id "
                + "LEFT JOIN authors a ON d.author_id = a.author_id "
                + "LEFT JOIN publishers p ON d.publisher_id = p.publisher_id "
                + "WHERE d.status = 'ACTIVE' "
                + "ORDER BY d.document_id DESC";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                list.add(mapDocument(rs));
            }

        } catch (Exception e) {
            System.out.println("Lỗi lấy danh sách tài liệu!");
            e.printStackTrace();
        }

        return list;
    }

    public List<Document> searchDocuments(String keyword) {
        List<Document> list = new ArrayList<Document>();

        String sql = "SELECT "
                + "d.document_id, "
                + "d.category_id, "
                + "d.type_id, "
                + "d.author_id, "
                + "d.publisher_id, "
                + "d.title, "
                + "d.description, "
                + "d.publish_year, "
                + "d.file_path, "
                + "d.cover_image, "
                + "d.status, "
                + "d.created_at, "
                + "d.source_name, "
                + "d.source_url, "
                + "d.subject_name, "
                + "d.department_name, "
                + "d.summary, "
                + "d.keywords, "
                + "d.file_type, "
                + "d.file_size, "
                + "d.view_count, "
                + "d.download_count, "
                + "d.is_featured, "
                + "d.updated_at, "
                + "c.category_name, "
                + "t.type_name, "
                + "a.author_name, "
                + "p.publisher_name "
                + "FROM documents d "
                + "JOIN document_categories c ON d.category_id = c.category_id "
                + "JOIN document_types t ON d.type_id = t.type_id "
                + "LEFT JOIN authors a ON d.author_id = a.author_id "
                + "LEFT JOIN publishers p ON d.publisher_id = p.publisher_id "
                + "WHERE d.status = 'ACTIVE' AND ("
                + "d.title LIKE ? "
                + "OR d.description LIKE ? "
                + "OR c.category_name LIKE ? "
                + "OR t.type_name LIKE ? "
                + "OR a.author_name LIKE ? "
                + "OR p.publisher_name LIKE ? "
                + "OR d.source_name LIKE ? "
                + "OR d.subject_name LIKE ? "
                + "OR d.department_name LIKE ? "
                + "OR d.keywords LIKE ? "
                + ") "
                + "ORDER BY d.document_id DESC";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            String key = "%" + keyword + "%";

            for (int i = 1; i <= 10; i++) {
                ps.setString(i, key);
            }

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                list.add(mapDocument(rs));
            }

        } catch (Exception e) {
            System.out.println("Lỗi tìm kiếm tài liệu!");
            e.printStackTrace();
        }

        return list;
    }

    public Document getDocumentById(int documentId) {
        String sql = "SELECT "
                + "d.document_id, "
                + "d.category_id, "
                + "d.type_id, "
                + "d.author_id, "
                + "d.publisher_id, "
                + "d.title, "
                + "d.description, "
                + "d.publish_year, "
                + "d.file_path, "
                + "d.cover_image, "
                + "d.status, "
                + "d.created_at, "
                + "d.source_name, "
                + "d.source_url, "
                + "d.subject_name, "
                + "d.department_name, "
                + "d.summary, "
                + "d.keywords, "
                + "d.file_type, "
                + "d.file_size, "
                + "d.view_count, "
                + "d.download_count, "
                + "d.is_featured, "
                + "d.updated_at, "
                + "c.category_name, "
                + "t.type_name, "
                + "a.author_name, "
                + "p.publisher_name "
                + "FROM documents d "
                + "JOIN document_categories c ON d.category_id = c.category_id "
                + "JOIN document_types t ON d.type_id = t.type_id "
                + "LEFT JOIN authors a ON d.author_id = a.author_id "
                + "LEFT JOIN publishers p ON d.publisher_id = p.publisher_id "
                + "WHERE d.document_id = ?";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setInt(1, documentId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return mapDocument(rs);
            }

        } catch (Exception e) {
            System.out.println("Lỗi lấy chi tiết tài liệu!");
            e.printStackTrace();
        }

        return null;
    }

    public List<Document> getFeaturedDocuments() {
        List<Document> list = new ArrayList<Document>();

        String sql = "SELECT TOP 6 "
                + "d.document_id, "
                + "d.category_id, "
                + "d.type_id, "
                + "d.author_id, "
                + "d.publisher_id, "
                + "d.title, "
                + "d.description, "
                + "d.publish_year, "
                + "d.file_path, "
                + "d.cover_image, "
                + "d.status, "
                + "d.created_at, "
                + "d.source_name, "
                + "d.source_url, "
                + "d.subject_name, "
                + "d.department_name, "
                + "d.summary, "
                + "d.keywords, "
                + "d.file_type, "
                + "d.file_size, "
                + "d.view_count, "
                + "d.download_count, "
                + "d.is_featured, "
                + "d.updated_at, "
                + "c.category_name, "
                + "t.type_name, "
                + "a.author_name, "
                + "p.publisher_name "
                + "FROM documents d "
                + "JOIN document_categories c ON d.category_id = c.category_id "
                + "JOIN document_types t ON d.type_id = t.type_id "
                + "LEFT JOIN authors a ON d.author_id = a.author_id "
                + "LEFT JOIN publishers p ON d.publisher_id = p.publisher_id "
                + "WHERE d.status = 'ACTIVE' AND d.is_featured = 1 "
                + "ORDER BY d.view_count DESC";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                list.add(mapDocument(rs));
            }

        } catch (Exception e) {
            System.out.println("Lỗi lấy tài liệu nổi bật!");
            e.printStackTrace();
        }

        return list;
    }

    public List<Document> getRelatedDocuments(int documentId, int categoryId) {
        List<Document> list = new ArrayList<Document>();

        String sql = "SELECT TOP 4 "
                + "d.document_id, "
                + "d.category_id, "
                + "d.type_id, "
                + "d.author_id, "
                + "d.publisher_id, "
                + "d.title, "
                + "d.description, "
                + "d.publish_year, "
                + "d.file_path, "
                + "d.cover_image, "
                + "d.status, "
                + "d.created_at, "
                + "d.source_name, "
                + "d.source_url, "
                + "d.subject_name, "
                + "d.department_name, "
                + "d.summary, "
                + "d.keywords, "
                + "d.file_type, "
                + "d.file_size, "
                + "d.view_count, "
                + "d.download_count, "
                + "d.is_featured, "
                + "d.updated_at, "
                + "c.category_name, "
                + "t.type_name, "
                + "a.author_name, "
                + "p.publisher_name "
                + "FROM documents d "
                + "JOIN document_categories c ON d.category_id = c.category_id "
                + "JOIN document_types t ON d.type_id = t.type_id "
                + "LEFT JOIN authors a ON d.author_id = a.author_id "
                + "LEFT JOIN publishers p ON d.publisher_id = p.publisher_id "
                + "WHERE d.status = 'ACTIVE' "
                + "AND d.document_id <> ? "
                + "AND d.category_id = ? "
                + "ORDER BY d.view_count DESC";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setInt(1, documentId);
            ps.setInt(2, categoryId);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                list.add(mapDocument(rs));
            }

        } catch (Exception e) {
            System.out.println("Lỗi lấy tài liệu liên quan!");
            e.printStackTrace();
        }

        return list;
    }

    public void increaseViewCount(int documentId) {
        String sql = "UPDATE documents SET view_count = view_count + 1 WHERE document_id = ?";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setInt(1, documentId);
            ps.executeUpdate();

        } catch (Exception e) {
            System.out.println("Lỗi tăng lượt xem!");
            e.printStackTrace();
        }
    }

    public void increaseDownloadCount(int documentId) {
        String sql = "UPDATE documents SET download_count = download_count + 1 WHERE document_id = ?";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setInt(1, documentId);
            ps.executeUpdate();

        } catch (Exception e) {
            System.out.println("Lỗi tăng lượt tải!");
            e.printStackTrace();
        }
    }

    public void addViewHistory(int userId, int documentId) {
        String sql = "INSERT INTO document_view_history(user_id, document_id) VALUES (?, ?)";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setInt(1, userId);
            ps.setInt(2, documentId);
            ps.executeUpdate();

        } catch (Exception e) {
            System.out.println("Lỗi lưu lịch sử xem!");
            e.printStackTrace();
        }
    }

    public void addDownloadHistory(int userId, int documentId) {
        String sql = "INSERT INTO document_download_history(user_id, document_id) VALUES (?, ?)";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setInt(1, userId);
            ps.setInt(2, documentId);
            ps.executeUpdate();

        } catch (Exception e) {
            System.out.println("Lỗi lưu lịch sử tải!");
            e.printStackTrace();
        }
    }

    public boolean isFavorite(int userId, int documentId) {
        String sql = "SELECT COUNT(*) FROM document_favorites WHERE user_id = ? AND document_id = ?";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setInt(1, userId);
            ps.setInt(2, documentId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt(1) > 0;
            }

        } catch (Exception e) {
            System.out.println("Lỗi kiểm tra yêu thích!");
            e.printStackTrace();
        }

        return false;
    }

    public void addFavorite(int userId, int documentId) {
        String sql = "INSERT INTO document_favorites(user_id, document_id) VALUES (?, ?)";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setInt(1, userId);
            ps.setInt(2, documentId);
            ps.executeUpdate();

        } catch (Exception e) {
            System.out.println("Lỗi thêm yêu thích!");
            e.printStackTrace();
        }
    }

    public void removeFavorite(int userId, int documentId) {
        String sql = "DELETE FROM document_favorites WHERE user_id = ? AND document_id = ?";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setInt(1, userId);
            ps.setInt(2, documentId);
            ps.executeUpdate();

        } catch (Exception e) {
            System.out.println("Lỗi xóa yêu thích!");
            e.printStackTrace();
        }
    }

    private Document mapDocument(ResultSet rs) throws Exception {
        Document doc = new Document();

        doc.setDocumentId(rs.getInt("document_id"));
        doc.setCategoryId(rs.getInt("category_id"));
        doc.setTypeId(rs.getInt("type_id"));

        int authorId = rs.getInt("author_id");
        if (rs.wasNull()) {
            doc.setAuthorId(null);
        } else {
            doc.setAuthorId(authorId);
        }

        int publisherId = rs.getInt("publisher_id");
        if (rs.wasNull()) {
            doc.setPublisherId(null);
        } else {
            doc.setPublisherId(publisherId);
        }

        doc.setTitle(rs.getString("title"));
        doc.setDescription(rs.getString("description"));
        doc.setPublishYear(rs.getInt("publish_year"));
        doc.setFilePath(rs.getString("file_path"));
        doc.setCoverImage(rs.getString("cover_image"));
        doc.setStatus(rs.getString("status"));
        doc.setCreatedAt(rs.getTimestamp("created_at"));

        doc.setCategoryName(rs.getString("category_name"));
        doc.setTypeName(rs.getString("type_name"));
        doc.setAuthorName(rs.getString("author_name"));
        doc.setPublisherName(rs.getString("publisher_name"));

        doc.setSourceName(rs.getString("source_name"));
        doc.setSourceUrl(rs.getString("source_url"));
        doc.setSubjectName(rs.getString("subject_name"));
        doc.setDepartmentName(rs.getString("department_name"));
        doc.setSummary(rs.getString("summary"));
        doc.setKeywords(rs.getString("keywords"));
        doc.setFileType(rs.getString("file_type"));
        doc.setFileSize(rs.getLong("file_size"));
        doc.setViewCount(rs.getInt("view_count"));
        doc.setDownloadCount(rs.getInt("download_count"));
        doc.setFeatured(rs.getBoolean("is_featured"));

        if (rs.getTimestamp("updated_at") != null) {
            doc.setUpdatedAt(rs.getTimestamp("updated_at").toString());
        } else {
        	doc.setUpdatedAt((String) null);
        }

        return doc;
    }
}
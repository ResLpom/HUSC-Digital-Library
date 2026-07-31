package vn.edu.husc.library.dao;

import vn.edu.husc.library.config.DBConnection;
import vn.edu.husc.library.model.Document;
import vn.edu.husc.library.model.OptionItem;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

public class AdminDocumentDAO {

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
                + "c.category_name, "
                + "t.type_name, "
                + "a.author_name, "
                + "p.publisher_name "
                + "FROM documents d "
                + "JOIN document_categories c ON d.category_id = c.category_id "
                + "JOIN document_types t ON d.type_id = t.type_id "
                + "LEFT JOIN authors a ON d.author_id = a.author_id "
                + "LEFT JOIN publishers p ON d.publisher_id = p.publisher_id "
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
            System.out.println("Lỗi lấy danh sách tài liệu quản trị!");
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
            System.out.println("Lỗi lấy tài liệu theo ID!");
            e.printStackTrace();
        }

        return null;
    }

    public boolean insertDocument(Document doc) {
        String sql = "INSERT INTO documents "
                + "(category_id, type_id, author_id, publisher_id, title, description, publish_year, file_path, cover_image, status) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            setDocumentParams(ps, doc, false);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            System.out.println("Lỗi thêm tài liệu!");
            e.printStackTrace();
        }

        return false;
    }

    public boolean updateDocument(Document doc) {
        String sql = "UPDATE documents SET "
                + "category_id = ?, "
                + "type_id = ?, "
                + "author_id = ?, "
                + "publisher_id = ?, "
                + "title = ?, "
                + "description = ?, "
                + "publish_year = ?, "
                + "file_path = ?, "
                + "cover_image = ?, "
                + "status = ? "
                + "WHERE document_id = ?";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            setDocumentParams(ps, doc, true);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            System.out.println("Lỗi cập nhật tài liệu!");
            e.printStackTrace();
        }

        return false;
    }

    public boolean hideDocument(int documentId) {
        String sql = "UPDATE documents SET status = 'INACTIVE' WHERE document_id = ?";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setInt(1, documentId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            System.out.println("Lỗi ẩn tài liệu!");
            e.printStackTrace();
        }

        return false;
    }

    public List<OptionItem> getCategories() {
        return getOptions("SELECT category_id, category_name FROM document_categories ORDER BY category_name");
    }

    public List<OptionItem> getTypes() {
        return getOptions("SELECT type_id, type_name FROM document_types ORDER BY type_name");
    }

    public List<OptionItem> getAuthors() {
        return getOptions("SELECT author_id, author_name FROM authors ORDER BY author_name");
    }

    public List<OptionItem> getPublishers() {
        return getOptions("SELECT publisher_id, publisher_name FROM publishers ORDER BY publisher_name");
    }

    private List<OptionItem> getOptions(String sql) {
        List<OptionItem> list = new ArrayList<OptionItem>();

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                list.add(new OptionItem(rs.getInt(1), rs.getString(2)));
            }

        } catch (Exception e) {
            System.out.println("Lỗi lấy dữ liệu dropdown!");
            e.printStackTrace();
        }

        return list;
    }

    private void setDocumentParams(PreparedStatement ps, Document doc, boolean isUpdate) throws Exception {
        ps.setInt(1, doc.getCategoryId());
        ps.setInt(2, doc.getTypeId());

        if (doc.getAuthorId() == null) {
            ps.setNull(3, Types.INTEGER);
        } else {
            ps.setInt(3, doc.getAuthorId());
        }

        if (doc.getPublisherId() == null) {
            ps.setNull(4, Types.INTEGER);
        } else {
            ps.setInt(4, doc.getPublisherId());
        }

        ps.setString(5, doc.getTitle());
        ps.setString(6, doc.getDescription());
        ps.setInt(7, doc.getPublishYear());
        ps.setString(8, doc.getFilePath());
        ps.setString(9, doc.getCoverImage());
        ps.setString(10, doc.getStatus());

        if (isUpdate) {
            ps.setInt(11, doc.getDocumentId());
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

        return doc;
    }
    public Integer findAuthorIdByName(String authorName) {
        String sql = "SELECT author_id FROM authors WHERE author_name = ?";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setString(1, authorName);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt("author_id");
            }

        } catch (Exception e) {
            System.out.println("Lỗi tìm tác giả theo tên!");
            e.printStackTrace();
        }

        return null;
    }

    public Integer insertAuthorAndReturnId(String authorName) {
        String sql = "INSERT INTO authors(author_name) VALUES (?)";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql, java.sql.Statement.RETURN_GENERATED_KEYS)
        ) {
            ps.setString(1, authorName);

            int rows = ps.executeUpdate();

            if (rows > 0) {
                ResultSet rs = ps.getGeneratedKeys();

                if (rs.next()) {
                    return rs.getInt(1);
                }
            }

        } catch (Exception e) {
            System.out.println("Lỗi thêm tác giả mới!");
            e.printStackTrace();
        }

        return null;
    }
    public Integer findPublisherIdByName(String publisherName) {
        String sql = "SELECT publisher_id FROM publishers WHERE publisher_name = ?";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setString(1, publisherName);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt("publisher_id");
            }

        } catch (Exception e) {
            System.out.println("Lỗi tìm nhà xuất bản theo tên!");
            e.printStackTrace();
        }

        return null;
    }

    public Integer insertPublisherAndReturnId(String publisherName) {
        String sql = "INSERT INTO publishers(publisher_name) VALUES (?)";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql, java.sql.Statement.RETURN_GENERATED_KEYS)
        ) {
            ps.setString(1, publisherName);

            int rows = ps.executeUpdate();

            if (rows > 0) {
                ResultSet rs = ps.getGeneratedKeys();

                if (rs.next()) {
                    return rs.getInt(1);
                }
            }

        } catch (Exception e) {
            System.out.println("Lỗi thêm nhà xuất bản mới!");
            e.printStackTrace();
        }

        return null;
    }
}
package vn.edu.husc.library.servlet;

import vn.edu.husc.library.config.DBConnection;
import vn.edu.husc.library.model.User;

import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.File;
import java.io.IOException;
import java.text.Normalizer;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.Year;
import java.util.regex.Pattern;

public class AdminDocumentFolderImportServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final String ROOT_FOLDER = "D:/upLoad/file_document";
    private static final String COVER_FOLDER = "D:/upLoad/document";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        syncFolders(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        syncFolders(request, response);
    }

    private void syncFolders(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        User currentUser = getCurrentUser(request);

        if (!isAdmin(currentUser)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        File rootFolder = new File(ROOT_FOLDER);

        if (!rootFolder.exists() || !rootFolder.isDirectory()) {
            request.getSession().setAttribute(
                    "adminDocumentError",
                    "Không tìm thấy thư mục tài liệu: " + ROOT_FOLDER
            );

            response.sendRedirect(request.getContextPath() + "/admin/documents");
            return;
        }

        File[] folders = rootFolder.listFiles();

        if (folders == null || folders.length == 0) {
            request.getSession().setAttribute(
                    "adminDocumentError",
                    "Thư mục file_document chưa có folder học phần nào."
            );

            response.sendRedirect(request.getContextPath() + "/admin/documents");
            return;
        }

        int inserted = 0;
        int skipped = 0;
        int updatedCover = 0;
        int failed = 0;

        try (Connection conn = DBConnection.getConnection()) {

            int categoryId = getFirstId(conn, "categories", "category_id", 1);
            int typeId = getFirstId(conn, "types", "type_id", 1);
            int authorId = getFirstId(conn, "authors", "author_id", 1);
            int publisherId = getFirstId(conn, "publishers", "publisher_id", 1);

            for (File folder : folders) {
                if (!folder.isDirectory()) {
                    continue;
                }

                String folderName = folder.getName();

                if (folderName == null || folderName.trim().isEmpty()) {
                    continue;
                }

                folderName = folderName.trim();

                String coverImage = findCoverImage(folderName);

                if (existsByFilePath(conn, folderName)) {
                    skipped++;

                    if (coverImage != null && !coverImage.trim().isEmpty()) {
                        if (updateCoverImage(conn, folderName, coverImage)) {
                            updatedCover++;
                        }
                    }

                    continue;
                }

                boolean success = insertDocumentFromFolder(
                        conn,
                        folder,
                        folderName,
                        coverImage,
                        categoryId,
                        typeId,
                        authorId,
                        publisherId
                );

                if (success) {
                    inserted++;
                } else {
                    failed++;
                }
            }

        } catch (Exception e) {
            System.out.println("Lỗi đồng bộ folder tài liệu!");
            e.printStackTrace();

            request.getSession().setAttribute(
                    "adminDocumentError",
                    "Đồng bộ folder thất bại. Kiểm tra Console để xem lỗi."
            );

            response.sendRedirect(request.getContextPath() + "/admin/documents");
            return;
        }

        request.getSession().setAttribute(
                "adminDocumentSuccess",
                "Đồng bộ folder hoàn tất. Thêm mới: " + inserted
                        + ", đã tồn tại: " + skipped
                        + ", cập nhật ảnh bìa: " + updatedCover
                        + ", lỗi: " + failed + "."
        );

        response.sendRedirect(request.getContextPath() + "/admin/documents");
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

    private boolean isAdmin(User user) {
        return user != null
                && user.getRoleCode() != null
                && "ADMIN".equalsIgnoreCase(user.getRoleCode());
    }

    private boolean existsByFilePath(Connection conn, String filePath) {
        String sql = "SELECT TOP 1 document_id FROM documents WHERE file_path = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, filePath);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }

        } catch (Exception e) {
            System.out.println("Lỗi kiểm tra file_path: " + filePath);
            e.printStackTrace();
        }

        return false;
    }

    private boolean insertDocumentFromFolder(Connection conn,
                                             File folder,
                                             String folderName,
                                             String coverImage,
                                             int categoryId,
                                             int typeId,
                                             int authorId,
                                             int publisherId) {

        String title = toTitle(folderName);
        int fileCount = countFiles(folder);

        String description = "Tài liệu học phần " + title
                + " được đồng bộ tự động từ thư mục "
                + folderName
                + ". Học phần hiện có "
                + fileCount
                + " file tài liệu.";

        int publishYear = Year.now().getValue();

        String sql = "INSERT INTO documents "
                + "(category_id, type_id, author_id, publisher_id, title, description, "
                + "publish_year, file_path, cover_image, status, created_at) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'ACTIVE', GETDATE())";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, categoryId);
            ps.setInt(2, typeId);
            ps.setInt(3, authorId);
            ps.setInt(4, publisherId);
            ps.setString(5, title);
            ps.setString(6, description);
            ps.setInt(7, publishYear);
            ps.setString(8, folderName);
            ps.setString(9, coverImage);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            System.out.println("Lỗi thêm tài liệu từ folder: " + folderName);
            e.printStackTrace();
        }

        return false;
    }

    private boolean updateCoverImage(Connection conn, String filePath, String coverImage) {
        String sql = "UPDATE documents "
                + "SET cover_image = ? "
                + "WHERE file_path = ? "
                + "AND (cover_image IS NULL OR LTRIM(RTRIM(cover_image)) = '')";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, coverImage);
            ps.setString(2, filePath);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            System.out.println("Lỗi cập nhật ảnh bìa cho folder: " + filePath);
            e.printStackTrace();
        }

        return false;
    }

    private int getFirstId(Connection conn, String tableName, String idColumn, int defaultValue) {
        String[] possibleColumns = {
                idColumn,
                "id",
                tableName + "_id"
        };

        for (String column : possibleColumns) {
            String sql = "SELECT TOP 1 " + column
                    + " FROM " + tableName
                    + " ORDER BY " + column;

            try (
                    PreparedStatement ps = conn.prepareStatement(sql);
                    ResultSet rs = ps.executeQuery()
            ) {
                if (rs.next()) {
                    return rs.getInt(column);
                }

            } catch (Exception ignored) {
            }
        }

        System.out.println("Không lấy được ID mặc định từ bảng: " + tableName);
        return defaultValue;
    }

    private int countFiles(File folder) {
        File[] files = folder.listFiles();

        if (files == null) {
            return 0;
        }

        int count = 0;

        for (File file : files) {
            if (file.isFile()) {
                count++;
            }
        }

        return count;
    }

    private String findCoverImage(String folderName) {
        File coverFolder = new File(COVER_FOLDER);

        if (!coverFolder.exists() || !coverFolder.isDirectory()) {
            return null;
        }

        File[] files = coverFolder.listFiles();

        if (files == null) {
            return null;
        }

        String normalizedFolder = normalize(folderName);
        String acronymFolder = acronym(folderName);

        for (File file : files) {
            if (!file.isFile() || !isImage(file.getName())) {
                continue;
            }

            String baseName = removeExtension(file.getName());
            String normalizedBase = normalize(baseName);

            if (normalizedBase.equals(normalizedFolder)) {
                return file.getName();
            }
        }

        for (File file : files) {
            if (!file.isFile() || !isImage(file.getName())) {
                continue;
            }

            String baseName = removeExtension(file.getName());
            String normalizedBase = normalize(baseName);

            if (normalizedBase.equals(normalize(acronymFolder))) {
                return file.getName();
            }
        }

        return null;
    }

    private boolean isImage(String fileName) {
        String lower = fileName.toLowerCase();

        return lower.endsWith(".jpg")
                || lower.endsWith(".jpeg")
                || lower.endsWith(".png")
                || lower.endsWith(".webp")
                || lower.endsWith(".gif");
    }

    private String removeExtension(String fileName) {
        int index = fileName.lastIndexOf(".");

        if (index > 0) {
            return fileName.substring(0, index);
        }

        return fileName;
    }

    private String normalize(String value) {
        if (value == null) {
            return "";
        }

        String result = value;

        result = result.replace("&", "_");
        result = result.replace("+", "plus");

        result = Normalizer.normalize(result, Normalizer.Form.NFD);
        result = Pattern.compile("\\p{InCombiningDiacriticalMarks}+").matcher(result).replaceAll("");

        result = result.replace("Đ", "D").replace("đ", "d");
        result = result.toLowerCase();
        result = result.replaceAll("[^a-z0-9]", "");

        return result;
    }

    private String acronym(String value) {
        if (value == null || value.trim().isEmpty()) {
            return "";
        }

        String prepared = value
                .replace("&", "_")
                .replace("-", "_")
                .replace(" ", "_");

        String[] parts = prepared.split("_+");

        StringBuilder result = new StringBuilder();

        for (String part : parts) {
            if (part == null || part.trim().isEmpty()) {
                continue;
            }

            part = part.trim();

            result.append(part.charAt(0));

            for (int i = 1; i < part.length(); i++) {
                char c = part.charAt(i);

                if (Character.isUpperCase(c)) {
                    result.append(c);
                }
            }
        }

        return result.toString();
    }

    private String toTitle(String folderName) {
        String title = folderName;

        title = title.replace("_", " ");
        title = title.replace("-", " ");
        title = title.replace("&", " & ");
        title = title.replaceAll("\\s+", " ");
        title = title.trim();

        if (title.isEmpty()) {
            return folderName;
        }

        return title;
    }
}
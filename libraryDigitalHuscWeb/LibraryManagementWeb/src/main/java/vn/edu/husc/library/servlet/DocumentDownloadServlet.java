package vn.edu.husc.library.servlet;

import vn.edu.husc.library.config.DBConnection;

import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.*;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import vn.edu.husc.library.util.DocumentStorageUtil;

public class DocumentDownloadServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final String ROOT_FOLDER = "D:/upLoad/file_document";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        String fileParam = request.getParameter("file");

        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu mã tài liệu.");
            return;
        }

        int documentId;

        try {
            documentId = Integer.parseInt(idParam.trim());
        } catch (Exception e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Mã tài liệu không hợp lệ.");
            return;
        }

        String filePath = getDocumentFilePath(documentId);

        if (filePath == null || filePath.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Tài liệu chưa có đường dẫn file.");
            return;
        }

        filePath = filePath.trim().replace("\\", "/");

        if (!isSafeRelativePath(filePath)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Đường dẫn tài liệu không hợp lệ.");
            return;
        }

        File root = DocumentStorageUtil.getRootFolder();
        File resource = DocumentStorageUtil.resolveResource(filePath);
        
        File downloadFile;

        if (resource.exists() && resource.isFile()) {
            downloadFile = resource;

        } else if (resource.exists() && resource.isDirectory()) {

            if (fileParam == null || fileParam.trim().isEmpty()) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Vui lòng chọn file cần tải.");
                return;
            }

            String fileName = URLDecoder.decode(fileParam, StandardCharsets.UTF_8.name()).trim();

            if (!isSafeFileName(fileName)) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Tên file không hợp lệ.");
                return;
            }

            downloadFile = DocumentStorageUtil.resolveFileInside(resource, fileName);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy tài nguyên: " + filePath);
            return;
        }

        if (!isSafeChild(root, downloadFile)
                || !downloadFile.exists()
                || !downloadFile.isFile()) {

            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy file cần tải.");
            return;
        }

        String downloadName = downloadFile.getName();
        String encodedName = URLEncoder.encode(downloadName, StandardCharsets.UTF_8.name())
                .replace("+", "%20");

        response.setContentType(getContentType(downloadName));
        response.setHeader("Content-Disposition", "attachment; filename*=UTF-8''" + encodedName);
        response.setContentLengthLong(downloadFile.length());

        try (
                FileInputStream input = new FileInputStream(downloadFile);
                OutputStream output = response.getOutputStream()
        ) {
            byte[] buffer = new byte[8192];
            int length;

            while ((length = input.read(buffer)) != -1) {
                output.write(buffer, 0, length);
            }
        }
    }

    private String getDocumentFilePath(int documentId) {
        String sql = "SELECT file_path FROM documents WHERE document_id = ?";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setInt(1, documentId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("file_path");
                }
            }

        } catch (Exception e) {
            System.out.println("Lỗi lấy file_path tài liệu!");
            e.printStackTrace();
        }

        return null;
    }

    private boolean isSafeRelativePath(String path) {
        return path != null
                && !path.contains("..")
                && !path.contains(":")
                && !path.startsWith("/")
                && !path.startsWith("\\");
    }

    private boolean isSafeFileName(String fileName) {
        return fileName != null
                && !fileName.trim().isEmpty()
                && !fileName.contains("..")
                && !fileName.contains("/")
                && !fileName.contains("\\")
                && !fileName.contains(":");
    }

    private boolean isSafeChild(File root, File file) {
        try {
            String rootPath = root.getCanonicalPath();
            String filePath = file.getCanonicalPath();

            return filePath.equals(rootPath) || filePath.startsWith(rootPath + File.separator);

        } catch (Exception e) {
            return false;
        }
    }

    private String getContentType(String fileName) {
        String lower = fileName.toLowerCase();

        if (lower.endsWith(".pdf")) {
            return "application/pdf";
        }

        if (lower.endsWith(".html") || lower.endsWith(".htm")) {
            return "text/html; charset=UTF-8";
        }

        if (lower.endsWith(".txt")) {
            return "text/plain; charset=UTF-8";
        }

        if (lower.endsWith(".doc")) {
            return "application/msword";
        }

        if (lower.endsWith(".docx")) {
            return "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
        }

        if (lower.endsWith(".ppt")) {
            return "application/vnd.ms-powerpoint";
        }

        if (lower.endsWith(".pptx")) {
            return "application/vnd.openxmlformats-officedocument.presentationml.presentation";
        }

        if (lower.endsWith(".xls")) {
            return "application/vnd.ms-excel";
        }

        if (lower.endsWith(".xlsx")) {
            return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
        }

        if (lower.endsWith(".zip")) {
            return "application/zip";
        }

        return "application/octet-stream";
    }
}
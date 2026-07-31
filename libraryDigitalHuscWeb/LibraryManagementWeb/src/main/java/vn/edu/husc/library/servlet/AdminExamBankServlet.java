package vn.edu.husc.library.servlet;

import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.text.Collator;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import vn.edu.husc.library.util.ExamStorageConfig;

public class AdminExamBankServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final String UPLOAD_ROOT = "D:/upLoad";
    private static final String EXAM_BANK_FOLDER = "exam-bank";
    private File getBaseDir(String type) {
        type = ExamStorageConfig.normalizeType(type);

        File baseDir = ExamStorageConfig.getRootFolder(type);

        if (!baseDir.exists()) {
            baseDir.mkdirs();
        }

        return baseDir;
    }
    public static class AdminExamItem {
        private String name;
        private boolean directory;
        private String fileType;
        private String fileSize;
        private String modifiedTime;

        public AdminExamItem(String name, boolean directory, String fileType, String fileSize, String modifiedTime) {
            this.name = name;
            this.directory = directory;
            this.fileType = fileType;
            this.fileSize = fileSize;
            this.modifiedTime = modifiedTime;
        }

        public String getName() {
            return name;
        }

        public boolean isDirectory() {
            return directory;
        }

        public String getFileType() {
            return fileType;
        }

        public String getFileSize() {
            return fileSize;
        }

        public String getModifiedTime() {
            return modifiedTime;
        }

        public boolean isPdf() {
            return "pdf".equalsIgnoreCase(fileType);
        }

        public boolean isImage() {
            return "jpg".equalsIgnoreCase(fileType)
                    || "jpeg".equalsIgnoreCase(fileType)
                    || "png".equalsIgnoreCase(fileType)
                    || "gif".equalsIgnoreCase(fileType)
                    || "webp".equalsIgnoreCase(fileType);
        }

        public boolean isOffice() {
            return "doc".equalsIgnoreCase(fileType)
                    || "docx".equalsIgnoreCase(fileType)
                    || "xls".equalsIgnoreCase(fileType)
                    || "xlsx".equalsIgnoreCase(fileType)
                    || "ppt".equalsIgnoreCase(fileType)
                    || "pptx".equalsIgnoreCase(fileType);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        showPage(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");

        if ("delete".equalsIgnoreCase(action)) {
            deleteFile(request, response);
            return;
        }

        uploadFile(request, response);
    }

    private void showPage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        File uploadRoot = new File(UPLOAD_ROOT);

        if (!uploadRoot.exists()) {
            uploadRoot.mkdirs();
        }

        ensureBaseFolders(uploadRoot);

        HttpSession session = request.getSession();

        String success = (String) session.getAttribute("examSuccess");
        String error = (String) session.getAttribute("examError");

        session.removeAttribute("examSuccess");
        session.removeAttribute("examError");

        String type = cleanType(request.getParameter("type"));
        String faculty = cleanName(request.getParameter("faculty"));
        String subject = cleanName(request.getParameter("subject"));
        String year = cleanName(request.getParameter("year"));
        String keyword = request.getParameter("keyword");

        if (keyword == null) {
            keyword = "";
        }

        String view = getView(type, faculty, subject, year);

        File currentDir = uploadRoot;

        if (type != null) {
            currentDir = new File(currentDir, type);
            currentDir = new File(currentDir, EXAM_BANK_FOLDER);
        }

        if (faculty != null) {
            currentDir = new File(currentDir, faculty);
        }

        if (subject != null) {
            currentDir = new File(currentDir, subject);
        }

        if (year != null) {
            currentDir = new File(currentDir, year);
        }

        if (!isSafeChild(uploadRoot, currentDir)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        List<AdminExamItem> items = new ArrayList<>();

        if (!"types".equals(view)) {
            if (!currentDir.exists() || !currentDir.isDirectory()) {
                error = "Không tìm thấy thư mục dữ liệu.";
            } else {
                items = listItems(currentDir, view, keyword);
            }
        }

        request.setAttribute("success", success);
        request.setAttribute("error", error);
        request.setAttribute("items", items);
        request.setAttribute("view", view);
        request.setAttribute("type", type);
        request.setAttribute("faculty", faculty);
        request.setAttribute("subject", subject);
        request.setAttribute("year", year);
        request.setAttribute("keyword", keyword);
        request.setAttribute("uploadRoot", UPLOAD_ROOT);

        request.getRequestDispatcher("/admin/exam-bank.jsp").forward(request, response);
    }

    private void uploadFile(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String type = cleanType(request.getParameter("type"));
        String faculty = cleanFolderName(request.getParameter("faculty"));
        String subject = cleanFolderName(request.getParameter("subject"));
        String year = cleanFolderName(request.getParameter("year"));

        HttpSession session = request.getSession();

        if (type == null || faculty == null || subject == null || year == null) {
            session.setAttribute("examError", "Vui lòng nhập đầy đủ loại tài liệu, khoa, học phần và niên khóa.");
            response.sendRedirect(request.getContextPath() + "/admin/exam-bank");
            return;
        }

        Part filePart = request.getPart("file");

        if (filePart == null || filePart.getSize() <= 0) {
            session.setAttribute("examError", "Vui lòng chọn file cần tải lên.");
            response.sendRedirect(buildAdminUrl(request, type, faculty, subject, year));
            return;
        }

        String originalFileName = getSubmittedFileName(filePart);
        String extension = getExtension(originalFileName);

        if (!isAllowedExtension(extension)) {
            session.setAttribute("examError", "Chỉ hỗ trợ PDF, DOC, DOCX, JPG, JPEG, PNG, GIF, WEBP, XLS, XLSX, PPT, PPTX.");
            response.sendRedirect(buildAdminUrl(request, type, faculty, subject, year));
            return;
        }

        File uploadRoot = new File(UPLOAD_ROOT);

        File targetDir = new File(uploadRoot, type);
        targetDir = new File(targetDir, EXAM_BANK_FOLDER);
        targetDir = new File(targetDir, faculty);
        targetDir = new File(targetDir, subject);
        targetDir = new File(targetDir, year);

        if (!targetDir.exists()) {
            targetDir.mkdirs();
        }

        if (!isSafeChild(uploadRoot, targetDir)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String safeOriginalName = cleanFileName(originalFileName);
        String timePrefix = new SimpleDateFormat("yyyyMMddHHmmss").format(new Date());
        String storedFileName = timePrefix + "_" + System.currentTimeMillis() + "_" + safeOriginalName;

        File targetFile = new File(targetDir, storedFileName);

        if (!isSafeChild(uploadRoot, targetFile)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        try (InputStream input = filePart.getInputStream()) {
            Files.copy(input, targetFile.toPath());
        }

        session.setAttribute("examSuccess", "Tải file lên thành công: " + storedFileName);
        response.sendRedirect(buildAdminUrl(request, type, faculty, subject, year));
    }

    private void deleteFile(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String type = cleanType(request.getParameter("type"));
        String faculty = cleanName(request.getParameter("faculty"));
        String subject = cleanName(request.getParameter("subject"));
        String year = cleanName(request.getParameter("year"));
        String fileName = cleanName(request.getParameter("file"));

        HttpSession session = request.getSession();

        if (type == null || faculty == null || subject == null || year == null || fileName == null) {
            session.setAttribute("examError", "Thiếu dữ liệu để xoá file.");
            response.sendRedirect(request.getContextPath() + "/admin/exam-bank");
            return;
        }

        File uploadRoot = new File(UPLOAD_ROOT);

        File file = new File(uploadRoot, type);
        file = new File(file, EXAM_BANK_FOLDER);
        file = new File(file, faculty);
        file = new File(file, subject);
        file = new File(file, year);
        file = new File(file, fileName);

        if (!isSafeChild(uploadRoot, file) || !file.exists() || !file.isFile()) {
            session.setAttribute("examError", "Không tìm thấy file cần xoá.");
            response.sendRedirect(buildAdminUrl(request, type, faculty, subject, year));
            return;
        }

        boolean deleted = file.delete();

        if (deleted) {
            session.setAttribute("examSuccess", "Đã xoá file: " + fileName);
        } else {
            session.setAttribute("examError", "Không xoá được file. Kiểm tra quyền truy cập hoặc file đang được mở.");
        }

        response.sendRedirect(buildAdminUrl(request, type, faculty, subject, year));
    }

    private void ensureBaseFolders(File uploadRoot) {
        File deCuong = new File(new File(uploadRoot, "de-cuong"), EXAM_BANK_FOLDER);
        File nganHangDe = new File(new File(uploadRoot, "ngan-hang-de"), EXAM_BANK_FOLDER);

        if (!deCuong.exists()) {
            deCuong.mkdirs();
        }

        if (!nganHangDe.exists()) {
            nganHangDe.mkdirs();
        }
    }

    private List<AdminExamItem> listItems(File dir, String view, String keyword) {
        List<AdminExamItem> list = new ArrayList<>();

        File[] files = dir.listFiles();

        if (files == null) {
            return list;
        }

        String keywordLower = keyword == null ? "" : keyword.trim().toLowerCase(Locale.ROOT);
        boolean fileView = "files".equals(view);

        for (File file : files) {
            if (file.isHidden()) {
                continue;
            }

            if (fileView && !file.isFile()) {
                continue;
            }

            if (!fileView && !file.isDirectory()) {
                continue;
            }

            if (!keywordLower.isEmpty()
                    && !file.getName().toLowerCase(Locale.ROOT).contains(keywordLower)) {
                continue;
            }

            String fileType = file.isFile() ? getExtension(file.getName()) : "folder";
            String fileSize = file.isFile() ? formatSize(file.length()) : "";
            String modifiedTime = formatTime(file.lastModified());

            list.add(new AdminExamItem(file.getName(), file.isDirectory(), fileType, fileSize, modifiedTime));
        }

        Collator collator = Collator.getInstance(new Locale("vi", "VN"));
        list.sort((a, b) -> collator.compare(a.getName(), b.getName()));

        return list;
    }

    private String getView(String type, String faculty, String subject, String year) {
        if (type == null) {
            return "types";
        }

        if (faculty == null) {
            return "faculties";
        }

        if (subject == null) {
            return "subjects";
        }

        if (year == null) {
            return "years";
        }

        return "files";
    }

    private String cleanType(String value) {
        value = cleanName(value);

        if (value == null) {
            return null;
        }

        if ("de-cuong".equalsIgnoreCase(value)) {
            return "de-cuong";
        }

        if ("ngan-hang-de".equalsIgnoreCase(value)) {
            return "ngan-hang-de";
        }

        return null;
    }

    private String cleanName(String value) {
        if (value == null) {
            return null;
        }

        value = value.trim();

        if (value.isEmpty()) {
            return null;
        }

        if (value.contains("..") || value.contains("/") || value.contains("\\")
                || value.contains(":") || value.contains("*")
                || value.contains("?") || value.contains("\"")
                || value.contains("<") || value.contains(">")
                || value.contains("|")) {
            return null;
        }

        return value;
    }

    private String cleanFolderName(String value) {
        if (value == null) {
            return null;
        }

        value = value.trim();

        if (value.isEmpty()) {
            return null;
        }

        value = value.replace("\\", " ")
                .replace("/", " ")
                .replace(":", " ")
                .replace("*", " ")
                .replace("?", " ")
                .replace("\"", " ")
                .replace("<", " ")
                .replace(">", " ")
                .replace("|", " ");

        value = value.replaceAll("\\s+", " ").trim();

        if (value.isEmpty() || value.contains("..")) {
            return null;
        }

        return value;
    }

    private String cleanFileName(String value) {
        if (value == null || value.trim().isEmpty()) {
            return "file";
        }

        value = value.trim();

        int slash = Math.max(value.lastIndexOf('/'), value.lastIndexOf('\\'));
        if (slash >= 0) {
            value = value.substring(slash + 1);
        }

        value = value.replace("\\", "_")
                .replace("/", "_")
                .replace(":", "_")
                .replace("*", "_")
                .replace("?", "_")
                .replace("\"", "_")
                .replace("<", "_")
                .replace(">", "_")
                .replace("|", "_");

        value = value.replaceAll("\\s+", "_");

        while (value.contains("..")) {
            value = value.replace("..", "_");
        }

        return value;
    }

    private String getSubmittedFileName(Part part) {
        String header = part.getHeader("content-disposition");

        if (header == null) {
            return "file";
        }

        String[] tokens = header.split(";");

        for (String token : tokens) {
            token = token.trim();

            if (token.startsWith("filename")) {
                String fileName = token.substring(token.indexOf("=") + 1).trim().replace("\"", "");

                int slash = Math.max(fileName.lastIndexOf('/'), fileName.lastIndexOf('\\'));
                if (slash >= 0) {
                    fileName = fileName.substring(slash + 1);
                }

                return fileName;
            }
        }

        return "file";
    }

    private String getExtension(String fileName) {
        if (fileName == null) {
            return "";
        }

        int dot = fileName.lastIndexOf(".");

        if (dot < 0 || dot == fileName.length() - 1) {
            return "";
        }

        return fileName.substring(dot + 1).toLowerCase(Locale.ROOT);
    }

    private boolean isAllowedExtension(String extension) {
        return "pdf".equals(extension)
                || "doc".equals(extension)
                || "docx".equals(extension)
                || "jpg".equals(extension)
                || "jpeg".equals(extension)
                || "png".equals(extension)
                || "gif".equals(extension)
                || "webp".equals(extension)
                || "xls".equals(extension)
                || "xlsx".equals(extension)
                || "ppt".equals(extension)
                || "pptx".equals(extension);
    }

    private boolean isSafeChild(File base, File target) {
        try {
            String basePath = base.getCanonicalPath();
            String targetPath = target.getCanonicalPath();

            return targetPath.equals(basePath) || targetPath.startsWith(basePath + File.separator);
        } catch (Exception e) {
            return false;
        }
    }

    private String formatSize(long size) {
        if (size < 1024) {
            return size + " B";
        }

        double kb = size / 1024.0;

        if (kb < 1024) {
            return String.format(Locale.US, "%.1f KB", kb);
        }

        double mb = kb / 1024.0;

        return String.format(Locale.US, "%.1f MB", mb);
    }

    private String formatTime(long time) {
        return new SimpleDateFormat("dd/MM/yyyy HH:mm").format(time);
    }

    private String buildAdminUrl(HttpServletRequest request, String type, String faculty, String subject, String year) {
        return request.getContextPath()
                + "/admin/exam-bank?type=" + url(type)
                + "&faculty=" + url(faculty)
                + "&subject=" + url(subject)
                + "&year=" + url(year);
    }

    private String url(String value) {
        if (value == null) {
            return "";
        }

        return URLEncoder.encode(value, StandardCharsets.UTF_8).replace("+", "%20");
    }
}
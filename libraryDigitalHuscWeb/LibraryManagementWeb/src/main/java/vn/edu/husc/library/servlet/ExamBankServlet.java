package vn.edu.husc.library.servlet;

import vn.edu.husc.library.util.ExamStorageConfig;

import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.*;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.*;

public class ExamBankServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    public static class ExamItem {
        private String name;
        private String displayName;
        private String type;

        public ExamItem(String name, String displayName, String type) {
            this.name = name;
            this.displayName = displayName;
            this.type = type;
        }

        public String getName() {
            return name;
        }

        public String getDisplayName() {
            return displayName;
        }

        public String getTitle() {
            return displayName;
        }

        public String getLabel() {
            return displayName;
        }

        public String getFileName() {
            return name;
        }

        public String getFolderName() {
            return name;
        }

        public String getSubjectName() {
            return displayName;
        }

        public String getFacultyName() {
            return displayName;
        }

        public String getYearName() {
            return displayName;
        }

        public String getValue() {
            return name;
        }

        public String getText() {
            return displayName;
        }

        public String getType() {
            return type;
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String type = getParam(request, "type");
        String faculty = getParam(request, "faculty");
        String subject = getParam(request, "subject");
        String year = getParam(request, "year");
        String file = getParam(request, "file");

        type = ExamStorageConfig.normalizeType(type);

        if (!file.isEmpty()) {
            serveFile(request, response, type, faculty, subject, year, file);
            return;
        }

        File rootFolder = ExamStorageConfig.getRootFolder(type);

        if (!rootFolder.exists()) {
            rootFolder.mkdirs();
        }

        request.setAttribute("type", type);
        request.setAttribute("typeLabel", ExamStorageConfig.getTypeLabel(type));
        request.setAttribute("faculty", faculty);
        request.setAttribute("subject", subject);
        request.setAttribute("year", year);

        /*
         * Cấu trúc đọc:
         *
         * D:/upLoad/ngan-hang-de/exam-bank/
         *      Khoa CNTT/
         *          Cấu Trúc Dữ liệu và Thuật Toán/
         *              2024-2025/
         *                  de1.pdf
         *
         * hoặc:
         *
         * D:/upLoad/ngan-hang-de/exam-bank/
         *      Khoa CNTT/
         *          Cấu Trúc Dữ liệu và Thuật Toán/
         *              de1.pdf
         */

        if (faculty.isEmpty()) {
            List<ExamItem> faculties = listFolders(rootFolder);
            request.setAttribute("faculties", faculties);
            request.setAttribute("items", faculties);
            forward(request, response);
            return;
        }

        File facultyFolder = new File(rootFolder, faculty);

        if (!isSafeChild(rootFolder, facultyFolder) || !facultyFolder.exists() || !facultyFolder.isDirectory()) {
            request.setAttribute("items", new ArrayList<ExamItem>());
            forward(request, response);
            return;
        }

        if (subject.isEmpty()) {
            List<ExamItem> subjects = listFolders(facultyFolder);
            request.setAttribute("subjects", subjects);
            request.setAttribute("items", subjects);
            forward(request, response);
            return;
        }

        File subjectFolder = new File(facultyFolder, subject);

        if (!isSafeChild(rootFolder, subjectFolder) || !subjectFolder.exists() || !subjectFolder.isDirectory()) {
            request.setAttribute("items", new ArrayList<ExamItem>());
            forward(request, response);
            return;
        }

        if (year.isEmpty()) {
            List<ExamItem> yearFolders = listFolders(subjectFolder);
            List<ExamItem> directFiles = listFiles(subjectFolder);

            /*
             * Nếu môn học có thư mục năm thì hiển thị năm.
             * Nếu môn học chứa file trực tiếp thì hiển thị file.
             */
            if (!yearFolders.isEmpty()) {
                request.setAttribute("years", yearFolders);
                request.setAttribute("items", yearFolders);
            } else {
                request.setAttribute("files", directFiles);
                request.setAttribute("items", directFiles);
            }

            forward(request, response);
            return;
        }

        File yearFolder = new File(subjectFolder, year);

        if (!isSafeChild(rootFolder, yearFolder) || !yearFolder.exists() || !yearFolder.isDirectory()) {
            request.setAttribute("files", new ArrayList<ExamItem>());
            request.setAttribute("items", new ArrayList<ExamItem>());
            forward(request, response);
            return;
        }

        List<ExamItem> files = listFiles(yearFolder);
        request.setAttribute("files", files);
        request.setAttribute("items", files);

        forward(request, response);
    }

    private void forward(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.getRequestDispatcher("/exam-bank.jsp").forward(request, response);
    }

    private String getParam(HttpServletRequest request, String name) {
        String value = request.getParameter(name);

        if (value == null) {
            return "";
        }

        try {
            value = URLDecoder.decode(value, StandardCharsets.UTF_8.name());
        } catch (Exception ignored) {
        }

        return value.trim();
    }

    private List<ExamItem> listFolders(File parent) {
        List<ExamItem> list = new ArrayList<ExamItem>();

        File[] files = parent.listFiles();

        if (files == null) {
            return list;
        }

        Arrays.sort(files, new Comparator<File>() {
            @Override
            public int compare(File a, File b) {
                return a.getName().compareToIgnoreCase(b.getName());
            }
        });

        for (File file : files) {
            if (file.isDirectory() && !file.isHidden()) {
                list.add(new ExamItem(file.getName(), niceName(file.getName()), "folder"));
            }
        }

        return list;
    }

    private List<ExamItem> listFiles(File parent) {
        List<ExamItem> list = new ArrayList<ExamItem>();

        File[] files = parent.listFiles();

        if (files == null) {
            return list;
        }

        Arrays.sort(files, new Comparator<File>() {
            @Override
            public int compare(File a, File b) {
                return a.getName().compareToIgnoreCase(b.getName());
            }
        });

        for (File file : files) {
            if (file.isFile() && !file.isHidden() && isAllowedFile(file.getName())) {
                list.add(new ExamItem(file.getName(), niceName(file.getName()), "file"));
            }
        }

        return list;
    }

    private boolean isAllowedFile(String name) {
        String lower = name.toLowerCase();

        return lower.endsWith(".pdf")
                || lower.endsWith(".doc")
                || lower.endsWith(".docx")
                || lower.endsWith(".ppt")
                || lower.endsWith(".pptx")
                || lower.endsWith(".xls")
                || lower.endsWith(".xlsx")
                || lower.endsWith(".png")
                || lower.endsWith(".jpg")
                || lower.endsWith(".jpeg")
                || lower.endsWith(".webp");
    }

    private String niceName(String name) {
        if (name == null) {
            return "";
        }

        String result = name;

        int dot = result.lastIndexOf(".");

        if (dot > 0) {
            result = result.substring(0, dot);
        }

        result = result.replace("_", " ")
                .replace("-", " ")
                .trim();

        return result.isEmpty() ? name : result;
    }

    private void serveFile(HttpServletRequest request, HttpServletResponse response,
                           String type, String faculty, String subject, String year, String fileName)
            throws IOException {

        File rootFolder = ExamStorageConfig.getRootFolder(type);

        File targetFolder;

        if (!year.isEmpty()) {
            targetFolder = new File(new File(new File(rootFolder, faculty), subject), year);
        } else {
            targetFolder = new File(new File(rootFolder, faculty), subject);
        }

        File file = new File(targetFolder, fileName);

        if (!isSafeChild(rootFolder, file) || !file.exists() || !file.isFile()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        response.setContentType(getContentType(file.getName()));
        response.setHeader("Content-Disposition", "inline; filename=\"" + file.getName() + "\"");
        response.setContentLengthLong(file.length());

        try (
                FileInputStream input = new FileInputStream(file);
                OutputStream output = response.getOutputStream()
        ) {
            byte[] buffer = new byte[8192];
            int length;

            while ((length = input.read(buffer)) != -1) {
                output.write(buffer, 0, length);
            }
        }
    }

    private boolean isSafeChild(File base, File target) {
        try {
            String basePath = base.getCanonicalPath();
            String targetPath = target.getCanonicalPath();

            return targetPath.equals(basePath)
                    || targetPath.startsWith(basePath + File.separator);

        } catch (Exception e) {
            return false;
        }
    }

    private String getContentType(String fileName) {
        String lower = fileName.toLowerCase();

        if (lower.endsWith(".pdf")) return "application/pdf";
        if (lower.endsWith(".doc")) return "application/msword";
        if (lower.endsWith(".docx")) return "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
        if (lower.endsWith(".ppt")) return "application/vnd.ms-powerpoint";
        if (lower.endsWith(".pptx")) return "application/vnd.openxmlformats-officedocument.presentationml.presentation";
        if (lower.endsWith(".xls")) return "application/vnd.ms-excel";
        if (lower.endsWith(".xlsx")) return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
        if (lower.endsWith(".png")) return "image/png";
        if (lower.endsWith(".jpg") || lower.endsWith(".jpeg")) return "image/jpeg";
        if (lower.endsWith(".webp")) return "image/webp";

        return "application/octet-stream";
    }
}
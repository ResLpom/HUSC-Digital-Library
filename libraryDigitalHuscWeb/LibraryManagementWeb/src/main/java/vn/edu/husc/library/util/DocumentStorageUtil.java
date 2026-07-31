package vn.edu.husc.library.util;

import java.io.File;
import java.util.Arrays;

public class DocumentStorageUtil {

    public static final String ROOT_FOLDER = "D:/upLoad/file_document";

    private DocumentStorageUtil() {
    }

    public static File getRootFolder() {
        return new File(ROOT_FOLDER);
    }

    public static File resolveResource(String filePath) {
        if (filePath == null || filePath.trim().isEmpty()) {
            return null;
        }

        String path = cleanPath(filePath);

        File root = getRootFolder();

        File exact = new File(root, path);

        if (exact.exists()) {
            return exact;
        }

        String fixedPath = fixSpecialPath(path);

        File fixed = new File(root, fixedPath);

        if (fixed.exists()) {
            return fixed;
        }

        File matched = findDirectChildByName(root, path);

        if (matched != null) {
            return matched;
        }

        matched = findDirectChildByName(root, fixedPath);

        if (matched != null) {
            return matched;
        }

        return exact;
    }

    public static File resolveFileInside(File folder, String fileName) {
        if (folder == null || fileName == null || fileName.trim().isEmpty()) {
            return null;
        }

        String name = fileName.trim();

        File exact = new File(folder, name);

        if (exact.exists() && exact.isFile()) {
            return exact;
        }

        File[] files = folder.listFiles();

        if (files == null) {
            return exact;
        }

        for (File file : files) {
            if (file.isFile() && file.getName().equalsIgnoreCase(name)) {
                return file;
            }
        }

        return exact;
    }

    public static File[] listFiles(File folder) {
        if (folder == null || !folder.exists() || !folder.isDirectory()) {
            return new File[0];
        }

        File[] files = folder.listFiles(file -> file.isFile());

        if (files == null) {
            return new File[0];
        }

        Arrays.sort(files);
        return files;
    }

    public static boolean isSafeRelativePath(String path) {
        return path != null
                && !path.contains("..")
                && !path.contains(":")
                && !path.startsWith("/")
                && !path.startsWith("\\");
    }

    public static boolean isSafeFileName(String fileName) {
        return fileName != null
                && !fileName.trim().isEmpty()
                && !fileName.contains("..")
                && !fileName.contains("/")
                && !fileName.contains("\\")
                && !fileName.contains(":");
    }

    public static boolean isSafeChild(File root, File file) {
        try {
            if (root == null || file == null) {
                return false;
            }

            String rootPath = root.getCanonicalPath();
            String filePath = file.getCanonicalPath();

            return filePath.equals(rootPath)
                    || filePath.startsWith(rootPath + File.separator);

        } catch (Exception e) {
            return false;
        }
    }

    public static boolean canPreview(String fileName) {
        if (fileName == null) {
            return false;
        }

        String lower = fileName.toLowerCase();

        return lower.endsWith(".pdf")
                || lower.endsWith(".html")
                || lower.endsWith(".htm")
                || lower.endsWith(".txt")
                || lower.endsWith(".jpg")
                || lower.endsWith(".jpeg")
                || lower.endsWith(".png")
                || lower.endsWith(".webp")
                || lower.endsWith(".gif");
    }

    public static String getContentType(String fileName) {
        String lower = fileName == null ? "" : fileName.toLowerCase();

        if (lower.endsWith(".pdf")) {
            return "application/pdf";
        }

        if (lower.endsWith(".html") || lower.endsWith(".htm")) {
            return "text/html; charset=UTF-8";
        }

        if (lower.endsWith(".txt")) {
            return "text/plain; charset=UTF-8";
        }

        if (lower.endsWith(".jpg") || lower.endsWith(".jpeg")) {
            return "image/jpeg";
        }

        if (lower.endsWith(".png")) {
            return "image/png";
        }

        if (lower.endsWith(".webp")) {
            return "image/webp";
        }

        if (lower.endsWith(".gif")) {
            return "image/gif";
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

    private static String cleanPath(String path) {
        return path.trim()
                .replace("\\", "/")
                .replace("&gt;", ">")
                .replace("&GT;", ">")
                .replace("&amp;", "&");
    }

    private static String fixSpecialPath(String path) {
        String fixed = path;

        if (fixed.contains(">")) {
            fixed = fixed.replace(">", "&GT");
        }

        return fixed;
    }

    private static File findDirectChildByName(File root, String name) {
        if (root == null || name == null || !root.exists() || !root.isDirectory()) {
            return null;
        }

        File[] children = root.listFiles();

        if (children == null) {
            return null;
        }

        String normalizedTarget = normalize(name);

        for (File child : children) {
            if (normalize(child.getName()).equals(normalizedTarget)) {
                return child;
            }
        }

        return null;
    }

    private static String normalize(String value) {
        if (value == null) {
            return "";
        }

        return value.toLowerCase()
                .replace("&", "")
                .replace(">", "gt")
                .replace("_", "")
                .replace("-", "")
                .replace(" ", "")
                .trim();
    }
}
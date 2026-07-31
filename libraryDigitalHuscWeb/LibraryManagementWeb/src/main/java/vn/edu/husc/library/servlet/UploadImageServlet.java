package vn.edu.husc.library.servlet;

import vn.edu.husc.library.util.UploadStorageConfig;

import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.*;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;

public class UploadImageServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final String[] IMAGE_EXTENSIONS = {
            ".jpg", ".jpeg", ".png", ".webp", ".gif"
    };

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo();

        if (pathInfo == null || pathInfo.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String[] parts = pathInfo.split("/", 3);

        if (parts.length < 3) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String type = parts[1];
        String fileName = parts[2];

        fileName = URLDecoder.decode(fileName, StandardCharsets.UTF_8.name()).trim();

        if (!isSafeFileName(fileName)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        File folder = UploadStorageConfig.getFolderByType(type);

        if (folder == null || !folder.exists() || !folder.isDirectory()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        File file = findImageFile(folder, fileName);

        if (file == null || !isSafeChild(folder, file) || !file.exists() || !file.isFile()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        response.setContentType(getContentType(file.getName()));
        response.setHeader("Content-Disposition", "inline; filename=\"" + file.getName() + "\"");
        response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);
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

    private File findImageFile(File folder, String fileName) {
        File exactFile = new File(folder, fileName);

        if (exactFile.exists() && exactFile.isFile()) {
            return exactFile;
        }

        File[] files = folder.listFiles();

        if (files == null) {
            return exactFile;
        }

        for (File file : files) {
            if (file.isFile() && file.getName().equalsIgnoreCase(fileName)) {
                return file;
            }
        }

        boolean hasExtension = hasImageExtension(fileName);

        if (!hasExtension) {
            for (String ext : IMAGE_EXTENSIONS) {
                File candidate = new File(folder, fileName + ext);

                if (candidate.exists() && candidate.isFile()) {
                    return candidate;
                }
            }

            for (File file : files) {
                if (!file.isFile()) {
                    continue;
                }

                for (String ext : IMAGE_EXTENSIONS) {
                    if (file.getName().equalsIgnoreCase(fileName + ext)) {
                        return file;
                    }
                }
            }
        }

        String normalizedInput = normalizeFileName(fileName);

        for (File file : files) {
            if (!file.isFile()) {
                continue;
            }

            if (normalizeFileName(file.getName()).equals(normalizedInput)) {
                return file;
            }
        }

        return exactFile;
    }

    private boolean hasImageExtension(String fileName) {
        if (fileName == null) {
            return false;
        }

        String lower = fileName.toLowerCase();

        for (String ext : IMAGE_EXTENSIONS) {
            if (lower.endsWith(ext)) {
                return true;
            }
        }

        return false;
    }

    private String normalizeFileName(String fileName) {
        if (fileName == null) {
            return "";
        }

        String value = fileName.toLowerCase();
        value = value.replace("đ", "d");

        return value.replaceAll("[^a-z0-9]", "");
    }

    private boolean isSafeFileName(String fileName) {
        if (fileName == null || fileName.trim().isEmpty()) {
            return false;
        }

        return !fileName.contains("..")
                && !fileName.contains("/")
                && !fileName.contains("\\")
                && !fileName.contains(":")
                && !fileName.contains("*")
                && !fileName.contains("?")
                && !fileName.contains("\"")
                && !fileName.contains("<")
                && !fileName.contains(">")
                && !fileName.contains("|");
    }

    private boolean isSafeChild(File base, File target) {
        try {
            String basePath = base.getCanonicalPath();
            String targetPath = target.getCanonicalPath();

            return targetPath.startsWith(basePath + File.separator);
        } catch (Exception e) {
            return false;
        }
    }

    private String getContentType(String fileName) {
        String lower = fileName.toLowerCase();

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

        return "application/octet-stream";
    }
}
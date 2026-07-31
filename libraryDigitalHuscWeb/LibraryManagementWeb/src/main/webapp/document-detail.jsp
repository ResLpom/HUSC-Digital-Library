<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.io.File" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.lang.reflect.Method" %>
<%@ page import="java.util.Arrays" %>
<%@ page import="vn.edu.husc.library.model.User" %>
<%@ page import="vn.edu.husc.library.util.DocumentStorageUtil" %>

<%!
    private Object call(Object object, String methodName) {
        if (object == null) return null;

        try {
            Method method = object.getClass().getMethod(methodName);
            return method.invoke(object);
        } catch (Exception e) {
            return null;
        }
    }

    private String getText(Object object, String methodName) {
        Object value = call(object, methodName);
        return value == null ? "" : String.valueOf(value);
    }

    private int getInt(Object object, String methodName) {
        Object value = call(object, methodName);

        if (value == null) return 0;

        try {
            return Integer.parseInt(String.valueOf(value));
        } catch (Exception e) {
            return 0;
        }
    }

    private String h(String value) {
        if (value == null) return "";

        return value.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }

    private String urlEncode(String value) {
        if (value == null) return "";

        try {
            return URLEncoder.encode(value, "UTF-8").replace("+", "%20");
        } catch (Exception e) {
            return "";
        }
    }

    private String fileSizeText(long size) {
        if (size < 1024) return size + " B";

        double kb = size / 1024.0;

        if (kb < 1024) {
            return String.format("%.1f KB", kb);
        }

        double mb = kb / 1024.0;
        return String.format("%.1f MB", mb);
    }

    private boolean canPreview(String fileName) {
        if (fileName == null) return false;

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

    private String fileIcon(String fileName) {
        if (fileName == null) return "📄";

        String lower = fileName.toLowerCase();

        if (lower.endsWith(".pdf")) return "📕";
        if (lower.endsWith(".doc") || lower.endsWith(".docx")) return "📘";
        if (lower.endsWith(".ppt") || lower.endsWith(".pptx")) return "📙";
        if (lower.endsWith(".xls") || lower.endsWith(".xlsx")) return "📗";
        if (lower.endsWith(".zip") || lower.endsWith(".rar")) return "🗜️";
        if (lower.endsWith(".html") || lower.endsWith(".htm")) return "🌐";
        if (lower.endsWith(".jpg") || lower.endsWith(".jpeg") || lower.endsWith(".png") || lower.endsWith(".webp")) return "🖼️";

        return "📄";
    }
%>

<%
    String contextPath = request.getContextPath();

    Object document = request.getAttribute("document");

    User currentUser = null;

    if (session != null) {
        currentUser = (User) session.getAttribute("currentUser");

        if (currentUser == null) {
            currentUser = (User) session.getAttribute("user");
        }
    }

    boolean loggedIn = currentUser != null;

    int documentId = getInt(document, "getDocumentId");

    String title = getText(document, "getTitle");
    String description = getText(document, "getDescription");
    String categoryName = getText(document, "getCategoryName");
    String typeName = getText(document, "getTypeName");
    String authorName = getText(document, "getAuthorName");
    String publisherName = getText(document, "getPublisherName");
    String publishYear = getText(document, "getPublishYear");
    String filePath = getText(document, "getFilePath");
    String coverImage = getText(document, "getCoverImage");
    String status = getText(document, "getStatus");

    if (title.trim().isEmpty()) title = "Chi tiết tài liệu";
    if (description.trim().isEmpty()) description = "Tài liệu này chưa có mô tả chi tiết.";
    if (categoryName.trim().isEmpty()) categoryName = "Tài liệu";
    if (typeName.trim().isEmpty()) typeName = "PDF";
    if (authorName.trim().isEmpty()) authorName = "Chưa cập nhật";
    if (publisherName.trim().isEmpty()) publisherName = "Chưa cập nhật";
    if (publishYear.trim().isEmpty() || "0".equals(publishYear)) publishYear = "Chưa cập nhật";
    if (status.trim().isEmpty()) status = "ACTIVE";

    boolean hasCover = coverImage != null && !coverImage.trim().isEmpty();
    boolean hasFile = filePath != null && !filePath.trim().isEmpty();

    File documentResource = null;
    File[] lessonFiles = null;
    boolean resourceIsFolder = false;
    boolean resourceIsSingleFile = false;

    if (hasFile) {
        documentResource = DocumentStorageUtil.resolveResource(filePath);

        if (documentResource != null && documentResource.exists() && documentResource.isDirectory()) {
            resourceIsFolder = true;
            lessonFiles = DocumentStorageUtil.listFiles(documentResource);

        } else if (documentResource != null && documentResource.exists() && documentResource.isFile()) {
            resourceIsSingleFile = true;
        }
    }
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title><%= h(title) %> - HUSC Digital Library</title>

    <link rel="stylesheet" href="<%= contextPath %>/assets/css/member/member-layout.css?v=9">

    <style>
        .detail-layout {
            display: grid;
            grid-template-columns: 420px minmax(0, 1fr);
            gap: 28px;
            align-items: start;
        }

        .cover-card,
        .info-card {
            border-radius: 30px;
            background: rgba(255, 255, 255, 0.98);
            border: 1px solid #dbeafe;
            box-shadow: 0 22px 55px rgba(15, 23, 42, 0.08);
            overflow: hidden;
        }

        .cover-box {
            width: 100%;
            height: 520px;
            background: linear-gradient(135deg, #dbeafe, #e0e7ff);
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .cover-box img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            display: block;
        }

        .cover-placeholder {
            width: 96px;
            height: 96px;
            border-radius: 30px;
            background: rgba(255, 255, 255, 0.72);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 46px;
        }

        .cover-caption {
            padding: 20px 22px;
            border-top: 1px solid #e2e8f0;
        }

        .cover-caption strong {
            display: block;
            font-size: 16px;
            font-weight: 800;
            color: #0f172a;
            line-height: 1.4;
        }

        .cover-caption span {
            display: block;
            margin-top: 6px;
            color: #64748b;
            font-size: 13px;
            font-weight: 600;
        }

        .info-card {
            padding: 32px;
        }

        .detail-title {
            margin: 0;
            font-size: 34px;
            line-height: 1.18;
            font-weight: 800;
            letter-spacing: -0.04em;
            color: #0f172a;
        }

        .detail-desc {
            margin: 18px 0 0;
            color: #475569;
            font-size: 15px;
            line-height: 1.75;
            font-weight: 500;
        }

        .meta-grid {
            margin-top: 28px;
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 16px;
        }

        .meta-item {
            padding: 18px;
            border-radius: 22px;
            background: #f8fafc;
            border: 1px solid #e2e8f0;
        }

        .meta-item span {
            display: block;
            color: #64748b;
            font-size: 12px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.08em;
            margin-bottom: 7px;
        }

        .meta-item strong {
            display: block;
            color: #0f172a;
            font-size: 15px;
            font-weight: 700;
            line-height: 1.45;
        }

        .detail-actions {
            margin-top: 30px;
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
        }

        .btn-primary,
        .btn-light,
        .btn-danger,
        .btn-disabled {
            min-height: 44px;
            padding: 0 18px;
            border-radius: 999px;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 13px;
            font-weight: 800;
            border: 1px solid transparent;
            white-space: nowrap;
        }

        .btn-primary {
            color: white;
            background: linear-gradient(135deg, #0284c7, #06b6d4);
            box-shadow: 0 14px 28px rgba(14, 165, 233, 0.18);
        }

        .btn-light {
            color: #0369a1;
            background: #e0f2fe;
            border-color: #bae6fd;
        }

        .btn-danger {
            color: #be123c;
            background: #ffe4e6;
            border-color: #fecdd3;
        }

        .btn-disabled {
            color: #64748b;
            background: #f1f5f9;
            border-color: #e2e8f0;
        }

        .lesson-box {
            margin-top: 28px;
            padding: 24px;
            border-radius: 26px;
            background: #f8fafc;
            border: 1px solid #e2e8f0;
        }

        .lesson-box h3 {
            margin: 0 0 8px;
            font-size: 22px;
            font-weight: 800;
            color: #0f172a;
        }

        .lesson-box p {
            margin: 0 0 18px;
            color: #64748b;
            font-size: 14px;
            font-weight: 600;
            line-height: 1.6;
        }

        .reader-frame {
            width: 100%;
            height: 720px;
            border: 1px solid #dbeafe;
            border-radius: 22px;
            background: white;
        }

        .lesson-list {
            display: grid;
            gap: 12px;
        }

        .lesson-item {
            padding: 14px 16px;
            border-radius: 18px;
            background: #ffffff;
            border: 1px solid #dbeafe;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 14px;
        }

        .lesson-name {
            min-width: 0;
        }

        .lesson-name strong {
            display: block;
            color: #0f172a;
            font-size: 14px;
            font-weight: 800;
            line-height: 1.45;
            word-break: break-word;
        }

        .lesson-name span {
            display: block;
            margin-top: 4px;
            color: #64748b;
            font-size: 12px;
            font-weight: 600;
        }

        .lesson-actions {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
            justify-content: flex-end;
        }

        .notice-box {
            margin-top: 24px;
            padding: 18px 20px;
            border-radius: 22px;
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            color: #475569;
            font-size: 14px;
            font-weight: 600;
            line-height: 1.65;
        }

        @media (max-width: 1050px) {
            .detail-layout {
                grid-template-columns: 1fr;
            }

            .cover-box {
                height: 420px;
            }
        }

        @media (max-width: 720px) {
            .info-card {
                padding: 24px;
            }

            .detail-title {
                font-size: 28px;
            }

            .meta-grid {
                grid-template-columns: 1fr;
            }

            .cover-box {
                height: 340px;
            }

            .lesson-item {
                align-items: flex-start;
                flex-direction: column;
            }

            .lesson-actions {
                justify-content: flex-start;
            }

            .reader-frame {
                height: 520px;
            }
        }
    </style>
</head>

<body>

<jsp:include page="/includes/member-header.jsp" />

<div class="member-page-shell">

    <section class="member-hero blue">
        <div>
            <div class="member-hero-badge">Document Detail</div>

            <h1>Chi tiết tài liệu</h1>

            <p>
                Xem thông tin tài liệu, đọc trực tiếp trên web hoặc tải file về máy.
            </p>
        </div>

        <div class="member-hero-stat">
            <strong><%= h(typeName) %></strong>
            <span>Loại tài liệu</span>
        </div>
    </section>

    <div class="member-section-head">
        <div>
            <p class="member-section-kicker">Document Information</p>
            <h2>Thông tin tài liệu</h2>
        </div>

        <p>Kiểm tra thông tin trước khi đọc, tải xuống hoặc lưu vào danh sách yêu thích.</p>
    </div>

    <% if (document == null) { %>

        <div class="member-empty-box">
            Không tìm thấy tài liệu.
            <br><br>
            <a class="btn-primary" href="<%= contextPath %>/documents">Quay lại danh sách tài liệu</a>
        </div>

    <% } else { %>

        <section class="detail-layout">

            <aside class="cover-card">
                <div class="cover-box">
                    <% if (hasCover) { %>
                        <img src="<%= contextPath %>/upload-image/documents/<%= urlEncode(coverImage) %>"
                             alt="<%= h(title) %>">
                    <% } else { %>
                        <div class="cover-placeholder">📄</div>
                    <% } %>
                </div>

                <div class="cover-caption">
                    <strong><%= h(title) %></strong>
                    <span><%= h(typeName) %> · <%= h(categoryName) %></span>
                </div>
            </aside>

            <article class="info-card">
                <h2 class="detail-title"><%= h(title) %></h2>

                <p class="detail-desc">
                    <%= h(description) %>
                </p>

                <div class="meta-grid">
                    <div class="meta-item">
                        <span>Danh mục</span>
                        <strong><%= h(categoryName) %></strong>
                    </div>

                    <div class="meta-item">
                        <span>Loại tài liệu</span>
                        <strong><%= h(typeName) %></strong>
                    </div>

                    <div class="meta-item">
                        <span>Tác giả</span>
                        <strong><%= h(authorName) %></strong>
                    </div>

                    <div class="meta-item">
                        <span>Nhà xuất bản</span>
                        <strong><%= h(publisherName) %></strong>
                    </div>

                    <div class="meta-item">
                        <span>Năm xuất bản</span>
                        <strong><%= h(publishYear) %></strong>
                    </div>

                    <div class="meta-item">
                        <span>Trạng thái</span>
                        <strong><%= h(status) %></strong>
                    </div>
                </div>

                <div class="detail-actions">
                    <a class="btn-light" href="<%= contextPath %>/documents">
                        ← Quay lại
                    </a>

                    <% if (resourceIsSingleFile) { %>

                        <% if (DocumentStorageUtil.canPreview(documentResource.getName())) { %>
                            <a class="btn-primary"
                               target="_blank"
                               href="<%= contextPath %>/document-read?id=<%= documentId %>">
                                Đọc trực tiếp
                            </a>
                        <% } else { %>
                            <span class="btn-disabled">
                                Không hỗ trợ đọc trực tiếp
                            </span>
                        <% } %>

                        <a class="btn-primary"
                           href="<%= contextPath %>/document-download?id=<%= documentId %>">
                            Tải xuống
                        </a>

                    <% } %>

                    <% if (loggedIn) { %>
                        <a class="btn-danger"
                           href="<%= contextPath %>/documents?action=favorite&id=<%= documentId %>">
                            Yêu thích
                        </a>
                    <% } else { %>
                        <a class="btn-light"
                           href="<%= contextPath %>/login.jsp">
                            Đăng nhập để yêu thích
                        </a>
                    <% } %>
                </div>

                <% if (resourceIsSingleFile && DocumentStorageUtil.canPreview(documentResource.getName())) { %>

                    <div class="lesson-box">
                        <h3>Đọc tài liệu trực tiếp</h3>
                        <p>
                            Tài liệu được mở trực tiếp từ thư mục
                            <strong>D:/upLoad/file_document</strong>.
                        </p>

                        <iframe class="reader-frame"
                                src="<%= contextPath %>/document-read?id=<%= documentId %>">
                        </iframe>
                    </div>

                <% } %>

                <% if (resourceIsFolder && lessonFiles != null && lessonFiles.length > 0) { %>

                    <div class="lesson-box">
                        <h3>Danh sách file tài liệu</h3>
                        <p>
                            Học phần này có <%= lessonFiles.length %> file. Bạn có thể đọc trực tiếp hoặc tải từng file.
                        </p>

                        <div class="lesson-list">
                            <% for (File f : lessonFiles) {
                                String encodedFileName = urlEncode(f.getName());
                            %>
                                <div class="lesson-item">
                                    <div class="lesson-name">
                                        <strong>
                                            <%= fileIcon(f.getName()) %>
                                            <%= h(f.getName()) %>
                                        </strong>
                                        <span><%= fileSizeText(f.length()) %></span>
                                    </div>

                                    <div class="lesson-actions">
                                        <% if (DocumentStorageUtil.canPreview(f.getName())) { %>
                                            <a class="btn-light"
                                               target="_blank"
                                               href="<%= contextPath %>/document-read?id=<%= documentId %>&file=<%= encodedFileName %>">
                                                Đọc
                                            </a>
                                        <% } else { %>
                                            <span class="btn-disabled">
                                                Không hỗ trợ đọc
                                            </span>
                                        <% } %>

                                        <a class="btn-primary"
                                           href="<%= contextPath %>/document-download?id=<%= documentId %>&file=<%= encodedFileName %>">
                                            Tải xuống
                                        </a>
                                    </div>
                                </div>
                            <% } %>
                        </div>
                    </div>

                <% } else if (hasFile && !resourceIsSingleFile) { %>

                    <div class="lesson-box">
                        <h3>Chưa tìm thấy file</h3>
                        <p>
                            Hệ thống chưa tìm thấy thư mục hoặc file tương ứng với đường dẫn:
                            <strong><%= h(filePath) %></strong>
                        </p>
                    </div>

                <% } %>

                <div class="notice-box">
                    Tài liệu được cung cấp phục vụ mục đích học tập và nghiên cứu trong hệ thống
                    HUSC Digital Library.
                </div>
            </article>

        </section>

    <% } %>

</div>

</body>
</html>
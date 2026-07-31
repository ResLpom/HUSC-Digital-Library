<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.lang.reflect.Method" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="vn.edu.husc.library.model.User" %>

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

    private String getText(Object object, String defaultValue, String... methods) {
        if (object == null) return defaultValue;

        for (String methodName : methods) {
            Object value = call(object, methodName);

            if (value != null && !String.valueOf(value).trim().isEmpty()) {
                return String.valueOf(value);
            }
        }

        return defaultValue;
    }

    private int getInt(Object object, String... methods) {
        if (object == null) return 0;

        for (String methodName : methods) {
            Object value = call(object, methodName);

            if (value != null) {
                try {
                    return Integer.parseInt(String.valueOf(value));
                } catch (Exception ignored) {
                }
            }
        }

        return 0;
    }

    private boolean getBoolean(Object object, String... methods) {
        if (object == null) return false;

        for (String methodName : methods) {
            Object value = call(object, methodName);

            if (value != null) {
                return Boolean.parseBoolean(String.valueOf(value));
            }
        }

        return false;
    }

    private String h(String value) {
        if (value == null) return "";

        return value.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }

    private String enc(String value) {
        if (value == null) return "";

        try {
            return URLEncoder.encode(value, "UTF-8").replace("+", "%20");
        } catch (Exception e) {
            return "";
        }
    }

    private String shortText(String value, int max) {
        if (value == null) return "";

        value = value.trim();

        if (value.length() <= max) {
            return value;
        }

        return value.substring(0, max) + "...";
    }
%>

<%
    String contextPath = request.getContextPath();

    List<?> documents = (List<?>) request.getAttribute("documents");

    User currentUser = null;

    if (session != null) {
        currentUser = (User) session.getAttribute("currentUser");

        if (currentUser == null) {
            currentUser = (User) session.getAttribute("user");
        }
    }

    String fullName = "Quản trị viên";
    String email = "admin@husc.edu.vn";
    String roleName = "Administrator";

    if (currentUser != null) {
        if (currentUser.getFullName() != null && !currentUser.getFullName().trim().isEmpty()) {
            fullName = currentUser.getFullName();
        }

        if (currentUser.getEmail() != null && !currentUser.getEmail().trim().isEmpty()) {
            email = currentUser.getEmail();
        }

        if (currentUser.getRoleName() != null && !currentUser.getRoleName().trim().isEmpty()) {
            roleName = currentUser.getRoleName();
        }
    }

    String success = (String) session.getAttribute("adminDocumentSuccess");
    String error = (String) session.getAttribute("adminDocumentError");

    session.removeAttribute("adminDocumentSuccess");
    session.removeAttribute("adminDocumentError");

    int totalDocuments = documents != null ? documents.size() : 0;
    int activeDocuments = 0;
    int hiddenDocuments = 0;
    int featuredDocuments = 0;

    if (documents != null) {
        for (Object d : documents) {
            String status = getText(d, "UNKNOWN", "getStatus");

            if ("ACTIVE".equalsIgnoreCase(status)) {
                activeDocuments++;
            } else {
                hiddenDocuments++;
            }

            if (getBoolean(d, "isFeatured", "getFeatured")) {
                featuredDocuments++;
            }
        }
    }
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản lý tài liệu - HUSC Digital Library</title>

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            font-family: "Segoe UI", Arial, sans-serif;
            background: linear-gradient(135deg, #e0f2fe, #eef2ff);
            color: #0f172a;
        }

        .admin-main {
            margin-left: 280px;
            min-height: 100vh;
            padding: 30px 42px 70px;
        }

        .admin-topbar,
        .docs-hero,
        .docs-toolbar,
        .docs-table-card {
            background: white;
            border: 1px solid #dbeafe;
            box-shadow: 0 24px 60px rgba(15, 23, 42, 0.08);
        }

        .admin-topbar {
            min-height: 90px;
            border-radius: 28px;
            padding: 22px 26px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 18px;
            margin-bottom: 22px;
        }

        .admin-topbar h1 {
            margin: 0;
            font-size: 30px;
            font-weight: 900;
            letter-spacing: -0.04em;
        }

        .admin-topbar p {
            margin: 8px 0 0;
            color: #475569;
            font-weight: 600;
        }

        .admin-top-actions {
            display: flex;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
        }

        .admin-btn {
            min-height: 42px;
            padding: 0 16px;
            border-radius: 999px;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-weight: 900;
            font-size: 13px;
            border: 1px solid transparent;
            white-space: nowrap;
            cursor: pointer;
        }

        .admin-btn.primary {
            color: white;
            background: linear-gradient(135deg, #0284c7, #06b6d4);
            box-shadow: 0 14px 30px rgba(6, 182, 212, 0.22);
        }

        .admin-btn.secondary {
            color: #0369a1;
            background: #e0f2fe;
            border-color: #bae6fd;
        }

        .admin-btn.danger {
            color: #be123c;
            background: #ffe4e6;
            border-color: #fecdd3;
        }

        .admin-alert-success,
        .admin-alert-error {
            margin-bottom: 22px;
            padding: 16px 18px;
            border-radius: 20px;
            font-weight: 900;
            line-height: 1.5;
        }

        .admin-alert-success {
            background: #dcfce7;
            color: #166534;
            border: 1px solid #bbf7d0;
        }

        .admin-alert-error {
            background: #ffe4e6;
            color: #be123c;
            border: 1px solid #fecdd3;
        }

        .docs-hero {
            border-radius: 34px;
            padding: 38px;
            color: white;
            background:
                radial-gradient(circle at 18% 20%, rgba(56, 189, 248, 0.35), transparent 32%),
                radial-gradient(circle at 90% 80%, rgba(99, 102, 241, 0.35), transparent 34%),
                linear-gradient(135deg, #0f172a, #1e3a8a);
            display: grid;
            grid-template-columns: minmax(0, 1fr) 340px;
            gap: 28px;
            align-items: center;
        }

        .admin-label {
            display: inline-flex;
            padding: 9px 16px;
            border-radius: 999px;
            background: rgba(255, 255, 255, 0.13);
            border: 1px solid rgba(255, 255, 255, 0.18);
            color: #bfdbfe;
            font-size: 12px;
            font-weight: 900;
            letter-spacing: 1.4px;
            text-transform: uppercase;
        }

        .docs-hero h2 {
            margin: 18px 0 12px;
            font-size: 44px;
            line-height: 1.1;
            letter-spacing: -0.06em;
        }

        .docs-hero h2 span {
            color: #7dd3fc;
        }

        .docs-hero p {
            color: #dbeafe;
            line-height: 1.75;
            font-weight: 600;
        }

        .docs-hero-actions {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
            margin-top: 24px;
        }

        .docs-hero-panel {
            padding: 24px;
            border-radius: 28px;
            background: rgba(255, 255, 255, 0.13);
            border: 1px solid rgba(255, 255, 255, 0.17);
        }

        .docs-hero-panel h3 {
            margin: 0 0 16px;
            color: white;
        }

        .docs-mini-stat {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 12px;
        }

        .docs-mini-stat div {
            padding: 15px;
            border-radius: 20px;
            background: rgba(255, 255, 255, 0.12);
        }

        .docs-mini-stat strong {
            display: block;
            color: white;
            font-size: 28px;
            margin-bottom: 6px;
        }

        .docs-mini-stat span {
            color: #bfdbfe;
            font-size: 12px;
            font-weight: 800;
        }

        .docs-toolbar {
            margin-top: 24px;
            padding: 20px;
            border-radius: 28px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 18px;
        }

        .docs-toolbar h2 {
            margin: 0 0 5px;
            font-size: 24px;
            color: #0f172a;
        }

        .docs-toolbar p {
            margin: 0;
            color: #64748b;
            font-size: 14px;
            font-weight: 600;
        }

        .fake-search {
            min-width: 340px;
            height: 44px;
            padding: 0 16px;
            border-radius: 999px;
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            color: #94a3b8;
            display: flex;
            align-items: center;
            font-weight: 700;
            font-size: 13px;
        }

        .docs-table-card {
            margin-top: 22px;
            border-radius: 32px;
            overflow: hidden;
        }

        .docs-table-wrapper {
            overflow-x: auto;
        }

        .docs-table {
            width: 100%;
            border-collapse: collapse;
            min-width: 1100px;
        }

        .docs-table thead {
            background: #f8fafc;
        }

        .docs-table th {
            padding: 18px;
            text-align: left;
            color: #475569;
            font-size: 12px;
            font-weight: 900;
            letter-spacing: 0.8px;
            text-transform: uppercase;
            border-bottom: 1px solid #e2e8f0;
        }

        .docs-table td {
            padding: 18px;
            border-bottom: 1px solid #f1f5f9;
            color: #334155;
            vertical-align: middle;
            font-size: 14px;
            font-weight: 600;
        }

        .docs-table tbody tr:hover {
            background: #f8fbff;
        }

        .doc-title-cell {
            display: flex;
            align-items: center;
            gap: 14px;
            min-width: 300px;
        }

        .doc-cover-mini {
            width: 54px;
            height: 70px;
            border-radius: 14px;
            background: linear-gradient(135deg, #dbeafe, #f8fafc);
            display: flex;
            align-items: center;
            justify-content: center;
            color: #0369a1;
            font-weight: 900;
            overflow: hidden;
            flex-shrink: 0;
        }

        .doc-cover-mini img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .doc-title-info strong {
            display: block;
            color: #0f172a;
            font-size: 15px;
            margin-bottom: 6px;
            line-height: 1.35;
            font-weight: 900;
        }

        .doc-title-info span {
            display: block;
            color: #64748b;
            font-size: 12px;
            line-height: 1.5;
            max-width: 420px;
        }

        .doc-chip,
        .featured-badge,
        .status-badge-admin {
            display: inline-flex;
            padding: 7px 11px;
            border-radius: 999px;
            font-size: 12px;
            font-weight: 900;
            white-space: nowrap;
            border: 1px solid transparent;
        }

        .doc-chip {
            background: #eff6ff;
            color: #1d4ed8;
        }

        .featured-badge {
            background: #fef3c7;
            color: #92400e;
        }

        .status-active {
            background: #dcfce7;
            color: #166534;
            border-color: #bbf7d0;
        }

        .status-hidden {
            background: #f1f5f9;
            color: #475569;
            border-color: #e2e8f0;
        }

        .status-danger {
            background: #ffe4e6;
            color: #be123c;
            border-color: #fecdd3;
        }

        .table-actions {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
        }

        .table-action {
            height: 34px;
            padding: 0 12px;
            border-radius: 999px;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-weight: 900;
            font-size: 12px;
        }

        .table-action.view {
            background: #eff6ff;
            color: #1d4ed8;
        }

        .table-action.edit {
            background: #ecfeff;
            color: #0e7490;
        }

        .table-action.hide {
            background: #fff7ed;
            color: #c2410c;
        }

        .table-action.delete {
            background: #ffe4e6;
            color: #be123c;
        }

        .empty-admin-box {
            padding: 56px 24px;
            text-align: center;
        }

        .empty-admin-icon {
            width: 86px;
            height: 86px;
            border-radius: 28px;
            background: #eff6ff;
            color: #1d4ed8;
            font-size: 42px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 18px;
        }

        .empty-admin-box h3 {
            margin: 0 0 10px;
            font-size: 24px;
        }

        .empty-admin-box p {
            margin: 0 auto 22px;
            max-width: 560px;
            color: #64748b;
            line-height: 1.65;
            font-weight: 600;
        }

        @media (max-width: 1180px) {
            .admin-main {
                margin-left: 0;
                padding: 24px 18px 60px;
            }

            .docs-hero {
                grid-template-columns: 1fr;
            }

            .docs-toolbar,
            .admin-topbar {
                flex-direction: column;
                align-items: flex-start;
            }

            .fake-search {
                min-width: 0;
                width: 100%;
            }
        }
    </style>
</head>

<body>

<jsp:include page="/admin/includes/admin-sidebar.jsp" />

<main class="admin-main">

    <section class="admin-topbar">
        <div>
            <h1>Quản lý tài liệu</h1>
            <p>Quản trị kho tài liệu số, metadata, file học phần và trạng thái hiển thị.</p>
        </div>

        <div class="admin-top-actions">
            <a class="admin-btn secondary"
               href="<%= contextPath %>/documents">
                Xem trang tài liệu
            </a>

            <a class="admin-btn secondary"
               href="<%= contextPath %>/admin/documents/import-folders"
               onclick="return confirm('Đồng bộ toàn bộ folder trong D:/upLoad/file_document vào danh sách tài liệu?');">
                Đồng bộ folder
            </a>

            <a class="admin-btn primary"
               href="<%= contextPath %>/admin/documents?action=form">
                + Thêm tài liệu
            </a>
        </div>
    </section>

    <% if (success != null && !success.trim().isEmpty()) { %>
        <div class="admin-alert-success"><%= h(success) %></div>
    <% } %>

    <% if (error != null && !error.trim().isEmpty()) { %>
        <div class="admin-alert-error"><%= h(error) %></div>
    <% } %>

    <section class="docs-hero">
        <div class="docs-hero-content">
            <span class="admin-label">Document Management</span>

            <h2>
                Quản lý kho<br>
                <span>tài liệu học tập</span>
            </h2>

            <p>
                Theo dõi danh sách tài liệu, tác giả, nhà xuất bản, danh mục, loại tài liệu,
                trạng thái hiển thị và các folder học phần trong hệ thống.
            </p>

            <div class="docs-hero-actions">
                <a class="admin-btn primary"
                   href="<%= contextPath %>/admin/documents?action=form">
                    Thêm tài liệu mới
                </a>

                <a class="admin-btn secondary"
                   href="<%= contextPath %>/admin/documents/import-folders"
                   onclick="return confirm('Đồng bộ toàn bộ folder trong D:/upLoad/file_document vào danh sách tài liệu?');">
                    Đồng bộ folder tài liệu
                </a>

                <a class="admin-btn secondary"
                   href="<%= contextPath %>/documents">
                    Xem giao diện người dùng
                </a>
            </div>
        </div>

        <div class="docs-hero-panel">
            <h3>Tổng quan tài liệu</h3>

            <div class="docs-mini-stat">
                <div>
                    <strong><%= totalDocuments %></strong>
                    <span>Tổng tài liệu</span>
                </div>

                <div>
                    <strong><%= activeDocuments %></strong>
                    <span>Đang hiển thị</span>
                </div>

                <div>
                    <strong><%= hiddenDocuments %></strong>
                    <span>Đã ẩn/khác</span>
                </div>

                <div>
                    <strong><%= featuredDocuments %></strong>
                    <span>Nổi bật</span>
                </div>
            </div>
        </div>
    </section>

    <section class="docs-toolbar">
        <div>
            <h2>Danh sách tài liệu</h2>
            <p>Quản lý toàn bộ tài liệu đang có trong hệ thống HUSC Digital Library.</p>
        </div>

        <div class="fake-search">
            🔎 Có thể bổ sung ô tìm kiếm/lọc tài liệu tại đây
        </div>
    </section>

    <section class="docs-table-card">

        <% if (documents == null || documents.isEmpty()) { %>

            <div class="empty-admin-box">
                <div class="empty-admin-icon">📄</div>
                <h3>Chưa có tài liệu nào</h3>
                <p>
                    Hãy thêm tài liệu đầu tiên hoặc bấm đồng bộ folder để tự tạo tài liệu từ thư mục học phần.
                </p>

                <a class="admin-btn secondary"
                   href="<%= contextPath %>/admin/documents/import-folders"
                   onclick="return confirm('Đồng bộ toàn bộ folder trong D:/upLoad/file_document vào danh sách tài liệu?');">
                    Đồng bộ folder
                </a>

                <a class="admin-btn primary"
                   href="<%= contextPath %>/admin/documents?action=form">
                    Thêm tài liệu mới
                </a>
            </div>

        <% } else { %>

            <div class="docs-table-wrapper">
                <table class="docs-table">
                    <thead>
                    <tr>
                        <th>Tài liệu</th>
                        <th>Danh mục</th>
                        <th>Tác giả</th>
                        <th>NXB</th>
                        <th>Năm</th>
                        <th>Trạng thái</th>
                        <th>Nổi bật</th>
                        <th>Thao tác</th>
                    </tr>
                    </thead>

                    <tbody>
                    <% for (Object d : documents) {
                        int documentId = getInt(d, "getDocumentId", "getId");

                        String title = getText(d, "Chưa có tiêu đề", "getTitle");
                        String description = getText(d, "Chưa có mô tả tài liệu.", "getDescription");
                        String categoryName = getText(d, "Chưa phân loại", "getCategoryName");
                        String authorName = getText(d, "Chưa cập nhật", "getAuthor", "getAuthorName");
                        String publisherName = getText(d, "Chưa cập nhật", "getPublisher", "getPublisherName");
                        String publishYear = getText(d, "Chưa rõ", "getPublishYear");
                        String status = getText(d, "UNKNOWN", "getStatus");
                        String coverImage = getText(d, "", "getCoverImage");

                        boolean featured = getBoolean(d, "isFeatured", "getFeatured");

                        String statusClass = "status-hidden";

                        if ("ACTIVE".equalsIgnoreCase(status)) {
                            statusClass = "status-active";
                        } else if ("DELETED".equalsIgnoreCase(status)) {
                            statusClass = "status-danger";
                        }
                    %>

                        <tr>
                            <td>
                                <div class="doc-title-cell">
                                    <div class="doc-cover-mini">
                                        <% if (coverImage != null && !coverImage.trim().isEmpty()) { %>
                                            <img src="<%= contextPath %>/upload-image/documents/<%= enc(coverImage) %>"
                                                 alt="cover">
                                        <% } else { %>
                                            PDF
                                        <% } %>
                                    </div>

                                    <div class="doc-title-info">
                                        <strong><%= h(title) %></strong>
                                        <span><%= h(shortText(description, 120)) %></span>
                                    </div>
                                </div>
                            </td>

                            <td>
                                <span class="doc-chip">
                                    <%= h(categoryName) %>
                                </span>
                            </td>

                            <td><%= h(authorName) %></td>

                            <td><%= h(publisherName) %></td>

                            <td><%= h(publishYear) %></td>

                            <td>
                                <span class="status-badge-admin <%= statusClass %>">
                                    <%= h(status) %>
                                </span>
                            </td>

                            <td>
                                <% if (featured) { %>
                                    <span class="featured-badge">Nổi bật</span>
                                <% } else { %>
                                    <span class="doc-chip">Thường</span>
                                <% } %>
                            </td>

                            <td>
                                <div class="table-actions">
                                    <a class="table-action view"
                                       href="<%= contextPath %>/documents?action=detail&id=<%= documentId %>">
                                        Xem
                                    </a>

                                    <a class="table-action edit"
                                       href="<%= contextPath %>/admin/documents?action=form&id=<%= documentId %>">
                                        Sửa
                                    </a>

                                    <a class="table-action hide"
                                       href="<%= contextPath %>/admin/documents?action=hide&id=<%= documentId %>"
                                       onclick="return confirm('Bạn có chắc muốn ẩn tài liệu này?');">
                                        Ẩn
                                    </a>

                                    <a class="table-action delete"
                                       href="<%= contextPath %>/admin/documents?action=delete&id=<%= documentId %>"
                                       onclick="return confirm('Bạn có chắc muốn xóa tài liệu này khỏi danh sách hiển thị không?');">
                                        Xóa
                                    </a>
                                </div>
                            </td>
                        </tr>

                    <% } %>
                    </tbody>
                </table>
            </div>

        <% } %>

    </section>

</main>

</body>
</html>
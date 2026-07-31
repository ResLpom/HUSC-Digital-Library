<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.lang.reflect.Method" %>
<%@ page import="vn.edu.husc.library.model.User" %>

<%!
    private String getText(Object obj, String defaultValue, String... methods) {
        if (obj == null) return defaultValue;

        for (String m : methods) {
            try {
                Method method = obj.getClass().getMethod(m);
                Object value = method.invoke(obj);

                if (value != null && !value.toString().trim().isEmpty()) {
                    return value.toString();
                }
            } catch (Exception e) {
                // ignore
            }
        }

        return defaultValue;
    }

    private int getInt(Object obj, int defaultValue, String... methods) {
        if (obj == null) return defaultValue;

        for (String m : methods) {
            try {
                Method method = obj.getClass().getMethod(m);
                Object value = method.invoke(obj);

                if (value == null) continue;

                if (value instanceof Number) {
                    return ((Number) value).intValue();
                }

                return Integer.parseInt(value.toString());
            } catch (Exception e) {
                // ignore
            }
        }

        return defaultValue;
    }

    private boolean getBoolean(Object obj, boolean defaultValue, String... methods) {
        if (obj == null) return defaultValue;

        for (String m : methods) {
            try {
                Method method = obj.getClass().getMethod(m);
                Object value = method.invoke(obj);

                if (value == null) continue;

                if (value instanceof Boolean) {
                    return ((Boolean) value).booleanValue();
                }

                return "true".equalsIgnoreCase(value.toString()) || "1".equals(value.toString());
            } catch (Exception e) {
                // ignore
            }
        }

        return defaultValue;
    }
%>

<%
    String contextPath = request.getContextPath();

    Object document = request.getAttribute("document");

    List<?> categories = (List<?>) request.getAttribute("categories");
    List<?> types = (List<?>) request.getAttribute("types");
    List<?> authors = (List<?>) request.getAttribute("authors");
    List<?> publishers = (List<?>) request.getAttribute("publishers");

    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        currentUser = (User) session.getAttribute("user");
    }

    String fullName = currentUser != null ? getText(currentUser, "Quản trị viên", "getFullName", "getName") : "Quản trị viên";
    String email = currentUser != null ? getText(currentUser, "admin@husc.edu.vn", "getEmail") : "admin@husc.edu.vn";
    String roleName = currentUser != null ? getText(currentUser, "Administrator", "getRoleName", "getRoleCode") : "Administrator";

    int documentId = getInt(document, 0, "getDocumentId", "getId");
    boolean isEdit = documentId > 0;

    String pageTitle = isEdit ? "Cập nhật tài liệu" : "Thêm tài liệu mới";
    String formAction = isEdit ? "update" : "insert";

    String title = getText(document, "", "getTitle");
    String description = getText(document, "", "getDescription");
    String summary = getText(document, "", "getSummary");
    String keywords = getText(document, "", "getKeywords");
    String filePath = getText(document, "", "getFilePath");
    String coverImage = getText(document, "", "getCoverImage");
    String sourceName = getText(document, "", "getSourceName");
    String sourceUrl = getText(document, "", "getSourceUrl");
    String subjectName = getText(document, "", "getSubjectName");
    String departmentName = getText(document, "", "getDepartmentName");
    String fileType = getText(document, "", "getFileType");
    String fileSize = getText(document, "", "getFileSize");
    String status = getText(document, "ACTIVE", "getStatus");
    String publishYear = getText(document, "", "getPublishYear");
    boolean featured = getBoolean(document, false, "isFeatured", "getFeatured", "getIsFeatured");

    int categoryId = getInt(document, 0, "getCategoryId");
    int typeId = getInt(document, 0, "getTypeId");
    int authorId = getInt(document, 0, "getAuthorId");
    int publisherId = getInt(document, 0, "getPublisherId");
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title><%= pageTitle %> - HUSC Digital Library</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/common/base.css?v=1">
	<link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/common/components.css?v=1">
	<link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/admin/admin-layout.css?v=1">
    <style>
        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background:
                radial-gradient(circle at top left, rgba(14, 165, 233, 0.12), transparent 30%),
                radial-gradient(circle at bottom right, rgba(99, 102, 241, 0.12), transparent 32%),
                #f6f9fc;
            color: #0f172a;
            overflow-x: hidden;
        }

        .admin-pro-layout {
            min-height: 100vh;
            display: grid;
            grid-template-columns: 292px minmax(0, 1fr);
        }

        .admin-sidebar {
            position: sticky;
            top: 0;
            height: 100vh;
            padding: 24px;
            background:
                radial-gradient(circle at top left, rgba(56, 189, 248, 0.18), transparent 32%),
                linear-gradient(180deg, #0f172a, #111827);
            color: white;
            box-sizing: border-box;
            overflow-y: auto;
        }

        .admin-brand {
            display: flex;
            align-items: center;
            gap: 14px;
            margin-bottom: 34px;
        }

        .admin-brand-icon {
            width: 54px;
            height: 54px;
            border-radius: 18px;
            background: linear-gradient(135deg, #0284c7, #06b6d4);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 26px;
            box-shadow: 0 18px 36px rgba(6, 182, 212, 0.28);
        }

        .admin-brand h2 {
            font-size: 18px;
            margin: 0;
            line-height: 1.2;
        }

        .admin-brand p {
            margin: 4px 0 0;
            color: #93c5fd;
            font-size: 12px;
        }

        .admin-user-card {
            padding: 18px;
            border-radius: 24px;
            background: rgba(255,255,255,0.1);
            border: 1px solid rgba(255,255,255,0.14);
            backdrop-filter: blur(16px);
            margin-bottom: 24px;
        }

        .admin-user-avatar {
            width: 58px;
            height: 58px;
            border-radius: 20px;
            background: white;
            color: #1e3a8a;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 26px;
            font-weight: 900;
            margin-bottom: 14px;
        }

        .admin-user-card strong {
            display: block;
            color: white;
            font-size: 16px;
            margin-bottom: 5px;
        }

        .admin-user-card span {
            display: block;
            color: #bfdbfe;
            font-size: 12px;
            line-height: 1.45;
        }

        .admin-menu-title {
            color: #64748b;
            font-size: 11px;
            font-weight: 900;
            letter-spacing: 1.4px;
            margin: 22px 0 10px;
        }

        .admin-nav {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .admin-nav a {
            height: 46px;
            padding: 0 14px;
            border-radius: 16px;
            color: #cbd5e1;
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 12px;
            font-weight: 800;
            font-size: 14px;
            transition: 0.22s ease;
        }

        .admin-nav a:hover,
        .admin-nav a.active {
            color: white;
            background: rgba(255,255,255,0.13);
            transform: translateX(5px);
        }

        .admin-nav a.active {
            box-shadow: inset 3px 0 0 #38bdf8;
        }

        .admin-main {
            min-width: 0;
            padding: 30px 42px 70px;
        }

        .admin-topbar {
            min-height: 76px;
            border-radius: 28px;
            padding: 18px 24px;
            background: rgba(255,255,255,0.86);
            border: 1px solid rgba(226,232,240,0.9);
            box-shadow: 0 16px 40px rgba(15,23,42,0.06);
            backdrop-filter: blur(18px);
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 16px;
            animation: fadeUp 0.7s ease both;
        }

        .admin-topbar h1 {
            font-size: 24px;
            margin: 0;
            color: #0f172a;
        }

        .admin-topbar p {
            margin: 4px 0 0;
            color: #64748b;
            font-size: 13px;
        }

        .admin-btn {
            height: 42px;
            padding: 0 16px;
            border-radius: 999px;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-weight: 900;
            font-size: 13px;
            transition: 0.22s ease;
            border: none;
            cursor: pointer;
        }

        .admin-btn.primary {
            color: white;
            background: linear-gradient(135deg, #0284c7, #06b6d4);
            box-shadow: 0 14px 30px rgba(6,182,212,0.24);
        }

        .admin-btn.secondary {
            color: #0369a1;
            background: #e0f2fe;
            border: 1px solid #bae6fd;
        }

        .admin-btn.danger {
            color: #be123c;
            background: #ffe4e6;
            border: 1px solid #fecdd3;
        }

        .admin-btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 18px 38px rgba(15,23,42,0.13);
        }

        .form-hero {
            margin-top: 26px;
            border-radius: 38px;
            padding: 42px;
            color: white;
            background:
                radial-gradient(circle at 18% 20%, rgba(56,189,248,0.35), transparent 32%),
                radial-gradient(circle at 90% 80%, rgba(99,102,241,0.35), transparent 34%),
                linear-gradient(135deg, #0f172a, #1e3a8a);
            box-shadow: 0 34px 82px rgba(15,23,42,0.18);
            position: relative;
            overflow: hidden;
            display: grid;
            grid-template-columns: minmax(0, 1fr) 340px;
            gap: 28px;
            align-items: center;
            animation: fadeUp 0.75s ease 0.08s both;
        }

        .form-hero::before {
            content: "";
            position: absolute;
            inset: 0;
            background: linear-gradient(120deg, transparent, rgba(255,255,255,0.08), transparent);
            transform: translateX(-120%);
            animation: shineMove 7s ease-in-out infinite;
        }

        .form-hero-content,
        .form-hero-panel {
            position: relative;
            z-index: 2;
        }

        .admin-label {
            display: inline-flex;
            padding: 9px 16px;
            border-radius: 999px;
            background: rgba(255,255,255,0.13);
            border: 1px solid rgba(255,255,255,0.18);
            color: #bfdbfe;
            font-size: 12px;
            font-weight: 900;
            letter-spacing: 1.4px;
        }

        .form-hero h2 {
            font-size: 44px;
            line-height: 1.1;
            letter-spacing: -1.5px;
            margin: 18px 0 12px;
        }

        .form-hero h2 span {
            background: linear-gradient(135deg, #7dd3fc, #ffffff, #c4b5fd);
            -webkit-background-clip: text;
            background-clip: text;
            color: transparent;
        }

        .form-hero p {
            color: #dbeafe;
            line-height: 1.75;
            max-width: 760px;
        }

        .form-hero-panel {
            padding: 24px;
            border-radius: 28px;
            background: rgba(255,255,255,0.13);
            border: 1px solid rgba(255,255,255,0.17);
            backdrop-filter: blur(18px);
            animation: floatCard 5s ease-in-out infinite;
        }

        .form-hero-panel h3 {
            color: white;
            margin: 0 0 12px;
        }

        .form-hero-panel p {
            margin: 0;
            color: #dbeafe;
            font-size: 14px;
        }

        .form-shell {
            margin-top: 26px;
            display: grid;
            grid-template-columns: minmax(0, 1fr) 360px;
            gap: 24px;
            animation: fadeUp 0.75s ease 0.16s both;
        }

        .form-card {
            background: white;
            border: 1px solid #e2e8f0;
            border-radius: 34px;
            box-shadow: 0 18px 48px rgba(15,23,42,0.06);
            padding: 30px;
        }

        .form-card h3 {
            margin: 0 0 18px;
            color: #0f172a;
            font-size: 24px;
        }

        .form-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 18px;
        }

        .form-group {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .form-group.full {
            grid-column: 1 / -1;
        }

        .form-group label {
            color: #334155;
            font-size: 13px;
            font-weight: 900;
        }

        .form-group input,
        .form-group select,
        .form-group textarea {
            width: 100%;
            border-radius: 18px;
            border: 1px solid #dbe3ef;
            background: #f8fafc;
            padding: 13px 15px;
            outline: none;
            font-family: Arial, sans-serif;
            font-size: 14px;
            box-sizing: border-box;
            transition: 0.22s ease;
        }

        .form-group textarea {
            min-height: 110px;
            resize: vertical;
        }

        .form-group input:focus,
        .form-group select:focus,
        .form-group textarea:focus {
            border-color: #0284c7;
            background: white;
            box-shadow: 0 0 0 5px rgba(2,132,199,0.12);
        }

        .form-help {
            color: #64748b;
            font-size: 12px;
            line-height: 1.5;
        }

        .form-actions {
            margin-top: 24px;
            padding-top: 22px;
            border-top: 1px solid #e2e8f0;
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
        }

        .side-card {
            background:
                radial-gradient(circle at top right, rgba(14,165,233,0.1), transparent 36%),
                white;
            border: 1px solid #e2e8f0;
            border-radius: 34px;
            box-shadow: 0 18px 48px rgba(15,23,42,0.06);
            padding: 26px;
            height: fit-content;
        }

        .side-card h3 {
            margin: 0 0 14px;
            color: #0f172a;
            font-size: 22px;
        }

        .preview-cover {
            height: 220px;
            border-radius: 26px;
            background:
                linear-gradient(135deg, rgba(2,132,199,0.14), rgba(99,102,241,0.14)),
                #f8fafc;
            border: 1px dashed #cbd5e1;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
            margin-bottom: 18px;
        }

        .preview-cover img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .preview-empty {
            font-size: 46px;
        }

        .tip-list {
            display: flex;
            flex-direction: column;
            gap: 12px;
        }

        .tip-item {
            padding: 14px;
            border-radius: 18px;
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            color: #475569;
            font-size: 13px;
            line-height: 1.55;
        }

        @keyframes fadeUp {
            from {
                opacity: 0;
                transform: translateY(26px);
            }

            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        @keyframes shineMove {
            0% {
                transform: translateX(-120%);
            }

            45%, 100% {
                transform: translateX(120%);
            }
        }

        @keyframes floatCard {
            0%, 100% {
                transform: translateY(0);
            }

            50% {
                transform: translateY(-14px);
            }
        }

        @media (max-width: 1180px) {
            .admin-pro-layout,
            .form-hero,
            .form-shell {
                grid-template-columns: 1fr;
            }

            .admin-sidebar {
                position: static;
                height: auto;
            }

            .admin-main {
                padding: 24px 18px 60px;
            }
        }

        @media (max-width: 760px) {
            .admin-topbar {
                flex-direction: column;
                align-items: flex-start;
            }

            .form-hero {
                padding: 30px 22px;
            }

            .form-hero h2 {
                font-size: 34px;
            }

            .form-grid {
                grid-template-columns: 1fr;
            }
        }
        .admin-sidebar {
    width: 280px;
    min-height: 100vh;
    background: #0f172a;
    color: white;
    padding: 22px 18px;
    position: fixed;
    left: 0;
    top: 0;
    overflow-y: auto;
    z-index: 100;
}

.admin-brand {
    padding: 12px 14px 22px;
    margin-bottom: 10px;
    border-bottom: 1px solid rgba(255, 255, 255, 0.08);
}

.admin-brand-text strong {
    display: block;
    font-size: 18px;
    font-weight: 900;
    color: #ffffff;
}

.admin-brand-text span {
    display: block;
    margin-top: 4px;
    font-size: 12px;
    font-weight: 700;
    color: #94a3b8;
}

.admin-menu-title {
    margin: 18px 0 10px;
    color: #94a3b8;
    font-size: 12px;
    font-weight: 900;
    letter-spacing: 2px;
}

.admin-nav {
    display: grid;
    gap: 8px;
}

.admin-nav a {
    min-height: 46px;
    padding: 0 14px;
    border-radius: 16px;
    color: #e2e8f0;
    text-decoration: none;
    display: flex;
    align-items: center;
    font-size: 15px;
    font-weight: 900;
    transition: 0.22s ease;
}

.admin-nav a:hover {
    background: rgba(255, 255, 255, 0.08);
    color: white;
}

.admin-nav a.active {
    background: rgba(255, 255, 255, 0.13);
    color: white;
    border: 1px solid #38bdf8;
    box-shadow: inset 4px 0 0 #38bdf8;
}

.admin-main {
    margin-left: 280px;
    min-height: 100vh;
    padding: 24px;
}
    </style>
</head>

<body>
<jsp:include page="/admin/includes/admin-sidebar.jsp" />

    <main class="admin-main">

        <section class="admin-topbar">
            <div>
                <h1><%= pageTitle %></h1>
                <p>Quản lý thông tin tài liệu số trong thư viện.</p>
            </div>

            <a class="admin-btn secondary" href="<%= contextPath %>/admin/documents">
                Quay lại danh sách
            </a>
        </section>

        <section class="form-hero">
            <div class="form-hero-content">
                <span class="admin-label">DOCUMENT FORM</span>

                <h2>
                    <%= isEdit ? "Cập nhật" : "Tạo mới" %><br>
                    <span>tài liệu số</span>
                </h2>

                <p>
                    Nhập thông tin tài liệu, nguồn tài liệu, tác giả, nhà xuất bản và các dữ liệu mô tả
                    để người dùng dễ tìm kiếm trong hệ thống thư viện số.
                </p>
            </div>

            <div class="form-hero-panel">
                <h3><%= isEdit ? "Chế độ chỉnh sửa" : "Chế độ thêm mới" %></h3>
                <p>
                    Các trường có dấu * nên được nhập đầy đủ để tài liệu hiển thị tốt ở trang người dùng.
                </p>
            </div>
        </section>

        <section class="form-shell">

            <form class="form-card" action="<%= contextPath %>/admin/documents" method="post">
                <h3>Thông tin tài liệu</h3>

                <input type="hidden" name="action" value="<%= formAction %>">

                <% if (isEdit) { %>
                    <input type="hidden" name="documentId" value="<%= documentId %>">
                    <input type="hidden" name="id" value="<%= documentId %>">
                <% } %>

                <div class="form-grid">

                    <div class="form-group full">
                        <label>Tiêu đề tài liệu *</label>
                        <input type="text" name="title" value="<%= title %>" required
                               placeholder="Nhập tiêu đề tài liệu">
                    </div>

                    <div class="form-group">
                        <label>Danh mục</label>
                        <select name="categoryId">
                            <option value="">-- Chọn danh mục --</option>
                            <% if (categories != null) {
                                for (Object c : categories) {
                                    int id = getInt(c, 0, "getId", "getCategoryId");
                                    String name = getText(c, "Danh mục", "getName", "getCategoryName");
                            %>
                                <option value="<%= id %>" <%= id == categoryId ? "selected" : "" %>>
                                    <%= name %>
                                </option>
                            <% } } %>
                        </select>
                    </div>

                    <div class="form-group">
                        <label>Loại tài liệu</label>
                        <select name="typeId">
                            <option value="">-- Chọn loại --</option>
                            <% if (types != null) {
                                for (Object t : types) {
                                    int id = getInt(t, 0, "getId", "getTypeId");
                                    String name = getText(t, "Loại tài liệu", "getName", "getTypeName");
                            %>
                                <option value="<%= id %>" <%= id == typeId ? "selected" : "" %>>
                                    <%= name %>
                                </option>
                            <% } } %>
                        </select>
                    </div>

                    <div class="form-group">
                        <label>Tác giả có sẵn</label>
                        <select name="authorId">
                            <option value="">-- Chọn tác giả --</option>
                            <% if (authors != null) {
                                for (Object a : authors) {
                                    int id = getInt(a, 0, "getId", "getAuthorId");
                                    String name = getText(a, "Tác giả", "getName", "getAuthorName", "getFullName");
                            %>
                                <option value="<%= id %>" <%= id == authorId ? "selected" : "" %>>
                                    <%= name %>
                                </option>
                            <% } } %>
                        </select>
                    </div>

                    <div class="form-group">
                        <label>Thêm tác giả mới</label>
                        <input type="text" name="newAuthorName" placeholder="Nhập nếu chưa có trong danh sách">
                        <span class="form-help">Nếu nhập ô này, hệ thống có thể tạo tác giả mới.</span>
                    </div>

                    <div class="form-group">
                        <label>Nhà xuất bản có sẵn</label>
                        <select name="publisherId">
                            <option value="">-- Chọn nhà xuất bản --</option>
                            <% if (publishers != null) {
                                for (Object p : publishers) {
                                    int id = getInt(p, 0, "getId", "getPublisherId");
                                    String name = getText(p, "Nhà xuất bản", "getName", "getPublisherName");
                            %>
                                <option value="<%= id %>" <%= id == publisherId ? "selected" : "" %>>
                                    <%= name %>
                                </option>
                            <% } } %>
                        </select>
                    </div>

                    <div class="form-group">
                        <label>Thêm NXB mới</label>
                        <input type="text" name="newPublisherName" placeholder="Nhập nếu chưa có trong danh sách">
                    </div>

                    <div class="form-group">
                        <label>Năm xuất bản</label>
                        <input type="number" name="publishYear" value="<%= publishYear %>" placeholder="Ví dụ: 2024">
                    </div>

                    <div class="form-group">
                        <label>Trạng thái</label>
                        <select name="status">
                            <option value="ACTIVE" <%= "ACTIVE".equalsIgnoreCase(status) ? "selected" : "" %>>Hiển thị</option>
                            <option value="INACTIVE" <%= "INACTIVE".equalsIgnoreCase(status) ? "selected" : "" %>>Ẩn</option>
                            <option value="HIDDEN" <%= "HIDDEN".equalsIgnoreCase(status) ? "selected" : "" %>>Đã ẩn</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label>Đường dẫn file</label>
                        <input type="text" name="filePath" value="<%= filePath %>"
                               placeholder="/uploads/documents/file.pdf">
                    </div>

                    <div class="form-group">
                        <label>Ảnh bìa</label>
                        <input type="text" name="coverImage" value="<%= coverImage %>"
                               placeholder="/uploads/covers/image.jpg">
                    </div>

                    <div class="form-group">
                        <label>Loại file</label>
                        <input type="text" name="fileType" value="<%= fileType %>" placeholder="PDF, DOCX, PPTX...">
                    </div>

                    <div class="form-group">
                        <label>Kích thước file</label>
                        <input type="text" name="fileSize" value="<%= fileSize %>" placeholder="Ví dụ: 2048000">
                    </div>

                    <div class="form-group">
                        <label>Nguồn tài liệu</label>
                        <input type="text" name="sourceName" value="<%= sourceName %>" placeholder="Tên nguồn">
                    </div>

                    <div class="form-group">
                        <label>URL nguồn</label>
                        <input type="text" name="sourceUrl" value="<%= sourceUrl %>" placeholder="https://...">
                    </div>

                    <div class="form-group">
                        <label>Môn học</label>
                        <input type="text" name="subjectName" value="<%= subjectName %>" placeholder="Ví dụ: Lập trình Java">
                    </div>

                    <div class="form-group">
                        <label>Khoa/Bộ môn</label>
                        <input type="text" name="departmentName" value="<%= departmentName %>" placeholder="Ví dụ: Công nghệ thông tin">
                    </div>

                    <div class="form-group full">
                        <label>Mô tả ngắn</label>
                        <textarea name="description" placeholder="Mô tả ngắn về tài liệu"><%= description %></textarea>
                    </div>

                    <div class="form-group full">
                        <label>Tóm tắt nội dung</label>
                        <textarea name="summary" placeholder="Tóm tắt nội dung chính của tài liệu"><%= summary %></textarea>
                    </div>

                    <div class="form-group full">
                        <label>Từ khóa</label>
                        <input type="text" name="keywords" value="<%= keywords %>"
                               placeholder="java, servlet, jsp, sql server">
                    </div>

                    <div class="form-group full">
                        <label>
                            <input type="checkbox" name="featured" value="true" <%= featured ? "checked" : "" %>>
                            Đánh dấu tài liệu nổi bật
                        </label>
                    </div>

                </div>

                <div class="form-actions">
                    <button class="admin-btn primary" type="submit">
                        <%= isEdit ? "Lưu thay đổi" : "Thêm tài liệu" %>
                    </button>

                    <a class="admin-btn secondary" href="<%= contextPath %>/admin/documents">
                        Hủy
                    </a>

                    <% if (isEdit) { %>
                        <a class="admin-btn danger"
                           href="<%= contextPath %>/admin/documents?action=hide&id=<%= documentId %>"
                           onclick="return confirm('Bạn có chắc muốn ẩn tài liệu này?');">
                            Ẩn tài liệu
                        </a>
                    <% } %>
                </div>
            </form>

            <aside class="side-card">
                <h3>Xem trước ảnh bìa</h3>

                <div class="preview-cover" id="previewBox">
                    <% if (coverImage != null && !coverImage.trim().isEmpty()) { %>
                        <img src="<%= contextPath %><%= coverImage.startsWith("/") ? coverImage : "/" + coverImage %>" alt="Cover">
                    <% } else { %>
                        <div class="preview-empty">📄</div>
                    <% } %>
                </div>

                <div class="tip-list">
                    <div class="tip-item">
                        <b>Gợi ý:</b> Ảnh bìa nên dùng đường dẫn bắt đầu bằng <code>/uploads/...</code>.
                    </div>

                    <div class="tip-item">
                        <b>Tài liệu nổi bật:</b> sẽ được ưu tiên hiển thị ở trang chủ hoặc khu vực giới thiệu.
                    </div>

                    <div class="tip-item">
                        <b>Từ khóa:</b> nên phân tách bằng dấu phẩy để hỗ trợ tìm kiếm tốt hơn.
                    </div>
                </div>
            </aside>

        </section>

    </main>

</div>

</body>
</html>
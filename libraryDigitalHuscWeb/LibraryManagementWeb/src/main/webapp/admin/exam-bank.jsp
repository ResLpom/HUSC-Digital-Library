<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page import="vn.edu.husc.library.servlet.AdminExamBankServlet.AdminExamItem" %>

<%!
    private String enc(String value) {
        if (value == null) return "";
        return URLEncoder.encode(value, StandardCharsets.UTF_8).replace("+", "%20");
    }

    private String h(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }

    private String typeLabel(String type) {
        if ("de-cuong".equals(type)) return "Đề cương";
        if ("ngan-hang-de".equals(type)) return "Ngân hàng đề";
        return "Kho đề";
    }

    private String titleByView(String view) {
        if ("types".equals(view)) return "Chọn nhóm tài liệu";
        if ("faculties".equals(view)) return "Danh sách khoa ngành";
        if ("subjects".equals(view)) return "Danh sách học phần";
        if ("years".equals(view)) return "Danh sách niên khóa";
        if ("files".equals(view)) return "Danh sách file";
        return "Kho đề";
    }

    private String iconByView(String view, AdminExamItem item) {
        if (item != null && !item.isDirectory()) {
            if (item.isPdf()) return "📄";
            if (item.isImage()) return "🖼️";
            if (item.isOffice()) return "📝";
            return "📎";
        }

        if ("faculties".equals(view)) return "🏫";
        if ("subjects".equals(view)) return "📘";
        if ("years".equals(view)) return "🗓️";
        return "📁";
    }
%>

<%
    String contextPath = request.getContextPath();

    String success = (String) request.getAttribute("success");
    String error = (String) request.getAttribute("error");

    List<AdminExamItem> items = (List<AdminExamItem>) request.getAttribute("items");

    String view = (String) request.getAttribute("view");
    String type = (String) request.getAttribute("type");
    String faculty = (String) request.getAttribute("faculty");
    String subject = (String) request.getAttribute("subject");
    String year = (String) request.getAttribute("year");
    String keyword = (String) request.getAttribute("keyword");
    String uploadRoot = (String) request.getAttribute("uploadRoot");

    if (view == null) view = "types";
    if (keyword == null) keyword = "";

    String uploadType = type != null ? type : "de-cuong";
    String uploadFaculty = faculty != null ? faculty : "";
    String uploadSubject = subject != null ? subject : "";
    String uploadYear = year != null ? year : "";

    int total = items != null ? items.size() : 0;
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản lý Kho đề - Admin</title>

    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/common/base.css?v=1">
	<link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/common/components.css?v=1">
	<link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/admin/admin-layout.css?v=1">
    <style>
        body {
            margin: 0;
            background:
                radial-gradient(circle at top left, rgba(124, 58, 237, 0.14), transparent 30%),
                radial-gradient(circle at bottom right, rgba(14, 165, 233, 0.12), transparent 32%),
                #f6f9fc;
        }

        .admin-main {
            margin-left: 280px;
            min-height: 100vh;
            padding: 24px;
        }

        .admin-shell {
            width: 100%;
            max-width: 1240px;
            margin: 0 auto;
            padding: 0 0 70px;
        }

        .admin-hero {
            padding: 44px;
            border-radius: 38px;
            color: white;
            background:
                radial-gradient(circle at 20% 20%, rgba(168, 85, 247, 0.40), transparent 34%),
                radial-gradient(circle at 88% 80%, rgba(14, 165, 233, 0.34), transparent 34%),
                linear-gradient(135deg, #0f172a, #4c1d95);
            box-shadow: 0 34px 82px rgba(15, 23, 42, 0.18);
            display: grid;
            grid-template-columns: minmax(0, 1fr) 260px;
            gap: 24px;
            align-items: center;
        }

        .admin-hero span {
            display: inline-flex;
            padding: 9px 16px;
            border-radius: 999px;
            background: rgba(255, 255, 255, 0.13);
            border: 1px solid rgba(255, 255, 255, 0.18);
            color: #ddd6fe;
            font-size: 12px;
            font-weight: 900;
            letter-spacing: 1.4px;
        }

        .admin-hero h1 {
            font-size: 46px;
            line-height: 1.08;
            margin: 18px 0 12px;
            letter-spacing: -1.4px;
        }

        .admin-hero p {
            color: #ede9fe;
            font-size: 16px;
            line-height: 1.7;
            margin: 0;
        }

        .stat-card {
            padding: 22px;
            border-radius: 28px;
            background: rgba(255, 255, 255, 0.13);
            border: 1px solid rgba(255, 255, 255, 0.17);
        }

        .stat-card strong {
            display: block;
            font-size: 34px;
            color: white;
            margin-bottom: 8px;
        }

        .stat-card small {
            color: #ede9fe;
            font-weight: 800;
        }

        .admin-layout {
            margin-top: 26px;
            display: grid;
            grid-template-columns: minmax(0, 1fr) 390px;
            gap: 24px;
            align-items: start;
        }

        .admin-card {
            background: white;
            border-radius: 32px;
            border: 1px solid #e2e8f0;
            box-shadow: 0 18px 48px rgba(15, 23, 42, 0.06);
            padding: 26px;
        }

        .admin-card h2 {
            margin: 0 0 8px;
            font-size: 26px;
            color: #0f172a;
        }

        .admin-card p {
            margin: 0 0 20px;
            color: #64748b;
            line-height: 1.6;
        }

        .breadcrumb-box {
            margin-bottom: 18px;
            padding: 14px 16px;
            border-radius: 22px;
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            align-items: center;
            color: #64748b;
            font-size: 13px;
            font-weight: 800;
        }

        .breadcrumb-box a {
            color: #7c3aed;
            text-decoration: none;
        }

        .search-box {
            margin-bottom: 18px;
            display: grid;
            grid-template-columns: minmax(0, 1fr) 130px;
            gap: 10px;
        }

        .search-box input {
            height: 44px;
            border-radius: 16px;
            border: 1px solid #dbe3ef;
            background: #f8fafc;
            padding: 0 14px;
            outline: none;
        }

        .search-box button {
            border: none;
            border-radius: 16px;
            color: white;
            background: linear-gradient(135deg, #7c3aed, #06b6d4);
            font-weight: 900;
            cursor: pointer;
        }

        .type-grid,
        .item-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 16px;
        }

        .item-grid {
            grid-template-columns: repeat(3, minmax(0, 1fr));
        }

        .item-card {
            border: 1px solid #e2e8f0;
            border-radius: 24px;
            background: #ffffff;
            padding: 18px;
            min-height: 170px;
            display: flex;
            flex-direction: column;
            transition: 0.22s ease;
        }

        .item-card:hover {
            transform: translateY(-5px);
            border-color: #ddd6fe;
            box-shadow: 0 18px 44px rgba(15, 23, 42, 0.09);
        }

        .item-icon {
            width: 54px;
            height: 54px;
            border-radius: 18px;
            background: #ede9fe;
            color: #7c3aed;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 26px;
            margin-bottom: 14px;
        }

        .item-card h3 {
            margin: 0 0 8px;
            color: #0f172a;
            font-size: 16px;
            line-height: 1.35;
            word-break: break-word;
        }

        .item-card p {
            margin: 0 0 16px;
            color: #64748b;
            font-size: 13px;
            line-height: 1.55;
            flex: 1;
        }

        .item-actions {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
        }

        .btn-open,
        .btn-delete,
        .btn-soft {
            height: 38px;
            padding: 0 13px;
            border-radius: 999px;
            border: none;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 12px;
            font-weight: 900;
            text-decoration: none;
        }

        .btn-open {
            color: white;
            background: linear-gradient(135deg, #7c3aed, #06b6d4);
        }

        .btn-soft {
            color: #7c3aed;
            background: #ede9fe;
            border: 1px solid #ddd6fe;
        }

        .btn-delete {
            color: #be123c;
            background: #ffe4e6;
            border: 1px solid #fecdd3;
        }

        .form-grid {
            display: grid;
            gap: 16px;
        }

        .form-group label {
            display: block;
            font-weight: 900;
            color: #334155;
            margin-bottom: 8px;
        }

        .form-group input,
        .form-group select {
            width: 100%;
            min-height: 46px;
            border-radius: 16px;
            border: 1px solid #cbd5e1;
            background: #f8fafc;
            padding: 0 14px;
            outline: none;
            color: #0f172a;
            box-sizing: border-box;
        }

        .form-group input[type="file"] {
            height: auto;
            padding: 13px 14px;
        }

        .btn-submit {
            width: 100%;
            height: 50px;
            border: none;
            border-radius: 999px;
            color: white;
            background: linear-gradient(135deg, #7c3aed, #06b6d4);
            font-weight: 900;
            font-size: 14px;
            cursor: pointer;
        }

        .alert-success,
        .alert-error {
            margin-bottom: 18px;
            padding: 14px 16px;
            border-radius: 18px;
            font-weight: 800;
            line-height: 1.5;
        }

        .alert-success {
            background: #dcfce7;
            color: #166534;
            border: 1px solid #bbf7d0;
        }

        .alert-error {
            background: #ffe4e6;
            color: #be123c;
            border: 1px solid #fecdd3;
        }

        .path-box {
            margin-top: 18px;
            padding: 14px;
            border-radius: 18px;
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            color: #475569;
            font-size: 13px;
            line-height: 1.6;
            word-break: break-all;
        }

        .empty-box {
            padding: 34px;
            border-radius: 26px;
            background: #f8fafc;
            border: 1px dashed #cbd5e1;
            text-align: center;
        }

        .empty-icon {
            font-size: 48px;
            margin-bottom: 12px;
        }

        @media (max-width: 1060px) {
            .admin-main {
                margin-left: 0;
                padding: 16px;
            }

            .admin-layout,
            .admin-hero,
            .item-grid,
            .type-grid {
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
    <div class="admin-shell">

        <section class="admin-hero">
            <div>
                <span>ADMIN EXAM BANK</span>
                <h1>Quản lý kho đề</h1>
                <p>
                    Duyệt dữ liệu hiện có, thêm thủ công khoa, học phần, niên khóa bằng cách nhập tên,
                    upload file và xoá file khi cần.
                </p>
            </div>

            <div class="stat-card">
                <strong><%= "types".equals(view) ? "2" : total %></strong>
                <small><%= titleByView(view) %></small>
            </div>
        </section>

        <section class="admin-layout">

            <main class="admin-card">
                <h2><%= titleByView(view) %></h2>
                <p>Đường dẫn gốc đang dùng: <strong><%= h(uploadRoot) %></strong></p>

                <% if (success != null) { %>
                    <div class="alert-success"><%= h(success) %></div>
                <% } %>

                <% if (error != null) { %>
                    <div class="alert-error"><%= h(error) %></div>
                <% } %>

                <section class="breadcrumb-box">
                    <a href="<%= contextPath %>/admin/exam-bank">Kho đề</a>

                    <% if (type != null) { %>
                        <span>›</span>
                        <a href="<%= contextPath %>/admin/exam-bank?type=<%= enc(type) %>"><%= typeLabel(type) %></a>
                    <% } %>

                    <% if (faculty != null) { %>
                        <span>›</span>
                        <a href="<%= contextPath %>/admin/exam-bank?type=<%= enc(type) %>&faculty=<%= enc(faculty) %>"><%= h(faculty) %></a>
                    <% } %>

                    <% if (subject != null) { %>
                        <span>›</span>
                        <a href="<%= contextPath %>/admin/exam-bank?type=<%= enc(type) %>&faculty=<%= enc(faculty) %>&subject=<%= enc(subject) %>"><%= h(subject) %></a>
                    <% } %>

                    <% if (year != null) { %>
                        <span>›</span>
                        <a href="<%= contextPath %>/admin/exam-bank?type=<%= enc(type) %>&faculty=<%= enc(faculty) %>&subject=<%= enc(subject) %>&year=<%= enc(year) %>"><%= h(year) %></a>
                    <% } %>
                </section>

                <% if (!"types".equals(view)) { %>
                    <form class="search-box" method="get" action="<%= contextPath %>/admin/exam-bank">
                        <input type="hidden" name="type" value="<%= h(type) %>">

                        <% if (faculty != null) { %>
                            <input type="hidden" name="faculty" value="<%= h(faculty) %>">
                        <% } %>

                        <% if (subject != null) { %>
                            <input type="hidden" name="subject" value="<%= h(subject) %>">
                        <% } %>

                        <% if (year != null) { %>
                            <input type="hidden" name="year" value="<%= h(year) %>">
                        <% } %>

                        <input type="text" name="keyword" value="<%= h(keyword) %>" placeholder="Tìm kiếm trong mục hiện tại...">
                        <button type="submit">Tìm</button>
                    </form>
                <% } %>

                <% if ("types".equals(view)) { %>

                    <section class="type-grid">
                        <article class="item-card">
                            <div class="item-icon">📘</div>
                            <h3>Đề cương</h3>
                            <p>Quản lý dữ liệu đề cương theo khoa, học phần và niên khóa.</p>
                            <a class="btn-open" href="<%= contextPath %>/admin/exam-bank?type=de-cuong">Mở Đề cương</a>
                        </article>

                        <article class="item-card">
                            <div class="item-icon">🧾</div>
                            <h3>Ngân hàng đề</h3>
                            <p>Quản lý đề thi, ảnh đề, file PDF/DOCX theo từng học phần.</p>
                            <a class="btn-open" href="<%= contextPath %>/admin/exam-bank?type=ngan-hang-de">Mở Ngân hàng đề</a>
                        </article>
                    </section>

                <% } else if (items == null || items.isEmpty()) { %>

                    <section class="empty-box">
                        <div class="empty-icon">🔎</div>
                        <h3>Chưa có dữ liệu</h3>
                        <p>Bạn có thể dùng form bên phải để thêm dữ liệu mới.</p>
                    </section>

                <% } else { %>

                    <section class="item-grid">

                        <% for (AdminExamItem item : items) {
                            String name = item.getName();

                            String nextUrl = contextPath + "/admin/exam-bank";

                            if ("faculties".equals(view)) {
                                nextUrl += "?type=" + enc(type) + "&faculty=" + enc(name);
                            } else if ("subjects".equals(view)) {
                                nextUrl += "?type=" + enc(type) + "&faculty=" + enc(faculty) + "&subject=" + enc(name);
                            } else if ("years".equals(view)) {
                                nextUrl += "?type=" + enc(type) + "&faculty=" + enc(faculty) + "&subject=" + enc(subject) + "&year=" + enc(name);
                            }

                            String previewUrl = contextPath + "/exam-bank?action=preview"
                                    + "&type=" + enc(type)
                                    + "&faculty=" + enc(faculty)
                                    + "&subject=" + enc(subject)
                                    + "&year=" + enc(year)
                                    + "&file=" + enc(name);

                            String downloadUrl = contextPath + "/exam-bank?action=download"
                                    + "&type=" + enc(type)
                                    + "&faculty=" + enc(faculty)
                                    + "&subject=" + enc(subject)
                                    + "&year=" + enc(year)
                                    + "&file=" + enc(name);
                        %>

                            <article class="item-card">
                                <div class="item-icon"><%= iconByView(view, item) %></div>

                                <h3><%= h(name) %></h3>

                                <% if ("files".equals(view)) { %>
                                    <p>
                                        Loại file: <%= h(item.getFileType().toUpperCase()) %><br>
                                        Dung lượng: <%= h(item.getFileSize()) %><br>
                                        Cập nhật: <%= h(item.getModifiedTime()) %>
                                    </p>

                                    <div class="item-actions">
                                        <a class="btn-open" href="<%= previewUrl %>" target="_blank">Xem</a>
                                        <a class="btn-soft" href="<%= downloadUrl %>">Tải</a>

                                        <form method="post"
                                              action="<%= contextPath %>/admin/exam-bank"
                                              onsubmit="return confirm('Bạn có chắc muốn xoá file này không?');">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="type" value="<%= h(type) %>">
                                            <input type="hidden" name="faculty" value="<%= h(faculty) %>">
                                            <input type="hidden" name="subject" value="<%= h(subject) %>">
                                            <input type="hidden" name="year" value="<%= h(year) %>">
                                            <input type="hidden" name="file" value="<%= h(name) %>">
                                            <button class="btn-delete" type="submit">Xoá</button>
                                        </form>
                                    </div>
                                <% } else { %>
                                    <p>
                                        <% if ("faculties".equals(view)) { %>
                                            Khoa ngành. Bấm để xem học phần.
                                        <% } else if ("subjects".equals(view)) { %>
                                            Học phần. Bấm để xem niên khóa.
                                        <% } else { %>
                                            Niên khóa. Bấm để xem danh sách file.
                                        <% } %>
                                    </p>

                                    <a class="btn-open" href="<%= nextUrl %>">Mở</a>
                                <% } %>
                            </article>

                        <% } %>

                    </section>

                <% } %>

            </main>

            <aside class="admin-card">
                <h2>Thêm file mới</h2>
                <p>Nhập tên khoa, học phần, niên khóa. Nếu chưa có thư mục, hệ thống tự tạo.</p>

                <form method="post"
                      action="<%= contextPath %>/admin/exam-bank"
                      enctype="multipart/form-data">

                    <div class="form-grid">
                        <div class="form-group">
                            <label>Loại tài liệu</label>
                            <select name="type" required>
                                <option value="de-cuong" <%= "de-cuong".equals(uploadType) ? "selected" : "" %>>Đề cương</option>
                                <option value="ngan-hang-de" <%= "ngan-hang-de".equals(uploadType) ? "selected" : "" %>>Ngân hàng đề</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label>Khoa ngành</label>
                            <input type="text" name="faculty" value="<%= h(uploadFaculty) %>" placeholder="Ví dụ: Khoa Công nghệ Thông tin" required>
                        </div>

                        <div class="form-group">
                            <label>Học phần</label>
                            <input type="text" name="subject" value="<%= h(uploadSubject) %>" placeholder="Ví dụ: Lập trình Java" required>
                        </div>

                        <div class="form-group">
                            <label>Niên khóa</label>
                            <input type="text" name="year" value="<%= h(uploadYear) %>" placeholder="Ví dụ: 2024 - 2025" required>
                        </div>

                        <div class="form-group">
                            <label>Chọn file</label>
                            <input type="file"
                                   name="file"
                                   accept=".pdf,.doc,.docx,.jpg,.jpeg,.png,.gif,.webp,.xls,.xlsx,.ppt,.pptx"
                                   required>
                        </div>

                        <button class="btn-submit" type="submit">Tải file lên</button>
                    </div>
                </form>
            </aside>

        </section>

    </div>
</main>

</body>
</html>
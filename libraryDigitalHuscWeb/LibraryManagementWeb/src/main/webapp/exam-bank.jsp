<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.lang.reflect.Method" %>
<%@ page import="java.lang.reflect.Field" %>

<%!
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

    private Object call(Object object, String methodName) {
        if (object == null) return null;

        try {
            Method method = object.getClass().getMethod(methodName);
            return method.invoke(object);
        } catch (Exception e) {
            return null;
        }
    }

    private Object field(Object object, String fieldName) {
        if (object == null) return null;

        try {
            Field f = object.getClass().getDeclaredField(fieldName);
            f.setAccessible(true);
            return f.get(object);
        } catch (Exception e) {
            return null;
        }
    }

    private String text(Object object) {
        if (object == null) return "";

        if (object instanceof String) {
            return String.valueOf(object);
        }

        String[] methods = {
                "getName",
                "getDisplayName",
                "getTitle",
                "getLabel",
                "getFileName",
                "getFolderName",
                "getSubjectName",
                "getFacultyName",
                "getYearName",
                "getValue",
                "getText"
        };

        for (String method : methods) {
            Object value = call(object, method);

            if (value != null && !String.valueOf(value).trim().isEmpty()) {
                return String.valueOf(value);
            }
        }

        String[] fields = {
                "name",
                "displayName",
                "title",
                "label",
                "fileName",
                "folderName",
                "subjectName",
                "facultyName",
                "yearName",
                "value",
                "text"
        };

        for (String f : fields) {
            Object value = field(object, f);

            if (value != null && !String.valueOf(value).trim().isEmpty()) {
                return String.valueOf(value);
            }
        }

        return "";
    }

    private String fileName(Object object) {
        if (object == null) return "";

        if (object instanceof String) {
            return String.valueOf(object);
        }

        String[] methods = {
                "getFileName",
                "getName",
                "getTitle",
                "getDisplayName"
        };

        for (String method : methods) {
            Object value = call(object, method);

            if (value != null && !String.valueOf(value).trim().isEmpty()) {
                return String.valueOf(value);
            }
        }

        String[] fields = {
                "fileName",
                "name",
                "title",
                "displayName"
        };

        for (String f : fields) {
            Object value = field(object, f);

            if (value != null && !String.valueOf(value).trim().isEmpty()) {
                return String.valueOf(value);
            }
        }

        return text(object);
    }

    private int sizeOf(List<?> list) {
        return list == null ? 0 : list.size();
    }
%>

<%
    String contextPath = request.getContextPath();

    String type = request.getParameter("type");
    String faculty = request.getParameter("faculty");
    String subject = request.getParameter("subject");
    String year = request.getParameter("year");

    if (type == null) type = "";
    if (faculty == null) faculty = "";
    if (subject == null) subject = "";
    if (year == null) year = "";

    List<?> items = (List<?>) request.getAttribute("items");
    List<?> faculties = (List<?>) request.getAttribute("faculties");
    List<?> subjects = (List<?>) request.getAttribute("subjects");
    List<?> years = (List<?>) request.getAttribute("years");
    List<?> files = (List<?>) request.getAttribute("files");

    int total = 0;

    if (files != null && !files.isEmpty()) {
        total = files.size();
    } else if (years != null && !years.isEmpty()) {
        total = years.size();
    } else if (subjects != null && !subjects.isEmpty()) {
        total = subjects.size();
    } else if (faculties != null && !faculties.isEmpty()) {
        total = faculties.size();
    } else if (items != null && !items.isEmpty()) {
        total = items.size();
    }

    String pageTitle = "Kho đề học tập";
    String heroBadge = "Exam Bank";

    if ("de-cuong".equalsIgnoreCase(type)) {
        pageTitle = "Kho đề cương";
        heroBadge = "Course Outline";
    }

    if ("ngan-hang-de".equalsIgnoreCase(type)) {
        pageTitle = "Ngân hàng đề";
        heroBadge = "Question Bank";
    }
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Kho đề - HUSC Digital Library</title>

    <link rel="stylesheet" href="<%= contextPath %>/assets/css/member/member-layout.css?v=10">

    <style>
        .exam-grid {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 24px;
        }

        .exam-card {
            min-height: 245px;
            padding: 28px;
            border-radius: 28px;
            background: rgba(255, 255, 255, 0.98);
            border: 1px solid #dbeafe;
            box-shadow: 0 22px 55px rgba(15, 23, 42, 0.08);
            transition: 0.22s ease;
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }

        .exam-card:hover {
            transform: translateY(-6px);
            box-shadow: 0 30px 70px rgba(15, 23, 42, 0.12);
        }

        .exam-icon {
            width: 62px;
            height: 62px;
            border-radius: 22px;
            background: linear-gradient(135deg, #ede9fe, #dbeafe);
            color: #4338ca;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 30px;
            margin-bottom: 20px;
            flex-shrink: 0;
        }

        .exam-card h3 {
            margin: 0;
            font-size: 21px;
            line-height: 1.35;
            font-weight: 800;
            letter-spacing: -0.03em;
            color: #0f172a;
            word-break: break-word;
        }

        .exam-card p {
            margin: 12px 0 22px;
            color: #475569;
            line-height: 1.65;
            font-size: 14px;
            font-weight: 500;
        }

        .exam-card a {
            margin-top: auto;
            min-height: 42px;
            padding: 0 16px;
            border-radius: 999px;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 13px;
            font-weight: 700;
            color: white;
            background: linear-gradient(135deg, #4338ca, #06b6d4);
            width: fit-content;
        }

        .exam-card a:hover {
            text-decoration: none;
            transform: translateY(-2px);
        }

        .breadcrumb-box {
            margin-top: 24px;
            padding: 16px 18px;
            border-radius: 24px;
            background: rgba(255,255,255,0.94);
            border: 1px solid #dbeafe;
            color: #475569;
            font-weight: 650;
            line-height: 1.7;
        }

        .breadcrumb-box a {
            color: #0284c7;
            text-decoration: none;
            font-weight: 800;
        }

        .breadcrumb-box a:hover {
            text-decoration: underline;
        }

        @media (max-width: 1050px) {
            .exam-grid {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }
        }

        @media (max-width: 720px) {
            .exam-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>

<body>

<jsp:include page="/includes/member-header.jsp" />

<div class="member-page-shell">

    <section class="member-hero purple">
        <div>
            <div class="member-hero-badge"><%= h(heroBadge) %></div>

            <h1><%= h(pageTitle) %></h1>

            <p>
                Tra cứu ngân hàng đề, đề cương học phần và tài liệu ôn tập theo khoa,
                môn học, năm học để hỗ trợ quá trình học tập và ôn thi.
            </p>
        </div>

        <div class="member-hero-stat">
            <strong><%= total %></strong>
            <span>Mục đang hiển thị</span>
        </div>
    </section>

    <div class="breadcrumb-box">
        <a href="<%= contextPath %>/exam-bank">Kho đề</a>

        <% if (!type.trim().isEmpty()) { %>
            / <%= "de-cuong".equals(type) ? "Đề cương" : "Ngân hàng đề" %>
        <% } %>

        <% if (!faculty.trim().isEmpty()) { %>
            / <%= h(faculty) %>
        <% } %>

        <% if (!subject.trim().isEmpty()) { %>
            / <%= h(subject) %>
        <% } %>

        <% if (!year.trim().isEmpty()) { %>
            / <%= h(year) %>
        <% } %>
    </div>

    <div class="member-section-head">
        <div>
            <p class="member-section-kicker">Exam Resources</p>
            <h2>Danh mục kho đề</h2>
        </div>

        <p>Chọn nhóm tài liệu, khoa, học phần hoặc file cần xem.</p>
    </div>

    <% if (type.trim().isEmpty()) { %>

        <section class="exam-grid">

            <article class="exam-card">
                <div class="exam-icon">📘</div>
                <h3>Đề cương học phần</h3>
                <p>Xem đề cương môn học, cấu trúc học phần và tài liệu định hướng ôn tập.</p>
                <a href="<%= contextPath %>/exam-bank?type=de-cuong">Xem đề cương</a>
            </article>

            <article class="exam-card">
                <div class="exam-icon">📝</div>
                <h3>Ngân hàng đề</h3>
                <p>Xem đề thi, đề luyện tập và tài liệu ôn tập được phân loại theo khoa, môn, năm.</p>
                <a href="<%= contextPath %>/exam-bank?type=ngan-hang-de">Xem ngân hàng đề</a>
            </article>

        </section>

    <% } else { %>

        <section class="exam-grid">

            <% if (files != null && !files.isEmpty()) { %>

                <% for (Object item : files) {
                    String name = fileName(item);
                    if (name.trim().isEmpty()) name = "Tài liệu chưa đặt tên";
                %>

                    <article class="exam-card">
                        <div class="exam-icon">📄</div>
                        <h3><%= h(name) %></h3>
                        <p>Nhấn mở để xem hoặc tải tài liệu.</p>

                        <a href="<%= contextPath %>/exam-bank?type=<%= enc(type) %>&faculty=<%= enc(faculty) %>&subject=<%= enc(subject) %>&year=<%= enc(year) %>&file=<%= enc(name) %>">
                            Mở file
                        </a>
                    </article>

                <% } %>

            <% } else if (years != null && !years.isEmpty()) { %>

                <% for (Object item : years) {
                    String name = text(item);
                    if (name.trim().isEmpty()) name = "Năm học";
                %>

                    <article class="exam-card">
                        <div class="exam-icon">📅</div>
                        <h3><%= h(name) %></h3>
                        <p>Xem danh sách file thuộc năm học này.</p>

                        <a href="<%= contextPath %>/exam-bank?type=<%= enc(type) %>&faculty=<%= enc(faculty) %>&subject=<%= enc(subject) %>&year=<%= enc(name) %>">
                            Xem file
                        </a>
                    </article>

                <% } %>

            <% } else if (subjects != null && !subjects.isEmpty()) { %>

                <% for (Object item : subjects) {
                    String name = text(item);
                    if (name.trim().isEmpty()) name = "Học phần";
                %>

                    <article class="exam-card">
                        <div class="exam-icon">📚</div>
                        <h3><%= h(name) %></h3>
                        <p>Xem các năm học và file thuộc học phần này.</p>

                        <a href="<%= contextPath %>/exam-bank?type=<%= enc(type) %>&faculty=<%= enc(faculty) %>&subject=<%= enc(name) %>">
                            Xem học phần
                        </a>
                    </article>

                <% } %>

            <% } else if (faculties != null && !faculties.isEmpty()) { %>

                <% for (Object item : faculties) {
                    String name = text(item);
                    if (name.trim().isEmpty()) name = "Khoa/Bộ môn";
                %>

                    <article class="exam-card">
                        <div class="exam-icon">🏫</div>
                        <h3><%= h(name) %></h3>
                        <p>Xem các học phần thuộc khoa/bộ môn này.</p>

                        <a href="<%= contextPath %>/exam-bank?type=<%= enc(type) %>&faculty=<%= enc(name) %>">
                            Xem khoa
                        </a>
                    </article>

                <% } %>

            <% } else if (items != null && !items.isEmpty()) { %>

                <% for (Object item : items) {
                    String name = text(item);
                    if (name.trim().isEmpty()) name = "Thư mục";
                %>

                    <article class="exam-card">
                        <div class="exam-icon">📁</div>
                        <h3><%= h(name) %></h3>
                        <p>Nhấn để xem nội dung bên trong.</p>

                        <a href="<%= contextPath %>/exam-bank?type=<%= enc(type) %>&faculty=<%= enc(name) %>">
                            Mở thư mục
                        </a>
                    </article>

                <% } %>

            <% } else { %>

                <div class="member-empty-box">
                    Chưa có dữ liệu trong mục này.
                </div>

            <% } %>

        </section>

    <% } %>

</div>

</body>
</html>
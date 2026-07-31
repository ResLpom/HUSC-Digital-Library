<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.lang.reflect.Method" %>

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
    String keyword = (String) request.getAttribute("keyword");

    if (keyword == null) {
        keyword = "";
    }
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Tài liệu - HUSC Digital Library</title>

    <link rel="stylesheet" href="<%= contextPath %>/assets/css/member/member-layout.css?v=3">

    <style>
        .search-form {
            display: grid;
            grid-template-columns: 1fr 150px;
            gap: 12px;
        }

        .search-form input {
            height: 50px;
            border-radius: 18px;
            border: 1px solid #cbd5e1;
            padding: 0 18px;
            font-weight: 800;
            color: #0f172a;
            background: #f8fafc;
            outline: none;
            font-family: inherit;
        }

        .search-form input:focus {
            border-color: #38bdf8;
            box-shadow: 0 0 0 4px rgba(14, 165, 233, 0.12);
            background: white;
        }

        .search-form button {
            border: none;
            border-radius: 18px;
            color: white;
            background: linear-gradient(135deg, #0284c7, #06b6d4);
            font-weight: 950;
            cursor: pointer;
            font-family: inherit;
        }

        .document-grid {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 24px;
        }

        .document-card {
            overflow: hidden;
            border-radius: 28px;
            background: rgba(255, 255, 255, 0.98);
            border: 1px solid #dbeafe;
            box-shadow: 0 22px 55px rgba(15, 23, 42, 0.08);
            transition: 0.22s ease;
            display: flex;
            flex-direction: column;
            min-height: 430px;
        }

        .document-card:hover {
            transform: translateY(-6px);
            box-shadow: 0 30px 70px rgba(15, 23, 42, 0.12);
        }

        .document-cover {
            width: 100%;
            height: 190px;
            overflow: hidden;
            background: linear-gradient(135deg, #dbeafe, #e0e7ff);
            display: flex;
            align-items: center;
            justify-content: center;
            position: relative;
        }

        .document-cover img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            display: block;
            font-size: 0;
        }

        .document-placeholder {
            width: 72px;
            height: 72px;
            border-radius: 22px;
            background: rgba(255, 255, 255, 0.72);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 34px;
        }

        .document-file-badge {
            position: absolute;
            left: 18px;
            top: 16px;
            min-height: 32px;
            padding: 0 13px;
            border-radius: 999px;
            background: rgba(255, 255, 255, 0.92);
            color: #0369a1;
            font-size: 12px;
            font-weight: 950;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            z-index: 2;
        }

        .document-body {
            padding: 24px;
            display: flex;
            flex-direction: column;
            flex: 1;
        }

        .document-body h3 {
            min-height: 64px;
            margin: 0;
            font-size: 20px;
            line-height: 1.35;
            font-weight: 950;
            letter-spacing: -0.4px;
        }

        .document-desc {
            min-height: 74px;
            margin: 12px 0 18px;
            color: #475569;
            line-height: 1.65;
            font-size: 14px;
            font-weight: 700;
        }

        .document-meta {
            display: flex;
            flex-wrap: wrap;
            gap: 9px;
            margin-bottom: 20px;
        }

        .meta-pill {
            min-height: 32px;
            padding: 0 12px;
            border-radius: 999px;
            background: #f8fafc;
            border: 1px solid #dbeafe;
            color: #1e3a8a;
            font-size: 12px;
            font-weight: 900;
            display: inline-flex;
            align-items: center;
        }

        .document-actions {
            margin-top: auto;
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }

        .btn-primary,
        .btn-light {
            min-height: 42px;
            padding: 0 16px;
            border-radius: 999px;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 13px;
            font-weight: 950;
            border: 1px solid transparent;
        }

        .btn-primary {
            color: white;
            background: linear-gradient(135deg, #0284c7, #06b6d4);
        }

        .btn-light {
            color: #0369a1;
            background: #e0f2fe;
            border-color: #bae6fd;
        }

        @media (max-width: 1050px) {
            .document-grid {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }
        }

        @media (max-width: 720px) {
            .search-form {
                grid-template-columns: 1fr;
            }

            .document-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>

<body>

<jsp:include page="/includes/member-header.jsp" />

<div class="member-page-shell">

    <section class="member-hero blue">
        <div>
            <div class="member-hero-badge">Digital Documents</div>

            <h1>Kho tài liệu học tập</h1>

            <p>
                Tra cứu giáo trình, bài giảng, tài liệu tham khảo và tải xuống các tài liệu số
                phục vụ học tập, nghiên cứu.
            </p>
        </div>

        <div class="member-hero-stat">
            <strong><%= documents == null ? 0 : documents.size() %></strong>
            <span>Tài liệu đang hiển thị</span>
        </div>
    </section>

    <section class="member-search-panel">
        <form class="search-form" method="get" action="<%= contextPath %>/documents">
            <input type="text"
                   name="keyword"
                   value="<%= h(keyword) %>"
                   placeholder="Tìm kiếm tài liệu theo tên, tác giả, danh mục...">

            <button type="submit">Tìm kiếm</button>
        </form>
    </section>

    <div class="member-section-head">
        <div>
            <p class="member-section-kicker">Document Collection</p>
            <h2>Danh sách tài liệu</h2>
        </div>

        <p>Chọn tài liệu để xem chi tiết, tải file hoặc lưu tài liệu yêu thích.</p>
    </div>

    <section class="document-grid">

        <% if (documents == null || documents.isEmpty()) { %>

            <div class="member-empty-box">
                Không có tài liệu nào phù hợp.
            </div>

        <% } else { %>

            <% for (Object document : documents) {
                int documentId = getInt(document, "getDocumentId");

                String title = getText(document, "getTitle");
                String description = getText(document, "getDescription");
                String categoryName = getText(document, "getCategoryName");
                String typeName = getText(document, "getTypeName");
                String authorName = getText(document, "getAuthorName");
                String publishYear = getText(document, "getPublishYear");
                String coverImage = getText(document, "getCoverImage");
                String filePath = getText(document, "getFilePath");

                if (title.trim().isEmpty()) title = "Tài liệu chưa đặt tên";
                if (description.trim().isEmpty()) description = "Chưa có mô tả cho tài liệu này.";
                if (categoryName.trim().isEmpty()) categoryName = "Tài liệu";
                if (typeName.trim().isEmpty()) typeName = "PDF";
                if (authorName.trim().isEmpty()) authorName = "Chưa rõ tác giả";
                if (publishYear.trim().isEmpty() || "0".equals(publishYear)) publishYear = "N/A";

                boolean hasCover = coverImage != null && !coverImage.trim().isEmpty();
                boolean hasFile = filePath != null && !filePath.trim().isEmpty();
            %>

                <article class="document-card">

                    <div class="document-cover">
                        <span class="document-file-badge"><%= h(typeName) %></span>

                        <% if (hasCover) { %>
                            <img src="<%= contextPath %>/upload-image/documents/<%= urlEncode(coverImage) %>"
                                 alt="<%= h(title) %>">
                        <% } else { %>
                            <div class="document-placeholder">📄</div>
                        <% } %>
                    </div>

                    <div class="document-body">
                        <h3><%= h(title) %></h3>

                        <p class="document-desc">
                            <%= h(shortText(description, 120)) %>
                        </p>

                        <div class="document-meta">
                            <span class="meta-pill">▣ <%= h(categoryName) %></span>
                            <span class="meta-pill">✍ <%= h(authorName) %></span>
                            <span class="meta-pill">▦ <%= h(publishYear) %></span>
                        </div>

                        <div class="document-actions">
                            <a class="btn-primary"
                               href="<%= contextPath %>/documents?action=detail&id=<%= documentId %>">
                                Xem chi tiết
                            </a>

                            <% if (hasFile) { %>
                                <a class="btn-light"
   href="<%= contextPath %>/documents?action=detail&id=<%= documentId %>">
    Đọc / Tải
</a>
                            <% } %>
                        </div>
                    </div>
                </article>

            <% } %>

        <% } %>

    </section>

</div>

</body>
</html>
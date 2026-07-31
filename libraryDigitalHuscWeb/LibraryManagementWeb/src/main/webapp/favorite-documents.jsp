<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.lang.reflect.Method" %>
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

    User currentUser = null;

    if (session != null) {
        currentUser = (User) session.getAttribute("currentUser");

        if (currentUser == null) {
            currentUser = (User) session.getAttribute("user");
        }
    }

    List<?> documents = (List<?>) request.getAttribute("favoriteDocuments");

    if (documents == null) {
        documents = (List<?>) request.getAttribute("documents");
    }

    if (documents == null) {
        documents = (List<?>) request.getAttribute("favorites");
    }

    String fullName = currentUser != null && currentUser.getFullName() != null
            ? currentUser.getFullName()
            : "Người dùng";

    String email = currentUser != null && currentUser.getEmail() != null
            ? currentUser.getEmail()
            : "";
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Tài liệu yêu thích - HUSC Digital Library</title>

    <link rel="stylesheet" href="<%= contextPath %>/assets/css/member/member-layout.css?v=5">

    <style>
        .favorite-user-card {
            padding: 30px;
            border-radius: 26px;
            background: rgba(255, 255, 255, 0.14);
            border: 1px solid rgba(255, 255, 255, 0.24);
            min-height: 132px;
        }

        .favorite-user-row {
            display: flex;
            align-items: center;
            gap: 14px;
            margin-bottom: 18px;
        }

        .favorite-avatar {
            width: 58px;
            height: 58px;
            border-radius: 20px;
            background: white;
            color: #be123c;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 25px;
            font-weight: 950;
        }

        .favorite-user-info strong {
            display: block;
            font-size: 17px;
            font-weight: 950;
        }

        .favorite-user-info span {
            display: block;
            margin-top: 4px;
            color: #fce7f3;
            font-size: 13px;
            font-weight: 800;
        }

        .favorite-count strong {
            display: block;
            font-size: 38px;
            line-height: 1;
            font-weight: 950;
        }

        .favorite-count span {
            display: block;
            margin-top: 8px;
            color: #fce7f3;
            font-weight: 900;
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
            border: 1px solid #fbcfe8;
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
            background: linear-gradient(135deg, #fce7f3, #dbeafe);
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

        .favorite-badge {
            position: absolute;
            left: 18px;
            top: 16px;
            min-height: 32px;
            padding: 0 13px;
            border-radius: 999px;
            background: rgba(255, 255, 255, 0.94);
            color: #be123c;
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
            background: #fdf2f8;
            border: 1px solid #fbcfe8;
            color: #9d174d;
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
        .btn-light,
        .btn-danger {
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
            background: linear-gradient(135deg, #db2777, #0284c7);
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

        .empty-icon {
            font-size: 48px;
            margin-bottom: 12px;
        }

        .member-empty-box h3 {
            margin: 0 0 8px;
            font-size: 26px;
            color: #0f172a;
        }

        .member-empty-box p {
            margin: 0 0 18px;
        }

        @media (max-width: 1050px) {
            .document-grid {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }
        }

        @media (max-width: 720px) {
            .document-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>

<body>

<jsp:include page="/includes/member-header.jsp" />

<div class="member-page-shell">

    <section class="member-hero pink">
        <div>
            <div class="member-hero-badge">My Favorite Documents</div>

            <h1>Bộ sưu tập<br>tài liệu yêu thích</h1>

            <p>
                Lưu lại các tài liệu quan trọng để truy cập nhanh, tải xuống hoặc xem lại
                trong quá trình học tập và nghiên cứu.
            </p>
        </div>

        <div class="favorite-user-card">
            <div class="favorite-user-row">
                <div class="favorite-avatar">
                    <%= h(fullName.substring(0, 1).toUpperCase()) %>
                </div>

                <div class="favorite-user-info">
                    <strong><%= h(fullName) %></strong>
                    <span><%= h(email) %></span>
                </div>
            </div>

            <div class="favorite-count">
                <strong><%= documents == null ? 0 : documents.size() %></strong>
                <span>Tài liệu yêu thích</span>
            </div>
        </div>
    </section>

    <div class="member-section-head">
        <div>
            <p class="member-section-kicker">Favorite Collection</p>
            <h2>Danh sách yêu thích</h2>
        </div>

        <p>Các tài liệu bạn đã đánh dấu yêu thích.</p>
    </div>

    <section class="document-grid">

        <% if (documents == null || documents.isEmpty()) { %>

            <div class="member-empty-box">
                <div class="empty-icon">💗</div>
                <h3>Chưa có tài liệu yêu thích</h3>
                <p>Hãy vào trang tài liệu và bấm yêu thích để lưu tài liệu vào bộ sưu tập của bạn.</p>

                <a class="btn-primary" href="<%= contextPath %>/documents">
                    Khám phá tài liệu
                </a>
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
                        <span class="favorite-badge">💗 <%= h(typeName) %></span>

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
                                   href="<%= contextPath %>/documents?action=download&id=<%= documentId %>">
                                    Tải xuống
                                </a>
                            <% } %>

                            <a class="btn-danger"
                               href="<%= contextPath %>/documents?action=favorite&id=<%= documentId %>"
                               onclick="return confirm('Bỏ tài liệu này khỏi danh sách yêu thích?');">
                                Bỏ yêu thích
                            </a>
                        </div>
                    </div>
                </article>

            <% } %>

        <% } %>

    </section>

</div>

</body>
</html>
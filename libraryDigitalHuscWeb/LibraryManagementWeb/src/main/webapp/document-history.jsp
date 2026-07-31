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

    private String actionText(String actionType) {
        if ("VIEW".equalsIgnoreCase(actionType)) return "Đã xem";
        if ("DOWNLOAD".equalsIgnoreCase(actionType)) return "Đã tải xuống";
        return "Hoạt động";
    }

    private String actionIcon(String actionType) {
        if ("VIEW".equalsIgnoreCase(actionType)) return "👁";
        if ("DOWNLOAD".equalsIgnoreCase(actionType)) return "⬇";
        return "📌";
    }

    private String actionClass(String actionType) {
        if ("VIEW".equalsIgnoreCase(actionType)) return "view";
        if ("DOWNLOAD".equalsIgnoreCase(actionType)) return "download";
        return "normal";
    }
%>

<%
    String contextPath = request.getContextPath();

    List<?> histories = (List<?>) request.getAttribute("histories");

    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        currentUser = (User) session.getAttribute("user");
    }

    if (currentUser == null) {
        response.sendRedirect(contextPath + "/login.jsp");
        return;
    }

    String fullName = getText(currentUser, "Người dùng", "getFullName", "getName");
    String email = getText(currentUser, "", "getEmail");
    String roleName = getText(currentUser, "User", "getRoleName", "getRoleCode");

    int totalCount = histories != null ? histories.size() : 0;
    int viewCount = 0;
    int downloadCount = 0;

    if (histories != null) {
        for (Object h : histories) {
            String type = getText(h, "", "getActionType");

            if ("VIEW".equalsIgnoreCase(type)) viewCount++;
            if ("DOWNLOAD".equalsIgnoreCase(type)) downloadCount++;
        }
    }
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Lịch sử tài liệu - HUSC Digital Library</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/common/base.css?v=1">
	<link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/common/components.css?v=1">
	<link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/member/member-layout.css?v=1">
	<link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/member/app-header.css?v=1">
    <style>
        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background:
                radial-gradient(circle at top left, rgba(14, 165, 233, 0.13), transparent 30%),
                radial-gradient(circle at bottom right, rgba(99, 102, 241, 0.13), transparent 32%),
                #f6f9fc;
            color: #0f172a;
            overflow-x: hidden;
        }

        .page-shell {
            max-width: 1240px;
            margin: 0 auto;
            padding: 24px 20px 70px;
        }

        .top-nav {
            min-height: 76px;
            border-radius: 28px;
            padding: 14px 20px;
            background: rgba(255,255,255,0.88);
            border: 1px solid rgba(226,232,240,0.9);
            box-shadow: 0 16px 40px rgba(15,23,42,0.06);
            backdrop-filter: blur(18px);
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 18px;
            animation: fadeUp 0.7s ease both;
        }

        .brand {
            display: flex;
            align-items: center;
            gap: 14px;
            text-decoration: none;
        }

        .brand-icon {
            width: 52px;
            height: 52px;
            border-radius: 18px;
            background: linear-gradient(135deg, #0284c7, #6366f1);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 25px;
            box-shadow: 0 16px 32px rgba(99,102,241,0.24);
        }

        .brand strong {
            display: block;
            color: #0f172a;
            font-size: 18px;
        }

        .brand span {
            color: #64748b;
            font-size: 12px;
            font-weight: 700;
        }

        .nav-links {
            display: flex;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
        }

        .nav-links a {
            height: 42px;
            padding: 0 15px;
            border-radius: 999px;
            color: #334155;
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 13px;
            font-weight: 900;
            white-space: nowrap;
            transition: 0.22s ease;
        }

        .nav-links a:hover,
        .nav-links a.active {
            color: #4f46e5;
            background: #eef2ff;
            border-color: #c7d2fe;
            transform: translateY(-3px);
            text-decoration: none;
        }

        .hero {
            margin-top: 26px;
            border-radius: 40px;
            padding: 48px;
            color: white;
            background:
                radial-gradient(circle at 20% 20%, rgba(14,165,233,0.38), transparent 34%),
                radial-gradient(circle at 88% 80%, rgba(99,102,241,0.38), transparent 34%),
                linear-gradient(135deg, #0f172a, #312e81);
            box-shadow: 0 34px 82px rgba(15,23,42,0.18);
            position: relative;
            overflow: hidden;
            display: grid;
            grid-template-columns: minmax(0, 1fr) 380px;
            gap: 28px;
            align-items: center;
            animation: fadeUp 0.75s ease 0.08s both;
        }

        .hero::before {
            content: "";
            position: absolute;
            inset: 0;
            background: linear-gradient(120deg, transparent, rgba(255,255,255,0.08), transparent);
            transform: translateX(-120%);
            animation: shineMove 7s ease-in-out infinite;
        }

        .hero-content,
        .hero-card {
            position: relative;
            z-index: 2;
        }

        .label {
            display: inline-flex;
            padding: 9px 16px;
            border-radius: 999px;
            background: rgba(255,255,255,0.13);
            border: 1px solid rgba(255,255,255,0.18);
            color: #c7d2fe;
            font-size: 12px;
            font-weight: 900;
            letter-spacing: 1.4px;
        }

        .hero h1 {
            font-size: 52px;
            line-height: 1.06;
            letter-spacing: -1.8px;
            margin: 18px 0 14px;
        }

        .hero h1 span {
            background: linear-gradient(135deg, #7dd3fc, #ffffff, #c4b5fd);
            -webkit-background-clip: text;
            background-clip: text;
            color: transparent;
        }

        .hero p {
            color: #dbeafe;
            line-height: 1.75;
            max-width: 760px;
        }

        .hero-card {
            padding: 24px;
            border-radius: 30px;
            background: rgba(255,255,255,0.13);
            border: 1px solid rgba(255,255,255,0.17);
            backdrop-filter: blur(18px);
            animation: floatCard 5s ease-in-out infinite;
        }

        .profile-box {
            display: flex;
            gap: 14px;
            align-items: center;
            margin-bottom: 18px;
        }

        .profile-avatar {
            width: 62px;
            height: 62px;
            border-radius: 22px;
            background: white;
            color: #4f46e5;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 28px;
            font-weight: 900;
        }

        .profile-box strong {
            display: block;
            color: white;
            font-size: 17px;
            margin-bottom: 5px;
        }

        .profile-box span {
            display: block;
            color: #dbeafe;
            font-size: 12px;
            line-height: 1.45;
        }

        .stat-grid {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 12px;
        }

        .stat-grid div {
            padding: 15px;
            border-radius: 20px;
            background: rgba(255,255,255,0.12);
        }

        .stat-grid strong {
            display: block;
            color: white;
            font-size: 28px;
            margin-bottom: 5px;
        }

        .stat-grid span {
            color: #dbeafe;
            font-size: 12px;
            font-weight: 800;
        }

        .section-head {
            margin: 34px 0 18px;
            display: flex;
            justify-content: space-between;
            align-items: end;
            gap: 18px;
            animation: fadeUp 0.75s ease 0.16s both;
        }

        .section-head span {
            color: #4f46e5;
            font-size: 12px;
            font-weight: 900;
            letter-spacing: 1.4px;
        }

        .section-head h2 {
            margin: 8px 0 0;
            font-size: 34px;
            color: #0f172a;
            letter-spacing: -1px;
        }

        .section-head p {
            color: #64748b;
            margin: 0;
            line-height: 1.6;
        }

        .history-list {
            display: grid;
            gap: 18px;
            animation: fadeUp 0.75s ease 0.24s both;
        }

        .history-card {
            background: white;
            border: 1px solid #e2e8f0;
            border-radius: 30px;
            padding: 18px;
            box-shadow: 0 18px 48px rgba(15,23,42,0.06);
            display: grid;
            grid-template-columns: 110px minmax(0, 1fr) 190px;
            gap: 18px;
            align-items: center;
            transition: 0.25s ease;
        }

        .history-card:hover {
            transform: translateY(-5px);
            border-color: #c7d2fe;
            box-shadow: 0 28px 70px rgba(15,23,42,0.12);
        }

        .doc-cover {
            width: 110px;
            height: 110px;
            border-radius: 24px;
            background:
                linear-gradient(135deg, rgba(14,165,233,0.15), rgba(99,102,241,0.15)),
                #f8fafc;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
            font-size: 42px;
        }

        .doc-cover img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .history-main h3 {
            margin: 0 0 9px;
            color: #0f172a;
            font-size: 22px;
            line-height: 1.3;
        }

        .history-main p {
            margin: 0;
            color: #64748b;
            font-size: 14px;
            line-height: 1.6;
        }

        .history-meta {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            margin-top: 12px;
        }

        .history-meta span {
            padding: 7px 10px;
            border-radius: 999px;
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            color: #475569;
            font-size: 12px;
            font-weight: 800;
        }

        .action-box {
            display: grid;
            gap: 10px;
            justify-items: end;
        }

        .action-badge {
            width: fit-content;
            padding: 9px 12px;
            border-radius: 999px;
            font-size: 12px;
            font-weight: 900;
            border: 1px solid transparent;
        }

        .action-badge.view {
            background: #e0f2fe;
            color: #0369a1;
            border-color: #bae6fd;
        }

        .action-badge.download {
            background: #dcfce7;
            color: #166534;
            border-color: #bbf7d0;
        }

        .action-badge.normal {
            background: #f1f5f9;
            color: #475569;
            border-color: #e2e8f0;
        }

        .btn-main {
            height: 40px;
            padding: 0 14px;
            border-radius: 999px;
            color: white;
            background: linear-gradient(135deg, #0284c7, #6366f1);
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 13px;
            font-weight: 900;
            box-shadow: 0 14px 30px rgba(99,102,241,0.22);
            transition: 0.22s ease;
        }

        .btn-main:hover {
            transform: translateY(-3px);
            box-shadow: 0 18px 38px rgba(99,102,241,0.32);
            text-decoration: none;
        }

        .empty-box {
            margin-top: 22px;
            padding: 60px 24px;
            background: white;
            border: 1px dashed #cbd5e1;
            border-radius: 34px;
            text-align: center;
            animation: fadeUp 0.75s ease 0.24s both;
        }

        .empty-icon {
            width: 92px;
            height: 92px;
            border-radius: 30px;
            background: #eef2ff;
            color: #4f46e5;
            font-size: 46px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 18px;
        }

        .empty-box h3 {
            margin: 0 0 10px;
            font-size: 25px;
            color: #0f172a;
        }

        .empty-box p {
            margin: 0 auto 24px;
            max-width: 560px;
            color: #64748b;
            line-height: 1.65;
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

        @media (max-width: 920px) {
            .hero {
                grid-template-columns: 1fr;
            }

            .history-card {
                grid-template-columns: 90px minmax(0, 1fr);
            }

            .doc-cover {
                width: 90px;
                height: 90px;
            }

            .action-box {
                grid-column: 1 / -1;
                justify-items: start;
            }
        }

        @media (max-width: 720px) {
            .top-nav,
            .section-head {
                flex-direction: column;
                align-items: flex-start;
            }

            .hero {
                padding: 32px 22px;
            }

            .hero h1 {
                font-size: 36px;
            }

            .stat-grid {
                grid-template-columns: 1fr;
            }

            .history-card {
                grid-template-columns: 1fr;
            }
        }
        /* ================= GLOBAL PAGE SIZE SYNC ================= */

/* Khung trang chung */
.page-shell,
.home-pro-page {
    max-width: 1240px !important;
    margin: 0 auto !important;
    padding-left: 20px !important;
    padding-right: 20px !important;
}

/* Header chung */
.top-nav {
    width: 100% !important;
    max-width: 1240px !important;
    margin: 24px auto 0 !important;
}

/* Hero chung */
.hero,
.home-pro-hero,
.detail-hero {
    max-width: 1240px !important;
    margin-left: auto !important;
    margin-right: auto !important;
    margin-top: 26px !important;
    border-radius: 40px !important;
}

/* Heading lớn ở hero */
.hero h1,
.home-pro-hero h1,
.detail-hero h1,
.hero-content h1 {
    font-size: 52px !important;
    line-height: 1.06 !important;
    letter-spacing: -1.8px !important;
    margin-top: 18px !important;
    margin-bottom: 14px !important;
}

/* Chữ mô tả dưới hero */
.hero p,
.home-pro-hero p,
.detail-hero p,
.hero-desc {
    font-size: 16px !important;
    line-height: 1.75 !important;
}

/* Tiêu đề section */
.section-head h2,
.home-pro-section-title h2,
.home-pro-feature-band h2,
.main-card h2,
.form-card h2,
.process-section h2 {
    font-size: 34px !important;
    line-height: 1.18 !important;
    letter-spacing: -1px !important;
}

/* Tiêu đề card */
.doc-body h3,
.equipment-body h3,
.request-card h3,
.history-main h3,
.home-pro-action-card h3 {
    font-size: 20px !important;
    line-height: 1.32 !important;
}

/* Text thường */
.doc-desc,
.equipment-desc,
.text-block,
.home-pro-action-card p,
.request-card p,
.history-main p {
    font-size: 14px !important;
    line-height: 1.65 !important;
}

/* Responsive */
@media (max-width: 720px) {
    .hero h1,
    .home-pro-hero h1,
    .detail-hero h1,
    .hero-content h1 {
        font-size: 36px !important;
        line-height: 1.12 !important;
    }

    .section-head h2,
    .home-pro-section-title h2,
    .home-pro-feature-band h2,
    .main-card h2,
    .form-card h2,
    .process-section h2 {
        font-size: 28px !important;
    }
}
/* ================= PAGE SIZE SYNC FINAL ================= */

.page-shell,
.home-pro-page {
    max-width: 1240px !important;
    margin-left: auto !important;
    margin-right: auto !important;
    padding-left: 20px !important;
    padding-right: 20px !important;
}

.top-nav {
    max-width: 1240px !important;
    width: 100% !important;
    margin: 24px auto 0 !important;
}

.hero,
.home-pro-hero,
.detail-hero {
    max-width: 1240px !important;
    margin: 26px auto 0 !important;
    border-radius: 40px !important;
}

.hero h1,
.home-pro-hero h1,
.detail-hero h1,
.hero-content h1 {
    font-size: 52px !important;
    line-height: 1.06 !important;
    letter-spacing: -1.8px !important;
    margin: 18px 0 14px !important;
}

.hero p,
.home-pro-hero p,
.detail-hero p,
.hero-desc {
    font-size: 16px !important;
    line-height: 1.75 !important;
}

.section-head h2,
.home-pro-section-title h2,
.home-pro-feature-band h2 {
    font-size: 34px !important;
    line-height: 1.18 !important;
    letter-spacing: -1px !important;
}

@media (max-width: 720px) {
    .hero h1,
    .home-pro-hero h1,
    .detail-hero h1,
    .hero-content h1 {
        font-size: 36px !important;
    }

    .section-head h2,
    .home-pro-section-title h2,
    .home-pro-feature-band h2 {
        font-size: 28px !important;
    }
}
    </style>
</head>

<body>

<div class="page-shell">

    <header class="top-nav">
        <a class="brand" href="<%= contextPath %>/index.jsp">
            <div class="brand-icon">🕘</div>

            <div>
                <strong>HUSC Digital Library</strong>
                <span>Lịch sử tài liệu cá nhân</span>
            </div>
        </a>

        <nav class="nav-links">
            <a href="<%= contextPath %>/index.jsp">Trang chủ</a>
            <a href="<%= contextPath %>/documents">Tài liệu</a>
            <a href="<%= contextPath %>/favorite-documents">Yêu thích</a>
            <a class="active" href="<%= contextPath %>/document-history">Lịch sử</a>
            <a href="<%= contextPath %>/equipments">Thiết bị</a>
            <a href="<%= contextPath %>/my-borrow-requests">Yêu cầu của tôi</a>
            <a href="<%= contextPath %>/logout">Đăng xuất</a>
        </nav>
    </header>

    <section class="hero">
        <div class="hero-content">
            <span class="label">DOCUMENT HISTORY</span>

            <h1>
                Lịch sử<br>
                <span>xem và tải tài liệu</span>
            </h1>

            <p>
                Theo dõi các tài liệu bạn đã xem hoặc tải xuống gần đây để dễ dàng mở lại khi cần học tập,
                ôn thi hoặc nghiên cứu.
            </p>
        </div>

        <div class="hero-card">
            <div class="profile-box">
                <div class="profile-avatar">
                    <%= fullName != null && !fullName.trim().isEmpty()
                            ? fullName.trim().substring(0, 1).toUpperCase()
                            : "U" %>
                </div>

                <div>
                    <strong><%= fullName %></strong>
                    <span><%= email %></span>
                    <span><%= roleName %></span>
                </div>
            </div>

            <div class="stat-grid">
                <div>
                    <strong><%= totalCount %></strong>
                    <span>Tổng hoạt động</span>
                </div>

                <div>
                    <strong><%= viewCount %></strong>
                    <span>Lượt xem</span>
                </div>

                <div>
                    <strong><%= downloadCount %></strong>
                    <span>Lượt tải</span>
                </div>
            </div>
        </div>
    </section>

    <section class="section-head">
        <div>
            <span>RECENT ACTIVITIES</span>
            <h2>Hoạt động gần đây</h2>
        </div>

        <p>
            Hiển thị tối đa 100 hoạt động xem và tải tài liệu gần nhất.
        </p>
    </section>

    <% if (histories == null || histories.isEmpty()) { %>

        <section class="empty-box">
            <div class="empty-icon">🕘</div>

            <h3>Chưa có lịch sử tài liệu</h3>

            <p>
                Khi bạn mở chi tiết tài liệu hoặc tải xuống tài liệu, lịch sử sẽ được lưu tại đây.
            </p>

            <a class="btn-main" href="<%= contextPath %>/documents">
                Khám phá tài liệu
            </a>
        </section>

    <% } else { %>

        <section class="history-list">

            <% for (Object item : histories) {
                int documentId = getInt(item, 0, "getDocumentId");
                String title = getText(item, "Tài liệu chưa có tiêu đề", "getTitle");
                String desc = getText(item, "Chưa có mô tả cho tài liệu này.", "getDescription");
                String cover = getText(item, "", "getCoverImage");
                String fileType = getText(item, "Tài liệu", "getFileType");
                String actionType = getText(item, "", "getActionType");
                String actionTime = getText(item, "Chưa cập nhật", "getActionTime");
            %>

                <article class="history-card">
                    <div class="doc-cover">
                        <% if (cover != null && !cover.trim().isEmpty()) { %>
                            <img src="<%= contextPath %><%= cover.startsWith("/") ? cover : "/" + cover %>" alt="<%= title %>">
                        <% } else { %>
                            📄
                        <% } %>
                    </div>

                    <div class="history-main">
                        <h3><%= title %></h3>

                        <p><%= desc %></p>

                        <div class="history-meta">
                            <span>🏷 <%= fileType %></span>
                            <span>🕘 <%= actionTime %></span>
                        </div>
                    </div>

                    <div class="action-box">
                        <span class="action-badge <%= actionClass(actionType) %>">
                            <%= actionIcon(actionType) %> <%= actionText(actionType) %>
                        </span>

                        <a class="btn-main" href="<%= contextPath %>/documents?action=detail&id=<%= documentId %>">
                            Mở tài liệu
                        </a>
                    </div>
                </article>

            <% } %>

        </section>

    <% } %>

</div>

</body>
</html>
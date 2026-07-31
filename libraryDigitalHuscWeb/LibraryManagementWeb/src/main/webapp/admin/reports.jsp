<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.lang.reflect.Method" %>
<%@ page import="vn.edu.husc.library.model.User" %>

<%!
    private int getIntValue(Object obj, String... methodNames) {
        if (obj == null) return 0;

        for (String methodName : methodNames) {
            try {
                Method method = obj.getClass().getMethod(methodName);
                Object value = method.invoke(obj);

                if (value == null) continue;

                if (value instanceof Number) {
                    return ((Number) value).intValue();
                }

                return Integer.parseInt(value.toString());
            } catch (Exception e) {
                // Bỏ qua nếu method không tồn tại
            }
        }

        return 0;
    }
%>

<%
    String contextPath = request.getContextPath();

    Object summary = request.getAttribute("summary");
    if (summary == null) summary = request.getAttribute("reportSummary");
    if (summary == null) summary = request.getAttribute("report");

    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        currentUser = (User) session.getAttribute("user");
    }

    String fullName = "Quản trị viên";
    String email = "admin@husc.edu.vn";
    String roleName = "Administrator";

    if (currentUser != null) {
        if (currentUser.getFullName() != null) fullName = currentUser.getFullName();
        if (currentUser.getEmail() != null) email = currentUser.getEmail();
        if (currentUser.getRoleName() != null) roleName = currentUser.getRoleName();
    }

    int totalUsers = getIntValue(summary, "getTotalUsers", "getUserCount", "getUsers");
    int totalDocuments = getIntValue(summary, "getTotalDocuments", "getDocumentCount", "getDocuments");
    int totalEquipments = getIntValue(summary, "getTotalEquipments", "getEquipmentCount", "getEquipments");
    int totalBorrowRequests = getIntValue(summary, "getTotalBorrowRequests", "getBorrowRequestCount", "getRequests");

    int pendingRequests = getIntValue(summary, "getPendingRequests", "getPendingBorrowRequests", "getPendingCount");
    int approvedRequests = getIntValue(summary, "getApprovedRequests", "getApprovedBorrowRequests", "getApprovedCount");
    int borrowingRequests = getIntValue(summary, "getBorrowingRequests", "getBorrowingCount", "getBorrowedCount");
    int returnedRequests = getIntValue(summary, "getReturnedRequests", "getReturnedCount");

    int availableEquipments = getIntValue(summary, "getAvailableEquipments", "getAvailableEquipmentCount");
    int borrowedEquipments = getIntValue(summary, "getBorrowedEquipments", "getBorrowedEquipmentCount");
    int maintenanceEquipments = getIntValue(summary, "getMaintenanceEquipments", "getMaintenanceEquipmentCount");

    int maxMain = Math.max(Math.max(totalUsers, totalDocuments), Math.max(totalEquipments, totalBorrowRequests));
    if (maxMain <= 0) maxMain = 1;

    int maxRequest = Math.max(Math.max(pendingRequests, approvedRequests), Math.max(borrowingRequests, returnedRequests));
    if (maxRequest <= 0) maxRequest = 1;

    int maxEquipment = Math.max(Math.max(availableEquipments, borrowedEquipments), maintenanceEquipments);
    if (maxEquipment <= 0) maxEquipment = 1;
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Báo cáo thống kê - HUSC Digital Library</title>
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
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(255, 255, 255, 0.14);
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
            background: rgba(255, 255, 255, 0.13);
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
            background: rgba(255, 255, 255, 0.86);
            border: 1px solid rgba(226, 232, 240, 0.9);
            box-shadow: 0 16px 40px rgba(15, 23, 42, 0.06);
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
            box-shadow: 0 14px 30px rgba(6, 182, 212, 0.24);
        }

        .admin-btn.secondary {
            color: #0369a1;
            background: #e0f2fe;
            border: 1px solid #bae6fd;
        }

        .admin-btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 18px 38px rgba(15, 23, 42, 0.13);
        }

        .report-hero {
            margin-top: 26px;
            border-radius: 38px;
            padding: 42px;
            color: white;
            background:
                radial-gradient(circle at 18% 20%, rgba(56, 189, 248, 0.35), transparent 32%),
                radial-gradient(circle at 90% 80%, rgba(99, 102, 241, 0.35), transparent 34%),
                linear-gradient(135deg, #0f172a, #1e3a8a);
            box-shadow: 0 34px 82px rgba(15, 23, 42, 0.18);
            position: relative;
            overflow: hidden;
            display: grid;
            grid-template-columns: minmax(0, 1fr) 380px;
            gap: 28px;
            align-items: center;
            animation: fadeUp 0.75s ease 0.08s both;
        }

        .report-hero::before {
            content: "";
            position: absolute;
            inset: 0;
            background: linear-gradient(120deg, transparent, rgba(255,255,255,0.08), transparent);
            transform: translateX(-120%);
            animation: shineMove 7s ease-in-out infinite;
        }

        .report-hero-content,
        .report-hero-panel {
            position: relative;
            z-index: 2;
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
        }

        .report-hero h2 {
            font-size: 46px;
            line-height: 1.1;
            letter-spacing: -1.6px;
            margin: 18px 0 12px;
        }

        .report-hero h2 span {
            background: linear-gradient(135deg, #7dd3fc, #ffffff, #c4b5fd);
            -webkit-background-clip: text;
            background-clip: text;
            color: transparent;
        }

        .report-hero p {
            color: #dbeafe;
            line-height: 1.75;
            max-width: 760px;
        }

        .report-hero-panel {
            padding: 24px;
            border-radius: 28px;
            background: rgba(255, 255, 255, 0.13);
            border: 1px solid rgba(255, 255, 255, 0.17);
            backdrop-filter: blur(18px);
            animation: floatCard 5s ease-in-out infinite;
        }

        .report-hero-panel h3 {
            margin: 0 0 16px;
            color: white;
        }

        .report-mini-stat {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 12px;
        }

        .report-mini-stat div {
            padding: 15px;
            border-radius: 20px;
            background: rgba(255, 255, 255, 0.12);
        }

        .report-mini-stat strong {
            display: block;
            color: white;
            font-size: 28px;
            margin-bottom: 6px;
        }

        .report-mini-stat span {
            color: #bfdbfe;
            font-size: 12px;
            font-weight: 800;
        }

        .report-stat-grid {
            margin-top: 26px;
            display: grid;
            grid-template-columns: repeat(4, minmax(0, 1fr));
            gap: 18px;
            animation: fadeUp 0.75s ease 0.14s both;
        }

        .report-stat-card {
            padding: 24px;
            border-radius: 28px;
            background: white;
            border: 1px solid #e2e8f0;
            box-shadow: 0 16px 40px rgba(15, 23, 42, 0.06);
            transition: 0.25s ease;
        }

        .report-stat-card:hover {
            transform: translateY(-7px);
            box-shadow: 0 28px 70px rgba(15, 23, 42, 0.13);
            border-color: #bae6fd;
        }

        .report-icon {
            width: 58px;
            height: 58px;
            border-radius: 20px;
            background: #dbeafe;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 28px;
            margin-bottom: 18px;
        }

        .report-stat-card strong {
            display: block;
            font-size: 32px;
            color: #0f172a;
            margin-bottom: 6px;
        }

        .report-stat-card span {
            color: #64748b;
            font-size: 13px;
            font-weight: 800;
        }

        .report-section {
            margin-top: 34px;
        }

        .section-heading {
            display: flex;
            align-items: end;
            justify-content: space-between;
            gap: 18px;
            margin-bottom: 18px;
        }

        .section-heading span {
            color: #0284c7;
            font-size: 12px;
            font-weight: 900;
            letter-spacing: 1.4px;
        }

        .section-heading h2 {
            font-size: 32px;
            margin: 8px 0 0;
            color: #0f172a;
            letter-spacing: -0.9px;
        }

        .section-heading p {
            color: #64748b;
            margin: 0;
            line-height: 1.6;
        }

        .report-panel-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 24px;
        }

        .chart-card {
            background: white;
            border: 1px solid #e2e8f0;
            border-radius: 32px;
            padding: 28px;
            box-shadow: 0 18px 48px rgba(15, 23, 42, 0.06);
            animation: fadeUp 0.75s ease 0.2s both;
        }

        .chart-card h3 {
            margin: 0 0 8px;
            color: #0f172a;
            font-size: 22px;
        }

        .chart-card p {
            margin: 0 0 22px;
            color: #64748b;
            line-height: 1.6;
        }

        .bar-row {
            margin-bottom: 18px;
        }

        .bar-label {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 8px;
            font-size: 14px;
            color: #334155;
            font-weight: 800;
        }

        .bar-track {
            height: 14px;
            border-radius: 999px;
            background: #f1f5f9;
            overflow: hidden;
        }

        .bar-fill {
            height: 100%;
            border-radius: inherit;
            background: linear-gradient(90deg, #0284c7, #06b6d4);
            animation: barGrow 1.1s ease both;
        }

        .bar-fill.green {
            background: linear-gradient(90deg, #0f766e, #14b8a6);
        }

        .bar-fill.violet {
            background: linear-gradient(90deg, #6d28d9, #a855f7);
        }

        .bar-fill.orange {
            background: linear-gradient(90deg, #c2410c, #fb923c);
        }

        .report-module-grid {
            display: grid;
            grid-template-columns: repeat(4, minmax(0, 1fr));
            gap: 18px;
            margin-top: 24px;
        }

        .report-module-card {
            padding: 24px;
            border-radius: 28px;
            background:
                radial-gradient(circle at top right, rgba(56, 189, 248, 0.08), transparent 36%),
                white;
            border: 1px solid #e2e8f0;
            box-shadow: 0 16px 40px rgba(15, 23, 42, 0.06);
            text-decoration: none;
            transition: 0.25s ease;
        }

        .report-module-card:hover {
            transform: translateY(-7px);
            box-shadow: 0 28px 70px rgba(15, 23, 42, 0.13);
            border-color: #bae6fd;
        }

        .report-module-card b {
            width: 58px;
            height: 58px;
            border-radius: 20px;
            background: #eff6ff;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 28px;
            margin-bottom: 18px;
        }

        .report-module-card span {
            color: #0284c7;
            font-size: 12px;
            font-weight: 900;
            letter-spacing: 1.2px;
        }

        .report-module-card h3 {
            color: #0f172a;
            font-size: 19px;
            margin: 10px 0;
        }

        .report-module-card p {
            color: #64748b;
            font-size: 14px;
            line-height: 1.6;
            margin: 0;
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

        @keyframes barGrow {
            from {
                width: 0;
            }
        }

        @media (max-width: 1180px) {
            .admin-pro-layout {
                grid-template-columns: 1fr;
            }

            .admin-sidebar {
                position: static;
                height: auto;
            }

            .admin-main {
                padding: 24px 18px 60px;
            }

            .report-hero,
            .report-panel-grid {
                grid-template-columns: 1fr;
            }

            .report-stat-grid,
            .report-module-grid {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }
        }

        @media (max-width: 760px) {
            .admin-topbar,
            .section-heading {
                flex-direction: column;
                align-items: flex-start;
            }

            .report-hero {
                padding: 30px 22px;
            }

            .report-hero h2 {
                font-size: 34px;
            }

            .report-mini-stat,
            .report-stat-grid,
            .report-module-grid {
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
<div class="admin-pro-layout">

    <main class="admin-main">

        <section class="admin-topbar">
            <div>
                <h1>Báo cáo thống kê</h1>
                <p>Theo dõi tổng quan dữ liệu tài liệu, thiết bị, người dùng và yêu cầu mượn trả.</p>
            </div>

            <a class="admin-btn secondary" href="<%= contextPath %>/admin/dashboard.jsp">
                Dashboard
            </a>
        </section>

        <section class="report-hero">
            <div class="report-hero-content">
                <span class="admin-label">REPORT & ANALYTICS</span>

                <h2>
                    Trung tâm báo cáo<br>
                    <span>HUSC Digital Library</span>
                </h2>

                <p>
                    Cung cấp góc nhìn tổng quan về dữ liệu hệ thống, giúp quản trị viên theo dõi
                    tình hình tài liệu, thiết bị, người dùng và các yêu cầu mượn thiết bị.
                </p>
            </div>

            <div class="report-hero-panel">
                <h3>Tổng quan nhanh</h3>

                <div class="report-mini-stat">
                    <div>
                        <strong><%= totalDocuments %></strong>
                        <span>Tài liệu</span>
                    </div>

                    <div>
                        <strong><%= totalEquipments %></strong>
                        <span>Thiết bị</span>
                    </div>

                    <div>
                        <strong><%= totalUsers %></strong>
                        <span>Người dùng</span>
                    </div>

                    <div>
                        <strong><%= totalBorrowRequests %></strong>
                        <span>Yêu cầu</span>
                    </div>
                </div>
            </div>
        </section>

        <section class="report-stat-grid">
            <article class="report-stat-card">
                <div class="report-icon">📄</div>
                <strong><%= totalDocuments %></strong>
                <span>Tổng tài liệu</span>
            </article>

            <article class="report-stat-card">
                <div class="report-icon">💻</div>
                <strong><%= totalEquipments %></strong>
                <span>Tổng thiết bị</span>
            </article>

            <article class="report-stat-card">
                <div class="report-icon">👥</div>
                <strong><%= totalUsers %></strong>
                <span>Tổng người dùng</span>
            </article>

            <article class="report-stat-card">
                <div class="report-icon">📥</div>
                <strong><%= totalBorrowRequests %></strong>
                <span>Tổng yêu cầu mượn</span>
            </article>
        </section>

        <section class="report-section">
            <div class="section-heading">
                <div>
                    <span>VISUAL OVERVIEW</span>
                    <h2>Biểu đồ tổng quan</h2>
                </div>

                <p>Các biểu đồ được dựng bằng CSS để giao diện nhẹ và mượt.</p>
            </div>

            <div class="report-panel-grid">

                <div class="chart-card">
                    <h3>Dữ liệu chính</h3>
                    <p>Tổng hợp số lượng tài liệu, thiết bị, người dùng và yêu cầu.</p>

                    <div class="bar-row">
                        <div class="bar-label">
                            <span>Tài liệu</span>
                            <b><%= totalDocuments %></b>
                        </div>
                        <div class="bar-track">
                            <div class="bar-fill" style="width:<%= (totalDocuments * 100 / maxMain) %>%"></div>
                        </div>
                    </div>

                    <div class="bar-row">
                        <div class="bar-label">
                            <span>Thiết bị</span>
                            <b><%= totalEquipments %></b>
                        </div>
                        <div class="bar-track">
                            <div class="bar-fill green" style="width:<%= (totalEquipments * 100 / maxMain) %>%"></div>
                        </div>
                    </div>

                    <div class="bar-row">
                        <div class="bar-label">
                            <span>Người dùng</span>
                            <b><%= totalUsers %></b>
                        </div>
                        <div class="bar-track">
                            <div class="bar-fill violet" style="width:<%= (totalUsers * 100 / maxMain) %>%"></div>
                        </div>
                    </div>

                    <div class="bar-row">
                        <div class="bar-label">
                            <span>Yêu cầu mượn</span>
                            <b><%= totalBorrowRequests %></b>
                        </div>
                        <div class="bar-track">
                            <div class="bar-fill orange" style="width:<%= (totalBorrowRequests * 100 / maxMain) %>%"></div>
                        </div>
                    </div>
                </div>

                <div class="chart-card">
                    <h3>Trạng thái yêu cầu</h3>
                    <p>Theo dõi các trạng thái xử lý yêu cầu mượn thiết bị.</p>

                    <div class="bar-row">
                        <div class="bar-label">
                            <span>Chờ duyệt</span>
                            <b><%= pendingRequests %></b>
                        </div>
                        <div class="bar-track">
                            <div class="bar-fill orange" style="width:<%= (pendingRequests * 100 / maxRequest) %>%"></div>
                        </div>
                    </div>

                    <div class="bar-row">
                        <div class="bar-label">
                            <span>Đã duyệt</span>
                            <b><%= approvedRequests %></b>
                        </div>
                        <div class="bar-track">
                            <div class="bar-fill" style="width:<%= (approvedRequests * 100 / maxRequest) %>%"></div>
                        </div>
                    </div>

                    <div class="bar-row">
                        <div class="bar-label">
                            <span>Đang mượn</span>
                            <b><%= borrowingRequests %></b>
                        </div>
                        <div class="bar-track">
                            <div class="bar-fill violet" style="width:<%= (borrowingRequests * 100 / maxRequest) %>%"></div>
                        </div>
                    </div>

                    <div class="bar-row">
                        <div class="bar-label">
                            <span>Đã trả</span>
                            <b><%= returnedRequests %></b>
                        </div>
                        <div class="bar-track">
                            <div class="bar-fill green" style="width:<%= (returnedRequests * 100 / maxRequest) %>%"></div>
                        </div>
                    </div>
                </div>

            </div>
        </section>

        <section class="report-section">
            <div class="section-heading">
                <div>
                    <span>REPORT MODULES</span>
                    <h2>Truy cập nhanh dữ liệu báo cáo</h2>
                </div>
            </div>

            <div class="report-module-grid">
                <a class="report-module-card" href="<%= contextPath %>/admin/documents">
                    <b>📄</b>
                    <span>DOCUMENTS</span>
                    <h3>Báo cáo tài liệu</h3>
                    <p>Xem danh sách, trạng thái và dữ liệu khai thác tài liệu.</p>
                </a>

                <a class="report-module-card" href="<%= contextPath %>/admin/equipments">
                    <b>💻</b>
                    <span>EQUIPMENTS</span>
                    <h3>Báo cáo thiết bị</h3>
                    <p>Theo dõi trạng thái sẵn sàng, đang mượn và bảo trì.</p>
                </a>

                <a class="report-module-card" href="<%= contextPath %>/admin/borrow-requests">
                    <b>📥</b>
                    <span>BORROW</span>
                    <h3>Báo cáo mượn</h3>
                    <p>Theo dõi luồng xử lý yêu cầu mượn thiết bị.</p>
                </a>

                <a class="report-module-card" href="<%= contextPath %>/admin/users">
                    <b>👥</b>
                    <span>USERS</span>
                    <h3>Báo cáo người dùng</h3>
                    <p>Quản lý số lượng tài khoản, vai trò và trạng thái.</p>
                </a>
            </div>
        </section>

    </main>

</div>

</body>
</html>
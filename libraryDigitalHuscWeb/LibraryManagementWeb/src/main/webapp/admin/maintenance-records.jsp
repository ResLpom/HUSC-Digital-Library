<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.lang.reflect.Method" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%@ page import="vn.edu.husc.library.model.User" %>

<%!
    private String getText(Object obj, String defaultValue, String... methodNames) {
        if (obj == null) return defaultValue;

        for (String methodName : methodNames) {
            try {
                Method method = obj.getClass().getMethod(methodName);
                Object value = method.invoke(obj);

                if (value != null && !value.toString().trim().isEmpty()) {
                    return value.toString();
                }
            } catch (Exception e) {
                // Bỏ qua nếu getter không tồn tại
            }
        }

        return defaultValue;
    }

    private String getDateText(Object obj, String... methodNames) {
        if (obj == null) return "Chưa cập nhật";

        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");

        for (String methodName : methodNames) {
            try {
                Method method = obj.getClass().getMethod(methodName);
                Object value = method.invoke(obj);

                if (value == null) continue;

                if (value instanceof Date) {
                    return sdf.format((Date) value);
                }

                return value.toString();
            } catch (Exception e) {
                // Bỏ qua nếu getter không tồn tại
            }
        }

        return "Chưa cập nhật";
    }
%>

<%
    String contextPath = request.getContextPath();

    List<?> records = (List<?>) request.getAttribute("records");
    if (records == null) records = (List<?>) request.getAttribute("maintenanceRecords");
    if (records == null) records = (List<?>) request.getAttribute("maintenances");
    if (records == null) records = (List<?>) request.getAttribute("maintenanceList");

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

    int total = records != null ? records.size() : 0;
    int pending = 0;
    int processing = 0;
    int completed = 0;
    int broken = 0;

    if (records != null) {
        for (Object r : records) {
            String status = getText(r, "", "getStatus", "getMaintenanceStatus", "getResultStatus");
            String lower = status.toLowerCase();

            if (lower.contains("pending") || lower.contains("chờ")) {
                pending++;
            } else if (lower.contains("process") || lower.contains("repair") || lower.contains("đang")) {
                processing++;
            } else if (lower.contains("complete") || lower.contains("done") || lower.contains("hoàn thành") || lower.contains("available")) {
                completed++;
            } else if (lower.contains("broken") || lower.contains("lost") || lower.contains("hỏng") || lower.contains("mất")) {
                broken++;
            }
        }
    }
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Bảo trì thiết bị - HUSC Digital Library</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/common/base.css?v=1">
	<link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/common/components.css?v=1">
	<link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/admin/admin-layout.css?v=1">
    <style>
        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background:
                radial-gradient(circle at top left, rgba(20, 184, 166, 0.12), transparent 30%),
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

        .admin-top-actions {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
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
            background: linear-gradient(135deg, #0f766e, #14b8a6);
            box-shadow: 0 14px 30px rgba(20, 184, 166, 0.24);
        }

        .admin-btn.secondary {
            color: #0f766e;
            background: #ecfeff;
            border: 1px solid #a5f3fc;
        }

        .admin-btn.warning {
            color: #92400e;
            background: #fef3c7;
            border: 1px solid #fde68a;
        }

        .admin-btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 18px 38px rgba(15, 23, 42, 0.13);
        }

        .maintenance-hero {
            margin-top: 26px;
            border-radius: 38px;
            padding: 42px;
            color: white;
            background:
                radial-gradient(circle at 18% 20%, rgba(20, 184, 166, 0.36), transparent 32%),
                radial-gradient(circle at 90% 80%, rgba(59, 130, 246, 0.34), transparent 34%),
                linear-gradient(135deg, #0f172a, #155e75);
            box-shadow: 0 34px 82px rgba(15, 23, 42, 0.18);
            position: relative;
            overflow: hidden;
            display: grid;
            grid-template-columns: minmax(0, 1fr) 380px;
            gap: 28px;
            align-items: center;
            animation: fadeUp 0.75s ease 0.08s both;
        }

        .maintenance-hero::before {
            content: "";
            position: absolute;
            inset: 0;
            background: linear-gradient(120deg, transparent, rgba(255,255,255,0.08), transparent);
            transform: translateX(-120%);
            animation: shineMove 7s ease-in-out infinite;
        }

        .maintenance-hero-content,
        .maintenance-hero-panel {
            position: relative;
            z-index: 2;
        }

        .admin-label {
            display: inline-flex;
            padding: 9px 16px;
            border-radius: 999px;
            background: rgba(255, 255, 255, 0.13);
            border: 1px solid rgba(255, 255, 255, 0.18);
            color: #ccfbf1;
            font-size: 12px;
            font-weight: 900;
            letter-spacing: 1.4px;
        }

        .maintenance-hero h2 {
            font-size: 46px;
            line-height: 1.1;
            letter-spacing: -1.6px;
            margin: 18px 0 12px;
        }

        .maintenance-hero h2 span {
            background: linear-gradient(135deg, #99f6e4, #ffffff, #bfdbfe);
            -webkit-background-clip: text;
            background-clip: text;
            color: transparent;
        }

        .maintenance-hero p {
            color: #dbeafe;
            line-height: 1.75;
            max-width: 760px;
        }

        .maintenance-hero-panel {
            padding: 24px;
            border-radius: 28px;
            background: rgba(255, 255, 255, 0.13);
            border: 1px solid rgba(255, 255, 255, 0.17);
            backdrop-filter: blur(18px);
            animation: floatCard 5s ease-in-out infinite;
        }

        .maintenance-hero-panel h3 {
            margin: 0 0 16px;
            color: white;
        }

        .maintenance-mini-stat {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 12px;
        }

        .maintenance-mini-stat div {
            padding: 15px;
            border-radius: 20px;
            background: rgba(255, 255, 255, 0.12);
        }

        .maintenance-mini-stat strong {
            display: block;
            color: white;
            font-size: 28px;
            margin-bottom: 6px;
        }

        .maintenance-mini-stat span {
            color: #ccfbf1;
            font-size: 12px;
            font-weight: 800;
        }

        .maintenance-stat-strip {
            margin-top: 24px;
            display: grid;
            grid-template-columns: repeat(4, minmax(0, 1fr));
            gap: 16px;
            animation: fadeUp 0.75s ease 0.14s both;
        }

        .maintenance-stat-card {
            background: white;
            border: 1px solid #e2e8f0;
            border-radius: 26px;
            padding: 20px;
            box-shadow: 0 16px 40px rgba(15, 23, 42, 0.06);
            transition: 0.24s ease;
        }

        .maintenance-stat-card:hover {
            transform: translateY(-6px);
            box-shadow: 0 26px 60px rgba(15, 23, 42, 0.11);
        }

        .maintenance-stat-card strong {
            display: block;
            font-size: 28px;
            color: #0f172a;
            margin-bottom: 6px;
        }

        .maintenance-stat-card span {
            color: #64748b;
            font-size: 13px;
            font-weight: 800;
        }

        .maintenance-toolbar {
            margin-top: 26px;
            padding: 20px;
            border-radius: 28px;
            background: white;
            border: 1px solid #e2e8f0;
            box-shadow: 0 16px 40px rgba(15, 23, 42, 0.06);
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 18px;
            animation: fadeUp 0.75s ease 0.2s both;
        }

        .maintenance-toolbar h2 {
            margin: 0 0 5px;
            font-size: 24px;
            color: #0f172a;
        }

        .maintenance-toolbar p {
            margin: 0;
            color: #64748b;
            font-size: 14px;
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

        .maintenance-grid {
            margin-top: 22px;
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 22px;
            animation: fadeUp 0.75s ease 0.26s both;
        }

        .maintenance-card {
            background: white;
            border: 1px solid #e2e8f0;
            border-radius: 30px;
            padding: 24px;
            box-shadow: 0 18px 48px rgba(15, 23, 42, 0.06);
            transition: 0.25s ease;
        }

        .maintenance-card:hover {
            transform: translateY(-6px);
            box-shadow: 0 28px 70px rgba(15, 23, 42, 0.12);
            border-color: #a5f3fc;
        }

        .maintenance-card-top {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 14px;
            margin-bottom: 18px;
        }

        .maintenance-id {
            width: 52px;
            height: 52px;
            border-radius: 18px;
            background: #ecfeff;
            color: #0f766e;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 900;
        }

        .maintenance-status {
            padding: 8px 12px;
            border-radius: 999px;
            font-size: 12px;
            font-weight: 900;
            border: 1px solid transparent;
            white-space: nowrap;
        }

        .status-pending {
            background: #fef9c3;
            color: #854d0e;
            border-color: #fde68a;
        }

        .status-processing {
            background: #ede9fe;
            color: #5b21b6;
            border-color: #ddd6fe;
        }

        .status-completed {
            background: #dcfce7;
            color: #166534;
            border-color: #bbf7d0;
        }

        .status-broken {
            background: #ffe4e6;
            color: #be123c;
            border-color: #fecdd3;
        }

        .status-neutral {
            background: #f1f5f9;
            color: #475569;
            border-color: #e2e8f0;
        }

        .equipment-box {
            display: flex;
            gap: 14px;
            align-items: flex-start;
            margin-bottom: 18px;
        }

        .equipment-icon {
            width: 60px;
            height: 60px;
            border-radius: 20px;
            background: linear-gradient(135deg, #0f766e, #14b8a6);
            color: white;
            font-size: 27px;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }

        .equipment-box small {
            display: inline-flex;
            padding: 6px 10px;
            border-radius: 999px;
            background: #ecfeff;
            color: #0e7490;
            font-size: 12px;
            font-weight: 900;
            margin-bottom: 8px;
        }

        .equipment-box h3 {
            margin: 0 0 5px;
            color: #0f172a;
            font-size: 20px;
        }

        .equipment-box p {
            margin: 0;
            color: #64748b;
            font-size: 14px;
        }

        .maintenance-info-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 12px;
            margin-bottom: 16px;
        }

        .maintenance-info-grid div {
            padding: 14px;
            border-radius: 18px;
            background: #f8fafc;
            border: 1px solid #e2e8f0;
        }

        .maintenance-info-grid span {
            display: block;
            color: #64748b;
            font-size: 12px;
            font-weight: 800;
            margin-bottom: 6px;
        }

        .maintenance-info-grid strong {
            color: #0f172a;
            font-size: 14px;
        }

        .maintenance-note {
            padding: 15px;
            border-radius: 20px;
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            margin-top: 12px;
        }

        .maintenance-note.warning {
            background: #fff7ed;
            border-color: #fed7aa;
        }

        .maintenance-note span {
            display: block;
            color: #475569;
            font-size: 12px;
            font-weight: 900;
            margin-bottom: 7px;
        }

        .maintenance-note p {
            margin: 0;
            color: #334155;
            font-size: 14px;
            line-height: 1.6;
        }

        .card-actions {
            margin-top: 18px;
            padding-top: 18px;
            border-top: 1px solid #e2e8f0;
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
        }

        .empty-admin-box {
            margin-top: 22px;
            padding: 56px 24px;
            text-align: center;
            background: white;
            border: 1px dashed #cbd5e1;
            border-radius: 30px;
            animation: fadeUp 0.75s ease 0.26s both;
        }

        .empty-admin-icon {
            width: 86px;
            height: 86px;
            border-radius: 28px;
            background: #ecfeff;
            color: #0e7490;
            font-size: 42px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 18px;
        }

        .empty-admin-box h3 {
            margin: 0 0 10px;
            font-size: 24px;
            color: #0f172a;
        }

        .empty-admin-box p {
            margin: 0 auto 22px;
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

            .maintenance-hero {
                grid-template-columns: 1fr;
            }

            .maintenance-stat-strip,
            .maintenance-grid {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }

            .maintenance-toolbar {
                flex-direction: column;
                align-items: flex-start;
            }

            .fake-search {
                min-width: 0;
                width: 100%;
                box-sizing: border-box;
            }
        }

        @media (max-width: 760px) {
            .admin-topbar {
                flex-direction: column;
                align-items: flex-start;
            }

            .maintenance-hero {
                padding: 30px 22px;
            }

            .maintenance-hero h2 {
                font-size: 34px;
            }

            .maintenance-mini-stat,
            .maintenance-stat-strip,
            .maintenance-grid,
            .maintenance-info-grid {
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
                <h1>Bảo trì thiết bị</h1>
                <p>Theo dõi tình trạng sửa chữa, bảo trì và xử lý thiết bị lỗi trong hệ thống.</p>
            </div>

            <div class="admin-top-actions">
                <a class="admin-btn secondary" href="<%= contextPath %>/admin/equipments">Danh sách thiết bị</a>
                <a class="admin-btn primary" href="<%= contextPath %>/admin/maintenance-records?action=form">+ Tạo bảo trì</a>
            </div>
        </section>

        <section class="maintenance-hero">
            <div class="maintenance-hero-content">
                <span class="admin-label">MAINTENANCE MANAGEMENT</span>

                <h2>
                    Quản lý bảo trì<br>
                    <span>thiết bị học tập</span>
                </h2>

                <p>
                    Ghi nhận tình trạng thiết bị sau khi trả, theo dõi quá trình bảo trì,
                    cập nhật kết quả sửa chữa và đưa thiết bị trở lại trạng thái sẵn sàng sử dụng.
                </p>
            </div>

            <div class="maintenance-hero-panel">
                <h3>Tổng quan bảo trì</h3>

                <div class="maintenance-mini-stat">
                    <div>
                        <strong><%= total %></strong>
                        <span>Tổng bản ghi</span>
                    </div>

                    <div>
                        <strong><%= pending %></strong>
                        <span>Chờ xử lý</span>
                    </div>

                    <div>
                        <strong><%= processing %></strong>
                        <span>Đang sửa</span>
                    </div>

                    <div>
                        <strong><%= completed %></strong>
                        <span>Hoàn thành</span>
                    </div>
                </div>
            </div>
        </section>

        <section class="maintenance-stat-strip">
            <div class="maintenance-stat-card">
                <strong><%= pending %></strong>
                <span>Chờ xử lý</span>
            </div>

            <div class="maintenance-stat-card">
                <strong><%= processing %></strong>
                <span>Đang bảo trì</span>
            </div>

            <div class="maintenance-stat-card">
                <strong><%= completed %></strong>
                <span>Đã hoàn thành</span>
            </div>

            <div class="maintenance-stat-card">
                <strong><%= broken %></strong>
                <span>Hỏng/Mất</span>
            </div>
        </section>

        <section class="maintenance-toolbar">
            <div>
                <h2>Danh sách bảo trì</h2>
                <p>Các bản ghi bảo trì thiết bị được hiển thị dưới dạng thẻ để dễ theo dõi.</p>
            </div>

            <div class="fake-search">
                🔎 Có thể bổ sung ô tìm kiếm/lọc bảo trì tại đây
            </div>
        </section>

        <% if (records == null || records.isEmpty()) { %>

            <section class="empty-admin-box">
                <div class="empty-admin-icon">🛠</div>
                <h3>Chưa có bản ghi bảo trì</h3>
                <p>
                    Khi thiết bị bị lỗi hoặc cần sửa chữa, bản ghi bảo trì sẽ xuất hiện tại đây.
                </p>

                <a class="admin-btn primary" href="<%= contextPath %>/admin/equipments">
                    Xem thiết bị
                </a>
            </section>

        <% } else { %>

            <section class="maintenance-grid">

                <%
                    int index = 1;

                    for (Object r : records) {
                        String equipmentName = getText(r, "Thiết bị học tập", "getEquipmentName", "getName", "getDeviceName");
                        String equipmentCode = getText(r, "NO-CODE", "getEquipmentCode", "getCode");
                        String typeName = getText(r, "Chưa phân loại", "getTypeName", "getEquipmentTypeName");
                        String location = getText(r, "Chưa cập nhật", "getLocation", "getRoomName");

                        String issueDescription = getText(r, "Chưa có mô tả lỗi.", "getIssueDescription", "getDescription", "getProblemDescription");
                        String maintenanceNote = getText(r, "Chưa có ghi chú.", "getNote", "getMaintenanceNote", "getManagerNote", "getResultNote");

                        String status = getText(r, "UNKNOWN", "getStatus", "getMaintenanceStatus", "getResultStatus");
                        String statusLower = status.toLowerCase();

                        String statusClass = "status-neutral";

                        if (statusLower.contains("pending") || statusLower.contains("chờ")) {
                            statusClass = "status-pending";
                        } else if (statusLower.contains("process") || statusLower.contains("repair") || statusLower.contains("đang")) {
                            statusClass = "status-processing";
                        } else if (statusLower.contains("complete") || statusLower.contains("done") || statusLower.contains("available") || statusLower.contains("hoàn thành")) {
                            statusClass = "status-completed";
                        } else if (statusLower.contains("broken") || statusLower.contains("lost") || statusLower.contains("hỏng") || statusLower.contains("mất")) {
                            statusClass = "status-broken";
                        }

                        String createdAt = getDateText(r, "getCreatedAt", "getCreatedDate", "getMaintenanceDate", "getStartDate");
                        String completedAt = getDateText(r, "getCompletedAt", "getCompletedDate", "getEndDate", "getFinishDate");

                        String recordId = getText(r, String.valueOf(index), "getMaintenanceId", "getMaintenanceRecordId", "getRecordId", "getId");
                %>

                    <article class="maintenance-card">

                        <div class="maintenance-card-top">
                            <div class="maintenance-id">#<%= index++ %></div>

                            <span class="maintenance-status <%= statusClass %>">
                                <%= status %>
                            </span>
                        </div>

                        <div class="equipment-box">
                            <div class="equipment-icon">💻</div>

                            <div>
                                <small><%= equipmentCode %></small>
                                <h3><%= equipmentName %></h3>
                                <p><%= typeName %> • <%= location %></p>
                            </div>
                        </div>

                        <div class="maintenance-info-grid">
                            <div>
                                <span>Ngày ghi nhận</span>
                                <strong><%= createdAt %></strong>
                            </div>

                            <div>
                                <span>Ngày hoàn thành</span>
                                <strong><%= completedAt %></strong>
                            </div>

                            <div>
                                <span>Loại thiết bị</span>
                                <strong><%= typeName %></strong>
                            </div>

                            <div>
                                <span>Vị trí</span>
                                <strong><%= location %></strong>
                            </div>
                        </div>

                        <div class="maintenance-note warning">
                            <span>Mô tả lỗi / tình trạng</span>
                            <p><%= issueDescription %></p>
                        </div>

                        <div class="maintenance-note">
                            <span>Ghi chú bảo trì</span>
                            <p><%= maintenanceNote %></p>
                        </div>

                        <div class="card-actions">
    <a class="admin-btn secondary"
       href="<%= contextPath %>/admin/maintenance-records?action=detail&id=<%= recordId %>">
        Xem chi tiết
    </a>

    <% if (!statusLower.contains("done")
            && !statusLower.contains("complete")
            && !statusLower.contains("hoàn thành")) { %>

        <a class="admin-btn warning"
           href="<%= contextPath %>/admin/maintenance-records?action=complete&id=<%= recordId %>"
           onclick="return confirm('Xác nhận hoàn tất bảo trì bản ghi này?');">
            Hoàn tất
        </a>

    <% } %>
</div>

                    </article>

                <% } %>

            </section>

        <% } %>

    </main>

</div>

</body>
</html>
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
                // Bỏ qua nếu method không tồn tại
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
                // Bỏ qua nếu method không tồn tại
            }
        }

        return "Chưa cập nhật";
    }
%>

<%
    String contextPath = request.getContextPath();

    List<?> logs = (List<?>) request.getAttribute("logs");
    if (logs == null) logs = (List<?>) request.getAttribute("systemLogs");
    if (logs == null) logs = (List<?>) request.getAttribute("logList");

    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        currentUser = (User) session.getAttribute("user");
    }

    String fullName = currentUser != null ? getText(currentUser, "Quản trị viên", "getFullName", "getName") : "Quản trị viên";
    String email = currentUser != null ? getText(currentUser, "admin@husc.edu.vn", "getEmail") : "admin@husc.edu.vn";
    String roleName = currentUser != null ? getText(currentUser, "Administrator", "getRoleName", "getRoleCode") : "Administrator";

    int totalLogs = logs != null ? logs.size() : 0;
    int loginLogs = 0;
    int documentLogs = 0;
    int equipmentLogs = 0;
    int userLogs = 0;

    if (logs != null) {
        for (Object log : logs) {
            String action = getText(log, "", "getAction", "getActionName", "getActivity");
            String module = getText(log, "", "getModule", "getModuleName", "getTargetTable");

            String combined = (action + " " + module).toLowerCase();

            if (combined.contains("login") || combined.contains("đăng nhập")) loginLogs++;
            if (combined.contains("document") || combined.contains("tài liệu")) documentLogs++;
            if (combined.contains("equipment") || combined.contains("thiết bị")) equipmentLogs++;
            if (combined.contains("user") || combined.contains("người dùng")) userLogs++;
        }
    }
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Nhật ký hệ thống - HUSC Digital Library</title>
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

        .admin-btn.secondary {
            color: #0369a1;
            background: #e0f2fe;
            border: 1px solid #bae6fd;
        }

        .admin-btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 18px 38px rgba(15, 23, 42, 0.13);
        }

        .logs-hero {
            margin-top: 26px;
            border-radius: 38px;
            padding: 42px;
            color: white;
            background:
                radial-gradient(circle at 18% 20%, rgba(56, 189, 248, 0.35), transparent 32%),
                radial-gradient(circle at 90% 80%, rgba(99, 102, 241, 0.35), transparent 34%),
                linear-gradient(135deg, #0f172a, #1e293b);
            box-shadow: 0 34px 82px rgba(15, 23, 42, 0.18);
            position: relative;
            overflow: hidden;
            display: grid;
            grid-template-columns: minmax(0, 1fr) 360px;
            gap: 28px;
            align-items: center;
            animation: fadeUp 0.75s ease 0.08s both;
        }

        .logs-hero::before {
            content: "";
            position: absolute;
            inset: 0;
            background: linear-gradient(120deg, transparent, rgba(255,255,255,0.08), transparent);
            transform: translateX(-120%);
            animation: shineMove 7s ease-in-out infinite;
        }

        .logs-hero-content,
        .logs-hero-panel {
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

        .logs-hero h2 {
            font-size: 46px;
            line-height: 1.1;
            letter-spacing: -1.6px;
            margin: 18px 0 12px;
        }

        .logs-hero h2 span {
            background: linear-gradient(135deg, #7dd3fc, #ffffff, #c4b5fd);
            -webkit-background-clip: text;
            background-clip: text;
            color: transparent;
        }

        .logs-hero p {
            color: #dbeafe;
            line-height: 1.75;
            max-width: 760px;
        }

        .logs-hero-panel {
            padding: 24px;
            border-radius: 28px;
            background: rgba(255, 255, 255, 0.13);
            border: 1px solid rgba(255, 255, 255, 0.17);
            backdrop-filter: blur(18px);
            animation: floatCard 5s ease-in-out infinite;
        }

        .logs-hero-panel h3 {
            margin: 0 0 16px;
            color: white;
        }

        .logs-mini-stat {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 12px;
        }

        .logs-mini-stat div {
            padding: 15px;
            border-radius: 20px;
            background: rgba(255, 255, 255, 0.12);
        }

        .logs-mini-stat strong {
            display: block;
            color: white;
            font-size: 28px;
            margin-bottom: 6px;
        }

        .logs-mini-stat span {
            color: #bfdbfe;
            font-size: 12px;
            font-weight: 800;
        }

        .logs-toolbar {
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
            animation: fadeUp 0.75s ease 0.14s both;
        }

        .logs-toolbar h2 {
            margin: 0 0 5px;
            font-size: 24px;
            color: #0f172a;
        }

        .logs-toolbar p {
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

        .logs-table-card {
            margin-top: 22px;
            border-radius: 32px;
            background: white;
            border: 1px solid #e2e8f0;
            box-shadow: 0 18px 48px rgba(15, 23, 42, 0.06);
            overflow: hidden;
            animation: fadeUp 0.75s ease 0.2s both;
        }

        .logs-table-wrapper {
            overflow-x: auto;
        }

        .logs-table {
            width: 100%;
            border-collapse: collapse;
            min-width: 1080px;
        }

        .logs-table thead {
            background: #f8fafc;
        }

        .logs-table th {
            padding: 18px;
            text-align: left;
            color: #475569;
            font-size: 12px;
            font-weight: 900;
            letter-spacing: 0.8px;
            text-transform: uppercase;
            border-bottom: 1px solid #e2e8f0;
        }

        .logs-table td {
            padding: 18px;
            border-bottom: 1px solid #f1f5f9;
            color: #334155;
            vertical-align: middle;
            font-size: 14px;
        }

        .logs-table tbody tr {
            transition: 0.22s ease;
        }

        .logs-table tbody tr:hover {
            background: #f8fbff;
        }

        .log-user-cell {
            display: flex;
            align-items: center;
            gap: 14px;
            min-width: 230px;
        }

        .log-avatar {
            width: 50px;
            height: 50px;
            border-radius: 17px;
            background: linear-gradient(135deg, #0f172a, #0284c7);
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 900;
            flex-shrink: 0;
        }

        .log-user-info strong {
            display: block;
            color: #0f172a;
            font-size: 15px;
            margin-bottom: 5px;
        }

        .log-user-info span {
            display: block;
            color: #64748b;
            font-size: 12px;
        }

        .log-badge {
            display: inline-flex;
            padding: 7px 11px;
            border-radius: 999px;
            font-size: 12px;
            font-weight: 900;
            white-space: nowrap;
            border: 1px solid transparent;
        }

        .badge-module {
            background: #eff6ff;
            color: #1d4ed8;
            border-color: #bfdbfe;
        }

        .badge-action {
            background: #ecfeff;
            color: #0e7490;
            border-color: #a5f3fc;
        }

        .badge-danger {
            background: #ffe4e6;
            color: #be123c;
            border-color: #fecdd3;
        }

        .log-description {
            max-width: 420px;
            line-height: 1.55;
            color: #475569;
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

            .logs-hero {
                grid-template-columns: 1fr;
            }

            .logs-toolbar {
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

            .logs-hero {
                padding: 30px 22px;
            }

            .logs-hero h2 {
                font-size: 34px;
            }

            .logs-mini-stat {
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
                <h1>Nhật ký hệ thống</h1>
                <p>Theo dõi hoạt động quan trọng của người dùng và quản trị viên trong hệ thống.</p>
            </div>

            <a class="admin-btn secondary" href="<%= contextPath %>/admin/dashboard.jsp">
                Dashboard
            </a>
        </section>

        <section class="logs-hero">
            <div class="logs-hero-content">
                <span class="admin-label">SYSTEM ACTIVITY LOGS</span>

                <h2>
                    Theo dõi hoạt động<br>
                    <span>trong hệ thống</span>
                </h2>

                <p>
                    Nhật ký giúp quản trị viên kiểm tra các thao tác quan trọng như đăng nhập,
                    thêm/sửa dữ liệu, xử lý yêu cầu mượn trả và các hoạt động quản trị khác.
                </p>
            </div>

            <div class="logs-hero-panel">
                <h3>Tổng quan log</h3>

                <div class="logs-mini-stat">
                    <div>
                        <strong><%= totalLogs %></strong>
                        <span>Tổng log</span>
                    </div>

                    <div>
                        <strong><%= loginLogs %></strong>
                        <span>Đăng nhập</span>
                    </div>

                    <div>
                        <strong><%= documentLogs %></strong>
                        <span>Tài liệu</span>
                    </div>

                    <div>
                        <strong><%= equipmentLogs + userLogs %></strong>
                        <span>Thiết bị/User</span>
                    </div>
                </div>
            </div>
        </section>

        <section class="logs-toolbar">
            <div>
                <h2>Danh sách nhật ký</h2>
                <p>Các hoạt động gần đây của hệ thống được hiển thị tại đây.</p>
            </div>

            <div class="fake-search">
                🔎 Có thể bổ sung ô tìm kiếm/lọc log tại đây
            </div>
        </section>

        <section class="logs-table-card">

            <% if (logs == null || logs.isEmpty()) { %>

                <div class="empty-admin-box">
                    <div class="empty-admin-icon">🧾</div>
                    <h3>Chưa có nhật ký hệ thống</h3>
                    <p>
                        Khi người dùng hoặc quản trị viên thao tác trong hệ thống, nhật ký sẽ được ghi nhận tại đây.
                    </p>
                </div>

            <% } else { %>

                <div class="logs-table-wrapper">
                    <table class="logs-table">
                        <thead>
                            <tr>
                                <th>Người thực hiện</th>
                                <th>Module</th>
                                <th>Hành động</th>
                                <th>Nội dung</th>
                                <th>IP</th>
                                <th>Thời gian</th>
                            </tr>
                        </thead>

                        <tbody>
                            <% for (Object log : logs) {
                                String actor = getText(log, "Hệ thống", "getFullName", "getUserName", "getUsername", "getActorName", "getEmail");
                                String module = getText(log, "SYSTEM", "getModule", "getModuleName", "getTargetTable");
                                String action = getText(log, "ACTION", "getAction", "getActionName", "getActivity");
                                String description = getText(log, "Không có mô tả chi tiết.", "getDescription", "getContent", "getDetail", "getMessage");
                                String ip = getText(log, "N/A", "getIpAddress", "getIp", "getClientIp");
                                String createdAt = getDateText(log, "getCreatedAt", "getLogTime", "getCreatedDate", "getTimestamp");

                                String actionClass = "badge-action";
                                String actionLower = action.toLowerCase();

                                if (actionLower.contains("delete")
                                        || actionLower.contains("xóa")
                                        || actionLower.contains("reject")
                                        || actionLower.contains("từ chối")) {
                                    actionClass = "badge-danger";
                                }
                            %>

                                <tr>
                                    <td>
                                        <div class="log-user-cell">
                                            <div class="log-avatar">👤</div>

                                            <div class="log-user-info">
                                                <strong><%= actor %></strong>
                                                <span>System actor</span>
                                            </div>
                                        </div>
                                    </td>

                                    <td>
                                        <span class="log-badge badge-module">
                                            <%= module %>
                                        </span>
                                    </td>

                                    <td>
                                        <span class="log-badge <%= actionClass %>">
                                            <%= action %>
                                        </span>
                                    </td>

                                    <td>
                                        <div class="log-description">
                                            <%= description %>
                                        </div>
                                    </td>

                                    <td>
                                        <%= ip %>
                                    </td>

                                    <td>
                                        <strong><%= createdAt %></strong>
                                    </td>
                                </tr>

                            <% } %>
                        </tbody>
                    </table>
                </div>

            <% } %>

        </section>

    </main>

</div>

</body>
</html>
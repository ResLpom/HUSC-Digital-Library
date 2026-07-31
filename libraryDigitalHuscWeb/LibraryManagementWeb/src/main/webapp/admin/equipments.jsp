<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="vn.edu.husc.library.model.Equipment" %>
<%@ page import="vn.edu.husc.library.model.User" %>

<%
    String contextPath = request.getContextPath();

    List<Equipment> equipments = (List<Equipment>) request.getAttribute("equipments");

    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        currentUser = (User) session.getAttribute("user");
    }

    String fullName = "Quản trị viên";
    String email = "admin@husc.edu.vn";
    String roleName = "Administrator";

    if (currentUser != null) {
        if (currentUser.getFullName() != null) {
            fullName = currentUser.getFullName();
        }

        if (currentUser.getEmail() != null) {
            email = currentUser.getEmail();
        }

        if (currentUser.getRoleName() != null) {
            roleName = currentUser.getRoleName();
        }
    }

    int totalEquipments = equipments != null ? equipments.size() : 0;
    int availableCount = 0;
    int borrowedCount = 0;
    int maintenanceCount = 0;

    if (equipments != null) {
        for (Equipment e : equipments) {
            String st = e.getStatus();

            if ("AVAILABLE".equalsIgnoreCase(st)) {
                availableCount++;
            } else if ("BORROWED".equalsIgnoreCase(st)) {
                borrowedCount++;
            } else if ("MAINTENANCE".equalsIgnoreCase(st)) {
                maintenanceCount++;
            }
        }
    }
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản lý thiết bị - HUSC Digital Library</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/common/base.css?v=1">
	<link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/common/components.css?v=1">
	<link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/admin/admin-layout.css?v=1">
    <style>
        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background:
                radial-gradient(circle at top left, rgba(20, 184, 166, 0.12), transparent 30%),
                radial-gradient(circle at bottom right, rgba(37, 99, 235, 0.12), transparent 32%),
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
            height: 76px;
            border-radius: 28px;
            padding: 0 24px;
            background: rgba(255, 255, 255, 0.86);
            border: 1px solid rgba(226, 232, 240, 0.9);
            box-shadow: 0 16px 40px rgba(15, 23, 42, 0.06);
            backdrop-filter: blur(18px);
            display: flex;
            align-items: center;
            justify-content: space-between;
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
            align-items: center;
            gap: 10px;
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

        .admin-btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 18px 38px rgba(15, 23, 42, 0.13);
        }

        .equip-hero {
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
            grid-template-columns: minmax(0, 1fr) 360px;
            gap: 28px;
            align-items: center;
            animation: fadeUp 0.75s ease 0.08s both;
        }

        .equip-hero::before {
            content: "";
            position: absolute;
            inset: 0;
            background: linear-gradient(120deg, transparent, rgba(255,255,255,0.08), transparent);
            transform: translateX(-120%);
            animation: shineMove 7s ease-in-out infinite;
        }

        .equip-hero-content,
        .equip-hero-panel {
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

        .equip-hero h2 {
            font-size: 46px;
            line-height: 1.1;
            letter-spacing: -1.6px;
            margin: 18px 0 12px;
        }

        .equip-hero h2 span {
            background: linear-gradient(135deg, #99f6e4, #ffffff, #bfdbfe);
            -webkit-background-clip: text;
            background-clip: text;
            color: transparent;
        }

        .equip-hero p {
            color: #dbeafe;
            line-height: 1.75;
            max-width: 760px;
        }

        .equip-hero-actions {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
            margin-top: 24px;
        }

        .equip-hero-panel {
            padding: 24px;
            border-radius: 28px;
            background: rgba(255, 255, 255, 0.13);
            border: 1px solid rgba(255, 255, 255, 0.17);
            backdrop-filter: blur(18px);
            animation: floatCard 5s ease-in-out infinite;
        }

        .equip-hero-panel h3 {
            margin: 0 0 16px;
            color: white;
        }

        .equip-mini-stat {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 12px;
        }

        .equip-mini-stat div {
            padding: 15px;
            border-radius: 20px;
            background: rgba(255, 255, 255, 0.12);
        }

        .equip-mini-stat strong {
            display: block;
            color: white;
            font-size: 28px;
            margin-bottom: 6px;
        }

        .equip-mini-stat span {
            color: #ccfbf1;
            font-size: 12px;
            font-weight: 800;
        }

        .equip-toolbar {
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

        .equip-toolbar-left h2 {
            margin: 0 0 5px;
            font-size: 24px;
            color: #0f172a;
        }

        .equip-toolbar-left p {
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

        .equip-table-card {
            margin-top: 22px;
            border-radius: 32px;
            background: white;
            border: 1px solid #e2e8f0;
            box-shadow: 0 18px 48px rgba(15, 23, 42, 0.06);
            overflow: hidden;
            animation: fadeUp 0.75s ease 0.2s both;
        }

        .equip-table-wrapper {
            overflow-x: auto;
        }

        .equip-table {
            width: 100%;
            border-collapse: collapse;
            min-width: 1120px;
        }

        .equip-table thead {
            background: #f8fafc;
        }

        .equip-table th {
            padding: 18px;
            text-align: left;
            color: #475569;
            font-size: 12px;
            font-weight: 900;
            letter-spacing: 0.8px;
            text-transform: uppercase;
            border-bottom: 1px solid #e2e8f0;
        }

        .equip-table td {
            padding: 18px;
            border-bottom: 1px solid #f1f5f9;
            color: #334155;
            vertical-align: middle;
            font-size: 14px;
        }

        .equip-table tbody tr {
            transition: 0.22s ease;
        }

        .equip-table tbody tr:hover {
            background: #f8fbff;
        }

        .equip-title-cell {
            display: flex;
            align-items: center;
            gap: 14px;
            min-width: 300px;
        }

        .equip-cover-mini {
            width: 70px;
            height: 58px;
            border-radius: 18px;
            background:
                radial-gradient(circle at top left, rgba(20, 184, 166, 0.18), transparent 34%),
                linear-gradient(135deg, #ccfbf1, #f8fafc);
            display: flex;
            align-items: center;
            justify-content: center;
            color: #0f766e;
            font-size: 26px;
            font-weight: 900;
            overflow: hidden;
            flex-shrink: 0;
        }

        .equip-cover-mini img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .equip-title-info strong {
            display: block;
            color: #0f172a;
            font-size: 15px;
            margin-bottom: 6px;
            line-height: 1.35;
        }

        .equip-title-info span {
            display: block;
            color: #64748b;
            font-size: 12px;
            line-height: 1.5;
            max-width: 380px;
        }

        .equip-chip {
            display: inline-flex;
            padding: 7px 11px;
            border-radius: 999px;
            background: #ecfeff;
            color: #0e7490;
            font-size: 12px;
            font-weight: 900;
            white-space: nowrap;
        }

        .status-badge-admin {
            display: inline-flex;
            padding: 7px 11px;
            border-radius: 999px;
            font-size: 12px;
            font-weight: 900;
            border: 1px solid transparent;
            white-space: nowrap;
        }

        .status-available {
            background: #dcfce7;
            color: #166534;
            border-color: #bbf7d0;
        }

        .status-borrowed {
            background: #fef9c3;
            color: #854d0e;
            border-color: #fde68a;
        }

        .status-maintenance {
            background: #ede9fe;
            color: #5b21b6;
            border-color: #ddd6fe;
        }

        .status-danger {
            background: #ffe4e6;
            color: #be123c;
            border-color: #fecdd3;
        }

        .status-neutral {
            background: #f1f5f9;
            color: #475569;
            border-color: #e2e8f0;
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
            transition: 0.22s ease;
        }

        .table-action.view {
            background: #eff6ff;
            color: #1d4ed8;
        }

        .table-action.edit {
            background: #ecfeff;
            color: #0e7490;
        }

        .table-action.maintenance {
            background: #f5f3ff;
            color: #6d28d9;
        }

        .table-action.hide {
            background: #fff7ed;
            color: #c2410c;
        }

        .table-action:hover {
            transform: translateY(-3px);
            box-shadow: 0 12px 24px rgba(15, 23, 42, 0.12);
        }

        .empty-admin-box {
            padding: 56px 24px;
            text-align: center;
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

            .equip-hero {
                grid-template-columns: 1fr;
            }

            .equip-toolbar {
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
                height: auto;
                padding: 18px;
                flex-direction: column;
                align-items: flex-start;
                gap: 14px;
            }

            .equip-hero {
                padding: 30px 22px;
            }

            .equip-hero h2 {
                font-size: 34px;
            }

            .equip-mini-stat {
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
                <h1>Quản lý thiết bị</h1>
                <p>Quản trị thiết bị học tập, trạng thái, vị trí, hình ảnh, giá trị và tình trạng mượn.</p>
            </div>

            <div class="admin-top-actions">
                <a class="admin-btn secondary" href="<%= contextPath %>/equipments">Xem trang thiết bị</a>
                <a class="admin-btn primary" href="<%= contextPath %>/admin/equipments?action=add">
    + Thêm thiết bị
</a>
            </div>
        </section>

        <section class="equip-hero">
            <div class="equip-hero-content">
                <span class="admin-label">EQUIPMENT MANAGEMENT</span>

                <h2>
                    Quản lý kho<br>
                    <span>thiết bị học tập</span>
                </h2>

                <p>
                    Theo dõi danh sách thiết bị, loại thiết bị, mã định danh, vị trí lưu trữ,
                    trạng thái sẵn sàng, đang mượn, bảo trì và các thông tin phục vụ quản lý.
                </p>

                <div class="equip-hero-actions">
                    <a class="admin-btn primary" href="<%= contextPath %>/admin/equipments?action=form">Thêm thiết bị mới</a>
                    <a class="admin-btn secondary" href="<%= contextPath %>/equipments">Xem giao diện người dùng</a>
                </div>
            </div>

            <div class="equip-hero-panel">
                <h3>Tổng quan thiết bị</h3>

                <div class="equip-mini-stat">
                    <div>
                        <strong><%= totalEquipments %></strong>
                        <span>Tổng thiết bị</span>
                    </div>

                    <div>
                        <strong><%= availableCount %></strong>
                        <span>Sẵn sàng</span>
                    </div>

                    <div>
                        <strong><%= borrowedCount %></strong>
                        <span>Đang mượn</span>
                    </div>

                    <div>
                        <strong><%= maintenanceCount %></strong>
                        <span>Bảo trì</span>
                    </div>
                </div>
            </div>
        </section>

        <section class="equip-toolbar">
            <div class="equip-toolbar-left">
                <h2>Danh sách thiết bị</h2>
                <p>Quản lý toàn bộ thiết bị học tập đang có trong hệ thống.</p>
            </div>

            <div class="fake-search">
                🔎 Có thể bổ sung ô tìm kiếm/lọc thiết bị tại đây
            </div>
        </section>

        <section class="equip-table-card">

            <% if (equipments == null || equipments.isEmpty()) { %>

                <div class="empty-admin-box">
                    <div class="empty-admin-icon">💻</div>
                    <h3>Chưa có thiết bị nào</h3>
                    <p>
                        Hãy thêm thiết bị đầu tiên để bắt đầu quản lý kho thiết bị học tập của hệ thống.
                    </p>
                    <a class="admin-btn primary" href="<%= contextPath %>/admin/equipments?action=form">
                        Thêm thiết bị mới
                    </a>
                </div>

            <% } else { %>

                <div class="equip-table-wrapper">
                    <table class="equip-table">
                        <thead>
                            <tr>
                                <th>Thiết bị</th>
                                <th>Loại</th>
                                <th>Mã</th>
                                <th>Vị trí</th>
                                <th>Giá trị</th>
                                <th>Trạng thái</th>
                                <th>Thao tác</th>
                            </tr>
                        </thead>

                        <tbody>
                            <% for (Equipment e : equipments) {
                                String status = e.getStatus();
                                String statusClass = "status-neutral";

                                if ("AVAILABLE".equalsIgnoreCase(status)) {
                                    statusClass = "status-available";
                                } else if ("BORROWED".equalsIgnoreCase(status)) {
                                    statusClass = "status-borrowed";
                                } else if ("MAINTENANCE".equalsIgnoreCase(status)) {
                                    statusClass = "status-maintenance";
                                } else if ("BROKEN".equalsIgnoreCase(status) || "LOST".equalsIgnoreCase(status)) {
                                    statusClass = "status-danger";
                                }

                                String statusText = e.getStatusName() != null ? e.getStatusName() : (status != null ? status : "UNKNOWN");
                            %>

                                <tr>
                                    <td>
                                        <div class="equip-title-cell">
                                            <div class="equip-cover-mini">
    <% if (e.getImagePath() != null && !e.getImagePath().trim().isEmpty()) { %>
        <img src="<%= contextPath %>/upload-image/equipments/<%= e.getImagePath() %>"
             alt="<%= e.getEquipmentName() != null ? e.getEquipmentName() : "Thiết bị" %>">
    <% } else { %>
        💻
    <% } %>
</div>
                                            </div>

                                            <div class="equip-title-info">
                                                <strong><%= e.getEquipmentName() != null ? e.getEquipmentName() : "Chưa cập nhật tên" %></strong>
                                                <span>
                                                    <%= e.getDescription() != null && !e.getDescription().trim().isEmpty()
                                                            ? e.getDescription()
                                                            : "Chưa có mô tả thiết bị." %>
                                                </span>
                                            </div>
                                        </div>
                                    </td>

                                    <td>
                                        <span class="equip-chip">
                                            <%= e.getTypeName() != null ? e.getTypeName() : "Chưa phân loại" %>
                                        </span>
                                    </td>

                                    <td>
                                        <strong><%= e.getCode() != null ? e.getCode() : "NO-CODE" %></strong>
                                    </td>

                                    <td>
                                        <%= e.getLocation() != null ? e.getLocation() : "Chưa cập nhật" %>
                                    </td>

                                    <td>
                                        <%= String.format("%,.0f", e.getValueMoney()) %> VNĐ
                                    </td>

                                    <td>
                                        <span class="status-badge-admin <%= statusClass %>">
                                            <%= statusText %>
                                        </span>
                                    </td>

                                    <td>
                                        <div class="table-actions">
    <a class="table-action view"
       href="<%= contextPath %>/admin/equipments?action=view&id=<%= e.getEquipmentId() %>">
        Xem
    </a>

    <a class="table-action edit"
       href="<%= contextPath %>/admin/equipments?action=edit&id=<%= e.getEquipmentId() %>">
        Sửa
    </a>

    <a class="table-action maintenance"
       href="<%= contextPath %>/admin/maintenance-records?action=form&equipmentId=<%= e.getEquipmentId() %>">
        Bảo trì
    </a>

    <a class="table-action hide"
       href="<%= contextPath %>/admin/equipments?action=hide&id=<%= e.getEquipmentId() %>"
       onclick="return confirm('Bạn có chắc muốn ẩn thiết bị này không?');">
        Ẩn
    </a>

    <a class="table-action delete"
       href="<%= contextPath %>/admin/equipments?action=delete&id=<%= e.getEquipmentId() %>"
       onclick="return confirm('Bạn có chắc muốn xóa thiết bị này khỏi danh sách hiển thị không?');">
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

</div>

</body>
</html>
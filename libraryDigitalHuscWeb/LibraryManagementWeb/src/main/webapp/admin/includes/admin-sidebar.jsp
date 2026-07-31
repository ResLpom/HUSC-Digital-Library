<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    String cp = request.getContextPath();
    String uri = request.getRequestURI();

    boolean activeDashboard = uri.contains("/admin/dashboard");
    boolean activeDocuments = uri.contains("/admin/documents");
    boolean activeExamBank = uri.contains("/admin/exam-bank");
    boolean activeEquipments = uri.contains("/admin/equipments");
    boolean activeBorrow = uri.contains("/admin/borrow-requests");
    boolean activeReturn = uri.contains("/admin/return-equipment");
    boolean activeMaintenance = uri.contains("/admin/maintenance-records");
    boolean activeUsers = uri.contains("/admin/users");
    boolean activeReports = uri.contains("/admin/reports");
    boolean activeLogs = uri.contains("/admin/system-logs");
%>

<style>
    .admin-sidebar {
        width: 270px;
        min-height: 100vh;
        height: 100vh;
        position: fixed;
        left: 0;
        top: 0;
        background: #0f172a;
        color: white;
        padding: 34px 22px;
        z-index: 1000;
        overflow-y: auto;
        box-shadow: 18px 0 45px rgba(15, 23, 42, 0.16);
    }

    .admin-brand {
        padding: 0 10px 24px;
        border-bottom: 1px solid rgba(148, 163, 184, 0.22);
        margin-bottom: 24px;
    }

    .admin-brand h2 {
        margin: 0;
        font-size: 20px;
        font-weight: 950;
        color: #ffffff;
        letter-spacing: -0.4px;
    }

    .admin-brand p {
        margin: 6px 0 0;
        color: #bfdbfe;
        font-size: 13px;
        font-weight: 700;
    }

    .admin-menu-title {
        margin: 18px 0 12px;
        color: #93c5fd;
        font-size: 12px;
        font-weight: 950;
        letter-spacing: 3px;
    }

    .admin-nav {
        display: flex;
        flex-direction: column;
        gap: 9px;
        margin-bottom: 22px;
    }

    .admin-nav a {
        min-height: 46px;
        padding: 0 15px;
        border-radius: 15px;
        color: #e2e8f0;
        text-decoration: none;
        display: flex;
        align-items: center;
        font-size: 15px;
        font-weight: 900;
        border: 1px solid transparent;
        transition: 0.2s ease;
    }

    .admin-nav a:hover {
        background: rgba(51, 65, 85, 0.9);
        color: white;
        transform: translateX(4px);
    }

    .admin-nav a.active {
        background: rgba(51, 65, 85, 0.95);
        border-color: #38bdf8;
        color: #ffffff;
        box-shadow: inset 4px 0 0 #06b6d4;
    }

    @media (max-width: 900px) {
        .admin-sidebar {
            position: relative;
            width: 100%;
            height: auto;
            min-height: auto;
            padding: 18px;
        }

        .admin-nav {
            flex-direction: row;
            flex-wrap: wrap;
        }

        .admin-nav a {
            min-height: 40px;
        }
    }
</style>

<aside class="admin-sidebar">
    <div class="admin-brand">
        <h2>HUSC Admin</h2>
        <p>Library Management</p>
    </div>

    <div class="admin-menu-title">MAIN MENU</div>

    <nav class="admin-nav">
        <a class="<%= activeDashboard ? "active" : "" %>" href="<%= cp %>/admin/dashboard">Dashboard</a>
        <a class="<%= activeDocuments ? "active" : "" %>" href="<%= cp %>/admin/documents">Tài liệu</a>
        <a class="<%= activeExamBank ? "active" : "" %>" href="<%= cp %>/admin/exam-bank">Quản lý Kho đề</a>
        <a class="<%= activeEquipments ? "active" : "" %>" href="<%= cp %>/admin/equipments">Thiết bị</a>
        <a class="<%= activeBorrow ? "active" : "" %>" href="<%= cp %>/admin/borrow-requests">Yêu cầu mượn</a>
        <a class="<%= activeReturn ? "active" : "" %>" href="<%= cp %>/admin/return-equipment">Trả thiết bị</a>
        <a class="<%= activeMaintenance ? "active" : "" %>" href="<%= cp %>/admin/maintenance-records">Bảo trì</a>
        <a class="<%= activeUsers ? "active" : "" %>" href="<%= cp %>/admin/users">Người dùng</a>
        <a class="<%= activeReports ? "active" : "" %>" href="<%= cp %>/admin/reports">Báo cáo</a>
        <a class="<%= activeLogs ? "active" : "" %>" href="<%= cp %>/admin/system-logs">Nhật ký</a>
    </nav>

    <div class="admin-menu-title">SYSTEM</div>

    <nav class="admin-nav">
        <a href="<%= cp %>/index.jsp">Về trang chủ</a>
        <a href="<%= cp %>/logout">Đăng xuất</a>
    </nav>
</aside>
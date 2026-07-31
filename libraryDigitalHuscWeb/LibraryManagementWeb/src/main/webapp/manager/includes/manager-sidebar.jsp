<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    String cp = request.getContextPath();
    String uri = request.getRequestURI();

    boolean activeDashboard = uri.contains("/manager/dashboard");
    boolean activeEquipments = uri.contains("/manager/equipments");
    boolean activeBorrow = uri.contains("/manager/borrow-requests");
    boolean activeReturn = uri.contains("/manager/return-equipment");
    boolean activeMaintenance = uri.contains("/manager/maintenance-records");
    boolean activeReports = uri.contains("/manager/reports");
%>

<link rel="stylesheet" href="<%= cp %>/assets/css/manager/manager-layout.css?v=2">

<aside class="manager-sidebar">
    <div class="manager-brand">
        <strong>HUSC Manager</strong>
        <span>Operation Management</span>
    </div>

    <div class="manager-menu-title">MAIN MENU</div>

    <nav class="manager-nav">
        <a class="<%= activeDashboard ? "active" : "" %>" href="<%= cp %>/manager/dashboard">
            Dashboard
        </a>

        <a class="<%= activeEquipments ? "active" : "" %>" href="<%= cp %>/manager/equipments">
            Thiết bị
        </a>

        <a class="<%= activeBorrow ? "active" : "" %>" href="<%= cp %>/manager/borrow-requests">
            Yêu cầu mượn
        </a>

        <a class="<%= activeReturn ? "active" : "" %>" href="<%= cp %>/manager/return-equipment">
            Trả thiết bị
        </a>

        <a class="<%= activeMaintenance ? "active" : "" %>" href="<%= cp %>/manager/maintenance-records">
            Bảo trì
        </a>

        <a class="<%= activeReports ? "active" : "" %>" href="<%= cp %>/manager/reports">
            Báo cáo
        </a>
    </nav>

    <div class="manager-menu-title">SYSTEM</div>

    <nav class="manager-nav">
        <a href="<%= cp %>/index.jsp">Về trang chủ</a>
        <a href="<%= cp %>/logout">Đăng xuất</a>
    </nav>
</aside>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    String contextPath = request.getContextPath();

    Integer totalEquipments = (Integer) request.getAttribute("totalEquipments");
    Integer totalRequests = (Integer) request.getAttribute("totalRequests");
    Integer pendingRequests = (Integer) request.getAttribute("pendingRequests");
    Integer borrowingRequests = (Integer) request.getAttribute("borrowingRequests");

    if (totalEquipments == null) totalEquipments = 0;
    if (totalRequests == null) totalRequests = 0;
    if (pendingRequests == null) pendingRequests = 0;
    if (borrowingRequests == null) borrowingRequests = 0;
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Manager Dashboard - HUSC Digital Library</title>
</head>

<body>

<jsp:include page="/manager/includes/manager-sidebar.jsp" />

<main class="manager-main">
    <div class="manager-page">

        <section class="manager-topbar">
            <div>
                <h1>Manager Dashboard</h1>
                <p>Quản lý vận hành thiết bị, yêu cầu mượn trả và bảo trì.</p>
            </div>

            <div class="manager-actions">
                <a class="btn-light" href="<%= contextPath %>/index.jsp">Xem website</a>
                <a class="btn-primary" href="<%= contextPath %>/manager/borrow-requests">Xem yêu cầu</a>
            </div>
        </section>

        <section class="manager-grid-4">
            <div class="manager-card">
                <h3>Thiết bị</h3>
                <h2><%= totalEquipments %></h2>
            </div>

            <div class="manager-card">
                <h3>Tổng yêu cầu</h3>
                <h2><%= totalRequests %></h2>
            </div>

            <div class="manager-card">
                <h3>Chờ duyệt</h3>
                <h2><%= pendingRequests %></h2>
            </div>

            <div class="manager-card">
                <h3>Đang mượn</h3>
                <h2><%= borrowingRequests %></h2>
            </div>
        </section>

        <section style="margin-top: 26px;" class="manager-grid-2">
            <div class="manager-card">
                <h2>Chức năng được phép</h2>
                <p>Manager được xử lý yêu cầu mượn, trả thiết bị, cập nhật bảo trì và xem báo cáo vận hành.</p>
            </div>

            <div class="manager-card">
                <h2>Chức năng bị giới hạn</h2>
                <p>Manager không được quản lý người dùng, nhật ký hệ thống, kho đề, tài liệu và dữ liệu cấu hình quan trọng.</p>
            </div>
        </section>

    </div>
</main>

</body>
</html>
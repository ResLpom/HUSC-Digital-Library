<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    String contextPath = request.getContextPath();

    Integer totalEquipments = (Integer) request.getAttribute("totalEquipments");
    Integer totalRequests = (Integer) request.getAttribute("totalRequests");
    Integer pendingRequests = (Integer) request.getAttribute("pendingRequests");
    Integer approvedRequests = (Integer) request.getAttribute("approvedRequests");
    Integer rejectedRequests = (Integer) request.getAttribute("rejectedRequests");
    Integer returnedRequests = (Integer) request.getAttribute("returnedRequests");

    if (totalEquipments == null) totalEquipments = 0;
    if (totalRequests == null) totalRequests = 0;
    if (pendingRequests == null) pendingRequests = 0;
    if (approvedRequests == null) approvedRequests = 0;
    if (rejectedRequests == null) rejectedRequests = 0;
    if (returnedRequests == null) returnedRequests = 0;
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Manager - Báo cáo</title>
</head>

<body>

<jsp:include page="/manager/includes/manager-sidebar.jsp" />

<main class="manager-main">
    <div class="manager-page">

        <section class="manager-topbar">
            <div>
                <h1>Báo cáo vận hành</h1>
                <p>Manager chỉ xem báo cáo thiết bị, mượn trả và bảo trì. Không xem người dùng, nhật ký hoặc dữ liệu hệ thống.</p>
            </div>

            <div class="manager-actions">
                <a class="btn-light" href="<%= contextPath %>/manager/dashboard">Dashboard</a>
            </div>
        </section>

        <section class="manager-grid-4">
            <div class="manager-card">
                <h3>Tổng thiết bị</h3>
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
                <h3>Đã duyệt</h3>
                <h2><%= approvedRequests %></h2>
            </div>
        </section>

        <section style="margin-top: 26px;" class="manager-grid-2">
            <div class="manager-card">
                <h2>Trạng thái yêu cầu</h2>
                <p>Từ chối: <strong><%= rejectedRequests %></strong></p>
                <p>Đã trả: <strong><%= returnedRequests %></strong></p>
            </div>

            <div class="manager-card">
                <h2>Giới hạn báo cáo</h2>
                <p>Trang này không hiển thị báo cáo người dùng, nhật ký hệ thống, kho đề hoặc tài liệu.</p>
            </div>
        </section>

    </div>
</main>

</body>
</html>
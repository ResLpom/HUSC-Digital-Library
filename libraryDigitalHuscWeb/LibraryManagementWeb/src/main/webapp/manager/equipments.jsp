<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="vn.edu.husc.library.model.Equipment" %>

<%!
    private String h(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }

    private String statusText(String status) {
        if ("AVAILABLE".equalsIgnoreCase(status)) return "Sẵn sàng";
        if ("BORROWED".equalsIgnoreCase(status)) return "Đang mượn";
        if ("MAINTENANCE".equalsIgnoreCase(status)) return "Bảo trì";
        if ("BROKEN".equalsIgnoreCase(status)) return "Hỏng";
        if ("INACTIVE".equalsIgnoreCase(status)) return "Đã ẩn";
        return status == null || status.trim().isEmpty() ? "Không rõ" : status;
    }

    private String statusClass(String status) {
        if ("AVAILABLE".equalsIgnoreCase(status)) return "status-ok";
        if ("BORROWED".equalsIgnoreCase(status)) return "status-info";
        if ("MAINTENANCE".equalsIgnoreCase(status)) return "status-warning";
        if ("BROKEN".equalsIgnoreCase(status)) return "status-danger";
        return "status-info";
    }
%>

<%
    String contextPath = request.getContextPath();

    List<Equipment> equipments = (List<Equipment>) request.getAttribute("equipments");
    String keyword = (String) request.getAttribute("keyword");

    String success = (String) session.getAttribute("managerSuccess");
    String error = (String) session.getAttribute("managerError");

    session.removeAttribute("managerSuccess");
    session.removeAttribute("managerError");

    if (keyword == null) keyword = "";
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Manager - Thiết bị</title>
</head>

<body>

<jsp:include page="/manager/includes/manager-sidebar.jsp" />

<main class="manager-main">
    <div class="manager-page">

        <section class="manager-topbar">
            <div>
                <h1>Quản lý thiết bị</h1>
                <p>Manager được xem và cập nhật trạng thái vận hành thiết bị. Không được xóa thiết bị.</p>
            </div>

            <div class="manager-actions">
                <a class="btn-light" href="<%= contextPath %>/manager/dashboard">Dashboard</a>
            </div>
        </section>

        <% if (success != null) { %>
            <div class="manager-card" style="margin-bottom:18px; color:#166534; background:#dcfce7;">
                <strong><%= h(success) %></strong>
            </div>
        <% } %>

        <% if (error != null) { %>
            <div class="manager-card" style="margin-bottom:18px; color:#be123c; background:#ffe4e6;">
                <strong><%= h(error) %></strong>
            </div>
        <% } %>

        <section class="manager-card">
            <h2>Danh sách thiết bị</h2>
            <p>Theo dõi thiết bị, loại thiết bị và trạng thái vận hành.</p>

            <form method="get" action="<%= contextPath %>/manager/equipments"
                  style="display:flex; gap:10px; margin-bottom:18px;">
                <input type="text"
                       name="keyword"
                       value="<%= h(keyword) %>"
                       placeholder="Tìm thiết bị, mã, vị trí, trạng thái..."
                       style="flex:1; height:44px; border-radius:16px; border:1px solid #cbd5e1; padding:0 14px;">

                <button class="btn-primary" type="submit">Tìm kiếm</button>
            </form>

            <% if (equipments == null || equipments.isEmpty()) { %>

                <div class="empty-box">
                    Chưa có dữ liệu thiết bị.
                </div>

            <% } else { %>

                <div class="manager-table-wrap">
                    <table class="manager-table">
                        <thead>
                        <tr>
                            <th>Mã thiết bị</th>
                            <th>Tên thiết bị</th>
                            <th>Loại</th>
                            <th>Vị trí</th>
                            <th>Trạng thái</th>
                            <th>Thao tác</th>
                        </tr>
                        </thead>

                        <tbody>
                        <% for (Equipment e : equipments) {
                            int equipmentId = e.getEquipmentId();
                            String code = e.getCode();
                            String name = e.getEquipmentName();
                            String typeName = e.getTypeName();
                            String location = e.getLocation();
                            String status = e.getStatus();
                        %>
                            <tr>
                                <td><%= h(code) %></td>
                                <td><%= h(name) %></td>
                                <td><%= h(typeName) %></td>
                                <td><%= h(location) %></td>
                                <td>
                                    <span class="status-badge <%= statusClass(status) %>">
                                        <%= h(statusText(status)) %>
                                    </span>
                                </td>
                                <td>
                                    <form method="post"
                                          action="<%= contextPath %>/manager/equipments"
                                          style="display:flex; gap:8px; align-items:center; flex-wrap:wrap;">
                                        <input type="hidden" name="action" value="updateEquipmentStatus">
                                        <input type="hidden" name="equipmentId" value="<%= equipmentId %>">

                                        <select name="status"
                                                style="height:34px; border-radius:999px; border:1px solid #cbd5e1; padding:0 10px;">
                                            <option value="AVAILABLE" <%= "AVAILABLE".equalsIgnoreCase(status) ? "selected" : "" %>>
                                                Sẵn sàng
                                            </option>
                                            <option value="MAINTENANCE" <%= "MAINTENANCE".equalsIgnoreCase(status) ? "selected" : "" %>>
                                                Bảo trì
                                            </option>
                                            <option value="BROKEN" <%= "BROKEN".equalsIgnoreCase(status) ? "selected" : "" %>>
                                                Hỏng
                                            </option>
                                        </select>

                                        <button class="btn-primary" type="submit">
                                            Cập nhật
                                        </button>
                                    </form>
                                </td>
                            </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>

            <% } %>
        </section>

    </div>
</main>

</body>
</html>
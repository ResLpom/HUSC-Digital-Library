<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="vn.edu.husc.library.model.Equipment" %>
<%@ page import="vn.edu.husc.library.model.MaintenanceRecord" %>

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
        if ("IN_PROGRESS".equalsIgnoreCase(status)) return "Đang bảo trì";
        if ("COMPLETED".equalsIgnoreCase(status)) return "Hoàn tất";
        return status == null || status.trim().isEmpty() ? "Không rõ" : status;
    }

    private String statusClass(String status) {
        if ("IN_PROGRESS".equalsIgnoreCase(status)) return "status-warning";
        if ("COMPLETED".equalsIgnoreCase(status)) return "status-ok";
        return "status-info";
    }

    private String equipmentStatusText(String status) {
        if ("AVAILABLE".equalsIgnoreCase(status)) return "Sẵn sàng";
        if ("BORROWED".equalsIgnoreCase(status)) return "Đang mượn";
        if ("MAINTENANCE".equalsIgnoreCase(status)) return "Bảo trì";
        if ("BROKEN".equalsIgnoreCase(status)) return "Hỏng";
        return status == null || status.trim().isEmpty() ? "Không rõ" : status;
    }
%>

<%
    String contextPath = request.getContextPath();

    List<Equipment> equipments = (List<Equipment>) request.getAttribute("equipments");
    List<MaintenanceRecord> records = (List<MaintenanceRecord>) request.getAttribute("records");

    String success = (String) request.getAttribute("success");
    String error = (String) request.getAttribute("error");
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Manager - Bảo trì</title>
</head>

<body>

<jsp:include page="/manager/includes/manager-sidebar.jsp" />

<main class="manager-main">
    <div class="manager-page">

        <section class="manager-topbar">
            <div>
                <h1>Bảo trì thiết bị</h1>
                <p>Manager được thêm ghi nhận bảo trì và hoàn tất bảo trì. Không được xóa bản ghi.</p>
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

        <section class="manager-card" style="margin-bottom:24px;">
            <h2>Thêm ghi nhận bảo trì</h2>
            <p>Chọn thiết bị và nhập tình trạng cần bảo trì.</p>

            <form method="post" action="<%= contextPath %>/manager/maintenance-records">
                <input type="hidden" name="action" value="createMaintenance">

                <div style="display:grid; grid-template-columns: 1fr 1fr; gap:16px;">
                    <div>
                        <label style="display:block; font-weight:900; margin-bottom:8px;">Thiết bị</label>
                        <select name="equipmentId"
                                required
                                style="width:100%; height:44px; border-radius:16px; border:1px solid #cbd5e1; padding:0 12px;">
                            <option value="">-- Chọn thiết bị --</option>

                            <% if (equipments != null) {
                                for (Equipment e : equipments) {
                            %>
                                <option value="<%= e.getEquipmentId() %>">
                                    <%= h(e.getCode()) %> - <%= h(e.getEquipmentName()) %>
                                    (<%= h(equipmentStatusText(e.getStatus())) %>)
                                </option>
                            <%  }
                            } %>
                        </select>
                    </div>

                    <div>
                        <label style="display:block; font-weight:900; margin-bottom:8px;">Ghi chú quản lý</label>
                        <input type="text"
                               name="managerNote"
                               placeholder="Ví dụ: Đưa vào danh sách bảo trì tháng này"
                               style="width:100%; height:44px; border-radius:16px; border:1px solid #cbd5e1; padding:0 12px;">
                    </div>

                    <div style="grid-column:1 / -1;">
                        <label style="display:block; font-weight:900; margin-bottom:8px;">Tình trạng cần bảo trì</label>
                        <textarea name="issueDescription"
                                  required
                                  rows="4"
                                  placeholder="Ví dụ: Máy chiếu bị mờ, cần kiểm tra bóng đèn..."
                                  style="width:100%; border-radius:18px; border:1px solid #cbd5e1; padding:12px;"></textarea>
                    </div>
                </div>

                <div class="manager-actions" style="margin-top:18px;">
                    <button class="btn-primary" type="submit">
                        Thêm ghi nhận
                    </button>
                </div>
            </form>
        </section>

        <section class="manager-card">
            <h2>Lịch sử bảo trì</h2>
            <p>Manager được hoàn tất bản ghi bảo trì, không được xóa dữ liệu.</p>

            <% if (records == null || records.isEmpty()) { %>

                <div class="empty-box">
                    Chưa có bản ghi bảo trì nào.
                </div>

            <% } else { %>

                <div class="manager-table-wrap">
                    <table class="manager-table">
                        <thead>
                        <tr>
                            <th>Thiết bị</th>
                            <th>Loại</th>
                            <th>Tình trạng</th>
                            <th>Trạng thái</th>
                            <th>Ghi chú</th>
                            <th>Ngày ghi nhận</th>
                            <th>Thao tác</th>
                        </tr>
                        </thead>

                        <tbody>
                        <% for (MaintenanceRecord r : records) { %>
                            <tr>
                                <td>
                                    <strong><%= h(r.getEquipmentName()) %></strong><br>
                                    <span style="color:#64748b;"><%= h(r.getEquipmentCode()) %></span>
                                </td>
                                <td><%= h(r.getTypeName()) %></td>
                                <td><%= h(r.getIssueDescription()) %></td>
                                <td>
                                    <span class="status-badge <%= statusClass(r.getMaintenanceStatus()) %>">
                                        <%= h(statusText(r.getMaintenanceStatus())) %>
                                    </span>
                                </td>
                                <td><%= h(r.getManagerNote()) %></td>
                                <td><%= r.getCreatedAt() == null ? "" : r.getCreatedAt() %></td>
                                <td>
                                    <% if ("IN_PROGRESS".equalsIgnoreCase(r.getMaintenanceStatus())) { %>

                                        <form method="post"
                                              action="<%= contextPath %>/manager/maintenance-records"
                                              onsubmit="return confirm('Xác nhận đã hoàn tất bảo trì thiết bị này?');">
                                            <input type="hidden" name="action" value="completeMaintenance">
                                            <input type="hidden" name="maintenanceId" value="<%= r.getMaintenanceId() %>">
                                            <input type="hidden" name="managerNote" value="Manager đã hoàn tất bảo trì.">

                                            <button class="btn-primary" type="submit">
                                                Hoàn tất
                                            </button>
                                        </form>

                                    <% } else { %>

                                        <span class="status-badge status-ok">Đã hoàn tất</span>

                                    <% } %>
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
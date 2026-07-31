<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="vn.edu.husc.library.model.BorrowRequest" %>

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
        if ("APPROVED".equalsIgnoreCase(status)) return "Đã duyệt";
        if ("BORROWING".equalsIgnoreCase(status)) return "Đang mượn";
        if ("BORROWED".equalsIgnoreCase(status)) return "Đang mượn";
        return status == null || status.trim().isEmpty() ? "Không rõ" : status;
    }

    private String statusClass(String status) {
        if ("APPROVED".equalsIgnoreCase(status)) return "status-warning";
        if ("BORROWING".equalsIgnoreCase(status)) return "status-info";
        if ("BORROWED".equalsIgnoreCase(status)) return "status-info";
        return "status-info";
    }
%>

<%
    String contextPath = request.getContextPath();

    List<BorrowRequest> requests = (List<BorrowRequest>) request.getAttribute("requests");

    String success = (String) session.getAttribute("managerSuccess");
    String error = (String) session.getAttribute("managerError");

    session.removeAttribute("managerSuccess");
    session.removeAttribute("managerError");
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Manager - Trả thiết bị</title>
</head>

<body>

<jsp:include page="/manager/includes/manager-sidebar.jsp" />

<main class="manager-main">
    <div class="manager-page">

        <section class="manager-topbar">
            <div>
                <h1>Trả thiết bị</h1>
                <p>Manager xác nhận thiết bị đã được trả và cập nhật trạng thái thiết bị về sẵn sàng.</p>
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
            <h2>Danh sách thiết bị cần trả</h2>
            <p>Chỉ hiển thị các yêu cầu đã duyệt, đang mượn hoặc đã bàn giao.</p>

            <% if (requests == null || requests.isEmpty()) { %>

                <div class="empty-box">
                    Hiện không có thiết bị nào đang chờ xác nhận trả.
                </div>

            <% } else { %>

                <div class="manager-table-wrap">
                    <table class="manager-table">
                        <thead>
                        <tr>
                            <th>Người mượn</th>
                            <th>Thiết bị</th>
                            <th>Ngày mượn</th>
                            <th>Hạn trả</th>
                            <th>Trạng thái</th>
                            <th>Thao tác</th>
                        </tr>
                        </thead>

                        <tbody>
                        <% for (BorrowRequest r : requests) {
                            int requestId = r.getRequestId();
                            String userName = r.getFullName();
                            String equipmentName = r.getEquipmentName();
                            String equipmentCode = r.getEquipmentCode();
                            String borrowDate = r.getBorrowDate() == null ? "" : String.valueOf(r.getBorrowDate());
                            String expectedReturnDate = r.getExpectedReturnDate() == null ? "" : String.valueOf(r.getExpectedReturnDate());
                            String status = r.getStatus();
                        %>
                            <tr>
                                <td><%= h(userName) %></td>
                                <td>
                                    <strong><%= h(equipmentName) %></strong><br>
                                    <span style="color:#64748b;"><%= h(equipmentCode) %></span>
                                </td>
                                <td><%= h(borrowDate) %></td>
                                <td><%= h(expectedReturnDate) %></td>
                                <td>
                                    <span class="status-badge <%= statusClass(status) %>">
                                        <%= h(statusText(status)) %>
                                    </span>
                                </td>
                                <td>
                                    <% if ("BORROWING".equalsIgnoreCase(status) || "BORROWED".equalsIgnoreCase(status)) { %>

                                        <form method="post"
                                              action="<%= contextPath %>/manager/return-equipment"
                                              onsubmit="return confirm('Xác nhận thiết bị đã được trả?');">
                                            <input type="hidden" name="action" value="return">
                                            <input type="hidden" name="requestId" value="<%= requestId %>">
                                            <input type="hidden" name="managerNote" value="Manager đã xác nhận trả thiết bị.">

                                            <button class="btn-primary" type="submit">
                                                Xác nhận trả
                                            </button>
                                        </form>

                                    <% } else { %>

                                        <span class="status-badge status-warning">
                                            Chưa bàn giao
                                        </span>

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
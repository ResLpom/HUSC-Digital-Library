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
        if ("PENDING".equalsIgnoreCase(status)) return "Chờ duyệt";
        if ("APPROVED".equalsIgnoreCase(status)) return "Đã duyệt";
        if ("REJECTED".equalsIgnoreCase(status)) return "Từ chối";
        if ("BORROWING".equalsIgnoreCase(status)) return "Đang mượn";
        if ("BORROWED".equalsIgnoreCase(status)) return "Đang mượn";
        if ("RETURNED".equalsIgnoreCase(status)) return "Đã trả";
        return status == null || status.trim().isEmpty() ? "Không rõ" : status;
    }

    private String statusClass(String status) {
        if ("PENDING".equalsIgnoreCase(status)) return "status-warning";
        if ("APPROVED".equalsIgnoreCase(status)) return "status-info";
        if ("REJECTED".equalsIgnoreCase(status)) return "status-danger";
        if ("BORROWING".equalsIgnoreCase(status)) return "status-info";
        if ("BORROWED".equalsIgnoreCase(status)) return "status-info";
        if ("RETURNED".equalsIgnoreCase(status)) return "status-ok";
        return "status-info";
    }
%>

<%
    String contextPath = request.getContextPath();

    List<BorrowRequest> requests = (List<BorrowRequest>) request.getAttribute("requests");
    if (requests == null) {
        requests = (List<BorrowRequest>) request.getAttribute("borrowRequests");
    }

    String success = (String) request.getAttribute("success");
    String error = (String) request.getAttribute("error");
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Manager - Yêu cầu mượn</title>
</head>

<body>

<jsp:include page="/manager/includes/manager-sidebar.jsp" />

<main class="manager-main">
    <div class="manager-page">

        <section class="manager-topbar">
            <div>
                <h1>Yêu cầu mượn thiết bị</h1>
                <p>Manager được theo dõi, duyệt, từ chối hoặc bàn giao thiết bị cho yêu cầu đã duyệt.</p>
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
            <h2>Danh sách yêu cầu</h2>
            <p>Danh sách các yêu cầu mượn thiết bị trong hệ thống.</p>

            <% if (requests == null || requests.isEmpty()) { %>

                <div class="empty-box">
                    Chưa có yêu cầu mượn thiết bị.
                </div>

            <% } else { %>

                <div class="manager-table-wrap">
                    <table class="manager-table">
                        <thead>
                        <tr>
                            <th>Người mượn</th>
                            <th>Thiết bị</th>
                            <th>Ngày mượn</th>
                            <th>Ngày trả dự kiến</th>
                            <th>Mục đích</th>
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
                            String purpose = r.getPurpose();
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
                                <td><%= h(purpose) %></td>
                                <td>
                                    <span class="status-badge <%= statusClass(status) %>">
                                        <%= h(statusText(status)) %>
                                    </span>
                                </td>
                                <td>
                                    <% if ("PENDING".equalsIgnoreCase(status)) { %>

                                        <form method="post"
                                              action="<%= contextPath %>/manager/borrow-requests"
                                              style="display:inline-flex; gap:8px; flex-wrap:wrap;">
                                            <input type="hidden" name="requestId" value="<%= requestId %>">

                                            <button class="btn-primary"
                                                    type="submit"
                                                    name="action"
                                                    value="approve">
                                                Duyệt
                                            </button>

                                            <button class="btn-danger"
                                                    type="submit"
                                                    name="action"
                                                    value="reject"
                                                    onclick="return confirm('Bạn có chắc muốn từ chối yêu cầu này không?');">
                                                Từ chối
                                            </button>
                                        </form>

                                    <% } else if ("APPROVED".equalsIgnoreCase(status)) { %>

                                        <form method="post"
                                              action="<%= contextPath %>/manager/borrow-requests"
                                              onsubmit="return confirm('Xác nhận bàn giao thiết bị cho người mượn?');">
                                            <input type="hidden" name="requestId" value="<%= requestId %>">

                                            <button class="btn-primary"
                                                    type="submit"
                                                    name="action"
                                                    value="handover">
                                                Bàn giao
                                            </button>
                                        </form>

                                    <% } else { %>

                                        <span class="status-badge status-info">
                                            Đã xử lý
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
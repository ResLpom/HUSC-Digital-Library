<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.lang.reflect.Method" %>

<%!
    private Object call(Object object, String methodName) {
        if (object == null) return null;

        try {
            Method method = object.getClass().getMethod(methodName);
            return method.invoke(object);
        } catch (Exception e) {
            return null;
        }
    }

    private String getText(Object object, String defaultValue, String... methods) {
        if (object == null) return defaultValue;

        for (String method : methods) {
            Object value = call(object, method);

            if (value != null && !String.valueOf(value).trim().isEmpty()) {
                return String.valueOf(value);
            }
        }

        return defaultValue;
    }

    private int getInt(Object object, String... methods) {
        if (object == null) return 0;

        for (String method : methods) {
            Object value = call(object, method);

            if (value != null) {
                try {
                    return Integer.parseInt(String.valueOf(value));
                } catch (Exception ignored) {
                }
            }
        }

        return 0;
    }

    private String h(String value) {
        if (value == null) return "";

        return value.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }

    private String statusText(String status) {
        if ("ACTIVE".equalsIgnoreCase(status)) return "Đang hoạt động";
        if ("LOCKED".equalsIgnoreCase(status)) return "Đã khóa";
        if ("PENDING".equalsIgnoreCase(status)) return "Chờ duyệt";
        if ("REJECTED".equalsIgnoreCase(status)) return "Từ chối";
        if ("DELETED".equalsIgnoreCase(status)) return "Đã xóa";
        if ("INACTIVE".equalsIgnoreCase(status)) return "Ngừng hoạt động";

        return status == null || status.trim().isEmpty() ? "Chưa rõ" : status;
    }

    private String statusClass(String status) {
        if ("ACTIVE".equalsIgnoreCase(status)) return "active";
        if ("LOCKED".equalsIgnoreCase(status)) return "locked";
        if ("PENDING".equalsIgnoreCase(status)) return "pending";
        if ("REJECTED".equalsIgnoreCase(status)) return "rejected";
        if ("DELETED".equalsIgnoreCase(status)) return "deleted";
        if ("INACTIVE".equalsIgnoreCase(status)) return "deleted";

        return "neutral";
    }
%>

<%
    String contextPath = request.getContextPath();

    List<?> users = (List<?>) request.getAttribute("users");

    String success = (String) request.getAttribute("success");
    String error = (String) request.getAttribute("error");

    Integer pendingRegistrationCountObj =
            (Integer) request.getAttribute("pendingRegistrationCount");

    int pendingRegistrationCount =
            pendingRegistrationCountObj == null ? 0 : pendingRegistrationCountObj;
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản lý người dùng - Admin</title>

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            font-family: "Segoe UI", Arial, sans-serif;
            background: linear-gradient(135deg, #e0f2fe, #eef2ff);
            color: #0f172a;
        }

        .admin-main {
            min-height: 100vh;
            margin-left: 280px;
            padding: 36px 44px 70px;
        }

        .page {
            max-width: 1240px;
            margin: 0 auto;
        }

        .topbar,
        .card,
        .notification-box {
            background: white;
            border-radius: 28px;
            border: 1px solid #dbeafe;
            box-shadow: 0 24px 60px rgba(15, 23, 42, 0.08);
        }

        .topbar {
            padding: 24px 28px;
            margin-bottom: 22px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 18px;
        }

        .topbar h1 {
            margin: 0;
            font-size: 32px;
            font-weight: 800;
            letter-spacing: -0.04em;
        }

        .topbar p {
            margin: 8px 0 0;
            color: #475569;
            font-weight: 500;
        }

        .btn {
            min-height: 42px;
            padding: 0 16px;
            border-radius: 999px;
            text-decoration: none;
            border: none;
            cursor: pointer;
            font-family: inherit;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-weight: 800;
            font-size: 13px;
            white-space: nowrap;
        }

        .btn.primary {
            color: white;
            background: linear-gradient(135deg, #0284c7, #06b6d4);
        }

        .btn.info {
            color: #0369a1;
            background: #e0f2fe;
            border: 1px solid #bae6fd;
        }

        .btn.warning {
            color: #92400e;
            background: #fef3c7;
            border: 1px solid #fde68a;
        }

        .btn.danger {
            color: #be123c;
            background: #ffe4e6;
            border: 1px solid #fecdd3;
        }

        .btn.success {
            color: #166534;
            background: #dcfce7;
            border: 1px solid #bbf7d0;
        }

        .notification-box {
            margin-bottom: 22px;
            padding: 18px 22px;
            background: #fff7ed;
            border-color: #fed7aa;
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 16px;
            color: #c2410c;
            font-weight: 900;
        }

        .notification-box strong {
            display: block;
            font-size: 16px;
            margin-bottom: 4px;
        }

        .notification-box span {
            display: block;
            color: #9a3412;
            font-size: 13px;
            font-weight: 700;
        }

        .alert-success,
        .alert-error {
            margin-bottom: 18px;
            padding: 14px 16px;
            border-radius: 18px;
            font-weight: 800;
        }

        .alert-success {
            background: #dcfce7;
            color: #166534;
            border: 1px solid #bbf7d0;
        }

        .alert-error {
            background: #ffe4e6;
            color: #be123c;
            border: 1px solid #fecdd3;
        }

        .card {
            padding: 24px;
            overflow-x: auto;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            min-width: 900px;
        }

        th {
            text-align: left;
            padding: 14px 12px;
            color: #64748b;
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: 0.08em;
            border-bottom: 1px solid #e2e8f0;
        }

        td {
            padding: 16px 12px;
            border-bottom: 1px solid #f1f5f9;
            vertical-align: middle;
            color: #0f172a;
            font-weight: 600;
        }

        .user-cell {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .avatar {
            width: 46px;
            height: 46px;
            border-radius: 16px;
            background: linear-gradient(135deg, #0284c7, #06b6d4);
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 900;
            flex-shrink: 0;
        }

        .user-cell strong {
            display: block;
            font-weight: 900;
            margin-bottom: 4px;
        }

        .user-cell span {
            display: block;
            color: #64748b;
            font-size: 13px;
            font-weight: 600;
        }

        .status-pill {
            min-height: 32px;
            padding: 0 12px;
            border-radius: 999px;
            display: inline-flex;
            align-items: center;
            font-size: 12px;
            font-weight: 900;
        }

        .status-pill.active {
            background: #dcfce7;
            color: #166534;
            border: 1px solid #bbf7d0;
        }

        .status-pill.locked {
            background: #fef3c7;
            color: #92400e;
            border: 1px solid #fde68a;
        }

        .status-pill.pending {
            background: #e0f2fe;
            color: #0369a1;
            border: 1px solid #bae6fd;
        }

        .status-pill.rejected {
            background: #ffe4e6;
            color: #be123c;
            border: 1px solid #fecdd3;
        }

        .status-pill.deleted,
        .status-pill.neutral {
            background: #f1f5f9;
            color: #475569;
            border: 1px solid #e2e8f0;
        }

        .actions {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
        }

        .empty-box {
            padding: 44px 20px;
            text-align: center;
            color: #64748b;
            font-weight: 800;
        }

        @media (max-width: 900px) {
            .admin-main {
                margin-left: 0;
                padding: 24px 16px 60px;
            }

            .topbar,
            .notification-box {
                flex-direction: column;
                align-items: flex-start;
            }
        }
    </style>
</head>

<body>

<jsp:include page="/admin/includes/admin-sidebar.jsp" />

<main class="admin-main">
    <div class="page">

        <section class="topbar">
            <div>
                <h1>Quản lý người dùng</h1>
                <p>Quản lý tài khoản sinh viên, quản lý và quản trị viên trong hệ thống.</p>
            </div>

            <div style="display:flex; gap:12px; flex-wrap:wrap;">
    <a class="btn info" href="<%= contextPath %>/admin/registrations">
        Duyệt thành viên mới
        <% if (pendingRegistrationCount > 0) { %>
            (<%= pendingRegistrationCount %>)
        <% } %>
    </a>

    <a class="btn primary" href="<%= contextPath %>/admin/users?action=add">
        + Thêm người dùng
    </a>
</div>
        </section>

        <% if (pendingRegistrationCount > 0) { %>
            <div class="notification-box">
                <div>
                    <strong>🔔 Có <%= pendingRegistrationCount %> tài khoản sinh viên mới</strong>
                    <span>Các tài khoản này đang chờ admin xác thực thông tin sinh viên.</span>
                </div>

                <a class="btn primary" href="<%= contextPath %>/admin/registrations">
                    Xem đăng ký
                </a>
            </div>
        <% } %>

        <% if (success != null && !success.trim().isEmpty()) { %>
            <div class="alert-success"><%= h(success) %></div>
        <% } %>

        <% if (error != null && !error.trim().isEmpty()) { %>
            <div class="alert-error"><%= h(error) %></div>
        <% } %>

        <section class="card">

            <% if (users == null || users.isEmpty()) { %>

                <div class="empty-box">
                    Chưa có người dùng nào trong hệ thống.
                </div>

            <% } else { %>

                <table>
                    <thead>
                    <tr>
                        <th>Người dùng</th>
                        <th>Email</th>
                        <th>Vai trò</th>
                        <th>Trạng thái</th>
                        <th>Thao tác</th>
                    </tr>
                    </thead>

                    <tbody>
                    <% for (Object user : users) {
                        int userId = getInt(user, "getUserId", "getId");

                        String fullName = getText(user, "Chưa cập nhật", "getFullName", "getName");
                        String username = getText(user, "", "getUsername", "getStudentCode", "getMaSinhVien");
                        String email = getText(user, "Chưa cập nhật", "getEmail");
                        String roleName = getText(user, "Thành viên", "getRoleName", "getRoleCode");
                        String status = getText(user, "ACTIVE", "getStatus");

                        String avatarText = fullName.trim().isEmpty() ? "U" : fullName.substring(0, 1).toUpperCase();
                    %>

                        <tr>
                            <td>
                                <div class="user-cell">
                                    <div class="avatar">
                                        <%= h(avatarText) %>
                                    </div>

                                    <div>
                                        <strong><%= h(fullName) %></strong>
                                        <span><%= h(username) %></span>
                                    </div>
                                </div>
                            </td>

                            <td><%= h(email) %></td>

                            <td><%= h(roleName) %></td>

                            <td>
                                <span class="status-pill <%= statusClass(status) %>">
                                    <%= h(statusText(status)) %>
                                </span>
                            </td>

                            <td>
                                <div class="actions">
                                    <a class="btn info"
                                       href="<%= contextPath %>/admin/users?action=edit&id=<%= userId %>">
                                        Sửa
                                    </a>

                                    <% if ("LOCKED".equalsIgnoreCase(status)) { %>
                                        <a class="btn success"
                                           href="<%= contextPath %>/admin/users?action=unlock&id=<%= userId %>"
                                           onclick="return confirm('Mở khóa tài khoản này?');">
                                            Mở khóa
                                        </a>
                                    <% } else { %>
                                        <a class="btn warning"
                                           href="<%= contextPath %>/admin/users?action=lock&id=<%= userId %>"
                                           onclick="return confirm('Khóa tài khoản này?');">
                                            Khóa
                                        </a>
                                    <% } %>

                                    <a class="btn danger"
                                       href="<%= contextPath %>/admin/users?action=delete&id=<%= userId %>"
                                       onclick="return confirm('Xóa tài khoản này khỏi danh sách?');">
                                        Xóa
                                    </a>
                                </div>
                            </td>
                        </tr>

                    <% } %>
                    </tbody>
                </table>

            <% } %>

        </section>

    </div>
</main>

</body>
</html>
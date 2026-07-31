<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="vn.edu.husc.library.model.OptionItem" %>
<%@ page import="vn.edu.husc.library.model.User" %>

<%!
    private String h(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
%>

<%
    String contextPath = request.getContextPath();

    String mode = (String) request.getAttribute("mode");
    if (mode == null) mode = "create";

    boolean editMode = "edit".equalsIgnoreCase(mode);

    User userEdit = (User) request.getAttribute("userEdit");
    List<OptionItem> roles = (List<OptionItem>) request.getAttribute("roles");

    String error = (String) session.getAttribute("adminUserError");
    session.removeAttribute("adminUserError");

    String pageTitle = editMode ? "Sửa người dùng" : "Thêm người dùng";
    String formAction = editMode ? "update" : "create";

    String username = editMode && userEdit != null ? userEdit.getUsername() : "";
    String fullName = editMode && userEdit != null ? userEdit.getFullName() : "";
    String email = editMode && userEdit != null ? userEdit.getEmail() : "";
    String phone = editMode && userEdit != null ? userEdit.getPhone() : "";
    String status = editMode && userEdit != null ? userEdit.getStatus() : "ACTIVE";
    int selectedRoleId = editMode && userEdit != null ? userEdit.getRoleId() : 0;
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title><%= pageTitle %> - HUSC Digital Library</title>

    <link rel="stylesheet" href="<%= contextPath %>/assets/css/admin-layout.css?v=user-form-edit-1">

    <style>
        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #e0f2fe, #eef2ff);
            color: #0f172a;
        }

        .admin-main {
            min-height: 100vh;
            margin-left: 270px;
            padding: 44px 48px;
        }

        .admin-page {
            max-width: 980px;
            margin: 0 auto;
        }

        .admin-topbar,
        .admin-card {
            background: white;
            border-radius: 28px;
            border: 1px solid #dbeafe;
            box-shadow: 0 20px 50px rgba(15, 23, 42, 0.08);
        }

        .admin-topbar {
            padding: 22px 26px;
            margin-bottom: 24px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .admin-card {
            padding: 26px;
        }

        .admin-topbar h1,
        .admin-card h2 {
            margin: 0;
            font-size: 30px;
            font-weight: 950;
        }

        .admin-topbar p,
        .admin-card p {
            color: #475569;
            font-weight: 700;
        }

        .form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 18px;
        }

        label {
            font-weight: 900;
        }

        input,
        select {
            width: 100%;
            height: 46px;
            margin-top: 8px;
            border-radius: 16px;
            border: 1px solid #cbd5e1;
            padding: 0 14px;
            font-weight: 700;
        }

        .admin-actions {
            display: flex;
            gap: 10px;
            margin-top: 22px;
        }

        .btn-primary,
        .btn-light {
            min-height: 42px;
            border: none;
            border-radius: 999px;
            padding: 0 18px;
            font-weight: 900;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
        }

        .btn-primary {
            color: white;
            background: linear-gradient(135deg, #0284c7, #06b6d4);
        }

        .btn-light {
            color: #0369a1;
            background: #e0f2fe;
            border: 1px solid #bae6fd;
        }

        .alert-error {
            margin-bottom: 18px;
            padding: 14px 18px;
            border-radius: 18px;
            color: #be123c;
            background: #ffe4e6;
            border: 1px solid #fecdd3;
            font-weight: 900;
        }

        @media (max-width: 900px) {
            .admin-main {
                margin-left: 0;
                padding: 24px 16px;
            }

            .form-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>

<body>

<jsp:include page="/admin/includes/admin-sidebar.jsp" />

<main class="admin-main">
    <div class="admin-page">

        <section class="admin-topbar">
            <div>
                <h1><%= pageTitle %></h1>
                <p><%= editMode ? "Cập nhật thông tin tài khoản người dùng." : "Tạo tài khoản mới cho ADMIN, MANAGER hoặc MEMBER." %></p>
            </div>

            <div>
                <a class="btn-light" href="<%= contextPath %>/admin/users">Quay lại</a>
            </div>
        </section>

        <% if (error != null) { %>
            <div class="alert-error">
                <%= h(error) %>
            </div>
        <% } %>

        <section class="admin-card">
            <h2>Thông tin tài khoản</h2>
            <p>
                <% if (editMode) { %>
                    Để trống mật khẩu nếu không muốn đổi mật khẩu.
                <% } else { %>
                    Nhập đầy đủ thông tin để tạo tài khoản mới.
                <% } %>
            </p>

            <form method="post" action="<%= contextPath %>/admin/users">
                <input type="hidden" name="action" value="<%= formAction %>">

                <% if (editMode && userEdit != null) { %>
                    <input type="hidden" name="userId" value="<%= userEdit.getUserId() %>">
                <% } %>

                <div class="form-grid">
                    <div>
                        <label>Tên đăng nhập</label>
                        <input name="username"
                               required
                               value="<%= h(username) %>"
                               placeholder="Ví dụ: nguyenvana">
                    </div>

                    <div>
                        <label>Mật khẩu</label>
                        <input name="password"
                               type="password"
                               <%= editMode ? "" : "required" %>
                               placeholder="<%= editMode ? "Để trống nếu không đổi" : "Nhập mật khẩu" %>">
                    </div>

                    <div>
                        <label>Họ tên</label>
                        <input name="fullName"
                               required
                               value="<%= h(fullName) %>"
                               placeholder="Ví dụ: Nguyễn Văn A">
                    </div>

                    <div>
                        <label>Email</label>
                        <input name="email"
                               type="email"
                               required
                               value="<%= h(email) %>"
                               placeholder="example@husc.edu.vn">
                    </div>

                    <div>
                        <label>Số điện thoại</label>
                        <input name="phone"
                               value="<%= h(phone) %>"
                               placeholder="Ví dụ: 0900000000">
                    </div>

                    <div>
                        <label>Vai trò</label>
                        <select name="roleId" required>
    <option value="">-- Chọn vai trò --</option>

    <% if (roles != null) {
        for (OptionItem role : roles) {
    %>
        <option value="<%= role.getId() %>"
            <%= selectedRoleId == role.getId() ? "selected" : "" %>>
            <%= role.getName() %>
        </option>
    <% 
        }
    } 
    %>
</select>
                    </div>

                    <% if (editMode) { %>
                        <div>
                            <label>Trạng thái</label>
                            <select name="status" required>
                                <option value="ACTIVE" <%= "ACTIVE".equalsIgnoreCase(status) ? "selected" : "" %>>Đang hoạt động</option>
                                <option value="LOCKED" <%= "LOCKED".equalsIgnoreCase(status) ? "selected" : "" %>>Đã khóa</option>
                            </select>
                        </div>
                    <% } else { %>
                        <input type="hidden" name="status" value="ACTIVE">
                    <% } %>
                </div>

                <div class="admin-actions">
                    <button class="btn-primary" type="submit">
                        <%= editMode ? "Cập nhật" : "Tạo tài khoản" %>
                    </button>

                    <a class="btn-light" href="<%= contextPath %>/admin/users">
                        Hủy
                    </a>
                </div>
            </form>
        </section>

    </div>
</main>

</body>
</html>
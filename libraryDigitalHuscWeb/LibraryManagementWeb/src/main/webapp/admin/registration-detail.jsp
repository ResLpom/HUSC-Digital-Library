<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="vn.edu.husc.library.model.RegistrationRequest" %>

<%
    String contextPath = request.getContextPath();
    RegistrationRequest r = (RegistrationRequest) request.getAttribute("registration");
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Chi tiết đăng ký - Admin</title>

    <style>
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
            max-width: 1000px;
            margin: 0 auto;
        }

        .card {
            background: white;
            border-radius: 28px;
            padding: 30px;
            border: 1px solid #dbeafe;
            box-shadow: 0 24px 60px rgba(15, 23, 42, 0.08);
        }

        h1 {
            margin: 0 0 8px;
            font-size: 32px;
            font-weight: 800;
        }

        .desc {
            margin: 0 0 24px;
            color: #475569;
            font-weight: 500;
            line-height: 1.6;
        }

        .grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 14px;
        }

        .item {
            padding: 16px;
            border-radius: 18px;
            background: #f8fafc;
            border: 1px solid #e2e8f0;
        }

        .item.full {
            grid-column: 1 / -1;
        }

        .item span {
            display: block;
            color: #64748b;
            font-size: 13px;
            font-weight: 700;
            margin-bottom: 6px;
        }

        .item strong {
            display: block;
            font-size: 15px;
            font-weight: 700;
            line-height: 1.5;
        }

        .actions {
            margin-top: 24px;
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }

        .btn {
            min-height: 42px;
            padding: 0 16px;
            border-radius: 999px;
            border: none;
            text-decoration: none;
            cursor: pointer;
            font-family: inherit;
            font-weight: 800;
            display: inline-flex;
            align-items: center;
            justify-content: center;
        }

        .btn.back {
            color: #0369a1;
            background: #e0f2fe;
            border: 1px solid #bae6fd;
        }

        .btn.approve {
            color: #166534;
            background: #dcfce7;
            border: 1px solid #bbf7d0;
        }

        .btn.reject {
            color: #be123c;
            background: #ffe4e6;
            border: 1px solid #fecdd3;
        }

        .reject-box {
            margin-top: 20px;
            padding: 18px;
            border-radius: 20px;
            background: #fff1f2;
            border: 1px solid #fecdd3;
        }

        .reject-box textarea {
            width: 100%;
            min-height: 90px;
            padding: 12px;
            border-radius: 14px;
            border: 1px solid #fecdd3;
            font-family: inherit;
            resize: vertical;
            box-sizing: border-box;
        }
    </style>
</head>

<body>

<jsp:include page="/admin/includes/admin-sidebar.jsp" />

<main class="admin-main">
    <div class="page">

        <section class="card">

            <% if (r == null) { %>

                <h1>Không tìm thấy đăng ký</h1>

                <div class="actions">
                    <a class="btn back" href="<%= contextPath %>/admin/registrations">Quay lại</a>
                </div>

            <% } else { %>

                <h1><%= r.getFullName() %></h1>

                <p class="desc">
                    Kiểm tra thông tin sinh viên trước khi duyệt tài khoản sử dụng hệ thống.
                </p>

                <div class="grid">
                    <div class="item">
                        <span>Mã người dùng</span>
                        <strong>#<%= r.getUserId() %></strong>
                    </div>

                    <div class="item">
                        <span>Trạng thái</span>
                        <strong><%= r.getStatusText() %></strong>
                    </div>

                    <div class="item">
                        <span>Họ tên</span>
                        <strong><%= r.getFullName() %></strong>
                    </div>

                    <div class="item">
                        <span>Mã sinh viên</span>
                        <strong><%= r.getStudentCode() %></strong>
                    </div>

                    <div class="item">
                        <span>Email HUSC</span>
                        <strong><%= r.getEmail() %></strong>
                    </div>

                    <div class="item">
                        <span>Số điện thoại</span>
                        <strong><%= r.getPhone() == null ? "Chưa nhập" : r.getPhone() %></strong>
                    </div>

                    <div class="item full">
                        <span>Địa chỉ</span>
                        <strong><%= r.getAddress() == null ? "Chưa nhập" : r.getAddress() %></strong>
                    </div>

                    <div class="item full">
                        <span>Ghi chú đăng ký</span>
                        <strong><%= r.getRegistrationNote() == null ? "Không có ghi chú" : r.getRegistrationNote() %></strong>
                    </div>

                    <div class="item">
                        <span>Ngày đăng ký</span>
                        <strong><%= r.getCreatedAt() %></strong>
                    </div>

                    <div class="item">
                        <span>Ngày xác thực</span>
                        <strong><%= r.getVerifiedAt() == null ? "Chưa xác thực" : r.getVerifiedAt() %></strong>
                    </div>

                    <% if (r.getRejectReason() != null && !r.getRejectReason().trim().isEmpty()) { %>
                        <div class="item full">
                            <span>Lý do từ chối</span>
                            <strong><%= r.getRejectReason() %></strong>
                        </div>
                    <% } %>
                </div>

                <div class="actions">
                    <a class="btn back" href="<%= contextPath %>/admin/registrations">
                        Quay lại
                    </a>

                    <% if ("PENDING".equalsIgnoreCase(r.getStatus())) { %>
                        <form method="post" action="<%= contextPath %>/admin/registrations">
                            <input type="hidden" name="action" value="approve">
                            <input type="hidden" name="id" value="<%= r.getUserId() %>">

                            <button class="btn approve" type="submit"
                                    onclick="return confirm('Duyệt tài khoản sinh viên này?');">
                                Duyệt tài khoản
                            </button>
                        </form>
                    <% } %>
                </div>

                <% if ("PENDING".equalsIgnoreCase(r.getStatus())) { %>
                    <form class="reject-box" method="post" action="<%= contextPath %>/admin/registrations">
                        <input type="hidden" name="action" value="reject">
                        <input type="hidden" name="id" value="<%= r.getUserId() %>">

                        <textarea name="rejectReason"
                                  required
                                  placeholder="Nhập lý do từ chối nếu thông tin không đúng..."></textarea>

                        <div class="actions">
                            <button class="btn reject" type="submit"
                                    onclick="return confirm('Từ chối tài khoản này?');">
                                Từ chối tài khoản
                            </button>
                        </div>
                    </form>
                <% } %>

            <% } %>

        </section>

    </div>
</main>

</body>
</html>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="vn.edu.husc.library.model.RegistrationRequest" %>

<%
    String contextPath = request.getContextPath();

    List<RegistrationRequest> pendingRequests =
            (List<RegistrationRequest>) request.getAttribute("pendingRequests");

    List<RegistrationRequest> recentRequests =
            (List<RegistrationRequest>) request.getAttribute("recentRequests");

    String success = (String) request.getAttribute("success");
    String error = (String) request.getAttribute("error");

    int pendingCount = pendingRequests == null ? 0 : pendingRequests.size();
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Duyệt đăng ký - Admin</title>

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
            max-width: 1200px;
            margin: 0 auto;
        }

        .topbar,
        .card {
            background: white;
            border-radius: 28px;
            border: 1px solid #dbeafe;
            box-shadow: 0 24px 60px rgba(15, 23, 42, 0.08);
        }

        .topbar {
            padding: 24px 28px;
            margin-bottom: 24px;
            display: flex;
            justify-content: space-between;
            gap: 18px;
            align-items: center;
        }

        .topbar h1 {
            margin: 0;
            font-size: 32px;
            font-weight: 800;
        }

        .topbar p {
            margin: 8px 0 0;
            color: #475569;
            font-weight: 500;
            line-height: 1.6;
        }

        .notification-pill {
            min-height: 48px;
            padding: 0 20px;
            border-radius: 999px;
            display: inline-flex;
            align-items: center;
            gap: 10px;
            background: #fff7ed;
            color: #c2410c;
            font-weight: 800;
            border: 1px solid #fed7aa;
            white-space: nowrap;
        }

        .alert-success,
        .alert-error {
            margin-bottom: 20px;
            padding: 14px 16px;
            border-radius: 18px;
            font-weight: 800;
            line-height: 1.5;
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

        .section-title {
            margin: 28px 0 16px;
            font-size: 24px;
            font-weight: 800;
        }

        .grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 18px;
        }

        .card {
            padding: 22px;
        }

        .card-head {
            display: flex;
            justify-content: space-between;
            gap: 14px;
            align-items: flex-start;
            margin-bottom: 16px;
        }

        .student-info {
            display: flex;
            gap: 14px;
            min-width: 0;
        }

        .avatar {
            width: 58px;
            height: 58px;
            border-radius: 20px;
            background: linear-gradient(135deg, #0284c7, #06b6d4);
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 26px;
            font-weight: 900;
            flex-shrink: 0;
        }

        .card h3 {
            margin: 0 0 6px;
            font-size: 20px;
            font-weight: 800;
            line-height: 1.35;
        }

        .card p {
            margin: 4px 0;
            color: #475569;
            font-weight: 500;
            line-height: 1.55;
            word-break: break-word;
        }

        .status {
            padding: 7px 12px;
            border-radius: 999px;
            font-size: 12px;
            font-weight: 800;
            white-space: nowrap;
        }

        .status.pending {
            background: #fef3c7;
            color: #92400e;
            border: 1px solid #fde68a;
        }

        .info-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 10px;
            margin: 16px 0;
        }

        .info-item {
            padding: 12px;
            border-radius: 16px;
            background: #f8fafc;
            border: 1px solid #e2e8f0;
        }

        .info-item span {
            display: block;
            color: #64748b;
            font-size: 12px;
            font-weight: 700;
            margin-bottom: 4px;
        }

        .info-item strong {
            display: block;
            font-size: 14px;
            font-weight: 700;
            word-break: break-word;
        }

        .actions {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
            margin-top: 16px;
        }

        .btn {
            min-height: 40px;
            padding: 0 15px;
            border-radius: 999px;
            border: none;
            text-decoration: none;
            cursor: pointer;
            font-family: inherit;
            font-size: 13px;
            font-weight: 800;
            display: inline-flex;
            align-items: center;
            justify-content: center;
        }

        .btn.view {
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
            margin-top: 12px;
            padding: 14px;
            border-radius: 18px;
            background: #fff1f2;
            border: 1px solid #fecdd3;
        }

        .reject-box textarea {
            width: 100%;
            min-height: 80px;
            border-radius: 14px;
            border: 1px solid #fecdd3;
            padding: 12px;
            resize: vertical;
            font-family: inherit;
            box-sizing: border-box;
            outline: none;
        }

        .empty-box {
            padding: 40px;
            border-radius: 28px;
            background: white;
            border: 1px dashed #cbd5e1;
            text-align: center;
            color: #64748b;
            font-weight: 700;
        }

        @media (max-width: 900px) {
            .admin-main {
                margin-left: 0;
                padding: 24px 16px 60px;
            }

            .grid,
            .info-grid {
                grid-template-columns: 1fr;
            }

            .topbar {
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
                <h1>Duyệt đăng ký sinh viên</h1>
                <p>Kiểm tra tài khoản mới đăng ký và xác thực sinh viên thuộc Trường Đại học Khoa học.</p>
            </div>

            <div class="notification-pill">
                🔔 <%= pendingCount %> đăng ký chờ duyệt
            </div>
        </section>

        <% if (success != null && !success.trim().isEmpty()) { %>
            <div class="alert-success"><%= success %></div>
        <% } %>

        <% if (error != null && !error.trim().isEmpty()) { %>
            <div class="alert-error"><%= error %></div>
        <% } %>

        <h2 class="section-title">Thông báo đăng ký mới</h2>

        <% if (pendingRequests == null || pendingRequests.isEmpty()) { %>

            <div class="empty-box">
                Hiện chưa có tài khoản sinh viên nào chờ duyệt.
            </div>

        <% } else { %>

            <section class="grid">
                <% for (RegistrationRequest r : pendingRequests) { %>

                    <article class="card">
                        <div class="card-head">
                            <div class="student-info">
                                <div class="avatar">👤</div>

                                <div>
                                    <h3><%= r.getFullName() %></h3>
                                    <p><%= r.getEmail() %></p>
                                    <p>Mã sinh viên: <b><%= r.getStudentCode() %></b></p>
                                </div>
                            </div>

                            <span class="status pending">Chờ duyệt</span>
                        </div>

                        <div class="info-grid">
                            <div class="info-item">
                                <span>Ngày đăng ký</span>
                                <strong><%= r.getCreatedAt() == null ? "Chưa cập nhật" : r.getCreatedAt() %></strong>
                            </div>

                            <div class="info-item">
                                <span>Số điện thoại</span>
                                <strong><%= r.getPhone() == null || r.getPhone().trim().isEmpty() ? "Chưa nhập" : r.getPhone() %></strong>
                            </div>
                        </div>

                        <div class="actions">
                            <a class="btn view"
                               href="<%= contextPath %>/admin/registrations?action=detail&id=<%= r.getUserId() %>">
                                Xem chi tiết
                            </a>

                            <form method="post" action="<%= contextPath %>/admin/registrations">
                                <input type="hidden" name="action" value="approve">
                                <input type="hidden" name="id" value="<%= r.getUserId() %>">

                                <button class="btn approve" type="submit"
                                        onclick="return confirm('Duyệt tài khoản sinh viên này?');">
                                    Duyệt
                                </button>
                            </form>
                        </div>

                        <form class="reject-box" method="post" action="<%= contextPath %>/admin/registrations">
                            <input type="hidden" name="action" value="reject">
                            <input type="hidden" name="id" value="<%= r.getUserId() %>">

                            <textarea name="rejectReason"
                                      required
                                      placeholder="Nhập lý do từ chối nếu thông tin sinh viên không đúng..."></textarea>

                            <div class="actions">
                                <button class="btn reject" type="submit"
                                        onclick="return confirm('Từ chối tài khoản này?');">
                                    Từ chối
                                </button>
                            </div>
                        </form>
                    </article>

                <% } %>
            </section>

        <% } %>

    </div>
</main>

</body>
</html>
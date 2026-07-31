<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.lang.reflect.Method" %>
<%@ page import="vn.edu.husc.library.model.User" %>

<%!
    private String getText(Object obj, String defaultValue, String... methods) {
        if (obj == null) return defaultValue;

        for (String m : methods) {
            try {
                Method method = obj.getClass().getMethod(m);
                Object value = method.invoke(obj);

                if (value != null && !value.toString().trim().isEmpty()) {
                    return value.toString();
                }
            } catch (Exception e) {
                // ignore
            }
        }

        return defaultValue;
    }

    private int getInt(Object obj, int defaultValue, String... methods) {
        if (obj == null) return defaultValue;

        for (String m : methods) {
            try {
                Method method = obj.getClass().getMethod(m);
                Object value = method.invoke(obj);

                if (value == null) continue;

                if (value instanceof Number) {
                    return ((Number) value).intValue();
                }

                return Integer.parseInt(value.toString());
            } catch (Exception e) {
                // ignore
            }
        }

        return defaultValue;
    }

    private String statusText(String status) {
        if (status == null) return "Không rõ";

        if ("PENDING".equalsIgnoreCase(status)) return "Chờ duyệt";
        if ("APPROVED".equalsIgnoreCase(status)) return "Đã duyệt";
        if ("BORROWING".equalsIgnoreCase(status)) return "Đang mượn";
        if ("RETURNED".equalsIgnoreCase(status)) return "Đã trả";
        if ("REJECTED".equalsIgnoreCase(status)) return "Từ chối";
        if ("CANCELED".equalsIgnoreCase(status)) return "Đã hủy";
        if ("OVERDUE".equalsIgnoreCase(status)) return "Quá hạn";

        return status;
    }

    private String statusClass(String status) {
        if (status == null) return "neutral";

        if ("PENDING".equalsIgnoreCase(status)) return "pending";
        if ("APPROVED".equalsIgnoreCase(status)) return "approved";
        if ("BORROWING".equalsIgnoreCase(status)) return "borrowing";
        if ("RETURNED".equalsIgnoreCase(status)) return "returned";
        if ("REJECTED".equalsIgnoreCase(status)) return "rejected";
        if ("CANCELED".equalsIgnoreCase(status)) return "rejected";
        if ("OVERDUE".equalsIgnoreCase(status)) return "overdue";

        return "neutral";
    }
%>

<%
    String contextPath = request.getContextPath();

    List<?> equipmentHistories = (List<?>) request.getAttribute("equipmentHistories");

    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        currentUser = (User) session.getAttribute("user");
    }

    if (currentUser == null) {
        response.sendRedirect(contextPath + "/login.jsp");
        return;
    }

    String fullName = getText(currentUser, "Người dùng", "getFullName", "getName");
    String email = getText(currentUser, "", "getEmail");
    String roleName = getText(currentUser, "User", "getRoleName", "getRoleCode");

    int totalCount = equipmentHistories != null ? equipmentHistories.size() : 0;
    int pendingCount = 0;
    int borrowingCount = 0;
    int returnedCount = 0;

    if (equipmentHistories != null) {
        for (Object item : equipmentHistories) {
            String st = getText(item, "", "getStatus");

            if ("PENDING".equalsIgnoreCase(st)) pendingCount++;
            if ("APPROVED".equalsIgnoreCase(st) || "BORROWING".equalsIgnoreCase(st)) borrowingCount++;
            if ("RETURNED".equalsIgnoreCase(st)) returnedCount++;
        }
    }
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Lịch sử thiết bị - HUSC Digital Library</title>
   <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/common/base.css?v=1">
	<link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/common/components.css?v=1">
	<link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/member/member-layout.css?v=1">
	<link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/member/app-header.css?v=1">

    <style>
        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background:
                radial-gradient(circle at top left, rgba(20, 184, 166, 0.13), transparent 30%),
                radial-gradient(circle at bottom right, rgba(59, 130, 246, 0.13), transparent 32%),
                #f6f9fc;
            color: #0f172a;
            overflow-x: hidden;
        }

        .page-shell {
            max-width: 1240px;
            margin: 0 auto;
            padding: 24px 20px 70px;
        }

        .top-nav {
            min-height: 76px;
            border-radius: 28px;
            padding: 14px 20px;
            background: rgba(255,255,255,0.88);
            border: 1px solid rgba(226,232,240,0.9);
            box-shadow: 0 16px 40px rgba(15,23,42,0.06);
            backdrop-filter: blur(18px);
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 18px;
        }

        .brand {
            display: flex;
            align-items: center;
            gap: 14px;
            text-decoration: none;
        }

        .brand-icon {
            width: 52px;
            height: 52px;
            border-radius: 18px;
            background: linear-gradient(135deg, #0f766e, #14b8a6);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 25px;
            box-shadow: 0 16px 32px rgba(20,184,166,0.24);
        }

        .brand strong {
            display: block;
            color: #0f172a;
            font-size: 18px;
            font-weight: 900;
        }

        .brand span {
            color: #64748b;
            font-size: 12px;
            font-weight: 700;
        }

        .nav-links {
            display: flex;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
        }

        .nav-links a {
            height: 42px;
            padding: 0 15px;
            border-radius: 999px;
            color: #334155;
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 13px;
            font-weight: 900;
            white-space: nowrap;
            transition: 0.22s ease;
        }

        .nav-links a:hover,
        .nav-links a.active {
            color: #0f766e;
            background: #ccfbf1;
            border-color: #99f6e4;
            transform: translateY(-3px);
            text-decoration: none;
        }

        .hero {
            margin-top: 26px;
            border-radius: 40px;
            padding: 48px;
            color: white;
            background:
                radial-gradient(circle at 20% 20%, rgba(20,184,166,0.38), transparent 34%),
                radial-gradient(circle at 88% 80%, rgba(59,130,246,0.35), transparent 34%),
                linear-gradient(135deg, #0f172a, #155e75);
            box-shadow: 0 34px 82px rgba(15,23,42,0.18);
            display: grid;
            grid-template-columns: minmax(0, 1fr) 380px;
            gap: 28px;
            align-items: center;
        }

        .label {
            display: inline-flex;
            padding: 9px 16px;
            border-radius: 999px;
            background: rgba(255,255,255,0.13);
            border: 1px solid rgba(255,255,255,0.18);
            color: #ccfbf1;
            font-size: 12px;
            font-weight: 900;
            letter-spacing: 1.4px;
        }

        .hero h1 {
            font-size: 52px;
            line-height: 1.06;
            letter-spacing: -1.8px;
            margin: 18px 0 14px;
        }

        .hero h1 span {
            background: linear-gradient(135deg, #99f6e4, #ffffff, #bfdbfe);
            -webkit-background-clip: text;
            background-clip: text;
            color: transparent;
        }

        .hero p {
            color: #dbeafe;
            font-size: 16px;
            line-height: 1.75;
            max-width: 760px;
        }

        .hero-card {
            padding: 24px;
            border-radius: 30px;
            background: rgba(255,255,255,0.13);
            border: 1px solid rgba(255,255,255,0.17);
            backdrop-filter: blur(18px);
        }

        .profile-box {
            display: flex;
            gap: 14px;
            align-items: center;
            margin-bottom: 18px;
        }

        .profile-avatar {
            width: 62px;
            height: 62px;
            border-radius: 22px;
            background: white;
            color: #0f766e;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 28px;
            font-weight: 900;
        }

        .profile-box strong {
            display: block;
            color: white;
            font-size: 17px;
            margin-bottom: 5px;
        }

        .profile-box span {
            display: block;
            color: #ccfbf1;
            font-size: 12px;
            line-height: 1.45;
        }

        .stat-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 12px;
        }

        .stat-grid div {
            padding: 15px;
            border-radius: 20px;
            background: rgba(255,255,255,0.12);
        }

        .stat-grid strong {
            display: block;
            color: white;
            font-size: 28px;
            margin-bottom: 5px;
        }

        .stat-grid span {
            color: #ccfbf1;
            font-size: 12px;
            font-weight: 800;
        }

        .section-head {
            margin: 34px 0 18px;
            display: flex;
            justify-content: space-between;
            align-items: end;
            gap: 18px;
        }

        .section-head span {
            color: #0f766e;
            font-size: 12px;
            font-weight: 900;
            letter-spacing: 1.4px;
        }

        .section-head h2 {
            margin: 8px 0 0;
            font-size: 34px;
            color: #0f172a;
            letter-spacing: -1px;
        }

        .section-head p {
            color: #64748b;
            margin: 0;
            line-height: 1.6;
        }

        .history-list {
            display: grid;
            gap: 18px;
        }

        .history-card {
            background: white;
            border: 1px solid #e2e8f0;
            border-radius: 30px;
            padding: 22px;
            box-shadow: 0 18px 48px rgba(15,23,42,0.06);
            display: grid;
            grid-template-columns: 78px minmax(0, 1fr) 170px;
            gap: 18px;
            align-items: center;
            transition: 0.25s ease;
        }

        .history-card:hover {
            transform: translateY(-5px);
            border-color: #99f6e4;
            box-shadow: 0 28px 70px rgba(15,23,42,0.12);
        }

        .device-icon {
            width: 78px;
            height: 78px;
            border-radius: 24px;
            background: linear-gradient(135deg, #0f766e, #14b8a6);
            color: white;
            font-size: 36px;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 18px 36px rgba(20,184,166,0.22);
        }

        .history-main h3 {
            margin: 0 0 8px;
            color: #0f172a;
            font-size: 21px;
            line-height: 1.3;
        }

        .history-main p {
            margin: 0;
            color: #64748b;
            font-size: 14px;
            line-height: 1.6;
        }

        .meta-row {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            margin-top: 12px;
        }

        .meta-row span {
            padding: 7px 10px;
            border-radius: 999px;
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            color: #475569;
            font-size: 12px;
            font-weight: 800;
        }

        .status-box {
            display: grid;
            gap: 10px;
            justify-items: end;
        }

        .status-badge {
            width: fit-content;
            padding: 9px 12px;
            border-radius: 999px;
            font-size: 12px;
            font-weight: 900;
            border: 1px solid transparent;
        }

        .status-badge.pending {
            background: #fef9c3;
            color: #854d0e;
            border-color: #fde68a;
        }

        .status-badge.approved {
            background: #dbeafe;
            color: #1d4ed8;
            border-color: #bfdbfe;
        }

        .status-badge.borrowing {
            background: #ede9fe;
            color: #5b21b6;
            border-color: #ddd6fe;
        }

        .status-badge.returned {
            background: #dcfce7;
            color: #166534;
            border-color: #bbf7d0;
        }

        .status-badge.rejected,
        .status-badge.overdue {
            background: #ffe4e6;
            color: #be123c;
            border-color: #fecdd3;
        }

        .status-badge.neutral {
            background: #f1f5f9;
            color: #475569;
            border-color: #e2e8f0;
        }

        .btn-main {
            height: 40px;
            padding: 0 14px;
            border-radius: 999px;
            color: white;
            background: linear-gradient(135deg, #0f766e, #14b8a6);
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 13px;
            font-weight: 900;
            box-shadow: 0 14px 30px rgba(20,184,166,0.22);
            transition: 0.22s ease;
        }

        .btn-main:hover {
            transform: translateY(-3px);
            text-decoration: none;
        }

        .empty-box {
            margin-top: 22px;
            padding: 60px 24px;
            background: white;
            border: 1px dashed #cbd5e1;
            border-radius: 34px;
            text-align: center;
        }

        .empty-icon {
            width: 92px;
            height: 92px;
            border-radius: 30px;
            background: #ecfeff;
            color: #0f766e;
            font-size: 46px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 18px;
        }

        .empty-box h3 {
            margin: 0 0 10px;
            font-size: 25px;
            color: #0f172a;
        }

        .empty-box p {
            margin: 0 auto 24px;
            max-width: 560px;
            color: #64748b;
            line-height: 1.65;
        }

        @media (max-width: 920px) {
            .hero {
                grid-template-columns: 1fr;
            }

            .history-card {
                grid-template-columns: 78px minmax(0, 1fr);
            }

            .status-box {
                grid-column: 1 / -1;
                justify-items: start;
            }
        }

        @media (max-width: 720px) {
            .top-nav,
            .section-head {
                flex-direction: column;
                align-items: flex-start;
            }

            .hero {
                padding: 32px 22px;
            }

            .hero h1 {
                font-size: 36px;
            }

            .stat-grid {
                grid-template-columns: 1fr;
            }

            .history-card {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>

<body>

<div class="page-shell">

    <header class="top-nav">
        <a class="brand" href="<%= contextPath %>/index.jsp">
            <div class="brand-icon">💻</div>

            <div>
                <strong>HUSC Digital Library</strong>
                <span>Lịch sử mượn thiết bị</span>
            </div>
        </a>

        <nav class="nav-links">
            <a href="<%= contextPath %>/index.jsp">Trang chủ</a>
            <a href="<%= contextPath %>/documents">Tài liệu</a>
            <a href="<%= contextPath %>/favorite-documents">Yêu thích</a>
            <a href="<%= contextPath %>/document-history">Lịch sử TL</a>
            <a href="<%= contextPath %>/equipments">Thiết bị</a>
            <a class="active" href="<%= contextPath %>/equipment-history">Lịch sử TB</a>
            <a href="<%= contextPath %>/my-borrow-requests">Yêu cầu của tôi</a>
            <a href="<%= contextPath %>/logout">Đăng xuất</a>
        </nav>
    </header>

    <section class="hero">
        <div>
            <span class="label">EQUIPMENT HISTORY</span>

            <h1>
                Lịch sử<br>
                <span>mượn thiết bị</span>
            </h1>

            <p>
                Theo dõi toàn bộ thiết bị bạn đã gửi yêu cầu mượn, đang mượn,
                đã trả hoặc bị từ chối trong hệ thống.
            </p>
        </div>

        <div class="hero-card">
            <div class="profile-box">
                <div class="profile-avatar">
                    <%= fullName != null && !fullName.trim().isEmpty()
                            ? fullName.trim().substring(0, 1).toUpperCase()
                            : "U" %>
                </div>

                <div>
                    <strong><%= fullName %></strong>
                    <span><%= email %></span>
                    <span><%= roleName %></span>
                </div>
            </div>

            <div class="stat-grid">
                <div>
                    <strong><%= totalCount %></strong>
                    <span>Tổng lịch sử</span>
                </div>

                <div>
                    <strong><%= pendingCount %></strong>
                    <span>Chờ duyệt</span>
                </div>

                <div>
                    <strong><%= borrowingCount %></strong>
                    <span>Đang xử lý/mượn</span>
                </div>

                <div>
                    <strong><%= returnedCount %></strong>
                    <span>Đã trả</span>
                </div>
            </div>
        </div>
    </section>

    <section class="section-head">
        <div>
            <span>BORROWING ACTIVITIES</span>
            <h2>Hoạt động mượn thiết bị</h2>
        </div>

        <p>
            Danh sách thiết bị gắn với các yêu cầu mượn của tài khoản hiện tại.
        </p>
    </section>

    <% if (equipmentHistories == null || equipmentHistories.isEmpty()) { %>

        <section class="empty-box">
            <div class="empty-icon">💻</div>

            <h3>Chưa có lịch sử thiết bị</h3>

            <p>
                Khi bạn gửi yêu cầu mượn thiết bị, lịch sử sẽ xuất hiện tại đây.
            </p>

            <a class="btn-main" href="<%= contextPath %>/equipments">
                Xem danh sách thiết bị
            </a>
        </section>

    <% } else { %>

        <section class="history-list">

            <% for (Object item : equipmentHistories) {
                int requestId = getInt(item, 0, "getRequestId", "getId");
                int equipmentId = getInt(item, 0, "getEquipmentId");

                String equipmentCode = getText(item, "N/A", "getEquipmentCode", "getCode");
                String equipmentName = getText(item, "Thiết bị chưa có tên", "getEquipmentName", "getName");
                String typeName = getText(item, "Thiết bị", "getTypeName", "getEquipmentTypeName");

                String status = getText(item, "PENDING", "getStatus");
                String borrowDate = getText(item, "Chưa cập nhật", "getBorrowDate");
                String expectedReturnDate = getText(item, "Chưa cập nhật", "getExpectedReturnDate");
                String purpose = getText(item, "", "getPurpose");
                String managerNote = getText(item, "", "getManagerNote");
                String createdAt = getText(item, "", "getCreatedAt");
            %>

                <article class="history-card">
                    <div class="device-icon">💻</div>

                    <div class="history-main">
                        <h3><%= equipmentName %></h3>

                        <p>
                            <%= purpose == null || purpose.trim().isEmpty()
                                    ? "Không có ghi chú mục đích mượn."
                                    : purpose %>
                        </p>

                        <div class="meta-row">
                            <span>🔖 Mã TB: <%= equipmentCode %></span>
                            <span>🏷 <%= typeName %></span>
                            <span>📅 Mượn: <%= borrowDate %></span>
                            <span>↩ Trả dự kiến: <%= expectedReturnDate %></span>

                            <% if (createdAt != null && !createdAt.trim().isEmpty()) { %>
                                <span>🕘 Gửi lúc: <%= createdAt %></span>
                            <% } %>

                            <% if (managerNote != null && !managerNote.trim().isEmpty()) { %>
                                <span>📝 Quản lý: <%= managerNote %></span>
                            <% } %>
                        </div>
                    </div>

                    <div class="status-box">
                        <span class="status-badge <%= statusClass(status) %>">
                            <%= statusText(status) %>
                        </span>

                        <% if (equipmentId > 0) { %>
                            <a class="btn-main" href="<%= contextPath %>/equipment-detail?id=<%= equipmentId %>">
                                Xem thiết bị
                            </a>
                        <% } %>

                        <span style="font-size:12px;color:#64748b;font-weight:800;">
                            Mã yêu cầu: <%= requestId %>
                        </span>
                    </div>
                </article>

            <% } %>

        </section>

    <% } %>

</div>

</body>
</html>
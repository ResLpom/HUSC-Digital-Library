<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="vn.edu.husc.library.model.BorrowRequest" %>
<%@ page import="vn.edu.husc.library.model.User" %>

<%
    String contextPath = request.getContextPath();

    List<BorrowRequest> requests = (List<BorrowRequest>) request.getAttribute("requests");
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");

    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        currentUser = (User) session.getAttribute("user");
    }

    String fullName = "Quản trị viên";
    String email = "admin@husc.edu.vn";
    String roleName = "Administrator";

    if (currentUser != null) {
        if (currentUser.getFullName() != null) fullName = currentUser.getFullName();
        if (currentUser.getEmail() != null) email = currentUser.getEmail();
        if (currentUser.getRoleName() != null) roleName = currentUser.getRoleName();
    }

    int total = 0;
    int pending = 0;
    int approved = 0;
    int borrowing = 0;
    int returned = 0;
    int rejected = 0;

    if (requests != null) {
        total = requests.size();

        for (BorrowRequest br : requests) {
            String st = br.getStatus();

            if ("PENDING".equalsIgnoreCase(st)) pending++;
            else if ("APPROVED".equalsIgnoreCase(st)) approved++;
            else if ("BORROWING".equalsIgnoreCase(st)) borrowing++;
            else if ("RETURNED".equalsIgnoreCase(st)) returned++;
            else if ("REJECTED".equalsIgnoreCase(st) || "CANCELED".equalsIgnoreCase(st)) rejected++;
        }
    }
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản lý yêu cầu mượn - HUSC Digital Library</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/common/base.css?v=1">
	<link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/common/components.css?v=1">
	<link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/admin/admin-layout.css?v=1">
    <style>
        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background:
                radial-gradient(circle at top left, rgba(20, 184, 166, 0.12), transparent 30%),
                radial-gradient(circle at bottom right, rgba(99, 102, 241, 0.12), transparent 32%),
                #f6f9fc;
            color: #0f172a;
            overflow-x: hidden;
        }

        .admin-pro-layout {
            min-height: 100vh;
            display: grid;
            grid-template-columns: 292px minmax(0, 1fr);
        }

        .admin-sidebar {
            position: sticky;
            top: 0;
            height: 100vh;
            padding: 24px;
            background:
                radial-gradient(circle at top left, rgba(56, 189, 248, 0.18), transparent 32%),
                linear-gradient(180deg, #0f172a, #111827);
            color: white;
            box-sizing: border-box;
            overflow-y: auto;
        }

        .admin-brand {
            display: flex;
            align-items: center;
            gap: 14px;
            margin-bottom: 34px;
        }

        .admin-brand-icon {
            width: 54px;
            height: 54px;
            border-radius: 18px;
            background: linear-gradient(135deg, #0284c7, #06b6d4);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 26px;
            box-shadow: 0 18px 36px rgba(6, 182, 212, 0.28);
        }

        .admin-brand h2 {
            font-size: 18px;
            margin: 0;
            line-height: 1.2;
        }

        .admin-brand p {
            margin: 4px 0 0;
            color: #93c5fd;
            font-size: 12px;
        }

        .admin-user-card {
            padding: 18px;
            border-radius: 24px;
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(255, 255, 255, 0.14);
            backdrop-filter: blur(16px);
            margin-bottom: 24px;
        }

        .admin-user-avatar {
            width: 58px;
            height: 58px;
            border-radius: 20px;
            background: white;
            color: #1e3a8a;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 26px;
            font-weight: 900;
            margin-bottom: 14px;
        }

        .admin-user-card strong {
            display: block;
            color: white;
            font-size: 16px;
            margin-bottom: 5px;
        }

        .admin-user-card span {
            display: block;
            color: #bfdbfe;
            font-size: 12px;
            line-height: 1.45;
        }

        .admin-menu-title {
            color: #64748b;
            font-size: 11px;
            font-weight: 900;
            letter-spacing: 1.4px;
            margin: 22px 0 10px;
        }

        .admin-nav {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .admin-nav a {
            height: 46px;
            padding: 0 14px;
            border-radius: 16px;
            color: #cbd5e1;
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 12px;
            font-weight: 800;
            font-size: 14px;
            transition: 0.22s ease;
        }

        .admin-nav a:hover,
        .admin-nav a.active {
            color: white;
            background: rgba(255, 255, 255, 0.13);
            transform: translateX(5px);
        }

        .admin-nav a.active {
            box-shadow: inset 3px 0 0 #38bdf8;
        }

        .admin-main {
            min-width: 0;
            padding: 30px 42px 70px;
        }

        .admin-topbar {
            min-height: 76px;
            border-radius: 28px;
            padding: 18px 24px;
            background: rgba(255, 255, 255, 0.86);
            border: 1px solid rgba(226, 232, 240, 0.9);
            box-shadow: 0 16px 40px rgba(15, 23, 42, 0.06);
            backdrop-filter: blur(18px);
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 16px;
            animation: fadeUp 0.7s ease both;
        }

        .admin-topbar h1 {
            font-size: 24px;
            margin: 0;
            color: #0f172a;
        }

        .admin-topbar p {
            margin: 4px 0 0;
            color: #64748b;
            font-size: 13px;
        }

        .admin-btn {
            height: 42px;
            padding: 0 16px;
            border-radius: 999px;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-weight: 900;
            font-size: 13px;
            transition: 0.22s ease;
            border: none;
            cursor: pointer;
        }

        .admin-btn.primary {
            color: white;
            background: linear-gradient(135deg, #0f766e, #14b8a6);
            box-shadow: 0 14px 30px rgba(20, 184, 166, 0.24);
        }

        .admin-btn.secondary {
            color: #0f766e;
            background: #ecfeff;
            border: 1px solid #a5f3fc;
        }

        .admin-btn.danger {
            color: #be123c;
            background: #ffe4e6;
            border: 1px solid #fecdd3;
        }

        .admin-btn.warning {
            color: #92400e;
            background: #fef3c7;
            border: 1px solid #fde68a;
        }

        .admin-btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 18px 38px rgba(15, 23, 42, 0.13);
        }

        .borrow-hero {
            margin-top: 26px;
            border-radius: 38px;
            padding: 42px;
            color: white;
            background:
                radial-gradient(circle at 18% 20%, rgba(20, 184, 166, 0.36), transparent 32%),
                radial-gradient(circle at 90% 80%, rgba(99, 102, 241, 0.35), transparent 34%),
                linear-gradient(135deg, #0f172a, #164e63);
            box-shadow: 0 34px 82px rgba(15, 23, 42, 0.18);
            position: relative;
            overflow: hidden;
            display: grid;
            grid-template-columns: minmax(0, 1fr) 380px;
            gap: 28px;
            align-items: center;
            animation: fadeUp 0.75s ease 0.08s both;
        }

        .borrow-hero::before {
            content: "";
            position: absolute;
            inset: 0;
            background: linear-gradient(120deg, transparent, rgba(255,255,255,0.08), transparent);
            transform: translateX(-120%);
            animation: shineMove 7s ease-in-out infinite;
        }

        .borrow-hero-content,
        .borrow-hero-panel {
            position: relative;
            z-index: 2;
        }

        .admin-label {
            display: inline-flex;
            padding: 9px 16px;
            border-radius: 999px;
            background: rgba(255, 255, 255, 0.13);
            border: 1px solid rgba(255, 255, 255, 0.18);
            color: #ccfbf1;
            font-size: 12px;
            font-weight: 900;
            letter-spacing: 1.4px;
        }

        .borrow-hero h2 {
            font-size: 46px;
            line-height: 1.1;
            letter-spacing: -1.6px;
            margin: 18px 0 12px;
        }

        .borrow-hero h2 span {
            background: linear-gradient(135deg, #99f6e4, #ffffff, #c4b5fd);
            -webkit-background-clip: text;
            background-clip: text;
            color: transparent;
        }

        .borrow-hero p {
            color: #dbeafe;
            line-height: 1.75;
            max-width: 760px;
        }

        .borrow-hero-panel {
            padding: 24px;
            border-radius: 28px;
            background: rgba(255, 255, 255, 0.13);
            border: 1px solid rgba(255, 255, 255, 0.17);
            backdrop-filter: blur(18px);
            animation: floatCard 5s ease-in-out infinite;
        }

        .borrow-hero-panel h3 {
            margin: 0 0 16px;
            color: white;
        }

        .borrow-mini-stat {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 12px;
        }

        .borrow-mini-stat div {
            padding: 15px;
            border-radius: 20px;
            background: rgba(255, 255, 255, 0.12);
        }

        .borrow-mini-stat strong {
            display: block;
            color: white;
            font-size: 28px;
            margin-bottom: 6px;
        }

        .borrow-mini-stat span {
            color: #ccfbf1;
            font-size: 12px;
            font-weight: 800;
        }

        .status-strip {
            margin-top: 24px;
            display: grid;
            grid-template-columns: repeat(5, minmax(0, 1fr));
            gap: 16px;
            animation: fadeUp 0.75s ease 0.14s both;
        }

        .status-card {
            background: white;
            border: 1px solid #e2e8f0;
            border-radius: 26px;
            padding: 20px;
            box-shadow: 0 16px 40px rgba(15, 23, 42, 0.06);
            transition: 0.24s ease;
        }

        .status-card:hover {
            transform: translateY(-6px);
            box-shadow: 0 26px 60px rgba(15, 23, 42, 0.11);
        }

        .status-card strong {
            display: block;
            font-size: 28px;
            color: #0f172a;
            margin-bottom: 6px;
        }

        .status-card span {
            color: #64748b;
            font-size: 13px;
            font-weight: 800;
        }

        .requests-section {
            margin-top: 28px;
            animation: fadeUp 0.75s ease 0.2s both;
        }

        .section-heading {
            display: flex;
            align-items: end;
            justify-content: space-between;
            gap: 18px;
            margin-bottom: 18px;
        }

        .section-heading span {
            color: #0f766e;
            font-size: 12px;
            font-weight: 900;
            letter-spacing: 1.4px;
        }

        .section-heading h2 {
            font-size: 32px;
            margin: 8px 0 0;
            color: #0f172a;
            letter-spacing: -0.9px;
        }

        .section-heading p {
            color: #64748b;
            margin: 0;
            line-height: 1.6;
        }

        .request-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 22px;
        }

        .request-card {
            background: white;
            border: 1px solid #e2e8f0;
            border-radius: 30px;
            padding: 24px;
            box-shadow: 0 18px 48px rgba(15, 23, 42, 0.06);
            transition: 0.25s ease;
        }

        .request-card:hover {
            transform: translateY(-6px);
            box-shadow: 0 28px 70px rgba(15, 23, 42, 0.12);
            border-color: #a5f3fc;
        }

        .request-top {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 14px;
            margin-bottom: 18px;
        }

        .request-id {
            width: 52px;
            height: 52px;
            border-radius: 18px;
            background: #ecfeff;
            color: #0f766e;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 900;
        }

        .request-status {
            padding: 8px 12px;
            border-radius: 999px;
            font-size: 12px;
            font-weight: 900;
            border: 1px solid transparent;
            white-space: nowrap;
        }

        .request-pending {
            background: #fef9c3;
            color: #854d0e;
            border-color: #fde68a;
        }

        .request-approved {
            background: #dbeafe;
            color: #1d4ed8;
            border-color: #bfdbfe;
        }

        .request-borrowing {
            background: #ede9fe;
            color: #5b21b6;
            border-color: #ddd6fe;
        }

        .request-returned {
            background: #dcfce7;
            color: #166534;
            border-color: #bbf7d0;
        }

        .request-rejected {
            background: #ffe4e6;
            color: #be123c;
            border-color: #fecdd3;
        }

        .request-neutral {
            background: #f1f5f9;
            color: #475569;
            border-color: #e2e8f0;
        }

        .borrower-box {
            display: flex;
            gap: 14px;
            align-items: flex-start;
            margin-bottom: 18px;
        }

        .borrower-avatar {
            width: 58px;
            height: 58px;
            border-radius: 20px;
            background: linear-gradient(135deg, #0f766e, #14b8a6);
            color: white;
            font-size: 25px;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }

        .borrower-box small {
            display: inline-flex;
            padding: 6px 10px;
            border-radius: 999px;
            background: #ecfeff;
            color: #0e7490;
            font-size: 12px;
            font-weight: 900;
            margin-bottom: 8px;
        }

        .borrower-box h3 {
            margin: 0 0 5px;
            color: #0f172a;
            font-size: 20px;
        }

        .borrower-box p {
            margin: 0;
            color: #64748b;
            font-size: 14px;
        }

        .request-info-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 12px;
            margin-bottom: 16px;
        }

        .request-info-grid div {
            padding: 14px;
            border-radius: 18px;
            background: #f8fafc;
            border: 1px solid #e2e8f0;
        }

        .request-info-grid span {
            display: block;
            color: #64748b;
            font-size: 12px;
            font-weight: 800;
            margin-bottom: 6px;
        }

        .request-info-grid strong {
            color: #0f172a;
            font-size: 14px;
        }

        .request-purpose,
        .manager-note {
            padding: 15px;
            border-radius: 20px;
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            margin-top: 12px;
        }

        .manager-note {
            background: #fff7ed;
            border-color: #fed7aa;
        }

        .request-purpose span,
        .manager-note span {
            display: block;
            color: #475569;
            font-size: 12px;
            font-weight: 900;
            margin-bottom: 7px;
        }

        .request-purpose p,
        .manager-note p {
            margin: 0;
            color: #334155;
            font-size: 14px;
            line-height: 1.6;
        }

        .action-zone {
            margin-top: 18px;
            padding-top: 18px;
            border-top: 1px solid #e2e8f0;
        }

        .action-form {
            display: flex;
            flex-direction: column;
            gap: 10px;
            margin-top: 10px;
        }

        .action-form input,
        .action-form textarea,
        .action-form select {
            width: 100%;
            border-radius: 16px;
            border: 1px solid #dbe3ef;
            background: #f8fafc;
            padding: 12px 14px;
            outline: none;
            box-sizing: border-box;
            font-family: Arial, sans-serif;
        }

        .action-form textarea {
            min-height: 88px;
            resize: vertical;
        }

        .action-form input:focus,
        .action-form textarea:focus,
        .action-form select:focus {
            border-color: #14b8a6;
            background: white;
            box-shadow: 0 0 0 5px rgba(20, 184, 166, 0.12);
        }

        .action-row {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
        }

        .empty-admin-box {
            padding: 56px 24px;
            text-align: center;
            background: white;
            border: 1px dashed #cbd5e1;
            border-radius: 30px;
        }

        .empty-admin-icon {
            width: 86px;
            height: 86px;
            border-radius: 28px;
            background: #ecfeff;
            color: #0e7490;
            font-size: 42px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 18px;
        }

        .empty-admin-box h3 {
            margin: 0 0 10px;
            font-size: 24px;
            color: #0f172a;
        }

        .empty-admin-box p {
            margin: 0 auto 22px;
            max-width: 560px;
            color: #64748b;
            line-height: 1.65;
        }

        @keyframes fadeUp {
            from {
                opacity: 0;
                transform: translateY(26px);
            }

            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        @keyframes shineMove {
            0% {
                transform: translateX(-120%);
            }

            45%, 100% {
                transform: translateX(120%);
            }
        }

        @keyframes floatCard {
            0%, 100% {
                transform: translateY(0);
            }

            50% {
                transform: translateY(-14px);
            }
        }

        @media (max-width: 1180px) {
            .admin-pro-layout {
                grid-template-columns: 1fr;
            }

            .admin-sidebar {
                position: static;
                height: auto;
            }

            .admin-main {
                padding: 24px 18px 60px;
            }

            .borrow-hero {
                grid-template-columns: 1fr;
            }

            .status-strip {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }

            .request-grid {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 760px) {
            .admin-topbar {
                flex-direction: column;
                align-items: flex-start;
            }

            .borrow-hero {
                padding: 30px 22px;
            }

            .borrow-hero h2 {
                font-size: 34px;
            }

            .borrow-mini-stat,
            .status-strip,
            .request-info-grid {
                grid-template-columns: 1fr;
            }
        }
        .admin-sidebar {
    width: 280px;
    min-height: 100vh;
    background: #0f172a;
    color: white;
    padding: 22px 18px;
    position: fixed;
    left: 0;
    top: 0;
    overflow-y: auto;
    z-index: 100;
}

.admin-brand {
    padding: 12px 14px 22px;
    margin-bottom: 10px;
    border-bottom: 1px solid rgba(255, 255, 255, 0.08);
}

.admin-brand-text strong {
    display: block;
    font-size: 18px;
    font-weight: 900;
    color: #ffffff;
}

.admin-brand-text span {
    display: block;
    margin-top: 4px;
    font-size: 12px;
    font-weight: 700;
    color: #94a3b8;
}

.admin-menu-title {
    margin: 18px 0 10px;
    color: #94a3b8;
    font-size: 12px;
    font-weight: 900;
    letter-spacing: 2px;
}

.admin-nav {
    display: grid;
    gap: 8px;
}

.admin-nav a {
    min-height: 46px;
    padding: 0 14px;
    border-radius: 16px;
    color: #e2e8f0;
    text-decoration: none;
    display: flex;
    align-items: center;
    font-size: 15px;
    font-weight: 900;
    transition: 0.22s ease;
}

.admin-nav a:hover {
    background: rgba(255, 255, 255, 0.08);
    color: white;
}

.admin-nav a.active {
    background: rgba(255, 255, 255, 0.13);
    color: white;
    border: 1px solid #38bdf8;
    box-shadow: inset 4px 0 0 #38bdf8;
}

.admin-main {
    margin-left: 280px;
    min-height: 100vh;
    padding: 24px;
}
    </style>
</head>

<body>
<jsp:include page="/admin/includes/admin-sidebar.jsp" />
<div class="admin-pro-layout">

    

    <main class="admin-main">

        <section class="admin-topbar">
            <div>
                <h1>Quản lý yêu cầu mượn</h1>
                <p>Duyệt yêu cầu, từ chối, bàn giao thiết bị và xác nhận trả thiết bị.</p>
            </div>

            <a class="admin-btn secondary" href="<%= contextPath %>/equipments">
                Xem danh sách thiết bị
            </a>
        </section>

        <section class="borrow-hero">
            <div class="borrow-hero-content">
                <span class="admin-label">BORROW REQUEST MANAGEMENT</span>

                <h2>
                    Trung tâm xử lý<br>
                    <span>yêu cầu mượn thiết bị</span>
                </h2>

                <p>
                    Quản trị viên có thể kiểm tra thông tin người mượn, thiết bị, thời gian mượn,
                    mục đích sử dụng và thực hiện duyệt, từ chối, bàn giao hoặc xác nhận trả thiết bị.
                </p>
            </div>

            <div class="borrow-hero-panel">
                <h3>Tổng quan yêu cầu</h3>

                <div class="borrow-mini-stat">
                    <div>
                        <strong><%= total %></strong>
                        <span>Tổng yêu cầu</span>
                    </div>

                    <div>
                        <strong><%= pending %></strong>
                        <span>Chờ duyệt</span>
                    </div>

                    <div>
                        <strong><%= approved %></strong>
                        <span>Đã duyệt</span>
                    </div>

                    <div>
                        <strong><%= borrowing %></strong>
                        <span>Đang mượn</span>
                    </div>
                </div>
            </div>
        </section>

        <section class="status-strip">
            <div class="status-card">
                <strong><%= pending %></strong>
                <span>Chờ duyệt</span>
            </div>

            <div class="status-card">
                <strong><%= approved %></strong>
                <span>Đã duyệt</span>
            </div>

            <div class="status-card">
                <strong><%= borrowing %></strong>
                <span>Đang mượn</span>
            </div>

            <div class="status-card">
                <strong><%= returned %></strong>
                <span>Đã trả</span>
            </div>

            <div class="status-card">
                <strong><%= rejected %></strong>
                <span>Từ chối/Hủy</span>
            </div>
        </section>

        <section class="requests-section">
            <div class="section-heading">
                <div>
                    <span>REQUEST LIST</span>
                    <h2>Danh sách yêu cầu</h2>
                </div>

                <p>Các yêu cầu mới nhất được hiển thị dưới dạng thẻ để dễ theo dõi và xử lý.</p>
            </div>

            <% if (requests == null || requests.isEmpty()) { %>

                <div class="empty-admin-box">
                    <div class="empty-admin-icon">📭</div>
                    <h3>Chưa có yêu cầu mượn nào</h3>
                    <p>
                        Khi người dùng gửi yêu cầu mượn thiết bị, dữ liệu sẽ được hiển thị tại đây.
                    </p>
                    <a class="admin-btn primary" href="<%= contextPath %>/equipments">
                        Xem thiết bị
                    </a>
                </div>

            <% } else { %>

                <div class="request-grid">

                    <%
                        int index = 1;

                        for (BorrowRequest br : requests) {
                            String status = br.getStatus();
                            String statusClass = "request-neutral";

                            if ("PENDING".equalsIgnoreCase(status)) {
                                statusClass = "request-pending";
                            } else if ("APPROVED".equalsIgnoreCase(status)) {
                                statusClass = "request-approved";
                            } else if ("BORROWING".equalsIgnoreCase(status)) {
                                statusClass = "request-borrowing";
                            } else if ("RETURNED".equalsIgnoreCase(status)) {
                                statusClass = "request-returned";
                            } else if ("REJECTED".equalsIgnoreCase(status) || "CANCELED".equalsIgnoreCase(status)) {
                                statusClass = "request-rejected";
                            }

                            String borrowDateText = br.getBorrowDate() != null ? sdf.format(br.getBorrowDate()) : "Chưa cập nhật";
                            String returnDateText = br.getExpectedReturnDate() != null ? sdf.format(br.getExpectedReturnDate()) : "Chưa cập nhật";
                            String createdDateText = br.getCreatedAt() != null ? sdf.format(br.getCreatedAt()) : "Chưa cập nhật";
                    %>

                        <article class="request-card">

                            <div class="request-top">
                                <div class="request-id">#<%= index++ %></div>

                                <span class="request-status <%= statusClass %>">
                                    <%= br.getStatusName() != null ? br.getStatusName() : "Chưa cập nhật" %>
                                </span>
                            </div>

                            <div class="borrower-box">
                                <div class="borrower-avatar">👤</div>

                                <div>
                                    <small>Người mượn</small>
                                    <h3><%= br.getFullName() != null ? br.getFullName() : "Chưa cập nhật người mượn" %></h3>
                                    <p>REQ-<%= br.getRequestId() %> • Gửi ngày <%= createdDateText %></p>
                                </div>
                            </div>

                            <div class="request-info-grid">
                                <div>
                                    <span>Mã thiết bị</span>
                                    <strong><%= br.getEquipmentCode() != null ? br.getEquipmentCode() : "NO-CODE" %></strong>
                                </div>

                                <div>
                                    <span>Tên thiết bị</span>
                                    <strong><%= br.getEquipmentName() != null ? br.getEquipmentName() : "Thiết bị học tập" %></strong>
                                </div>

                                <div>
                                    <span>Loại thiết bị</span>
                                    <strong><%= br.getTypeName() != null ? br.getTypeName() : "Chưa cập nhật" %></strong>
                                </div>

                                <div>
                                    <span>Ngày mượn</span>
                                    <strong><%= borrowDateText %></strong>
                                </div>

                                <div>
                                    <span>Ngày trả dự kiến</span>
                                    <strong><%= returnDateText %></strong>
                                </div>

                                <div>
                                    <span>Trạng thái</span>
                                    <strong><%= br.getStatusName() != null ? br.getStatusName() : "Chưa cập nhật" %></strong>
                                </div>
                            </div>

                            <div class="request-purpose">
                                <span>Mục đích mượn</span>
                                <p>
                                    <%= br.getPurpose() != null && !br.getPurpose().trim().isEmpty()
                                            ? br.getPurpose()
                                            : "Chưa cập nhật mục đích mượn." %>
                                </p>
                            </div>

                            <% if (br.getManagerNote() != null && !br.getManagerNote().trim().isEmpty()) { %>
                                <div class="manager-note">
                                    <span>Ghi chú quản lý</span>
                                    <p><%= br.getManagerNote() %></p>
                                </div>
                            <% } %>

                            <div class="action-zone">

                                <% if ("PENDING".equalsIgnoreCase(br.getStatus())) { %>

                                    <form class="action-form" action="<%= contextPath %>/admin/borrow-requests" method="post">
                                        <input type="hidden" name="requestId" value="<%= br.getRequestId() %>">
                                        <input type="hidden" name="action" value="approve">

                                        <input type="text" name="managerNote" placeholder="Ghi chú duyệt, ví dụ: Đủ điều kiện mượn">

                                        <button class="admin-btn primary" type="submit">
                                            Duyệt yêu cầu
                                        </button>
                                    </form>

                                    <form class="action-form" action="<%= contextPath %>/admin/borrow-requests" method="post">
                                        <input type="hidden" name="requestId" value="<%= br.getRequestId() %>">
                                        <input type="hidden" name="action" value="reject">

                                        <input type="text" name="managerNote" placeholder="Lý do từ chối" required>

                                        <button class="admin-btn danger" type="submit">
                                            Từ chối yêu cầu
                                        </button>
                                    </form>

                                <% } else if ("APPROVED".equalsIgnoreCase(br.getStatus())) { %>

                                    <form class="action-form" action="<%= contextPath %>/admin/borrow-requests" method="post">
                                        <input type="hidden" name="requestId" value="<%= br.getRequestId() %>">
                                        <input type="hidden" name="action" value="handover">

                                        <button class="admin-btn warning" type="submit">
                                            Bàn giao thiết bị
                                        </button>
                                    </form>

                                <% } else if ("BORROWING".equalsIgnoreCase(br.getStatus())) { %>

                                    <form class="action-form" action="<%= contextPath %>/admin/return-equipment" method="post">
                                        <input type="hidden" name="requestId" value="<%= br.getRequestId() %>">

                                        <textarea name="conditionAfter" placeholder="Tình trạng thiết bị khi trả" required></textarea>

                                        <select name="resultStatus" required>
                                            <option value="AVAILABLE">Thiết bị bình thường</option>
                                            <option value="MAINTENANCE">Thiết bị cần bảo trì</option>
                                            <option value="LOST">Thiết bị bị mất</option>
                                        </select>

                                        <textarea name="issueDescription" placeholder="Mô tả lỗi nếu cần bảo trì"></textarea>

                                        <input type="text" name="note" placeholder="Ghi chú khi nhận trả">

                                        <button class="admin-btn primary" type="submit">
                                            Xác nhận trả thiết bị
                                        </button>
                                    </form>

                                <% } else { %>

                                    <div class="manager-note">
                                        <span>Trạng thái hiện tại</span>
                                        <p>Yêu cầu này hiện không còn thao tác xử lý trực tiếp.</p>
                                    </div>

                                <% } %>

                            </div>

                        </article>

                    <% } %>

                </div>

            <% } %>

        </section>

    </main>

</div>

</body>
</html>
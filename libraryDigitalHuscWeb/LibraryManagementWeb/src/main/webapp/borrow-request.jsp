<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="vn.edu.husc.library.model.Equipment" %>
<%@ page import="vn.edu.husc.library.model.User" %>

<%!
    private String statusText(String status) {
        if (status == null) return "Không rõ";

        if ("AVAILABLE".equalsIgnoreCase(status)) return "Sẵn sàng";
        if ("BORROWED".equalsIgnoreCase(status)) return "Đang mượn";
        if ("MAINTENANCE".equalsIgnoreCase(status)) return "Bảo trì";
        if ("LOST".equalsIgnoreCase(status)) return "Bị mất";
        if ("INACTIVE".equalsIgnoreCase(status)) return "Tạm ẩn";

        return status;
    }
%>

<%
    String contextPath = request.getContextPath();

    Equipment equipment = (Equipment) request.getAttribute("equipment");
    String error = (String) request.getAttribute("error");
    String message = (String) request.getAttribute("message");

    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        currentUser = (User) session.getAttribute("user");
    }

    if (currentUser == null) {
        response.sendRedirect(contextPath + "/login.jsp");
        return;
    }

    if (equipment == null) {
        response.sendRedirect(contextPath + "/equipments");
        return;
    }

    String imagePath = equipment.getImagePath();
    String status = equipment.getStatus();
    boolean canBorrow = "AVAILABLE".equalsIgnoreCase(status);
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Gửi yêu cầu mượn - HUSC Digital Library</title>
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

        .brand:hover {
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
            display: block;
            color: #64748b;
            font-size: 12px;
            font-weight: 700;
            margin-top: 3px;
        }

        .nav-links {
            display: flex;
            align-items: center;
            justify-content: flex-end;
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
                linear-gradient(135deg, #0f172a, #164e63);
            box-shadow: 0 34px 82px rgba(15,23,42,0.18);
            position: relative;
            overflow: hidden;
            display: grid;
            grid-template-columns: minmax(0, 1fr) 360px;
            gap: 28px;
            align-items: center;
        }

        .hero::before {
            content: "";
            position: absolute;
            inset: 0;
            background: linear-gradient(120deg, transparent, rgba(255,255,255,0.08), transparent);
            transform: translateX(-120%);
            animation: shineMove 7s ease-in-out infinite;
        }

        .hero-content,
        .hero-card {
            position: relative;
            z-index: 2;
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
            color: white;
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
            margin: 0;
        }

        .hero-card {
            padding: 24px;
            border-radius: 30px;
            background: rgba(255,255,255,0.13);
            border: 1px solid rgba(255,255,255,0.17);
            backdrop-filter: blur(18px);
        }

        .hero-card strong {
            display: block;
            color: white;
            font-size: 22px;
            margin-bottom: 8px;
        }

        .hero-card span {
            display: block;
            color: #ccfbf1;
            font-size: 13px;
            line-height: 1.55;
            font-weight: 700;
        }

        .content-grid {
            margin-top: 26px;
            display: grid;
            grid-template-columns: 420px minmax(0, 1fr);
            gap: 24px;
            align-items: start;
        }

        .equipment-card,
        .form-card {
            background: white;
            border: 1px solid #e2e8f0;
            border-radius: 34px;
            box-shadow: 0 18px 48px rgba(15,23,42,0.06);
            overflow: hidden;
        }

        .equipment-card {
            position: sticky;
            top: 24px;
        }

        .equipment-image {
            height: 270px;
            background:
                linear-gradient(135deg, rgba(20,184,166,0.16), rgba(59,130,246,0.15)),
                #f8fafc;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
            position: relative;
        }

        .equipment-image img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .equipment-empty {
            width: 110px;
            height: 110px;
            border-radius: 34px;
            background: linear-gradient(135deg, #0f766e, #14b8a6);
            color: white;
            font-size: 54px;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 20px 44px rgba(20,184,166,0.28);
        }

        .status-badge {
            position: absolute;
            right: 16px;
            top: 16px;
            padding: 8px 12px;
            border-radius: 999px;
            font-size: 12px;
            font-weight: 900;
            background: #dcfce7;
            color: #166534;
            border: 1px solid #bbf7d0;
        }

        .status-badge.not-ready {
            background: #fff7ed;
            color: #9a3412;
            border-color: #fed7aa;
        }

        .equipment-body {
            padding: 26px;
        }

        .equipment-code {
            display: inline-flex;
            width: fit-content;
            padding: 7px 11px;
            border-radius: 999px;
            background: #ecfeff;
            color: #0f766e;
            font-size: 12px;
            font-weight: 900;
            margin-bottom: 12px;
        }

        .equipment-body h2 {
            margin: 0 0 10px;
            color: #0f172a;
            font-size: 24px;
            line-height: 1.25;
        }

        .equipment-body p {
            color: #64748b;
            line-height: 1.65;
            font-size: 14px;
            margin: 0 0 18px;
        }

        .equipment-info {
            display: grid;
            gap: 10px;
        }

        .equipment-info div {
            padding: 14px;
            border-radius: 18px;
            background: #f8fafc;
            border: 1px solid #e2e8f0;
        }

        .equipment-info span {
            display: block;
            color: #64748b;
            font-size: 12px;
            font-weight: 900;
            margin-bottom: 6px;
        }

        .equipment-info strong {
            color: #0f172a;
            font-size: 14px;
        }

        .form-card {
            padding: 30px;
        }

        .form-card h2 {
            color: #0f172a;
            font-size: 34px;
            line-height: 1.18;
            letter-spacing: -1px;
            margin: 0 0 10px;
        }

        .form-card > p {
            color: #64748b;
            line-height: 1.65;
            margin: 0 0 24px;
        }

        .alert-error,
        .alert-success {
            padding: 14px 16px;
            border-radius: 18px;
            margin-bottom: 18px;
            font-weight: 800;
            font-size: 14px;
            line-height: 1.5;
        }

        .alert-error {
            background: #ffe4e6;
            color: #be123c;
            border: 1px solid #fecdd3;
        }

        .alert-success {
            background: #dcfce7;
            color: #166534;
            border: 1px solid #bbf7d0;
        }

        .form-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 18px;
        }

        .form-group {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .form-group.full {
            grid-column: 1 / -1;
        }

        .form-group label {
            color: #334155;
            font-size: 13px;
            font-weight: 900;
        }

        .form-group input,
        .form-group textarea {
            width: 100%;
            border-radius: 18px;
            border: 1px solid #dbe3ef;
            background: #f8fafc;
            padding: 13px 15px;
            outline: none;
            font-family: Arial, sans-serif;
            font-size: 14px;
            box-sizing: border-box;
            transition: 0.22s ease;
        }

        .form-group input {
            height: 52px;
        }

        .form-group textarea {
            min-height: 145px;
            resize: vertical;
        }

        .form-group input:focus,
        .form-group textarea:focus {
            border-color: #14b8a6;
            background: white;
            box-shadow: 0 0 0 5px rgba(20,184,166,0.12);
        }

        .notice-box {
            margin-top: 18px;
            padding: 16px;
            border-radius: 20px;
            background: #ecfeff;
            border: 1px solid #99f6e4;
            color: #0f766e;
            line-height: 1.65;
            font-size: 14px;
            font-weight: 700;
        }

        .notice-box.warning {
            background: #fff7ed;
            border-color: #fed7aa;
            color: #9a3412;
        }

        .form-actions {
            margin-top: 24px;
            padding-top: 22px;
            border-top: 1px solid #e2e8f0;
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
        }

        .btn-main,
        .btn-soft,
        .btn-disabled {
            height: 46px;
            padding: 0 18px;
            border-radius: 999px;
            font-weight: 900;
            font-size: 13px;
            text-decoration: none;
            border: none;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            transition: 0.22s ease;
        }

        .btn-main {
            color: white;
            background: linear-gradient(135deg, #0f766e, #14b8a6);
            box-shadow: 0 14px 30px rgba(20,184,166,0.24);
        }

        .btn-soft {
            color: #0f766e;
            background: #ecfeff;
            border: 1px solid #99f6e4;
        }

        .btn-disabled {
            color: #64748b;
            background: #f1f5f9;
            cursor: not-allowed;
        }

        .btn-main:hover,
        .btn-soft:hover {
            transform: translateY(-3px);
            box-shadow: 0 18px 38px rgba(15,23,42,0.14);
            text-decoration: none;
        }

        @keyframes shineMove {
            0% {
                transform: translateX(-120%);
            }

            45%, 100% {
                transform: translateX(120%);
            }
        }

        @media (max-width: 1080px) {
            .hero,
            .content-grid {
                grid-template-columns: 1fr;
            }

            .equipment-card {
                position: static;
            }
        }

        @media (max-width: 720px) {
            .top-nav {
                flex-direction: column;
                align-items: flex-start;
            }

            .hero {
                padding: 32px 22px;
            }

            .hero h1 {
                font-size: 36px;
                line-height: 1.12;
            }

            .form-grid {
                grid-template-columns: 1fr;
            }

            .form-card h2 {
                font-size: 28px;
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
                <span>Borrow Equipment Request</span>
            </div>
        </a>

        <nav class="nav-links">
            <a href="<%= contextPath %>/index.jsp">Trang chủ</a>
            <a href="<%= contextPath %>/documents">Tài liệu</a>
            <a href="<%= contextPath %>/exam-bank">Kho đề</a>
            <a class="active" href="<%= contextPath %>/equipments">Thiết bị</a>
            <a href="<%= contextPath %>/favorite-documents">Yêu thích</a>
            <a href="<%= contextPath %>/history">Lịch sử</a>
            <a href="<%= contextPath %>/my-borrow-requests">Yêu cầu của tôi</a>
            <a href="<%= contextPath %>/logout">Đăng xuất</a>
        </nav>
    </header>

    <section class="hero">
        <div class="hero-content">
            <span class="label">BORROW EQUIPMENT REQUEST</span>

            <h1>
                Gửi yêu cầu<br>
                <span>mượn thiết bị</span>
            </h1>

            <p>
                Điền ngày mượn, ngày trả dự kiến và mục đích sử dụng.
                Yêu cầu của bạn sẽ được gửi đến quản lý để xét duyệt.
            </p>
        </div>

        <div class="hero-card">
            <strong>Quy trình xử lý</strong>
            <span>1. Gửi yêu cầu mượn thiết bị</span>
            <span>2. Quản lý xét duyệt yêu cầu</span>
            <span>3. Nhận thiết bị nếu được duyệt</span>
        </div>
    </section>

    <section class="content-grid">

        <aside class="equipment-card">
            <div class="equipment-image">
                <span class="status-badge <%= canBorrow ? "" : "not-ready" %>">
                    <%= statusText(status) %>
                </span>

                <% if (imagePath != null && !imagePath.trim().isEmpty()) { %>
                    <img src="<%= contextPath %><%= imagePath.startsWith("/") ? imagePath : "/" + imagePath %>" alt="equipment">
                <% } else { %>
                    <div class="equipment-empty">💻</div>
                <% } %>
            </div>

            <div class="equipment-body">
                <span class="equipment-code">
                    <%= equipment.getCode() != null ? equipment.getCode() : "NO-CODE" %>
                </span>

                <h2>
                    <%= equipment.getEquipmentName() != null ? equipment.getEquipmentName() : "Thiết bị học tập" %>
                </h2>

                <p>
                    <%= equipment.getDescription() != null && !equipment.getDescription().trim().isEmpty()
                            ? equipment.getDescription()
                            : "Thiết bị phục vụ nhu cầu học tập, thực hành, giảng dạy và nghiên cứu tại HUSC." %>
                </p>

                <div class="equipment-info">
                    <div>
                        <span>Loại thiết bị</span>
                        <strong><%= equipment.getTypeName() != null ? equipment.getTypeName() : "Chưa cập nhật" %></strong>
                    </div>

                    <div>
                        <span>Trạng thái</span>
                        <strong><%= statusText(status) %></strong>
                    </div>

                    <div>
                        <span>Vị trí lưu trữ</span>
                        <strong><%= equipment.getLocation() != null ? equipment.getLocation() : "Chưa cập nhật" %></strong>
                    </div>
                </div>
            </div>
        </aside>

        <main class="form-card">
            <h2>Thông tin yêu cầu</h2>

            <p>
                Vui lòng nhập đầy đủ thông tin để quá trình duyệt yêu cầu được nhanh hơn.
            </p>

            <% if (error != null) { %>
                <div class="alert-error"><%= error %></div>
            <% } %>

            <% if (message != null) { %>
                <div class="alert-success"><%= message %></div>
            <% } %>

            <% if (canBorrow) { %>

                <form action="<%= contextPath %>/borrow-request" method="post">
                    <input type="hidden" name="equipmentId" value="<%= equipment.getEquipmentId() %>">

                    <div class="form-grid">
                        <div class="form-group">
                            <label>Ngày mượn *</label>
                            <input type="date" name="borrowDate" required>
                        </div>

                        <div class="form-group">
                            <label>Ngày trả dự kiến *</label>
                            <input type="date" name="expectedReturnDate" required>
                        </div>

                        <div class="form-group full">
                            <label>Mục đích mượn *</label>
                            <textarea name="purpose"
                                      placeholder="Ví dụ: Mượn thiết bị để phục vụ buổi thuyết trình nhóm, thực hành môn học..."
                                      required></textarea>
                        </div>
                    </div>

                    <div class="notice-box">
                        Sau khi gửi, yêu cầu của bạn sẽ ở trạng thái chờ duyệt. Bạn có thể theo dõi tại mục “Yêu cầu của tôi”.
                    </div>

                    <div class="form-actions">
                        <button class="btn-main" type="submit">
                            Gửi yêu cầu mượn
                        </button>

                        <a class="btn-soft" href="<%= contextPath %>/equipment-detail?id=<%= equipment.getEquipmentId() %>">
                            Xem lại thiết bị
                        </a>

                        <a class="btn-soft" href="<%= contextPath %>/equipments">
                            Quay lại danh sách
                        </a>
                    </div>
                </form>

            <% } else { %>

                <div class="notice-box warning">
                    Thiết bị hiện không ở trạng thái sẵn sàng, nên bạn chưa thể gửi yêu cầu mượn thiết bị này.
                </div>

                <div class="form-actions">
                    <span class="btn-disabled">
                        Không thể gửi yêu cầu
                    </span>

                    <a class="btn-soft" href="<%= contextPath %>/equipments">
                        Chọn thiết bị khác
                    </a>
                </div>

            <% } %>
        </main>

    </section>

</div>

</body>
</html>
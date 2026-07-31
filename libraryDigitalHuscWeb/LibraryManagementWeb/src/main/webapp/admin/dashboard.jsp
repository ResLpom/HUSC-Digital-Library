<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="vn.edu.husc.library.model.User" %>

<%
    String contextPath = request.getContextPath();

    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        currentUser = (User) session.getAttribute("user");
    }

    String fullName = "Admin";
    if (currentUser != null && currentUser.getFullName() != null) {
        fullName = currentUser.getFullName();
    }
%>
<%
    Integer totalDocuments = (Integer) request.getAttribute("totalDocuments");
    Integer totalEquipments = (Integer) request.getAttribute("totalEquipments");
    Integer totalBorrowRequests = (Integer) request.getAttribute("totalBorrowRequests");
    Integer totalUsers = (Integer) request.getAttribute("totalUsers");
    Integer totalMaintenance = (Integer) request.getAttribute("totalMaintenance");

    Integer deCuongFiles = (Integer) request.getAttribute("deCuongFiles");
    Integer nganHangDeFiles = (Integer) request.getAttribute("nganHangDeFiles");
    Integer totalExamFiles = (Integer) request.getAttribute("totalExamFiles");

    if (totalDocuments == null) totalDocuments = 0;
    if (totalEquipments == null) totalEquipments = 0;
    if (totalBorrowRequests == null) totalBorrowRequests = 0;
    if (totalUsers == null) totalUsers = 0;
    if (totalMaintenance == null) totalMaintenance = 0;

    if (deCuongFiles == null) deCuongFiles = 0;
    if (nganHangDeFiles == null) nganHangDeFiles = 0;
    if (totalExamFiles == null) totalExamFiles = 0;
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Admin Dashboard - HUSC Digital Library</title>

    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/common/base.css?v=1">
	<link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/common/components.css?v=1">
	<link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/admin/admin-layout.css?v=1">
    <style>
        .dashboard-grid {
            display: grid;
            grid-template-columns: repeat(4, minmax(0, 1fr));
            gap: 18px;
            margin-bottom: 26px;
        }

        .stat-card {
            background: white;
            border: 1px solid #e2e8f0;
            border-radius: 26px;
            padding: 24px;
            box-shadow: 0 18px 48px rgba(15, 23, 42, 0.06);
        }

        .stat-card span {
            display: block;
            color: #64748b;
            font-size: 13px;
            font-weight: 900;
            margin-bottom: 10px;
        }

        .stat-card strong {
            display: block;
            color: #0f172a;
            font-size: 34px;
            font-weight: 900;
        }

        .dashboard-layout {
            display: grid;
            grid-template-columns: minmax(0, 1.2fr) 380px;
            gap: 24px;
            align-items: start;
        }

        .admin-card {
            background: white;
            border: 1px solid #e2e8f0;
            border-radius: 30px;
            padding: 26px;
            box-shadow: 0 18px 48px rgba(15, 23, 42, 0.06);
        }

        .admin-card h2 {
            margin: 0 0 10px;
            color: #0f172a;
            font-size: 26px;
            font-weight: 900;
        }

        .admin-card p {
            margin: 0 0 20px;
            color: #64748b;
            line-height: 1.6;
        }

        .quick-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 14px;
        }

        .quick-card {
            padding: 18px;
            border-radius: 22px;
            border: 1px solid #e2e8f0;
            background: #f8fafc;
            text-decoration: none;
            color: #0f172a;
            transition: 0.22s ease;
        }

        .quick-card:hover {
            transform: translateY(-4px);
            border-color: #38bdf8;
            background: #f0f9ff;
            text-decoration: none;
        }

        .quick-card strong {
            display: block;
            font-size: 16px;
            font-weight: 900;
            margin-bottom: 6px;
        }

        .quick-card span {
            color: #64748b;
            font-size: 13px;
            line-height: 1.5;
        }

        .notice-list {
            display: grid;
            gap: 12px;
        }

        .notice-item {
            padding: 16px;
            border-radius: 20px;
            background: #f8fafc;
            border: 1px solid #e2e8f0;
        }

        .notice-item strong {
            display: block;
            color: #0f172a;
            margin-bottom: 6px;
        }

        .notice-item span {
            color: #64748b;
            font-size: 13px;
            line-height: 1.5;
        }

        @media (max-width: 1100px) {
            .dashboard-grid,
            .dashboard-layout,
            .quick-grid {
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
                <h1>Admin Dashboard</h1>
                <p>Xin chào, <strong><%= fullName %></strong>. Quản lý tài liệu, kho đề, thiết bị và yêu cầu mượn trả.</p>
            </div>

            <div class="admin-actions">
                <a class="btn-light" href="<%= contextPath %>/index.jsp" target="_blank">Xem website</a>
                <a class="btn-primary" href="<%= contextPath %>/admin/documents?action=new">Thêm tài liệu</a>
            </div>
        </section>

        <section class="dashboard-grid">
            <div class="stat-card">
    			<span>Tài liệu</span>
   				<strong><%= totalDocuments %></strong>
			</div>

			<div class="stat-card">
    			<span>Kho đề</span>
    			<strong><%= totalExamFiles %></strong>
			</div>

			<div class="stat-card">
    			<span>Thiết bị</span>
    			<strong><%= totalEquipments %></strong>
			</div>

<div class="stat-card">
    <span>Yêu cầu mượn</span>
    <strong><%= totalBorrowRequests %></strong>
</div>
        </section>

        <section class="dashboard-layout">

            <div class="admin-card">
                <h2>Truy cập nhanh</h2>
                <p>Chọn chức năng quản lý cần thao tác.</p>

                <div class="quick-grid">
                    <a class="quick-card" href="<%= contextPath %>/admin/documents">
                        <strong>Quản lý tài liệu</strong>
                        <span>Thêm, sửa, xóa và quản lý tài liệu thư viện.</span>
                    </a>

                    <a class="quick-card" href="<%= contextPath %>/admin/exam-bank">
                        <strong>Quản lý Kho đề</strong>
                        <span>Quản lý Đề cương, Ngân hàng đề, upload file và ảnh đề.</span>
                    </a>

                    <a class="quick-card" href="<%= contextPath %>/admin/equipments">
                        <strong>Quản lý thiết bị</strong>
                        <span>Theo dõi thiết bị, trạng thái và thông tin mượn trả.</span>
                    </a>

                    <a class="quick-card" href="<%= contextPath %>/admin/borrow-requests">
                        <strong>Yêu cầu mượn</strong>
                        <span>Duyệt, từ chối hoặc xử lý yêu cầu mượn thiết bị.</span>
                    </a>

                    <a class="quick-card" href="<%= contextPath %>/admin/return-equipment">
                        <strong>Trả thiết bị</strong>
                        <span>Xác nhận trả thiết bị và cập nhật trạng thái.</span>
                    </a>

                    <a class="quick-card" href="<%= contextPath %>/admin/users">
                        <strong>Người dùng</strong>
                        <span>Quản lý tài khoản và quyền truy cập.</span>
                    </a>
                </div>
            </div>

            <aside class="admin-card">
                <h2>Ghi chú hệ thống</h2>
                <p>Các module chính đang dùng trong trang quản trị.</p>

                <div class="notice-list">
                    <div class="notice-item">
    					<strong>Kho đề</strong>
    					<span>Đề cương: <%= deCuongFiles %> file. Ngân hàng đề: <%= nganHangDeFiles %> file.</span>
					</div>

                    <div class="notice-item">
                        <strong>Xem trước file</strong>
                        <span>PDF và ảnh xem trực tiếp. DOCX, XLSX, PPTX tải xuống.</span>
                    </div>

                    <div class="notice-item">
                        <strong>Sidebar dùng chung</strong>
                        <span>Menu admin đang dùng file /admin/includes/admin-sidebar.jsp.</span>
                    </div>
                </div>
            </aside>

        </section>

    </div>
</main>

</body>
</html>
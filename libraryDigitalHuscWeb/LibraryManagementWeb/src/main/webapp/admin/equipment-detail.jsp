<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="vn.edu.husc.library.model.Equipment" %>

<%
    String contextPath = request.getContextPath();
    Equipment equipment = (Equipment) request.getAttribute("equipment");
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Chi tiết thiết bị - Admin</title>

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
            padding: 38px 46px 70px;
        }

        .admin-page {
            max-width: 1100px;
            margin: 0 auto;
        }

        .admin-card {
            background: white;
            border-radius: 28px;
            padding: 30px;
            border: 1px solid #dbeafe;
            box-shadow: 0 24px 60px rgba(15, 23, 42, 0.08);
        }

        h1 {
            margin: 0 0 22px;
            font-size: 32px;
            font-weight: 800;
            letter-spacing: -0.04em;
        }

        .detail-grid {
            display: grid;
            grid-template-columns: 330px minmax(0, 1fr);
            gap: 24px;
            align-items: start;
        }

        .image-box {
            width: 100%;
            height: 330px;
            border-radius: 24px;
            background: #f8fafc;
            border: 1px dashed #cbd5e1;
            overflow: hidden;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #64748b;
            font-weight: 700;
        }

        .image-box img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            display: block;
        }

        .info-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 16px;
        }

        .item {
            padding: 18px;
            border-radius: 18px;
            background: #f8fafc;
            border: 1px solid #e2e8f0;
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

        .item.full {
            grid-column: 1 / -1;
        }

        .actions {
            margin-top: 26px;
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
        }

        .btn {
            min-height: 42px;
            padding: 0 16px;
            border-radius: 999px;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            background: #e0f2fe;
            color: #0369a1;
            border: 1px solid #bae6fd;
        }

        .btn.primary {
            background: linear-gradient(135deg, #0284c7, #06b6d4);
            color: white;
            border-color: transparent;
        }

        .btn.warning {
            background: #fef3c7;
            color: #92400e;
            border-color: #fde68a;
        }

        @media (max-width: 900px) {
            .admin-main {
                margin-left: 0;
                padding: 24px 16px 60px;
            }

            .detail-grid {
                grid-template-columns: 1fr;
            }

            .info-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>

<body>

<jsp:include page="/admin/includes/admin-sidebar.jsp" />

<main class="admin-main">
    <div class="admin-page">
        <section class="admin-card">

            <% if (equipment == null) { %>

                <h1>Không tìm thấy thiết bị</h1>

                <div class="actions">
                    <a class="btn" href="<%= contextPath %>/admin/equipments">
                        Quay lại danh sách
                    </a>
                </div>

            <% } else { %>

                <h1><%= equipment.getEquipmentName() %></h1>

                <div class="detail-grid">

                    <div class="image-box">
                        <% if (equipment.getImagePath() != null && !equipment.getImagePath().trim().isEmpty()) { %>
                            <img src="<%= contextPath %>/upload-image/equipments/<%= equipment.getImagePath() %>"
                                 alt="<%= equipment.getEquipmentName() %>">
                        <% } else { %>
                            Chưa có ảnh
                        <% } %>
                    </div>

                    <div>
                        <div class="info-grid">
                            <div class="item">
                                <span>Mã thiết bị</span>
                                <strong><%= equipment.getCode() %></strong>
                            </div>

                            <div class="item">
                                <span>Loại thiết bị</span>
                                <strong><%= equipment.getTypeName() %></strong>
                            </div>

                            <div class="item">
                                <span>Vị trí</span>
                                <strong><%= equipment.getLocation() %></strong>
                            </div>

                            <div class="item">
                                <span>Trạng thái</span>
                                <strong><%= equipment.getStatus() %></strong>
                            </div>

                            <div class="item">
                                <span>Giá trị</span>
                                <strong><%= equipment.getValueMoney() %></strong>
                            </div>

                            <div class="item">
                                <span>ID</span>
                                <strong><%= equipment.getEquipmentId() %></strong>
                            </div>

                            <div class="item full">
                                <span>Mô tả</span>
                                <strong><%= equipment.getDescription() %></strong>
                            </div>
                        </div>

                        <div class="actions">
                            <a class="btn" href="<%= contextPath %>/admin/equipments">
                                Quay lại
                            </a>

                            <a class="btn primary"
                               href="<%= contextPath %>/admin/equipments?action=edit&id=<%= equipment.getEquipmentId() %>">
                                Cập nhật thiết bị
                            </a>

                            <a class="btn warning"
                               href="<%= contextPath %>/admin/maintenance-records?action=form&equipmentId=<%= equipment.getEquipmentId() %>">
                                Thêm bảo trì
                            </a>
                        </div>
                    </div>

                </div>

            <% } %>

        </section>
    </div>
</main>

</body>
</html>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
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

    private String getText(Object object, String methodName) {
        Object value = call(object, methodName);
        return value == null ? "" : String.valueOf(value);
    }

    private int getInt(Object object, String methodName) {
        Object value = call(object, methodName);

        if (value == null) return 0;

        try {
            return Integer.parseInt(String.valueOf(value));
        } catch (Exception e) {
            return 0;
        }
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
        if ("PENDING".equalsIgnoreCase(status)) return "Chờ xử lý";
        if ("PROCESSING".equalsIgnoreCase(status)) return "Đang xử lý";
        if ("DONE".equalsIgnoreCase(status)) return "Đã hoàn tất";
        if ("COMPLETED".equalsIgnoreCase(status)) return "Đã hoàn tất";
        if ("CANCELED".equalsIgnoreCase(status)) return "Đã hủy";
        if ("CANCELLED".equalsIgnoreCase(status)) return "Đã hủy";

        return status == null || status.trim().isEmpty() ? "Chưa rõ" : status;
    }

    private String statusClass(String status) {
        if ("PENDING".equalsIgnoreCase(status)) return "pending";
        if ("PROCESSING".equalsIgnoreCase(status)) return "processing";
        if ("DONE".equalsIgnoreCase(status) || "COMPLETED".equalsIgnoreCase(status)) return "done";
        if ("CANCELED".equalsIgnoreCase(status) || "CANCELLED".equalsIgnoreCase(status)) return "cancelled";
        return "neutral";
    }
%>

<%
    String contextPath = request.getContextPath();

    Object record = request.getAttribute("record");

    if (record == null) {
        record = request.getAttribute("maintenanceRecord");
    }

    int maintenanceId = getInt(record, "getMaintenanceId");
    int equipmentId = getInt(record, "getEquipmentId");

    String equipmentName = getText(record, "getEquipmentName");
    String equipmentCode = getText(record, "getEquipmentCode");
    String equipmentLocation = getText(record, "getEquipmentLocation");
    String typeName = getText(record, "getTypeName");
    String issueDescription = getText(record, "getIssueDescription");
    String managerNote = getText(record, "getManagerNote");
    String status = getText(record, "getMaintenanceStatus");
    String createdAt = getText(record, "getCreatedAt");
    String updatedAt = getText(record, "getUpdatedAt");
    String completedAt = getText(record, "getCompletedAt");
    String managerName = getText(record, "getManagerName");
    String createdByName = getText(record, "getCreatedByName");
    String completedByName = getText(record, "getCompletedByName");

    if (equipmentName.trim().isEmpty()) equipmentName = "Thiết bị chưa xác định";
    if (equipmentCode.trim().isEmpty()) equipmentCode = "Chưa cập nhật";
    if (equipmentLocation.trim().isEmpty()) equipmentLocation = "Chưa cập nhật";
    if (typeName.trim().isEmpty()) typeName = "Thiết bị";
    if (issueDescription.trim().isEmpty()) issueDescription = "Chưa có mô tả tình trạng.";
    if (managerNote.trim().isEmpty()) managerNote = "Chưa có ghi chú.";
    if (status.trim().isEmpty()) status = getText(record, "getStatus");
    if (createdAt.trim().isEmpty()) createdAt = "Chưa cập nhật";
    if (updatedAt.trim().isEmpty()) updatedAt = "Chưa cập nhật";
    if (completedAt.trim().isEmpty()) completedAt = "Chưa cập nhật";
    if (managerName.trim().isEmpty()) managerName = "Chưa cập nhật";
    if (createdByName.trim().isEmpty()) createdByName = "Chưa cập nhật";
    if (completedByName.trim().isEmpty()) completedByName = "Chưa cập nhật";
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Chi tiết bảo trì - Admin</title>

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
            padding: 38px 46px 70px;
        }

        .admin-page {
            max-width: 1120px;
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
            align-items: center;
            justify-content: space-between;
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
            line-height: 1.6;
        }

        .status-pill {
            min-height: 38px;
            padding: 0 16px;
            border-radius: 999px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-weight: 800;
            font-size: 13px;
            border: 1px solid transparent;
        }

        .status-pill.pending {
            background: #fef3c7;
            color: #92400e;
            border-color: #fde68a;
        }

        .status-pill.processing {
            background: #dbeafe;
            color: #1d4ed8;
            border-color: #bfdbfe;
        }

        .status-pill.done {
            background: #dcfce7;
            color: #166534;
            border-color: #bbf7d0;
        }

        .status-pill.cancelled {
            background: #ffe4e6;
            color: #be123c;
            border-color: #fecdd3;
        }

        .status-pill.neutral {
            background: #f1f5f9;
            color: #475569;
            border-color: #e2e8f0;
        }

        .card {
            padding: 30px;
        }

        .detail-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 18px;
        }

        .info-box {
            padding: 18px;
            border-radius: 20px;
            background: #f8fafc;
            border: 1px solid #e2e8f0;
        }

        .info-box.full {
            grid-column: 1 / -1;
        }

        .info-box.warning {
            background: #fff7ed;
            border-color: #fed7aa;
        }

        .info-box span {
            display: block;
            margin-bottom: 7px;
            color: #64748b;
            font-size: 13px;
            font-weight: 700;
        }

        .info-box strong {
            display: block;
            color: #0f172a;
            font-size: 15px;
            line-height: 1.55;
            font-weight: 700;
            white-space: pre-line;
        }

        .actions {
            margin-top: 26px;
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
        }

        .btn {
            min-height: 44px;
            border-radius: 999px;
            padding: 0 18px;
            border: none;
            cursor: pointer;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 14px;
            font-weight: 700;
            font-family: inherit;
        }

        .btn.primary {
            color: white;
            background: linear-gradient(135deg, #0284c7, #06b6d4);
        }

        .btn.secondary {
            color: #0369a1;
            background: #e0f2fe;
            border: 1px solid #bae6fd;
        }

        .btn.success {
            color: #166534;
            background: #dcfce7;
            border: 1px solid #bbf7d0;
        }

        .btn.warning {
            color: #92400e;
            background: #fef3c7;
            border: 1px solid #fde68a;
        }

        .btn:hover {
            transform: translateY(-2px);
            text-decoration: none;
        }

        @media (max-width: 900px) {
            .admin-main {
                margin-left: 0;
                padding: 24px 16px 60px;
            }

            .topbar {
                flex-direction: column;
                align-items: flex-start;
            }

            .detail-grid {
                grid-template-columns: 1fr;
            }

            .info-box.full {
                grid-column: auto;
            }
        }
    </style>
</head>

<body>

<jsp:include page="/admin/includes/admin-sidebar.jsp" />

<main class="admin-main">
    <div class="admin-page">

        <section class="topbar">
            <div>
                <h1>Chi tiết bảo trì #<%= maintenanceId %></h1>
                <p>Theo dõi tình trạng bảo trì, thiết bị liên quan và thông tin xử lý.</p>
            </div>

            <span class="status-pill <%= statusClass(status) %>">
                <%= h(statusText(status)) %>
            </span>
        </section>

        <section class="card">

            <% if (record == null) { %>

                <div class="info-box full">
                    <span>Thông báo</span>
                    <strong>Không tìm thấy bản ghi bảo trì.</strong>
                </div>

                <div class="actions">
                    <a class="btn secondary" href="<%= contextPath %>/admin/maintenance-records">
                        Quay lại
                    </a>
                </div>

            <% } else { %>

                <div class="detail-grid">

                    <div class="info-box">
                        <span>Mã bảo trì</span>
                        <strong>#<%= maintenanceId %></strong>
                    </div>

                    <div class="info-box">
                        <span>Trạng thái</span>
                        <strong><%= h(statusText(status)) %></strong>
                    </div>

                    <div class="info-box">
                        <span>Tên thiết bị</span>
                        <strong><%= h(equipmentName) %></strong>
                    </div>

                    <div class="info-box">
                        <span>Mã thiết bị</span>
                        <strong><%= h(equipmentCode) %></strong>
                    </div>

                    <div class="info-box">
                        <span>Loại thiết bị</span>
                        <strong><%= h(typeName) %></strong>
                    </div>

                    <div class="info-box">
                        <span>Vị trí</span>
                        <strong><%= h(equipmentLocation) %></strong>
                    </div>

                    <div class="info-box">
                        <span>Ngày ghi nhận</span>
                        <strong><%= h(createdAt) %></strong>
                    </div>

                    <div class="info-box">
                        <span>Ngày cập nhật</span>
                        <strong><%= h(updatedAt) %></strong>
                    </div>

                    <div class="info-box">
                        <span>Ngày hoàn thành</span>
                        <strong><%= h(completedAt) %></strong>
                    </div>

                    <div class="info-box">
                        <span>Người quản lý</span>
                        <strong><%= h(managerName) %></strong>
                    </div>

                    <div class="info-box">
                        <span>Người tạo</span>
                        <strong><%= h(createdByName) %></strong>
                    </div>

                    <div class="info-box">
                        <span>Người hoàn thành</span>
                        <strong><%= h(completedByName) %></strong>
                    </div>

                    <div class="info-box warning full">
                        <span>Mô tả lỗi / tình trạng</span>
                        <strong><%= h(issueDescription) %></strong>
                    </div>

                    <div class="info-box full">
                        <span>Ghi chú bảo trì</span>
                        <strong><%= h(managerNote) %></strong>
                    </div>

                </div>

                <div class="actions">
                    <a class="btn secondary" href="<%= contextPath %>/admin/maintenance-records">
                        Quay lại
                    </a>

                    <% if (equipmentId > 0) { %>
                        <a class="btn primary"
                           href="<%= contextPath %>/admin/equipments?action=view&id=<%= equipmentId %>">
                            Xem thiết bị
                        </a>
                    <% } %>

                    <% if (!"DONE".equalsIgnoreCase(status) && !"COMPLETED".equalsIgnoreCase(status)) { %>
                        <a class="btn success"
                           href="<%= contextPath %>/admin/maintenance-records?action=complete&id=<%= maintenanceId %>"
                           onclick="return confirm('Xác nhận hoàn tất bảo trì bản ghi này?');">
                            Hoàn tất bảo trì
                        </a>
                    <% } %>

                    <% if (equipmentId > 0) { %>
                        <a class="btn warning"
                           href="<%= contextPath %>/admin/maintenance-records?action=form&equipmentId=<%= equipmentId %>">
                            Tạo bảo trì mới
                        </a>
                    <% } %>
                </div>

            <% } %>

        </section>

    </div>
</main>

</body>
</html>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="vn.edu.husc.library.model.Equipment" %>

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

    List<Equipment> equipments = (List<Equipment>) request.getAttribute("equipments");

    Integer selectedEquipmentIdObj = (Integer) request.getAttribute("selectedEquipmentId");
    int selectedEquipmentId = selectedEquipmentIdObj == null ? 0 : selectedEquipmentIdObj;

    String error = (String) session.getAttribute("adminMaintenanceError");

    if (error != null) {
        session.removeAttribute("adminMaintenanceError");
    }
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Thêm bảo trì - Admin</title>

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
            max-width: 1000px;
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

        .card {
            padding: 30px;
        }

        .alert-error {
            margin-bottom: 20px;
            padding: 14px 16px;
            border-radius: 18px;
            background: #ffe4e6;
            border: 1px solid #fecdd3;
            color: #be123c;
            font-weight: 700;
        }

        label {
            display: block;
            margin: 16px 0 8px;
            color: #334155;
            font-weight: 700;
        }

        select,
        input,
        textarea {
            width: 100%;
            border: 1px solid #cbd5e1;
            border-radius: 18px;
            background: #f8fafc;
            color: #0f172a;
            font-weight: 500;
            font-size: 14px;
            outline: none;
            font-family: inherit;
        }

        select,
        input {
            height: 48px;
            padding: 0 15px;
        }

        textarea {
            min-height: 140px;
            padding: 15px;
            resize: vertical;
            line-height: 1.6;
        }

        select:focus,
        input:focus,
        textarea:focus {
            border-color: #38bdf8;
            box-shadow: 0 0 0 4px rgba(14, 165, 233, 0.12);
            background: white;
        }

        .hint {
            margin-top: 7px;
            color: #64748b;
            font-size: 12px;
            font-weight: 500;
            line-height: 1.5;
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
            padding: 0 20px;
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
        }
    </style>
</head>

<body>

<jsp:include page="/admin/includes/admin-sidebar.jsp" />

<main class="admin-main">
    <div class="admin-page">

        <section class="topbar">
            <div>
                <h1>Thêm ghi nhận bảo trì</h1>
                <p>
                    Chọn thiết bị và nhập tình trạng cần bảo trì.
                    Sau khi tạo, thiết bị sẽ được chuyển sang trạng thái bảo trì.
                </p>
            </div>

            <a class="btn secondary" href="<%= contextPath %>/admin/maintenance-records">
                Quay lại
            </a>
        </section>

        <section class="card">

            <% if (error != null && !error.trim().isEmpty()) { %>
                <div class="alert-error">
                    <%= h(error) %>
                </div>
            <% } %>

            <form method="post" action="<%= contextPath %>/admin/maintenance-records">

                <input type="hidden" name="action" value="create">

                <label>Thiết bị cần bảo trì *</label>

                <select name="equipmentId" required>
                    <option value="">-- Chọn thiết bị --</option>

                    <% if (equipments != null) {
                        for (Equipment equipment : equipments) {
                            if (equipment == null) continue;

                            String name = equipment.getEquipmentName();
                            String code = equipment.getCode();
                            String location = equipment.getLocation();

                            if (name == null) name = "Thiết bị chưa đặt tên";
                            if (code == null) code = "";
                            if (location == null) location = "";
                    %>

                        <option value="<%= equipment.getEquipmentId() %>"
                                <%= selectedEquipmentId == equipment.getEquipmentId() ? "selected" : "" %>>
                            <%= h(name) %>
                            <% if (!code.trim().isEmpty()) { %>
                                - <%= h(code) %>
                            <% } %>
                            <% if (!location.trim().isEmpty()) { %>
                                - <%= h(location) %>
                            <% } %>
                        </option>

                    <%  }
                    } %>
                </select>

                <div class="hint">
                    Danh sách này lấy từ bảng thiết bị hiện có trong hệ thống.
                </div>

                <label>Ghi chú quản lý</label>

                <input type="text"
                       name="managerNote"
                       placeholder="Ví dụ: Ưu tiên kiểm tra trong tuần này">

                <label>Tình trạng cần bảo trì *</label>

                <textarea name="issueDescription"
                          required
                          placeholder="Ví dụ: Máy chiếu bị mờ, cần kiểm tra bóng đèn..."></textarea>

                <div class="actions">
                    <button class="btn primary" type="submit">
                        Thêm ghi nhận
                    </button>

                    <a class="btn secondary" href="<%= contextPath %>/admin/maintenance-records">
                        Hủy
                    </a>
                </div>

            </form>
        </section>

    </div>
</main>

</body>
</html>
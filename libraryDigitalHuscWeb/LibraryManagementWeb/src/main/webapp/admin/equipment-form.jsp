<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.lang.reflect.Method" %>
<%@ page import="vn.edu.husc.library.model.Equipment" %>

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
%>

<%
    String contextPath = request.getContextPath();

    Equipment equipment = (Equipment) request.getAttribute("equipment");
    boolean editMode = equipment != null && equipment.getEquipmentId() > 0;

    List<?> types = (List<?>) request.getAttribute("equipmentTypes");

    if (types == null) {
        types = (List<?>) request.getAttribute("types");
    }

    int equipmentId = editMode ? equipment.getEquipmentId() : 0;
    int selectedTypeId = editMode ? equipment.getEquipmentTypeId() : 0;

    String equipmentName = editMode && equipment.getEquipmentName() != null ? equipment.getEquipmentName() : "";
    String code = editMode && equipment.getCode() != null ? equipment.getCode() : "";
    String description = editMode && equipment.getDescription() != null ? equipment.getDescription() : "";
    String location = editMode && equipment.getLocation() != null ? equipment.getLocation() : "";
    String imagePath = editMode && equipment.getImagePath() != null ? equipment.getImagePath() : "";
    String status = editMode && equipment.getStatus() != null ? equipment.getStatus() : "AVAILABLE";
    double valueMoney = editMode ? equipment.getValueMoney() : 0;
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title><%= editMode ? "Sửa thiết bị" : "Thêm thiết bị" %> - HUSC Digital Library</title>

    <link rel="stylesheet" href="<%= contextPath %>/assets/css/admin-layout.css?v=equipment-form-2">

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
            max-width: 1050px;
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
            align-items: center;
            justify-content: space-between;
            gap: 16px;
        }

        .admin-topbar h1 {
            margin: 0;
            font-size: 30px;
            font-weight: 800;
            letter-spacing: -0.04em;
        }

        .admin-topbar p {
            margin: 8px 0 0;
            color: #475569;
            font-weight: 500;
            line-height: 1.6;
        }

        .admin-card {
            padding: 28px;
        }

        .form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 18px;
        }

        .form-field.full {
            grid-column: 1 / -1;
        }

        label {
            display: block;
            margin-bottom: 8px;
            font-weight: 700;
            color: #334155;
        }

        input,
        select,
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

        input,
        select {
            height: 48px;
            padding: 0 15px;
        }

        textarea {
            min-height: 120px;
            padding: 15px;
            resize: vertical;
            line-height: 1.6;
        }

        input:focus,
        select:focus,
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

        .preview-box {
            margin-top: 12px;
            width: 150px;
            height: 110px;
            border-radius: 18px;
            background: #f8fafc;
            border: 1px dashed #cbd5e1;
            overflow: hidden;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #64748b;
            font-size: 13px;
            font-weight: 600;
        }

        .preview-box img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            display: block;
        }

        .form-actions {
            margin-top: 24px;
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
        }

        .admin-btn {
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

        .admin-btn.primary {
            color: white;
            background: linear-gradient(135deg, #0284c7, #06b6d4);
        }

        .admin-btn.secondary {
            color: #0369a1;
            background: #e0f2fe;
            border: 1px solid #bae6fd;
        }

        .admin-btn.danger {
            color: #be123c;
            background: #ffe4e6;
            border: 1px solid #fecdd3;
        }

        .admin-btn:hover {
            transform: translateY(-2px);
            text-decoration: none;
        }

        @media (max-width: 900px) {
            .admin-main {
                margin-left: 0;
                padding: 24px 16px 60px;
            }

            .form-grid {
                grid-template-columns: 1fr;
            }

            .admin-topbar {
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

        <section class="admin-topbar">
            <div>
                <h1><%= editMode ? "Sửa thiết bị" : "Thêm thiết bị" %></h1>

                <p>
                    Nhập thông tin thiết bị, hình ảnh, vị trí và trạng thái vận hành.
                </p>
            </div>

            <a class="admin-btn secondary" href="<%= contextPath %>/admin/equipments">
                Quay lại
            </a>
        </section>

        <section class="admin-card">

            <form method="post" action="<%= contextPath %>/admin/equipments">

                <input type="hidden" name="action" value="<%= editMode ? "update" : "insert" %>">
                <input type="hidden" name="equipmentId" value="<%= equipmentId %>">
                <input type="hidden" name="id" value="<%= equipmentId %>">

                <div class="form-grid">

                    <div class="form-field">
                        <label>Tên thiết bị *</label>

                        <input type="text"
                               name="equipmentName"
                               required
                               value="<%= h(equipmentName) %>"
                               placeholder="Ví dụ: Laptop Dell Inspiron 15">
                    </div>

                    <div class="form-field">
                        <label>Mã thiết bị *</label>

                        <input type="text"
                               name="code"
                               required
                               value="<%= h(code) %>"
                               placeholder="Ví dụ: LT001">
                    </div>

                    <div class="form-field">
                        <label>Loại thiết bị *</label>

                        <select name="equipmentTypeId" required>
                            <option value="">-- Chọn loại thiết bị --</option>

                            <% if (types != null) {
                                for (Object type : types) {
                                    int typeId = getInt(type, "getId");

                                    if (typeId == 0) {
                                        typeId = getInt(type, "getValue");
                                    }

                                    if (typeId == 0) {
                                        typeId = getInt(type, "getEquipmentTypeId");
                                    }

                                    if (typeId == 0) {
                                        typeId = getInt(type, "getTypeId");
                                    }

                                    String typeName = getText(type, "getName");

                                    if (typeName.trim().isEmpty()) {
                                        typeName = getText(type, "getLabel");
                                    }

                                    if (typeName.trim().isEmpty()) {
                                        typeName = getText(type, "getTypeName");
                                    }

                                    if (typeName.trim().isEmpty()) {
                                        typeName = "Loại thiết bị";
                                    }
                            %>

                                <option value="<%= typeId %>"
                                        <%= selectedTypeId == typeId ? "selected" : "" %>>
                                    <%= h(typeName) %>
                                </option>

                            <%  }
                            } %>
                        </select>
                    </div>

                    <div class="form-field">
                        <label>Trạng thái</label>

                        <select name="status">
                            <option value="AVAILABLE"
                                    <%= "AVAILABLE".equalsIgnoreCase(status) ? "selected" : "" %>>
                                Sẵn sàng
                            </option>

                            <option value="BORROWED"
                                    <%= "BORROWED".equalsIgnoreCase(status) || "BORROWING".equalsIgnoreCase(status) ? "selected" : "" %>>
                                Đang mượn
                            </option>

                            <option value="MAINTENANCE"
                                    <%= "MAINTENANCE".equalsIgnoreCase(status) ? "selected" : "" %>>
                                Bảo trì
                            </option>

                            <option value="BROKEN"
                                    <%= "BROKEN".equalsIgnoreCase(status) ? "selected" : "" %>>
                                Hỏng
                            </option>

                            <option value="LOST"
                                    <%= "LOST".equalsIgnoreCase(status) ? "selected" : "" %>>
                                Mất
                            </option>
                        </select>
                    </div>

                    <div class="form-field">
                        <label>Vị trí</label>

                        <input type="text"
                               name="location"
                               value="<%= h(location) %>"
                               placeholder="Ví dụ: Phòng A101">
                    </div>

                    <div class="form-field">
                        <label>Giá trị</label>

                        <input type="number"
                               name="valueMoney"
                               value="<%= valueMoney %>"
                               min="0"
                               step="1000"
                               placeholder="Ví dụ: 15000000">
                    </div>

                    <div class="form-field full">
                        <label>Ảnh thiết bị</label>

                        <input type="text"
                               name="imagePath"
                               value="<%= h(imagePath) %>"
                               placeholder="Ví dụ: laptop-dell.jpg">

                        <div class="hint">
                            Chỉ nhập tên file ảnh, ví dụ: <b>laptop-dell.jpg</b>.
                            Ảnh đặt tại: <b>D:/upLoad/equipment</b>
                        </div>

                        <% if (imagePath != null && !imagePath.trim().isEmpty()) { %>
    <div class="preview-box">
        <img src="<%= contextPath %>/upload-image/equipments/<%= imagePath %>"
             alt="Ảnh thiết bị">
    </div>
<% } else { %>
    <div class="preview-box">
        Chưa có ảnh
    </div>
<% } %>
                    </div>

                    <div class="form-field full">
                        <label>Mô tả</label>

                        <textarea name="description"
                                  placeholder="Mô tả tình trạng, thông số hoặc ghi chú thiết bị"><%= h(description) %></textarea>
                    </div>

                </div>

                <div class="form-actions">
                    <button class="admin-btn primary" type="submit">
                        <%= editMode ? "Cập nhật thiết bị" : "Thêm thiết bị" %>
                    </button>

                    <% if (editMode) { %>
                        <a class="admin-btn secondary"
                           href="<%= contextPath %>/admin/equipments?action=view&id=<%= equipmentId %>">
                            Xem chi tiết
                        </a>
                    <% } %>

                    <a class="admin-btn secondary" href="<%= contextPath %>/admin/equipments">
                        Hủy
                    </a>
                </div>

            </form>
        </section>

    </div>
</main>

</body>
</html>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.lang.reflect.Method" %>
<%@ page import="vn.edu.husc.library.model.User" %>

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

    private double getDouble(Object object, String methodName) {
        Object value = call(object, methodName);

        if (value == null) return 0;

        try {
            return Double.parseDouble(String.valueOf(value));
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

    private String urlEncode(String value) {
        if (value == null) return "";

        try {
            return URLEncoder.encode(value, "UTF-8").replace("+", "%20");
        } catch (Exception e) {
            return "";
        }
    }

    private String statusText(String status) {
        if ("AVAILABLE".equalsIgnoreCase(status)) return "Sẵn sàng";
        if ("BORROWED".equalsIgnoreCase(status) || "BORROWING".equalsIgnoreCase(status)) return "Đang mượn";
        if ("MAINTENANCE".equalsIgnoreCase(status)) return "Bảo trì";
        if ("BROKEN".equalsIgnoreCase(status)) return "Hỏng";
        if ("LOST".equalsIgnoreCase(status)) return "Mất";

        return status == null || status.trim().isEmpty() ? "Chưa rõ" : status;
    }

    private String statusClass(String status) {
        if ("AVAILABLE".equalsIgnoreCase(status)) return "status-available";
        if ("BORROWED".equalsIgnoreCase(status) || "BORROWING".equalsIgnoreCase(status)) return "status-borrowed";
        if ("MAINTENANCE".equalsIgnoreCase(status)) return "status-maintenance";
        if ("BROKEN".equalsIgnoreCase(status) || "LOST".equalsIgnoreCase(status)) return "status-danger";

        return "status-neutral";
    }

    private String money(double value) {
        if (value <= 0) return "Chưa cập nhật";

        try {
            return String.format("%,.0f VNĐ", value);
        } catch (Exception e) {
            return String.valueOf(value);
        }
    }
%>

<%
    String contextPath = request.getContextPath();

    Object equipment = request.getAttribute("equipment");

    User currentUser = null;

    if (session != null) {
        currentUser = (User) session.getAttribute("currentUser");

        if (currentUser == null) {
            currentUser = (User) session.getAttribute("user");
        }
    }

    boolean loggedIn = currentUser != null;

    int equipmentId = getInt(equipment, "getEquipmentId");

    String equipmentName = getText(equipment, "getEquipmentName");
    String description = getText(equipment, "getDescription");
    String typeName = getText(equipment, "getTypeName");
    String code = getText(equipment, "getCode");
    String location = getText(equipment, "getLocation");
    String status = getText(equipment, "getStatus");
    String imagePath = getText(equipment, "getImagePath");
    double valueMoney = getDouble(equipment, "getValueMoney");

    if (equipmentName.trim().isEmpty()) equipmentName = "Chi tiết thiết bị";
    if (description.trim().isEmpty()) description = "Thiết bị này chưa có mô tả chi tiết.";
    if (typeName.trim().isEmpty()) typeName = "Thiết bị";
    if (code.trim().isEmpty()) code = "Chưa cập nhật";
    if (location.trim().isEmpty()) location = "Chưa cập nhật";
    if (status.trim().isEmpty()) status = "UNKNOWN";

    boolean hasImage = imagePath != null && !imagePath.trim().isEmpty();
    boolean available = "AVAILABLE".equalsIgnoreCase(status);
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title><%= h(equipmentName) %> - HUSC Digital Library</title>

    <link rel="stylesheet" href="<%= contextPath %>/assets/css/member/member-layout.css?v=9">

    <style>
        .detail-layout {
            display: grid;
            grid-template-columns: 420px minmax(0, 1fr);
            gap: 28px;
            align-items: start;
        }

        .cover-card,
        .info-card {
            border-radius: 30px;
            background: rgba(255, 255, 255, 0.98);
            border: 1px solid #ccfbf1;
            box-shadow: 0 22px 55px rgba(15, 23, 42, 0.08);
            overflow: hidden;
        }

        .cover-box {
            width: 100%;
            height: 520px;
            background: linear-gradient(135deg, #ccfbf1, #dbeafe);
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .cover-box img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            display: block;
        }

        .cover-placeholder {
            width: 96px;
            height: 96px;
            border-radius: 30px;
            background: rgba(255, 255, 255, 0.72);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 46px;
        }

        .cover-caption {
            padding: 20px 22px;
            border-top: 1px solid #e2e8f0;
        }

        .cover-caption strong {
            display: block;
            font-size: 16px;
            font-weight: 800;
            color: #0f172a;
            line-height: 1.4;
        }

        .cover-caption span {
            display: block;
            margin-top: 6px;
            color: #64748b;
            font-size: 13px;
            font-weight: 600;
        }

        .info-card {
            padding: 32px;
        }

        .detail-title {
            margin: 0;
            font-size: 34px;
            line-height: 1.18;
            font-weight: 800;
            letter-spacing: -0.04em;
            color: #0f172a;
        }

        .detail-desc {
            margin: 18px 0 0;
            color: #475569;
            font-size: 15px;
            line-height: 1.75;
            font-weight: 500;
        }

        .meta-grid {
            margin-top: 28px;
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 16px;
        }

        .meta-item {
            padding: 18px;
            border-radius: 22px;
            background: #f8fafc;
            border: 1px solid #e2e8f0;
        }

        .meta-item span {
            display: block;
            color: #64748b;
            font-size: 12px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.08em;
            margin-bottom: 7px;
        }

        .meta-item strong {
            display: block;
            color: #0f172a;
            font-size: 15px;
            font-weight: 700;
            line-height: 1.45;
        }

        .status-pill {
            min-height: 34px;
            padding: 0 13px;
            border-radius: 999px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 13px;
            font-weight: 700;
            border: 1px solid transparent;
            width: fit-content;
        }

        .status-available {
            background: #dcfce7;
            color: #166534;
            border-color: #bbf7d0;
        }

        .status-borrowed {
            background: #fef3c7;
            color: #92400e;
            border-color: #fde68a;
        }

        .status-maintenance {
            background: #ede9fe;
            color: #5b21b6;
            border-color: #ddd6fe;
        }

        .status-danger {
            background: #ffe4e6;
            color: #be123c;
            border-color: #fecdd3;
        }

        .status-neutral {
            background: #f1f5f9;
            color: #475569;
            border-color: #e2e8f0;
        }

        .detail-actions {
            margin-top: 30px;
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
        }

        .btn-primary,
        .btn-light,
        .btn-disabled {
            min-height: 44px;
            padding: 0 18px;
            border-radius: 999px;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 13px;
            font-weight: 700;
            border: 1px solid transparent;
            white-space: nowrap;
        }

        .btn-primary {
            color: white;
            background: linear-gradient(135deg, #0f766e, #06b6d4);
            box-shadow: 0 14px 28px rgba(20, 184, 166, 0.18);
        }

        .btn-light {
            color: #0f766e;
            background: #ecfeff;
            border-color: #ccfbf1;
        }

        .btn-disabled {
            color: #64748b;
            background: #f1f5f9;
            border-color: #e2e8f0;
            pointer-events: none;
        }

        .btn-primary:hover,
        .btn-light:hover {
            text-decoration: none;
            transform: translateY(-2px);
        }

        .notice-box {
            margin-top: 24px;
            padding: 18px 20px;
            border-radius: 22px;
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            color: #475569;
            font-size: 14px;
            font-weight: 600;
            line-height: 1.65;
        }

        @media (max-width: 1050px) {
            .detail-layout {
                grid-template-columns: 1fr;
            }

            .cover-box {
                height: 420px;
            }
        }

        @media (max-width: 720px) {
            .info-card {
                padding: 24px;
            }

            .detail-title {
                font-size: 28px;
            }

            .meta-grid {
                grid-template-columns: 1fr;
            }

            .cover-box {
                height: 340px;
            }
        }
    </style>
</head>

<body>

<jsp:include page="/includes/member-header.jsp" />

<div class="member-page-shell">

    <section class="member-hero cyan">
        <div>
            <div class="member-hero-badge">Equipment Detail</div>

            <h1>Chi tiết thiết bị</h1>

            <p>
                Xem thông tin thiết bị, vị trí, trạng thái và gửi yêu cầu mượn thiết bị
                phục vụ học tập khi thiết bị sẵn sàng.
            </p>
        </div>

        <div class="member-hero-stat">
            <strong><%= h(statusText(status)) %></strong>
            <span>Trạng thái thiết bị</span>
        </div>
    </section>

    <div class="member-section-head">
        <div>
            <p class="member-section-kicker">Equipment Information</p>
            <h2>Thông tin thiết bị</h2>
        </div>

        <p>Kiểm tra tình trạng thiết bị trước khi gửi yêu cầu mượn.</p>
    </div>

    <% if (equipment == null) { %>

        <div class="member-empty-box">
            Không tìm thấy thiết bị.
            <br><br>
            <a class="btn-primary" href="<%= contextPath %>/equipments">Quay lại danh sách thiết bị</a>
        </div>

    <% } else { %>

        <section class="detail-layout">

            <aside class="cover-card">
                <div class="cover-box">
                    <% if (hasImage) { %>
                        <img src="<%= contextPath %>/upload-image/equipments/<%= urlEncode(imagePath) %>"
                             alt="<%= h(equipmentName) %>">
                    <% } else { %>
                        <div class="cover-placeholder">💻</div>
                    <% } %>
                </div>

                <div class="cover-caption">
                    <strong><%= h(equipmentName) %></strong>
                    <span><%= h(typeName) %> · <%= h(code) %></span>
                </div>
            </aside>

            <article class="info-card">
                <h2 class="detail-title"><%= h(equipmentName) %></h2>

                <p class="detail-desc">
                    <%= h(description) %>
                </p>

                <div class="meta-grid">
                    <div class="meta-item">
                        <span>Loại thiết bị</span>
                        <strong><%= h(typeName) %></strong>
                    </div>

                    <div class="meta-item">
                        <span>Mã thiết bị</span>
                        <strong><%= h(code) %></strong>
                    </div>

                    <div class="meta-item">
                        <span>Vị trí</span>
                        <strong><%= h(location) %></strong>
                    </div>

                    <div class="meta-item">
                        <span>Giá trị</span>
                        <strong><%= h(money(valueMoney)) %></strong>
                    </div>

                    <div class="meta-item">
                        <span>Trạng thái</span>
                        <strong>
                            <span class="status-pill <%= statusClass(status) %>">
                                <%= h(statusText(status)) %>
                            </span>
                        </strong>
                    </div>

                    <div class="meta-item">
                        <span>Khả năng mượn</span>
                        <strong><%= available ? "Có thể gửi yêu cầu" : "Tạm thời chưa thể mượn" %></strong>
                    </div>
                </div>

                <div class="detail-actions">
                    <a class="btn-light" href="<%= contextPath %>/equipments">
                        ← Quay lại
                    </a>

                    <% if (available && loggedIn) { %>
                        <a class="btn-primary"
                           href="<%= contextPath %>/borrow-request?equipmentId=<%= equipmentId %>">
                            Gửi yêu cầu mượn
                        </a>
                    <% } else if (available) { %>
                        <a class="btn-primary"
                           href="<%= contextPath %>/login.jsp">
                            Đăng nhập để mượn
                        </a>
                    <% } else { %>
                        <span class="btn-disabled">
                            Thiết bị chưa sẵn sàng
                        </span>
                    <% } %>
                </div>

                <div class="notice-box">
                    Việc mượn thiết bị cần được quản lý hoặc admin duyệt trước khi sử dụng.
                    Hãy kiểm tra kỹ trạng thái thiết bị trước khi gửi yêu cầu.
                </div>
            </article>

        </section>

    <% } %>

</div>

</body>
</html>
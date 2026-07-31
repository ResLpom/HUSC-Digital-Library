<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.net.URLEncoder" %>
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

    private String shortText(String value, int max) {
        if (value == null) return "";

        value = value.trim();

        if (value.length() <= max) {
            return value;
        }

        return value.substring(0, max) + "...";
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
%>

<%
    String contextPath = request.getContextPath();

    List<?> equipments = (List<?>) request.getAttribute("equipments");
    String keyword = (String) request.getAttribute("keyword");

    if (keyword == null) {
        keyword = "";
    }
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Thiết bị - HUSC Digital Library</title>

    <link rel="stylesheet" href="<%= contextPath %>/assets/css/member/member-layout.css?v=3">

    <style>
        .search-form {
            display: grid;
            grid-template-columns: 1fr 150px;
            gap: 12px;
        }

        .search-form input {
            height: 50px;
            border-radius: 18px;
            border: 1px solid #cbd5e1;
            padding: 0 18px;
            font-weight: 800;
            color: #0f172a;
            background: #f8fafc;
            outline: none;
            font-family: inherit;
        }

        .search-form input:focus {
            border-color: #38bdf8;
            box-shadow: 0 0 0 4px rgba(14, 165, 233, 0.12);
            background: white;
        }

        .search-form button {
            border: none;
            border-radius: 18px;
            color: white;
            background: linear-gradient(135deg, #0f766e, #06b6d4);
            font-weight: 950;
            cursor: pointer;
            font-family: inherit;
        }

        .equipment-grid {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 24px;
        }

        .equipment-card {
            overflow: hidden;
            border-radius: 28px;
            background: rgba(255, 255, 255, 0.98);
            border: 1px solid #ccfbf1;
            box-shadow: 0 22px 55px rgba(15, 23, 42, 0.08);
            transition: 0.22s ease;
            display: flex;
            flex-direction: column;
            min-height: 430px;
        }

        .equipment-card:hover {
            transform: translateY(-6px);
            box-shadow: 0 30px 70px rgba(15, 23, 42, 0.12);
        }

        .equipment-cover {
            width: 100%;
            height: 190px;
            overflow: hidden;
            background: linear-gradient(135deg, #ccfbf1, #dbeafe);
            display: flex;
            align-items: center;
            justify-content: center;
            position: relative;
        }

        .equipment-cover img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            display: block;
            font-size: 0;
        }

        .equipment-placeholder {
            width: 72px;
            height: 72px;
            border-radius: 22px;
            background: rgba(255, 255, 255, 0.72);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 34px;
        }

        .equipment-badge {
            position: absolute;
            left: 18px;
            top: 16px;
            min-height: 32px;
            padding: 0 13px;
            border-radius: 999px;
            background: rgba(255, 255, 255, 0.92);
            color: #0f766e;
            font-size: 12px;
            font-weight: 950;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            z-index: 2;
        }

        .equipment-body {
            padding: 24px;
            display: flex;
            flex-direction: column;
            flex: 1;
        }

        .equipment-body h3 {
            min-height: 64px;
            margin: 0;
            font-size: 20px;
            line-height: 1.35;
            font-weight: 950;
            letter-spacing: -0.4px;
        }

        .equipment-desc {
            min-height: 74px;
            margin: 12px 0 18px;
            color: #475569;
            line-height: 1.65;
            font-size: 14px;
            font-weight: 700;
        }

        .equipment-meta {
            display: flex;
            flex-wrap: wrap;
            gap: 9px;
            margin-bottom: 20px;
        }

        .meta-pill {
            min-height: 32px;
            padding: 0 12px;
            border-radius: 999px;
            background: #f8fafc;
            border: 1px solid #ccfbf1;
            color: #0f766e;
            font-size: 12px;
            font-weight: 900;
            display: inline-flex;
            align-items: center;
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

        .equipment-actions {
            margin-top: auto;
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }

        .btn-primary,
        .btn-light {
            min-height: 42px;
            padding: 0 16px;
            border-radius: 999px;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 13px;
            font-weight: 950;
            border: 1px solid transparent;
        }

        .btn-primary {
            color: white;
            background: linear-gradient(135deg, #0f766e, #06b6d4);
        }

        .btn-light {
            color: #0f766e;
            background: #ecfeff;
            border-color: #ccfbf1;
        }

        @media (max-width: 1050px) {
            .equipment-grid {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }
        }

        @media (max-width: 720px) {
            .search-form {
                grid-template-columns: 1fr;
            }

            .equipment-grid {
                grid-template-columns: 1fr;
            }
        }
        .equipment-grid {
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: 26px;
    align-items: stretch;
}

.equipment-card {
    background: #ffffff;
    border-radius: 28px;
    overflow: hidden;
    border: 1px solid #ccfbf1;
    box-shadow: 0 22px 55px rgba(15, 23, 42, 0.08);
    display: flex;
    flex-direction: column;
    min-height: 520px;
}

.equipment-cover {
    position: relative;
    width: 100%;
    height: 230px;
    background: linear-gradient(135deg, #ccfbf1, #dbeafe);
    overflow: hidden;
    flex-shrink: 0;
}

.equipment-cover img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    display: block;
}

.equipment-cover .type-badge {
    position: absolute;
    top: 18px;
    left: 18px;
    z-index: 2;
    min-height: 36px;
    padding: 0 15px;
    border-radius: 999px;
    background: rgba(255, 255, 255, 0.92);
    color: #0f766e;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    font-size: 13px;
    font-weight: 800;
}

.equipment-placeholder {
    width: 100%;
    height: 100%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 48px;
}

.equipment-body {
    padding: 26px;
    display: flex;
    flex-direction: column;
    flex: 1;
}

.equipment-body h3 {
    margin: 0;
    font-size: 21px;
    line-height: 1.35;
    font-weight: 800;
    letter-spacing: -0.03em;
    color: #0f172a;
}

.equipment-desc {
    margin: 14px 0 20px;
    color: #334155;
    line-height: 1.65;
    font-size: 14px;
    font-weight: 500;
    min-height: 92px;
}

.equipment-meta {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
    margin-top: auto;
}

.equipment-meta span {
    min-height: 34px;
    padding: 0 13px;
    border-radius: 999px;
    background: #ecfeff;
    border: 1px solid #a5f3fc;
    color: #0f766e;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    font-size: 13px;
    font-weight: 800;
}

.equipment-meta .status-available {
    background: #dcfce7;
    color: #166534;
    border-color: #bbf7d0;
}

.equipment-actions {
    margin-top: 22px;
    display: flex;
    gap: 12px;
    flex-wrap: wrap;
}

.equipment-actions a {
    min-height: 44px;
    padding: 0 18px;
    border-radius: 999px;
    text-decoration: none;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    font-size: 13px;
    font-weight: 800;
}

.equipment-actions .btn-detail {
    color: #ffffff;
    background: linear-gradient(135deg, #0f766e, #06b6d4);
}

.equipment-actions .btn-borrow {
    color: #0f766e;
    background: #ecfeff;
    border: 1px solid #a5f3fc;
}

@media (max-width: 1100px) {
    .equipment-grid {
        grid-template-columns: repeat(2, minmax(0, 1fr));
    }
}

@media (max-width: 720px) {
    .equipment-grid {
        grid-template-columns: 1fr;
    }
}
    </style>
</head>

<body>

<jsp:include page="/includes/member-header.jsp" />

<div class="member-page-shell">

    <section class="member-hero cyan">
        <div>
            <div class="member-hero-badge">Learning Equipment</div>

            <h1>Thiết bị học tập</h1>

            <p>
                Xem danh sách thiết bị hỗ trợ học tập, kiểm tra trạng thái sẵn sàng
                và gửi yêu cầu mượn thiết bị khi cần sử dụng.
            </p>
        </div>

        <div class="member-hero-stat">
            <strong><%= equipments == null ? 0 : equipments.size() %></strong>
            <span>Thiết bị đang hiển thị</span>
        </div>
    </section>

    <section class="member-search-panel">
        <form class="search-form" method="get" action="<%= contextPath %>/equipments">
            <input type="text"
                   name="keyword"
                   value="<%= h(keyword) %>"
                   placeholder="Tìm kiếm thiết bị theo tên, mã, vị trí...">

            <button type="submit">Tìm kiếm</button>
        </form>
    </section>

    <div class="member-section-head">
        <div>
            <p class="member-section-kicker">Equipment Collection</p>
            <h2>Danh sách thiết bị</h2>
        </div>

        <p>Chọn thiết bị để xem chi tiết hoặc gửi yêu cầu mượn.</p>
    </div>

    <section class="equipment-grid">

        <% if (equipments == null || equipments.isEmpty()) { %>

            <div class="member-empty-box">
                Không có thiết bị nào phù hợp.
            </div>

        <% } else { %>

            <% for (Object equipment : equipments) {
                int equipmentId = getInt(equipment, "getEquipmentId");

                String equipmentName = getText(equipment, "getEquipmentName");
                String description = getText(equipment, "getDescription");
                String typeName = getText(equipment, "getTypeName");
                String code = getText(equipment, "getCode");
                String location = getText(equipment, "getLocation");
                String status = getText(equipment, "getStatus");
                String imagePath = getText(equipment, "getImagePath");

                if (equipmentName.trim().isEmpty()) equipmentName = "Thiết bị chưa đặt tên";
                if (description.trim().isEmpty()) description = "Chưa có mô tả cho thiết bị này.";
                if (typeName.trim().isEmpty()) typeName = "Thiết bị";
                if (code.trim().isEmpty()) code = "NO-CODE";
                if (location.trim().isEmpty()) location = "Chưa cập nhật";

                boolean hasImage = imagePath != null && !imagePath.trim().isEmpty();
            %>

                <article class="equipment-card">

    <div class="equipment-cover">

        <span class="type-badge">
            <%= h(typeName) %>
        </span>

        <% if (imagePath != null && !imagePath.trim().isEmpty()) { %>
            <img src="<%= contextPath %>/upload-image/equipments/<%= imagePath %>"
                 alt="<%= h(equipmentName) %>">
        <% } else { %>
            <div class="equipment-placeholder">💻</div>
        <% } %>

    </div>

    <div class="equipment-body">

        <h3><%= h(equipmentName) %></h3>

        <p class="equipment-desc">
            <%= h(description) %>
        </p>

        <div class="equipment-meta">
            <span># <%= h(code) %></span>
            <span>📍 <%= h(location) %></span>
            <span class="status-available">
                <%= h(statusText(status)) %>
            </span>
        </div>

        <div class="equipment-actions">
            <a class="btn-detail"
               href="<%= contextPath %>/equipment-detail?id=<%= equipmentId %>">
                Xem chi tiết
            </a>

            <a class="btn-borrow"
               href="<%= contextPath %>/borrow-request?equipmentId=<%= equipmentId %>">
                Gửi yêu cầu mượn
            </a>
        </div>

    </div>

</article>
            <% } %>

        <% } %>

    </section>

</div>

</body>
</html>
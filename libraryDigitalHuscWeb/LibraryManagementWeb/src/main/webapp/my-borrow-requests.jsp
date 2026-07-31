<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
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

    private String firstText(Object object, String... methods) {
        for (String method : methods) {
            String value = getText(object, method);

            if (value != null && !value.trim().isEmpty() && !"0".equals(value.trim())) {
                return value;
            }
        }

        return "";
    }

    private String statusText(String status) {
        if ("PENDING".equalsIgnoreCase(status)) return "Chờ duyệt";
        if ("APPROVED".equalsIgnoreCase(status)) return "Đã duyệt";
        if ("BORROWING".equalsIgnoreCase(status)) return "Đang mượn";
        if ("BORROWED".equalsIgnoreCase(status)) return "Đang mượn";
        if ("RETURNED".equalsIgnoreCase(status)) return "Đã trả";
        if ("REJECTED".equalsIgnoreCase(status)) return "Từ chối";
        if ("CANCELLED".equalsIgnoreCase(status)) return "Đã hủy";
        if ("OVERDUE".equalsIgnoreCase(status)) return "Quá hạn";

        return status == null || status.trim().isEmpty() ? "Chưa rõ" : status;
    }

    private String statusClass(String status) {
        if ("PENDING".equalsIgnoreCase(status)) return "status-pending";
        if ("APPROVED".equalsIgnoreCase(status)) return "status-approved";
        if ("BORROWING".equalsIgnoreCase(status) || "BORROWED".equalsIgnoreCase(status)) return "status-borrowing";
        if ("RETURNED".equalsIgnoreCase(status)) return "status-returned";
        if ("REJECTED".equalsIgnoreCase(status) || "CANCELLED".equalsIgnoreCase(status)) return "status-rejected";
        if ("OVERDUE".equalsIgnoreCase(status)) return "status-overdue";

        return "status-neutral";
    }
%>

<%
    String contextPath = request.getContextPath();

    List<?> requests = (List<?>) request.getAttribute("borrowRequests");

    if (requests == null) {
        requests = (List<?>) request.getAttribute("requests");
    }

    if (requests == null) {
        requests = (List<?>) request.getAttribute("myBorrowRequests");
    }

    int total = requests == null ? 0 : requests.size();

    int pendingCount = 0;
    int approvedCount = 0;
    int returnedCount = 0;

    if (requests != null) {
        for (Object item : requests) {
            String status = firstText(item, "getStatus", "getRequestStatus");

            if ("PENDING".equalsIgnoreCase(status)) pendingCount++;
            if ("APPROVED".equalsIgnoreCase(status)
                    || "BORROWING".equalsIgnoreCase(status)
                    || "BORROWED".equalsIgnoreCase(status)) approvedCount++;
            if ("RETURNED".equalsIgnoreCase(status)) returnedCount++;
        }
    }
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Yêu cầu của tôi - HUSC Digital Library</title>

    <link rel="stylesheet" href="<%= contextPath %>/assets/css/member/member-layout.css?v=7">

    <style>
        .request-summary-grid {
            display: grid;
            grid-template-columns: repeat(4, minmax(0, 1fr));
            gap: 18px;
            margin-top: 24px;
        }

        .summary-card {
            padding: 22px;
            border-radius: 26px;
            background: rgba(255, 255, 255, 0.96);
            border: 1px solid #dbeafe;
            box-shadow: 0 18px 45px rgba(15, 23, 42, 0.08);
        }

        .summary-card strong {
            display: block;
            font-size: 34px;
            font-weight: 950;
            line-height: 1;
            color: #0284c7;
        }

        .summary-card span {
            display: block;
            margin-top: 8px;
            color: #475569;
            font-weight: 850;
            line-height: 1.45;
        }

        .request-card {
            overflow: hidden;
            border-radius: 28px;
            background: rgba(255,255,255,0.98);
            border: 1px solid #dbeafe;
            box-shadow: 0 22px 55px rgba(15, 23, 42, 0.08);
        }

        .request-table-wrap {
            width: 100%;
            overflow-x: auto;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            min-width: 920px;
        }

        th {
            padding: 15px 18px;
            background: #f8fafc;
            color: #334155;
            text-align: left;
            font-size: 12px;
            font-weight: 950;
            text-transform: uppercase;
            letter-spacing: 0.8px;
            border-bottom: 1px solid #e2e8f0;
        }

        td {
            padding: 16px 18px;
            color: #0f172a;
            font-size: 14px;
            font-weight: 750;
            border-bottom: 1px solid #eef2f7;
            vertical-align: middle;
        }

        tr:last-child td {
            border-bottom: none;
        }

        .item-title {
            font-weight: 950;
            color: #0f172a;
            line-height: 1.4;
        }

        .item-sub {
            display: block;
            margin-top: 4px;
            color: #64748b;
            font-size: 12px;
            font-weight: 750;
        }

        .status-pill {
            min-height: 32px;
            padding: 0 12px;
            border-radius: 999px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 12px;
            font-weight: 950;
            border: 1px solid transparent;
            white-space: nowrap;
        }

        .status-pending {
            background: #fef3c7;
            color: #92400e;
            border-color: #fde68a;
        }

        .status-approved {
            background: #dbeafe;
            color: #1d4ed8;
            border-color: #bfdbfe;
        }

        .status-borrowing {
            background: #ede9fe;
            color: #5b21b6;
            border-color: #ddd6fe;
        }

        .status-returned {
            background: #dcfce7;
            color: #166534;
            border-color: #bbf7d0;
        }

        .status-rejected,
        .status-overdue {
            background: #ffe4e6;
            color: #be123c;
            border-color: #fecdd3;
        }

        .status-neutral {
            background: #f1f5f9;
            color: #475569;
            border-color: #e2e8f0;
        }

        .btn-primary,
        .btn-light {
            min-height: 38px;
            padding: 0 14px;
            border-radius: 999px;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 12px;
            font-weight: 950;
            border: 1px solid transparent;
            white-space: nowrap;
        }

        .btn-primary {
            color: white;
            background: linear-gradient(135deg, #0284c7, #06b6d4);
        }

        .btn-light {
            color: #0369a1;
            background: #e0f2fe;
            border-color: #bae6fd;
        }

        .empty-request {
            padding: 58px 24px;
            text-align: center;
            color: #64748b;
            font-weight: 850;
        }

        .empty-request h3 {
            margin: 12px 0 8px;
            color: #0f172a;
            font-size: 26px;
            font-weight: 950;
        }

        .empty-icon {
            font-size: 48px;
        }

        @media (max-width: 1050px) {
            .request-summary-grid {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }
        }

        @media (max-width: 720px) {
            .request-summary-grid {
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
            <div class="member-hero-badge">My Borrow Requests</div>

            <h1>Yêu cầu của tôi</h1>

            <p>
                Theo dõi các yêu cầu mượn thiết bị, trạng thái duyệt, thời gian mượn
                và thông tin xử lý từ quản lý thư viện.
            </p>
        </div>

        <div class="member-hero-stat">
            <strong><%= total %></strong>
            <span>Yêu cầu đã gửi</span>
        </div>
    </section>

    <section class="request-summary-grid">
        <div class="summary-card">
            <strong><%= total %></strong>
            <span>Tổng yêu cầu</span>
        </div>

        <div class="summary-card">
            <strong><%= pendingCount %></strong>
            <span>Đang chờ duyệt</span>
        </div>

        <div class="summary-card">
            <strong><%= approvedCount %></strong>
            <span>Đã duyệt / đang mượn</span>
        </div>

        <div class="summary-card">
            <strong><%= returnedCount %></strong>
            <span>Đã hoàn tất</span>
        </div>
    </section>

    <div class="member-section-head">
        <div>
            <p class="member-section-kicker">Request Tracking</p>
            <h2>Danh sách yêu cầu</h2>
        </div>

        <p>Xem trạng thái các yêu cầu mượn thiết bị bạn đã gửi.</p>
    </div>

    <section class="request-card">

        <% if (requests == null || requests.isEmpty()) { %>

            <div class="empty-request">
                <div class="empty-icon">📋</div>
                <h3>Chưa có yêu cầu nào</h3>
                <p>Bạn có thể vào trang thiết bị để gửi yêu cầu mượn thiết bị học tập.</p>

                <br>

                <a class="btn-primary" href="<%= contextPath %>/equipments">
                    Xem thiết bị
                </a>
            </div>

        <% } else { %>

            <div class="request-table-wrap">
                <table>
                    <thead>
                    <tr>
                        <th>Thiết bị / Nội dung</th>
                        <th>Ngày gửi</th>
                        <th>Ngày mượn</th>
                        <th>Ngày trả dự kiến</th>
                        <th>Trạng thái</th>
                        <th>Ghi chú</th>
                        <th>Thao tác</th>
                    </tr>
                    </thead>

                    <tbody>
                    <% for (Object item : requests) {
                        int requestId = getInt(item, "getRequestId");
                        if (requestId == 0) requestId = getInt(item, "getBorrowRequestId");

                        int equipmentId = getInt(item, "getEquipmentId");

                        String title = firstText(item, "getEquipmentName", "getTitle", "getDocumentTitle", "getName");
                        String code = firstText(item, "getEquipmentCode", "getCode");
                        String createdAt = firstText(item, "getCreatedAt", "getRequestDate", "getCreatedDate");
                        String borrowDate = firstText(item, "getBorrowDate", "getStartDate");
                        String returnDate = firstText(item, "getReturnDate", "getDueDate", "getExpectedReturnDate");
                        String status = firstText(item, "getStatus", "getRequestStatus");
                        String note = firstText(item, "getNote", "getReason", "getManagerNote", "getDescription");

                        if (title.trim().isEmpty()) title = "Nội dung chưa xác định";
                        if (createdAt.trim().isEmpty()) createdAt = "Chưa cập nhật";
                        if (borrowDate.trim().isEmpty()) borrowDate = "Chưa cập nhật";
                        if (returnDate.trim().isEmpty()) returnDate = "Chưa cập nhật";
                        if (note.trim().isEmpty()) note = "Không có";
                    %>

                        <tr>
                            <td>
                                <span class="item-title"><%= h(title) %></span>
                                <% if (!code.trim().isEmpty()) { %>
                                    <span class="item-sub">Mã: <%= h(code) %></span>
                                <% } %>
                            </td>

                            <td><%= h(createdAt) %></td>
                            <td><%= h(borrowDate) %></td>
                            <td><%= h(returnDate) %></td>

                            <td>
                                <span class="status-pill <%= statusClass(status) %>">
                                    <%= h(statusText(status)) %>
                                </span>
                            </td>

                            <td><%= h(note) %></td>

                            <td>
                                <% if (equipmentId > 0) { %>
                                    <a class="btn-light"
                                       href="<%= contextPath %>/equipment-detail?id=<%= equipmentId %>">
                                        Xem thiết bị
                                    </a>
                                <% } else { %>
                                    <a class="btn-light"
                                       href="<%= contextPath %>/equipments">
                                        Xem thiết bị
                                    </a>
                                <% } %>
                            </td>
                        </tr>

                    <% } %>
                    </tbody>
                </table>
            </div>

        <% } %>

    </section>

</div>

</body>
</html>
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

    List<?> documentHistories = (List<?>) request.getAttribute("documentHistories");
    List<?> equipmentHistories = (List<?>) request.getAttribute("equipmentHistories");

    if (documentHistories == null) {
        documentHistories = (List<?>) request.getAttribute("documents");
    }

    if (equipmentHistories == null) {
        equipmentHistories = (List<?>) request.getAttribute("equipments");
    }

    List<?> histories = (List<?>) request.getAttribute("histories");

    int documentCount = documentHistories == null ? 0 : documentHistories.size();
    int equipmentCount = equipmentHistories == null ? 0 : equipmentHistories.size();
    int historyCount = histories == null ? 0 : histories.size();

    int total = documentCount + equipmentCount + historyCount;
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Lịch sử - HUSC Digital Library</title>

    <link rel="stylesheet" href="<%= contextPath %>/assets/css/member/member-layout.css?v=7">

    <style>
        .history-summary-grid {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
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

        .history-table-card {
            overflow: hidden;
            border-radius: 28px;
            background: rgba(255,255,255,0.98);
            border: 1px solid #dbeafe;
            box-shadow: 0 22px 55px rgba(15, 23, 42, 0.08);
            margin-bottom: 26px;
        }

        .history-table-head {
            padding: 22px 24px;
            border-bottom: 1px solid #e2e8f0;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 16px;
        }

        .history-table-head h3 {
            margin: 0;
            font-size: 22px;
            font-weight: 950;
            letter-spacing: -0.4px;
        }

        .history-table-head span {
            min-height: 34px;
            padding: 0 13px;
            border-radius: 999px;
            background: #e0f2fe;
            color: #0369a1;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 12px;
            font-weight: 950;
        }

        .history-table-wrap {
            width: 100%;
            overflow-x: auto;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            min-width: 820px;
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

        .empty-row {
            padding: 44px 24px;
            text-align: center;
            color: #64748b;
            font-weight: 850;
        }

        @media (max-width: 1050px) {
            .history-summary-grid {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }
        }

        @media (max-width: 720px) {
            .history-summary-grid {
                grid-template-columns: 1fr;
            }

            .history-table-head {
                flex-direction: column;
                align-items: flex-start;
            }
        }
    </style>
</head>

<body>

<jsp:include page="/includes/member-header.jsp" />

<div class="member-page-shell">

    <section class="member-hero purple">
        <div>
            <div class="member-hero-badge">Borrowing History</div>

            <h1>Lịch sử sử dụng</h1>

            <p>
                Theo dõi các tài liệu, thiết bị đã mượn, trạng thái xử lý và thông tin trả
                trong quá trình sử dụng hệ thống thư viện số.
            </p>
        </div>

        <div class="member-hero-stat">
            <strong><%= total %></strong>
            <span>Lượt lịch sử</span>
        </div>
    </section>

    <section class="history-summary-grid">
        <div class="summary-card">
            <strong><%= documentCount %></strong>
            <span>Lịch sử tài liệu</span>
        </div>

        <div class="summary-card">
            <strong><%= equipmentCount %></strong>
            <span>Lịch sử thiết bị</span>
        </div>

        <div class="summary-card">
            <strong><%= total %></strong>
            <span>Tổng lượt sử dụng</span>
        </div>
    </section>

    <div class="member-section-head">
        <div>
            <p class="member-section-kicker">History List</p>
            <h2>Chi tiết lịch sử</h2>
        </div>

        <p>Xem lại các lần mượn tài liệu, thiết bị và trạng thái hiện tại.</p>
    </div>

    <% if (histories != null && !histories.isEmpty()) { %>

        <section class="history-table-card">
            <div class="history-table-head">
                <h3>Lịch sử chung</h3>
                <span><%= histories.size() %> bản ghi</span>
            </div>

            <div class="history-table-wrap">
                <table>
                    <thead>
                    <tr>
                        <th>Nội dung</th>
                        <th>Ngày mượn</th>
                        <th>Ngày trả</th>
                        <th>Trạng thái</th>
                    </tr>
                    </thead>

                    <tbody>
                    <% for (Object item : histories) {
                        String title = firstText(item, "getTitle", "getDocumentTitle", "getEquipmentName", "getName");
                        String code = firstText(item, "getCode", "getDocumentCode", "getEquipmentCode");
                        String borrowDate = firstText(item, "getBorrowDate", "getBorrowedAt", "getStartDate", "getCreatedAt");
                        String returnDate = firstText(item, "getReturnDate", "getReturnedAt", "getEndDate", "getDueDate");
                        String status = firstText(item, "getStatus", "getRequestStatus");

                        if (title.trim().isEmpty()) title = "Nội dung chưa xác định";
                        if (borrowDate.trim().isEmpty()) borrowDate = "Chưa cập nhật";
                        if (returnDate.trim().isEmpty()) returnDate = "Chưa cập nhật";
                    %>
                        <tr>
                            <td>
                                <span class="item-title"><%= h(title) %></span>
                                <% if (!code.trim().isEmpty()) { %>
                                    <span class="item-sub">Mã: <%= h(code) %></span>
                                <% } %>
                            </td>
                            <td><%= h(borrowDate) %></td>
                            <td><%= h(returnDate) %></td>
                            <td>
                                <span class="status-pill <%= statusClass(status) %>">
                                    <%= h(statusText(status)) %>
                                </span>
                            </td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        </section>

    <% } %>

    <section class="history-table-card">
        <div class="history-table-head">
            <h3>Lịch sử tài liệu</h3>
            <span><%= documentCount %> bản ghi</span>
        </div>

        <% if (documentHistories == null || documentHistories.isEmpty()) { %>
            <div class="empty-row">
                Chưa có lịch sử tài liệu.
            </div>
        <% } else { %>
            <div class="history-table-wrap">
                <table>
                    <thead>
                    <tr>
                        <th>Tài liệu</th>
                        <th>Ngày mượn</th>
                        <th>Ngày trả</th>
                        <th>Trạng thái</th>
                    </tr>
                    </thead>

                    <tbody>
                    <% for (Object item : documentHistories) {
                        String title = firstText(item, "getTitle", "getDocumentTitle", "getDocumentName");
                        String code = firstText(item, "getDocumentCode", "getCode");
                        String borrowDate = firstText(item, "getBorrowDate", "getBorrowedAt", "getCreatedAt");
                        String returnDate = firstText(item, "getReturnDate", "getReturnedAt", "getDueDate");
                        String status = firstText(item, "getStatus", "getRequestStatus");

                        if (title.trim().isEmpty()) title = "Tài liệu chưa xác định";
                        if (borrowDate.trim().isEmpty()) borrowDate = "Chưa cập nhật";
                        if (returnDate.trim().isEmpty()) returnDate = "Chưa cập nhật";
                    %>
                        <tr>
                            <td>
                                <span class="item-title"><%= h(title) %></span>
                                <% if (!code.trim().isEmpty()) { %>
                                    <span class="item-sub">Mã: <%= h(code) %></span>
                                <% } %>
                            </td>
                            <td><%= h(borrowDate) %></td>
                            <td><%= h(returnDate) %></td>
                            <td>
                                <span class="status-pill <%= statusClass(status) %>">
                                    <%= h(statusText(status)) %>
                                </span>
                            </td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        <% } %>
    </section>

    <section class="history-table-card">
        <div class="history-table-head">
            <h3>Lịch sử thiết bị</h3>
            <span><%= equipmentCount %> bản ghi</span>
        </div>

        <% if (equipmentHistories == null || equipmentHistories.isEmpty()) { %>
            <div class="empty-row">
                Chưa có lịch sử thiết bị.
            </div>
        <% } else { %>
            <div class="history-table-wrap">
                <table>
                    <thead>
                    <tr>
                        <th>Thiết bị</th>
                        <th>Ngày mượn</th>
                        <th>Ngày trả</th>
                        <th>Trạng thái</th>
                    </tr>
                    </thead>

                    <tbody>
                    <% for (Object item : equipmentHistories) {
                        String title = firstText(item, "getEquipmentName", "getTitle", "getName");
                        String code = firstText(item, "getEquipmentCode", "getCode");
                        String borrowDate = firstText(item, "getBorrowDate", "getBorrowedAt", "getCreatedAt");
                        String returnDate = firstText(item, "getReturnDate", "getReturnedAt", "getDueDate");
                        String status = firstText(item, "getStatus", "getRequestStatus");

                        if (title.trim().isEmpty()) title = "Thiết bị chưa xác định";
                        if (borrowDate.trim().isEmpty()) borrowDate = "Chưa cập nhật";
                        if (returnDate.trim().isEmpty()) returnDate = "Chưa cập nhật";
                    %>
                        <tr>
                            <td>
                                <span class="item-title"><%= h(title) %></span>
                                <% if (!code.trim().isEmpty()) { %>
                                    <span class="item-sub">Mã: <%= h(code) %></span>
                                <% } %>
                            </td>
                            <td><%= h(borrowDate) %></td>
                            <td><%= h(returnDate) %></td>
                            <td>
                                <span class="status-pill <%= statusClass(status) %>">
                                    <%= h(statusText(status)) %>
                                </span>
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
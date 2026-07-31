<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>

<%
    String contextPath = request.getContextPath();

    Object statusObj = request.getAttribute("javax.servlet.error.status_code");
    Object messageObj = request.getAttribute("javax.servlet.error.message");
    Object uriObj = request.getAttribute("javax.servlet.error.request_uri");

    int statusCode = 500;

    if (statusObj != null) {
        try {
            statusCode = Integer.parseInt(statusObj.toString());
        } catch (Exception e) {
            statusCode = 500;
        }
    }

    String title = "Có lỗi xảy ra";
    String description = "Hệ thống gặp sự cố trong quá trình xử lý yêu cầu.";

    if (statusCode == 404) {
        title = "Không tìm thấy trang";
        description = "Đường dẫn bạn truy cập không tồn tại hoặc đã được thay đổi.";
    } else if (statusCode == 403) {
        title = "Không có quyền truy cập";
        description = "Bạn không có quyền truy cập vào chức năng này.";
    } else if (statusCode == 500) {
        title = "Lỗi máy chủ";
        description = "Máy chủ đang gặp lỗi. Vui lòng thử lại sau hoặc kiểm tra console Tomcat.";
    }

    String requestUri = uriObj != null ? uriObj.toString() : "";
    String message = messageObj != null ? messageObj.toString() : "";
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title><%= statusCode %> - HUSC Digital Library</title>

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            min-height: 100vh;
            font-family: Arial, sans-serif;
            background:
                radial-gradient(circle at top left, rgba(14, 165, 233, 0.16), transparent 30%),
                radial-gradient(circle at bottom right, rgba(244, 63, 94, 0.16), transparent 32%),
                linear-gradient(135deg, #0f172a, #1e3a8a);
            color: #0f172a;
            overflow-x: hidden;
        }

        .error-page {
            min-height: 100vh;
            padding: 30px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .error-card {
            width: 100%;
            max-width: 980px;
            border-radius: 42px;
            padding: 48px;
            background: rgba(255, 255, 255, 0.92);
            border: 1px solid rgba(226, 232, 240, 0.9);
            box-shadow: 0 36px 90px rgba(15, 23, 42, 0.28);
            backdrop-filter: blur(22px);
            display: grid;
            grid-template-columns: 330px minmax(0, 1fr);
            gap: 38px;
            align-items: center;
            position: relative;
            overflow: hidden;
            animation: fadeUp 0.75s ease both;
        }

        .error-card::before {
            content: "";
            position: absolute;
            width: 280px;
            height: 280px;
            border-radius: 999px;
            background: rgba(14, 165, 233, 0.12);
            top: -120px;
            right: -110px;
        }

        .error-code-box {
            min-height: 330px;
            border-radius: 34px;
            background:
                radial-gradient(circle at 25% 20%, rgba(56, 189, 248, 0.3), transparent 38%),
                linear-gradient(135deg, #0f172a, #1e3a8a);
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-direction: column;
            position: relative;
            overflow: hidden;
            box-shadow: 0 28px 70px rgba(15, 23, 42, 0.22);
        }

        .error-code-box::after {
            content: "";
            position: absolute;
            inset: 0;
            background: linear-gradient(120deg, transparent, rgba(255,255,255,0.1), transparent);
            transform: translateX(-120%);
            animation: shineMove 6s ease-in-out infinite;
        }

        .error-icon {
            font-size: 74px;
            margin-bottom: 18px;
            position: relative;
            z-index: 2;
            animation: floatIcon 4s ease-in-out infinite;
        }

        .error-code {
            font-size: 86px;
            line-height: 1;
            font-weight: 1000;
            letter-spacing: -4px;
            position: relative;
            z-index: 2;
        }

        .error-label {
            margin-top: 12px;
            padding: 8px 14px;
            border-radius: 999px;
            background: rgba(255,255,255,0.14);
            border: 1px solid rgba(255,255,255,0.18);
            color: #bfdbfe;
            font-size: 12px;
            font-weight: 900;
            letter-spacing: 1.4px;
            position: relative;
            z-index: 2;
        }

        .error-content {
            position: relative;
            z-index: 2;
        }

        .brand {
            display: flex;
            align-items: center;
            gap: 14px;
            margin-bottom: 26px;
        }

        .brand-icon {
            width: 54px;
            height: 54px;
            border-radius: 18px;
            background: linear-gradient(135deg, #0284c7, #06b6d4);
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 26px;
            box-shadow: 0 18px 36px rgba(6, 182, 212, 0.24);
        }

        .brand strong {
            display: block;
            font-size: 18px;
            color: #0f172a;
        }

        .brand span {
            display: block;
            margin-top: 4px;
            color: #64748b;
            font-size: 12px;
            font-weight: 700;
        }

        .error-content h1 {
            margin: 0 0 14px;
            font-size: 42px;
            line-height: 1.12;
            letter-spacing: -1.2px;
            color: #0f172a;
        }

        .error-content p {
            margin: 0;
            color: #64748b;
            line-height: 1.75;
            font-size: 15px;
            max-width: 620px;
        }

        .debug-box {
            margin-top: 22px;
            padding: 18px;
            border-radius: 22px;
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            color: #475569;
            font-size: 13px;
            line-height: 1.65;
        }

        .debug-box b {
            color: #0f172a;
        }

        .actions {
            margin-top: 26px;
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
        }

        .btn-main,
        .btn-soft,
        .btn-danger {
            height: 46px;
            padding: 0 18px;
            border-radius: 999px;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 13px;
            font-weight: 900;
            transition: 0.22s ease;
        }

        .btn-main {
            color: white;
            background: linear-gradient(135deg, #0284c7, #06b6d4);
            box-shadow: 0 16px 34px rgba(6, 182, 212, 0.24);
        }

        .btn-soft {
            color: #0369a1;
            background: #e0f2fe;
            border: 1px solid #bae6fd;
        }

        .btn-danger {
            color: #be123c;
            background: #ffe4e6;
            border: 1px solid #fecdd3;
        }

        .btn-main:hover,
        .btn-soft:hover,
        .btn-danger:hover {
            transform: translateY(-3px);
            box-shadow: 0 18px 38px rgba(15, 23, 42, 0.13);
        }

        @keyframes fadeUp {
            from {
                opacity: 0;
                transform: translateY(28px);
            }

            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        @keyframes shineMove {
            0% {
                transform: translateX(-120%);
            }

            45%, 100% {
                transform: translateX(120%);
            }
        }

        @keyframes floatIcon {
            0%, 100% {
                transform: translateY(0);
            }

            50% {
                transform: translateY(-12px);
            }
        }

        @media (max-width: 900px) {
            .error-card {
                grid-template-columns: 1fr;
                padding: 30px;
            }

            .error-code-box {
                min-height: 240px;
            }

            .error-content h1 {
                font-size: 34px;
            }
        }

        @media (max-width: 540px) {
            .error-page {
                padding: 18px;
            }

            .error-card {
                padding: 22px;
                border-radius: 30px;
            }

            .error-code {
                font-size: 64px;
            }
        }
    </style>
</head>

<body>

<main class="error-page">

    <section class="error-card">

        <div class="error-code-box">
            <div class="error-icon">
                <%= statusCode == 404 ? "🔎" : statusCode == 403 ? "🔒" : "⚠️" %>
            </div>

            <div class="error-code"><%= statusCode %></div>

            <div class="error-label">
                ERROR PAGE
            </div>
        </div>

        <div class="error-content">
            <div class="brand">
                <div class="brand-icon">📚</div>

                <div>
                    <strong>HUSC Digital Library</strong>
                    <span>Hệ thống thư viện số và mượn thiết bị</span>
                </div>
            </div>

            <h1><%= title %></h1>

            <p>
                <%= description %>
            </p>

            <div class="debug-box">
                <b>Đường dẫn:</b>
                <%= requestUri == null || requestUri.trim().isEmpty() ? "Không xác định" : requestUri %>
                <br>

                <b>Thông báo:</b>
                <%= message == null || message.trim().isEmpty() ? "Không có thông báo chi tiết." : message %>
            </div>

            <div class="actions">
                <a class="btn-main" href="<%= contextPath %>/index.jsp">
                    Về trang chủ
                </a>

                <a class="btn-soft" href="<%= contextPath %>/documents">
                    Xem tài liệu
                </a>

                <a class="btn-soft" href="<%= contextPath %>/equipments">
                    Xem thiết bị
                </a>

                <a class="btn-danger" href="javascript:history.back();">
                    Quay lại
                </a>
            </div>
        </div>

    </section>

</main>

</body>
</html>
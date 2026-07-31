<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    String contextPath = request.getContextPath();

    String error = (String) request.getAttribute("error");
    String message = request.getParameter("message");
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Đăng nhập - HUSC Digital Library</title>

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            min-height: 100vh;
            font-family: Inter, Arial, sans-serif;
            background:
                    radial-gradient(circle at 20% 20%, rgba(56, 189, 248, 0.22), transparent 34%),
                    radial-gradient(circle at 82% 78%, rgba(59, 130, 246, 0.26), transparent 36%),
                    linear-gradient(135deg, #071b3a 0%, #0f3f8f 48%, #0b63d1 100%);
            color: #0f172a;
            overflow-x: hidden;
        }

        .login-page {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 42px 24px;
        }

        .login-shell {
            width: 100%;
            max-width: 1120px;
            display: grid;
            grid-template-columns: minmax(0, 1.35fr) 390px;
            gap: 54px;
            align-items: center;
        }

        .login-left {
            color: white;
        }

        .brand-row {
            display: flex;
            align-items: center;
            gap: 14px;
            margin-bottom: 34px;
        }

        .brand-icon {
            width: 52px;
            height: 52px;
            border-radius: 18px;
            background: linear-gradient(135deg, #22d3ee, #0ea5e9);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 26px;
            box-shadow: 0 18px 38px rgba(34, 211, 238, 0.28);
        }

        .brand-text strong {
            display: block;
            color: white;
            font-size: 20px;
            font-weight: 950;
            line-height: 1.2;
        }

        .brand-text span {
            display: block;
            margin-top: 4px;
            color: #dbeafe;
            font-size: 13px;
            font-weight: 800;
        }

        .secure-badge {
            display: inline-flex;
            align-items: center;
            min-height: 34px;
            padding: 0 16px;
            border-radius: 999px;
            color: #e0f2fe;
            background: rgba(255, 255, 255, 0.14);
            border: 1px solid rgba(255, 255, 255, 0.22);
            font-size: 12px;
            font-weight: 950;
            letter-spacing: 1.8px;
            text-transform: uppercase;
            box-shadow: 0 14px 34px rgba(15, 23, 42, 0.14);
            margin-bottom: 22px;
        }

        .login-title {
            margin: 0;
            max-width: 650px;
            font-size: 56px;
            line-height: 1.05;
            letter-spacing: -1.8px;
            font-weight: 950;
            text-shadow: 0 14px 38px rgba(15, 23, 42, 0.22);
        }

        .login-title span {
            color: #67e8f9;
        }

        .login-desc {
            margin: 24px 0 0;
            max-width: 680px;
            color: #e0f2fe;
            line-height: 1.75;
            font-size: 16px;
            font-weight: 800;
        }

        .feature-row {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 14px;
            margin-top: 34px;
            max-width: 710px;
        }

        .feature-card {
            padding: 18px;
            border-radius: 22px;
            background: rgba(255, 255, 255, 0.12);
            border: 1px solid rgba(255, 255, 255, 0.22);
            color: white;
            backdrop-filter: blur(14px);
            box-shadow: 0 18px 46px rgba(15, 23, 42, 0.12);
        }

        .feature-icon {
            width: 38px;
            height: 38px;
            border-radius: 14px;
            background: rgba(255, 255, 255, 0.18);
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 12px;
            font-size: 20px;
        }

        .feature-card strong {
            display: block;
            margin-bottom: 6px;
            color: white;
            font-size: 14px;
            font-weight: 950;
        }

        .feature-card span {
            display: block;
            color: #dbeafe;
            font-size: 12px;
            line-height: 1.5;
            font-weight: 750;
        }

        .login-card {
            position: relative;
            padding: 34px 30px;
            border-radius: 34px;
            background:
                    radial-gradient(circle at top right, rgba(34, 211, 238, 0.13), transparent 32%),
                    rgba(255, 255, 255, 0.94);
            border: 1px solid rgba(219, 234, 254, 0.9);
            box-shadow: 0 34px 90px rgba(15, 23, 42, 0.28);
            backdrop-filter: blur(18px);
            overflow: hidden;
        }

        .login-card::before {
            content: "";
            position: absolute;
            width: 170px;
            height: 170px;
            border-radius: 999px;
            right: -70px;
            top: -70px;
            background: rgba(34, 211, 238, 0.18);
        }

        .login-card-inner {
            position: relative;
            z-index: 2;
        }

        .login-lock {
            width: 58px;
            height: 58px;
            border-radius: 18px;
            background: linear-gradient(135deg, #22d3ee, #0ea5e9);
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 26px;
            box-shadow: 0 18px 36px rgba(14, 165, 233, 0.22);
            margin-bottom: 22px;
        }

        .login-card h1 {
            margin: 0 0 8px;
            color: #0f172a;
            font-size: 32px;
            font-weight: 950;
            letter-spacing: -0.8px;
        }

        .login-card .small-desc {
            margin: 0 0 24px;
            color: #64748b;
            font-size: 13px;
            font-weight: 750;
            line-height: 1.6;
        }

        .alert-error,
        .alert-success {
            margin-bottom: 16px;
            padding: 13px 15px;
            border-radius: 18px;
            font-size: 13px;
            font-weight: 900;
            line-height: 1.5;
        }

        .alert-error {
            color: #be123c;
            background: #ffe4e6;
            border: 1px solid #fecdd3;
        }

        .alert-success {
            color: #166534;
            background: #dcfce7;
            border: 1px solid #bbf7d0;
        }

        label {
            display: block;
            margin: 16px 0 8px;
            color: #334155;
            font-size: 13px;
            font-weight: 950;
        }

        .input-wrap {
            position: relative;
        }

        .input-icon {
            position: absolute;
            left: 15px;
            top: 50%;
            transform: translateY(-50%);
            color: #0ea5e9;
            font-size: 15px;
            z-index: 2;
        }

        input[type="text"],
        input[type="email"],
        input[type="password"] {
            width: 100%;
            height: 50px;
            border-radius: 17px;
            border: 1px solid #dbeafe;
            background: rgba(248, 250, 252, 0.96);
            color: #0f172a;
            font-size: 14px;
            font-weight: 750;
            outline: none;
            padding: 0 15px 0 44px;
            font-family: inherit;
            transition: 0.22s ease;
        }

        input:focus {
            border-color: #38bdf8;
            box-shadow: 0 0 0 4px rgba(14, 165, 233, 0.12);
            background: white;
        }

        .login-options {
            margin-top: 16px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 12px;
            color: #64748b;
            font-size: 12px;
            font-weight: 800;
        }

        .remember {
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        .remember input {
            width: 14px;
            height: 14px;
            accent-color: #0ea5e9;
        }

        .home-link {
            color: #0284c7;
            text-decoration: none;
            font-weight: 950;
        }

        .btn-login {
            width: 100%;
            height: 50px;
            margin-top: 22px;
            border: none;
            border-radius: 999px;
            color: white;
            background: linear-gradient(135deg, #0ea5e9, #06b6d4);
            box-shadow: 0 18px 38px rgba(6, 182, 212, 0.24);
            font-weight: 950;
            cursor: pointer;
            font-family: inherit;
            transition: 0.22s ease;
        }

        .btn-login:hover {
            transform: translateY(-3px);
            box-shadow: 0 24px 48px rgba(6, 182, 212, 0.32);
        }

        .register-now-btn {
            width: 100%;
            height: 46px;
            margin-top: 12px;
            border-radius: 999px;
            text-decoration: none;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 950;
            font-size: 14px;
            color: #0369a1;
            background: #e0f2fe;
            border: 1px solid #bae6fd;
            transition: 0.22s ease;
        }

        .register-now-btn:hover {
            color: white;
            background: linear-gradient(135deg, #0284c7, #06b6d4);
            box-shadow: 0 14px 28px rgba(6, 182, 212, 0.22);
            transform: translateY(-2px);
            text-decoration: none;
        }

        .login-note {
            margin-top: 24px;
            padding: 16px;
            border-radius: 20px;
            color: #475569;
            background: rgba(248, 250, 252, 0.86);
            border: 1px solid #e2e8f0;
            font-size: 12px;
            font-weight: 750;
            line-height: 1.6;
        }

        .quick-links {
            display: flex;
            justify-content: center;
            gap: 14px;
            margin-top: 18px;
        }

        .quick-links a {
            color: #0369a1;
            text-decoration: none;
            font-size: 13px;
            font-weight: 950;
        }

        .quick-links a:hover {
            text-decoration: underline;
        }

        @media (max-width: 1000px) {
            .login-shell {
                grid-template-columns: 1fr;
                gap: 34px;
                max-width: 620px;
            }

            .login-left {
                text-align: center;
            }

            .brand-row {
                justify-content: center;
            }

            .login-title {
                font-size: 44px;
                margin: 0 auto;
            }

            .login-desc {
                margin-left: auto;
                margin-right: auto;
            }

            .feature-row {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 560px) {
            .login-page {
                padding: 24px 14px;
            }

            .login-title {
                font-size: 36px;
            }

            .login-card {
                padding: 28px 22px;
                border-radius: 28px;
            }

            .login-options {
                flex-direction: column;
                align-items: flex-start;
            }
        }
    </style>
</head>

<body>

<div class="login-page">
    <div class="login-shell">

        <section class="login-left">
            <div class="brand-row">
                <div class="brand-icon">📚</div>

                <div class="brand-text">
                    <strong>HUSC Digital Library</strong>
                    <span>Hệ thống thư viện số và mượn thiết bị</span>
                </div>
            </div>

            <div class="secure-badge">Secure Access</div>

            <h1 class="login-title">
                Chào mừng trở lại<br>
                <span>thư viện số HUSC</span>
            </h1>

            <p class="login-desc">
                Đăng nhập để xem tài liệu, lưu tài liệu yêu thích, gửi yêu cầu mượn thiết bị
                và theo dõi lịch sử mượn trả của bạn.
            </p>

            <div class="feature-row">
                <div class="feature-card">
                    <div class="feature-icon">📄</div>
                    <strong>Tài liệu số</strong>
                    <span>Tra cứu giáo trình, bài giảng và tài liệu học tập.</span>
                </div>

                <div class="feature-card">
                    <div class="feature-icon">💻</div>
                    <strong>Thiết bị học tập</strong>
                    <span>Gửi yêu cầu mượn laptop, máy chiếu và thiết bị hỗ trợ.</span>
                </div>

                <div class="feature-card">
                    <div class="feature-icon">📋</div>
                    <strong>Theo dõi yêu cầu</strong>
                    <span>Xem trạng thái duyệt, đang mượn, trả thiết bị.</span>
                </div>
            </div>
        </section>

        <section class="login-card">
            <div class="login-card-inner">

                <div class="login-lock">🔐</div>

                <h1>Đăng nhập</h1>

                <p class="small-desc">
                    Nhập email, mã sinh viên hoặc tài khoản và mật khẩu để truy cập hệ thống.
                </p>

                <% if (error != null && !error.trim().isEmpty()) { %>
                    <div class="alert-error">
                        <%= error %>
                    </div>
                <% } %>

                <% if ("register-success".equals(message)) { %>
                    <div class="alert-success">
                        Đăng ký thành công. Tài khoản đang chờ admin xác thực.
                    </div>
                <% } %>

                <form method="post"
                      action="<%= contextPath %>/login"
                      onsubmit="syncLoginFields();">

                    <label>Email / Mã sinh viên / Tài khoản</label>
                    <div class="input-wrap">
                        <span class="input-icon">✉</span>
                        <input id="accountInput"
                               type="text"
                               name="account"
                               required
                               placeholder="member@husc.edu.vn">
                    </div>

                    <input type="hidden" id="emailInput" name="email">
                    <input type="hidden" id="usernameInput" name="username">

                    <label>Mật khẩu</label>
                    <div class="input-wrap">
                        <span class="input-icon">🔑</span>
                        <input type="password"
                               name="password"
                               required
                               placeholder="••••••">
                    </div>

                    <div class="login-options">
                        <label class="remember">
                            <input type="checkbox" name="remember" value="yes">
                            Ghi nhớ đăng nhập
                        </label>

                        <a class="home-link" href="<%= contextPath %>/index.jsp">
                            Về trang chủ
                        </a>
                    </div>

                    <button class="btn-login" type="submit">
                        Đăng nhập hệ thống
                    </button>
                </form>

                <a href="<%= contextPath %>/resignter.jsp"
                   class="register-now-btn">
                    Đăng ký tài khoản sinh viên
                </a>

                <div class="login-note">
                    Gợi ý: nếu bạn là quản trị viên hoặc quản lý, hệ thống sẽ tự điều hướng
                    đến khu vực quản trị sau khi đăng nhập.
                </div>

                <div class="quick-links">
                    <a href="<%= contextPath %>/documents">Xem tài liệu</a>
                    <a href="<%= contextPath %>/equipments">Xem thiết bị</a>
                </div>

            </div>
        </section>

    </div>
</div>

<script>
    function syncLoginFields() {
        var accountInput = document.getElementById("accountInput");
        var emailInput = document.getElementById("emailInput");
        var usernameInput = document.getElementById("usernameInput");

        if (accountInput && emailInput && usernameInput) {
            emailInput.value = accountInput.value;
            usernameInput.value = accountInput.value;
        }

        return true;
    }
</script>

</body>
</html>
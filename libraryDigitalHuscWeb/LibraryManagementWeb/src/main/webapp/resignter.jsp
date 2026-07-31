<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    String contextPath = request.getContextPath();

    String error = (String) request.getAttribute("error");
    String success = (String) request.getAttribute("success");

    String oldStudentCode = (String) request.getAttribute("oldStudentCode");
    String oldFullName = (String) request.getAttribute("oldFullName");

    if (oldStudentCode == null) {
        oldStudentCode = request.getParameter("studentCode");
    }

    if (oldFullName == null) {
        oldFullName = request.getParameter("fullName");
    }

    if (oldStudentCode == null) oldStudentCode = "";
    if (oldFullName == null) oldFullName = "";
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Đăng ký tài khoản - HUSC Digital Library</title>

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            min-height: 100vh;
            font-family: Inter, Arial, sans-serif;
            background:
                    radial-gradient(circle at 15% 15%, rgba(6, 182, 212, 0.2), transparent 32%),
                    radial-gradient(circle at 85% 80%, rgba(79, 70, 229, 0.22), transparent 34%),
                    linear-gradient(135deg, #0f172a, #1e3a8a);
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 24px;
            color: #0f172a;
        }

        .register-card {
            width: 100%;
            max-width: 560px;
            padding: 34px;
            border-radius: 34px;
            background: rgba(255, 255, 255, 0.96);
            border: 1px solid rgba(219, 234, 254, 0.9);
            box-shadow: 0 32px 90px rgba(15, 23, 42, 0.32);
        }

        .brand {
            display: flex;
            align-items: center;
            gap: 14px;
            margin-bottom: 28px;
        }

        .brand-icon {
            width: 56px;
            height: 56px;
            border-radius: 20px;
            background: linear-gradient(135deg, #0284c7, #06b6d4);
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 28px;
            box-shadow: 0 18px 38px rgba(6, 182, 212, 0.28);
        }

        .brand strong {
            display: block;
            font-size: 20px;
            font-weight: 950;
            color: #0f172a;
        }

        .brand span {
            display: block;
            margin-top: 4px;
            color: #475569;
            font-size: 13px;
            font-weight: 800;
        }

        h1 {
            margin: 0 0 8px;
            font-size: 34px;
            font-weight: 950;
            letter-spacing: -0.8px;
        }

        .desc {
            margin: 0 0 22px;
            color: #475569;
            line-height: 1.65;
            font-weight: 700;
        }

        .alert-success,
        .alert-error {
            margin-bottom: 18px;
            padding: 14px 16px;
            border-radius: 18px;
            font-weight: 900;
            line-height: 1.5;
        }

        .alert-success {
            background: #dcfce7;
            border: 1px solid #bbf7d0;
            color: #166534;
        }

        .alert-error {
            background: #ffe4e6;
            border: 1px solid #fecdd3;
            color: #be123c;
        }

        label {
            display: block;
            margin: 14px 0 7px;
            color: #334155;
            font-weight: 950;
            font-size: 13px;
        }

        input {
            width: 100%;
            height: 50px;
            border-radius: 18px;
            border: 1px solid #cbd5e1;
            background: #f8fafc;
            padding: 0 15px;
            outline: none;
            color: #0f172a;
            font-weight: 750;
            font-family: inherit;
        }

        input:focus {
            border-color: #38bdf8;
            box-shadow: 0 0 0 4px rgba(14, 165, 233, 0.12);
        }

        .email-note {
            margin-top: 8px;
            padding: 12px 14px;
            border-radius: 16px;
            background: #f0f9ff;
            border: 1px solid #bae6fd;
            color: #0369a1;
            font-size: 13px;
            font-weight: 850;
            line-height: 1.5;
        }

        .btn-submit,
        .btn-back {
            width: 100%;
            min-height: 48px;
            margin-top: 18px;
            border-radius: 999px;
            border: none;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-weight: 950;
            cursor: pointer;
            font-family: inherit;
            font-size: 14px;
        }

        .btn-submit {
            color: white;
            background: linear-gradient(135deg, #0284c7, #06b6d4);
            box-shadow: 0 16px 34px rgba(6, 182, 212, 0.22);
        }

        .btn-back {
            color: #0369a1;
            background: #e0f2fe;
            border: 1px solid #bae6fd;
            margin-top: 12px;
        }

        .rule-box {
            margin-top: 18px;
            padding: 16px;
            border-radius: 20px;
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            color: #475569;
            font-size: 13px;
            font-weight: 750;
            line-height: 1.6;
        }

        .rule-box strong {
            color: #0f172a;
        }
    </style>
</head>

<body>

<div class="register-card">

    <div class="brand">
        <div class="brand-icon">📚</div>

        <div>
            <strong>HUSC Digital Library</strong>
            <span>Academic Resource Platform</span>
        </div>
    </div>

    <h1>Đăng ký tài khoản</h1>

    <p class="desc">
        Sinh viên đăng ký bằng mã sinh viên. Email sẽ tự tạo theo dạng
        <strong>mã sinh viên + @husc.edu.vn</strong>.
        Tài khoản chỉ được đăng nhập sau khi admin xác thực.
    </p>

    <% if (success != null && !success.trim().isEmpty()) { %>
        <div class="alert-success">
            <%= success %>
            <br>
            <a href="<%= contextPath %>/login.jsp" style="color:#166534; font-weight:900;">
                Quay lại đăng nhập
            </a>
        </div>
    <% } %>

    <% if (error != null && !error.trim().isEmpty()) { %>
        <div class="alert-error">
            <%= error %>
        </div>
    <% } %>

    <form method="post" action="<%= contextPath %>/register">

        <label>Mã sinh viên</label>
        <input type="text"
               name="studentCode"
               value="<%= oldStudentCode %>"
               required
               placeholder="Ví dụ: 23T1020001">

        <div class="email-note">
            Email mặc định sẽ là:
            <strong>mã_sinh_viên@husc.edu.vn</strong>
        </div>

        <label>Họ và tên</label>
        <input type="text"
               name="fullName"
               value="<%= oldFullName %>"
               required
               placeholder="Nhập họ tên sinh viên">
		<label>Số điện thoại</label>
<input type="text"
       name="phone"
       placeholder="Nhập số điện thoại liên hệ">

<label>Địa chỉ / Lớp / Khoa</label>
<input type="text"
       name="address"
       placeholder="Ví dụ: Khoa CNTT, lớp K47...">

<label>Ghi chú xác minh</label>
<input type="text"
       name="registrationNote"
       placeholder="Ví dụ: Sinh viên đang học tại khoa...">
        <label>Mật khẩu</label>
        <input type="password"
               name="password"
               required
               placeholder="Tạo mật khẩu">

        <label>Nhập lại mật khẩu</label>
        <input type="password"
               name="confirmPassword"
               required
               placeholder="Nhập lại mật khẩu">

        <button class="btn-submit" type="submit">
            Gửi đăng ký chờ duyệt
        </button>
    </form>

    <a class="btn-back" href="<%= contextPath %>/login.jsp">
        Quay lại đăng nhập
    </a>

    <div class="rule-box">
        <strong>Lưu ý:</strong>
        Admin sẽ kiểm tra mã sinh viên để xác thực người đăng ký có thuộc Trường Đại học Khoa học hay không.
        Tài khoản mới sẽ có trạng thái <strong>PENDING</strong> và chưa thể đăng nhập.
    </div>

</div>

</body>
</html>
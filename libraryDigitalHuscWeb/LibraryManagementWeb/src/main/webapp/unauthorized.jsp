<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String contextPath = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Không có quyền truy cập</title>
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/style.css">
</head>
<body>

<div class="container">
    <div class="card">

        <h1 class="page-title">Không có quyền truy cập</h1>

        <div class="alert-error">
            Bạn không có quyền truy cập chức năng này.
        </div>

        <p>
            <a class="btn" href="<%= contextPath %>/index.jsp">Về trang chủ</a>
            <a class="btn btn-danger" href="<%= contextPath %>/logout">Đăng xuất</a>
        </p>

    </div>
</div>

</body>
</html>
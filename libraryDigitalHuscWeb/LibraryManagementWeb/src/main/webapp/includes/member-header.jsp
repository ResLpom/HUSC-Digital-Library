<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="vn.edu.husc.library.model.User" %>

<%
    String cp = request.getContextPath();

    String uri = request.getRequestURI();
    Object forwardUriObject = request.getAttribute("javax.servlet.forward.request_uri");

    if (forwardUriObject != null) {
        uri = String.valueOf(forwardUriObject);
    }

    String path = uri;

    if (path.startsWith(cp)) {
        path = path.substring(cp.length());
    }

    User headerUser = null;

    if (session != null) {
        headerUser = (User) session.getAttribute("currentUser");

        if (headerUser == null) {
            headerUser = (User) session.getAttribute("user");
        }
    }

    boolean headerLoggedIn = headerUser != null;

    boolean activeHome = "/".equals(path)
            || "/index.jsp".equals(path)
            || path.endsWith("/index.jsp");

    boolean activeFavorite = path.equals("/favorite-documents")
            || path.equals("/favorite-documents.jsp");

    boolean activeDocuments = !activeFavorite
            && (
                    path.equals("/documents")
                    || path.equals("/documents.jsp")
                    || path.equals("/document-detail")
                    || path.equals("/document-detail.jsp")
                    || path.equals("/document-history")
                    || path.equals("/document-history.jsp")
            );

    boolean activeExamBank = path.equals("/exam-bank")
            || path.equals("/exam-bank.jsp");

    boolean activeEquipments = path.equals("/equipments")
            || path.equals("/equipments.jsp")
            || path.equals("/equipment-detail")
            || path.equals("/equipment-detail.jsp")
            || path.equals("/equipment-history")
            || path.equals("/equipment-history.jsp");

    boolean activeHistory = path.equals("/history")
            || path.equals("/history.jsp");

    boolean activeBorrow = path.equals("/my-borrow-requests")
            || path.equals("/my-borrow-requests.jsp")
            || path.equals("/borrow-request")
            || path.equals("/borrow-request.jsp");
%>

<style>
    .member-header {
        width: calc(100% - 40px);
        max-width: 1240px;
        min-height: 78px;
        margin: 24px auto 0;
        padding: 14px 18px;
        border-radius: 28px;
        background: rgba(255, 255, 255, 0.94);
        border: 1px solid #dbeafe;
        box-shadow: 0 18px 50px rgba(15, 23, 42, 0.08);
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 18px;
        position: relative;
        z-index: 50;
        font-family: "Segoe UI", "Roboto", "Arial", sans-serif;
    }

    .member-brand {
        display: flex;
        align-items: center;
        gap: 14px;
        text-decoration: none;
        color: #0f172a;
        flex-shrink: 0;
    }

    .member-brand:hover {
        text-decoration: none;
    }

    .member-brand-icon {
        width: 52px;
        height: 52px;
        border-radius: 18px;
        background: linear-gradient(135deg, #0284c7, #06b6d4);
        color: white;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 25px;
        box-shadow: 0 16px 32px rgba(6, 182, 212, 0.24);
    }

    .member-brand-text strong {
        display: block;
        font-size: 18px;
        font-weight: 800;
        line-height: 1.2;
        color: #0f172a;
        white-space: nowrap;
    }

    .member-brand-text span {
    display: block;
    margin-top: 3px;
    font-size: 12px;
    font-weight: 600;
    color: #475569;
    white-space: nowrap;
}
    .member-menu {
        display: flex;
        align-items: center;
        justify-content: flex-end;
        gap: 10px;
        flex-wrap: nowrap;
    }

    .member-menu a {
    min-width: 88px;
    height: 42px;
    padding: 0 15px;
    border-radius: 999px;
    background: #f8fafc;
    border: 1px solid #e2e8f0;
    color: #0f172a;
    text-decoration: none;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    font-size: 13px;
    font-weight: 700;
    white-space: nowrap;
    transition: 0.22s ease;
}

    .member-menu a:hover {
        color: #0284c7;
        background: #e0f2fe;
        border-color: #bae6fd;
        transform: translateY(-3px);
        text-decoration: none;
    }

    .member-menu a.active {
        color: #0284c7;
        background: linear-gradient(135deg, #e0f2fe, #f0f9ff);
        border-color: #7dd3fc;
        box-shadow: 0 10px 24px rgba(14, 165, 233, 0.14);
        transform: translateY(-2px);
        text-decoration: none;
    }

    .member-menu a.login-link {
        min-width: 96px;
    }

    .member-menu a.logout-link {
        min-width: 96px;
        color: #be123c;
        background: #fff1f2;
        border-color: #fecdd3;
    }

    .member-menu a.logout-link:hover {
        color: white;
        background: linear-gradient(135deg, #e11d48, #f43f5e);
        border-color: #f43f5e;
    }

    .member-menu a.long-link {
        min-width: 132px;
    }

    @media (max-width: 1100px) {
        .member-header {
            flex-direction: column;
            align-items: flex-start;
        }

        .member-menu {
            justify-content: flex-start;
            flex-wrap: wrap;
        }
    }

    @media (max-width: 720px) {
        .member-header {
            width: calc(100% - 24px);
            margin-top: 12px;
            border-radius: 22px;
        }

        .member-brand-text strong {
            font-size: 16px;
        }

        .member-menu {
            gap: 8px;
        }

        .member-menu a {
            min-width: auto;
            height: 40px;
            padding: 0 12px;
            font-size: 12px;
        }
    }
</style>

<header class="member-header">
    <a class="member-brand" href="<%= cp %>/index.jsp">
        <div class="member-brand-icon">📚</div>

        <div class="member-brand-text">
            <strong>HUSC Digital Library</strong>
            <span>Academic Resource Platform</span>
        </div>
    </a>

    <nav class="member-menu">
        <a class="<%= activeHome ? "active" : "" %>"
           href="<%= cp %>/index.jsp">
            Trang chủ
        </a>

        <a class="<%= activeDocuments ? "active" : "" %>"
           href="<%= cp %>/documents">
            Tài liệu
        </a>

        <a class="<%= activeExamBank ? "active" : "" %>"
           href="<%= cp %>/exam-bank">
            Kho đề
        </a>

        <a class="<%= activeEquipments ? "active" : "" %>"
           href="<%= cp %>/equipments">
            Thiết bị
        </a>

        <% if (headerLoggedIn) { %>
            <a class="<%= activeFavorite ? "active" : "" %>"
               href="<%= cp %>/favorite-documents">
                Yêu thích
            </a>

            <a class="<%= activeHistory ? "active" : "" %>"
               href="<%= cp %>/history">
                Lịch sử
            </a>

            <a class="<%= activeBorrow ? "active long-link" : "long-link" %>"
               href="<%= cp %>/my-borrow-requests">
                Yêu cầu của tôi
            </a>

            <a class="logout-link"
               href="<%= cp %>/logout">
                Đăng xuất
            </a>
        <% } else { %>
            <a class="login-link"
               href="<%= cp %>/login.jsp">
                Đăng nhập
            </a>
        <% } %>
    </nav>
</header>
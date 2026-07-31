<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    String contextPath = request.getContextPath();
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Trang chủ - HUSC Digital Library</title>

    <link rel="stylesheet" href="<%= contextPath %>/assets/css/member/member-layout.css?v=6">

    <style>
        .home-feature-grid {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 24px;
        }

        .home-card {
            min-height: 250px;
            padding: 28px;
            border-radius: 28px;
            background: rgba(255, 255, 255, 0.98);
            border: 1px solid #dbeafe;
            box-shadow: 0 22px 55px rgba(15, 23, 42, 0.08);
            transition: 0.22s ease;
            display: flex;
            flex-direction: column;
        }

        .home-card:hover {
            transform: translateY(-6px);
            box-shadow: 0 30px 70px rgba(15, 23, 42, 0.12);
        }

        .home-card-icon {
            width: 62px;
            height: 62px;
            border-radius: 22px;
            background: linear-gradient(135deg, #e0f2fe, #dbeafe);
            color: #0284c7;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 30px;
            margin-bottom: 20px;
        }

        .home-card h3 {
            margin: 0;
            font-size: 22px;
            font-weight: 950;
            line-height: 1.3;
            letter-spacing: -0.4px;
        }

        .home-card p {
            margin: 12px 0 22px;
            color: #475569;
            line-height: 1.65;
            font-size: 14px;
            font-weight: 750;
        }

        .home-card a {
            margin-top: auto;
            min-height: 42px;
            padding: 0 16px;
            border-radius: 999px;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 13px;
            font-weight: 950;
            color: white;
            background: linear-gradient(135deg, #0284c7, #06b6d4);
            width: fit-content;
        }

        .home-card a:hover {
            text-decoration: none;
            transform: translateY(-2px);
        }

        .home-mini-panel {
            margin-top: 24px;
            padding: 24px;
            border-radius: 28px;
            background: rgba(255, 255, 255, 0.96);
            border: 1px solid #dbeafe;
            box-shadow: 0 18px 45px rgba(15, 23, 42, 0.08);
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 18px;
        }

        .home-mini-item {
            padding: 18px;
            border-radius: 22px;
            background: #f8fafc;
            border: 1px solid #e2e8f0;
        }

        .home-mini-item strong {
            display: block;
            color: #0f172a;
            font-size: 16px;
            font-weight: 950;
            margin-bottom: 6px;
        }

        .home-mini-item span {
            display: block;
            color: #475569;
            font-size: 13px;
            line-height: 1.55;
            font-weight: 750;
        }

        @media (max-width: 1050px) {
            .home-feature-grid,
            .home-mini-panel {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }
        }

        @media (max-width: 720px) {
            .home-feature-grid,
            .home-mini-panel {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>

<body>

<jsp:include page="/includes/member-header.jsp" />

<div class="member-page-shell">

    <section class="member-hero blue">
        <div>
            <div class="member-hero-badge">HUSC Digital Library</div>

            <h1>Thư viện số<br>Trường Đại học Khoa học</h1>

            <p>
                Tra cứu tài liệu học tập, xem kho đề, mượn thiết bị hỗ trợ học tập
                và theo dõi lịch sử sử dụng hệ thống trên một nền tảng thống nhất.
            </p>
        </div>

        <div class="member-hero-stat">
            <strong>HUSC</strong>
            <span>Academic Resource Platform</span>
        </div>
    </section>

    <div class="home-mini-panel">
        <div class="home-mini-item">
            <strong>📄 Tài liệu số</strong>
            <span>Truy cập giáo trình, bài giảng và tài liệu tham khảo.</span>
        </div>

        <div class="home-mini-item">
            <strong>📝 Kho đề</strong>
            <span>Xem đề cương, ngân hàng đề và tài liệu ôn tập.</span>
        </div>

        <div class="home-mini-item">
            <strong>💻 Thiết bị</strong>
            <span>Gửi yêu cầu mượn laptop, máy chiếu và thiết bị học tập.</span>
        </div>
    </div>

    <div class="member-section-head">
        <div>
            <p class="member-section-kicker">Main Features</p>
            <h2>Chức năng nổi bật</h2>
        </div>

        <p>Chọn nhanh khu vực bạn muốn sử dụng trong hệ thống.</p>
    </div>

    <section class="home-feature-grid">

        <article class="home-card">
            <div class="home-card-icon">📄</div>

            <h3>Kho tài liệu học tập</h3>

            <p>
                Tra cứu giáo trình, bài giảng, tài liệu tham khảo và tải xuống tài liệu số
                phục vụ học tập, nghiên cứu.
            </p>

            <a href="<%= contextPath %>/documents">
                Xem tài liệu
            </a>
        </article>

        <article class="home-card">
            <div class="home-card-icon">📝</div>

            <h3>Kho đề và đề cương</h3>

            <p>
                Xem ngân hàng đề, đề cương học phần và các tài liệu ôn tập được phân loại
                theo khoa, môn học và năm học.
            </p>

            <a href="<%= contextPath %>/exam-bank">
                Xem kho đề
            </a>
        </article>

        <article class="home-card">
            <div class="home-card-icon">💻</div>

            <h3>Thiết bị học tập</h3>

            <p>
                Kiểm tra danh sách thiết bị hỗ trợ học tập, xem trạng thái thiết bị
                và gửi yêu cầu mượn khi cần sử dụng.
            </p>

            <a href="<%= contextPath %>/equipments">
                Xem thiết bị
            </a>
        </article>

    </section>

</div>

</body>
</html>
package vn.edu.husc.library.servlet;

import vn.edu.husc.library.dao.RegistrationRequestDAO;

import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.IOException;

public class RegisterServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private RegistrationRequestDAO registrationDAO;

    @Override
    public void init() throws ServletException {
        registrationDAO = new RegistrationRequestDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        request.getRequestDispatcher("/resignter.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String studentCode = trim(request.getParameter("studentCode"));
        String fullName = trim(request.getParameter("fullName"));
        String password = trim(request.getParameter("password"));
        String confirmPassword = trim(request.getParameter("confirmPassword"));

        String phone = trim(request.getParameter("phone"));
        String address = trim(request.getParameter("address"));
        String registrationNote = trim(request.getParameter("registrationNote"));

        String email = "";

        if (!studentCode.isEmpty()) {
            email = studentCode.toLowerCase() + "@husc.edu.vn";
        }

        request.setAttribute("oldStudentCode", studentCode);
        request.setAttribute("oldFullName", fullName);
        request.setAttribute("oldPhone", phone);
        request.setAttribute("oldAddress", address);
        request.setAttribute("oldRegistrationNote", registrationNote);

        if (studentCode.isEmpty()
                || fullName.isEmpty()
                || password.isEmpty()
                || confirmPassword.isEmpty()) {

            request.setAttribute("error", "Vui lòng nhập đầy đủ mã sinh viên, họ tên và mật khẩu.");
            request.getRequestDispatcher("/resignter.jsp").forward(request, response);
            return;
        }

        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Mật khẩu nhập lại không khớp.");
            request.getRequestDispatcher("/resignter.jsp").forward(request, response);
            return;
        }

        if (password.length() < 6) {
            request.setAttribute("error", "Mật khẩu phải có ít nhất 6 ký tự.");
            request.getRequestDispatcher("/resignter.jsp").forward(request, response);
            return;
        }

        if (registrationDAO.existsEmailOrStudentCode(email, studentCode)) {
            request.setAttribute("error", "Mã sinh viên hoặc email đã tồn tại trong hệ thống.");
            request.getRequestDispatcher("/resignter.jsp").forward(request, response);
            return;
        }

        boolean success = registrationDAO.createPendingUser(
                fullName,
                studentCode,
                email,
                password,
                phone,
                address,
                registrationNote
        );

        if (success) {
            request.setAttribute("success", "Đăng ký thành công. Tài khoản đang chờ admin xác thực.");
            request.getRequestDispatcher("/resignter.jsp").forward(request, response);
            return;
        }

        request.setAttribute("error", "Đăng ký thất bại. Vui lòng kiểm tra Console để xem lỗi SQL.");
        request.getRequestDispatcher("/resignter.jsp").forward(request, response);
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }
}
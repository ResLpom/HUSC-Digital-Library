package vn.edu.husc.library.servlet;

import vn.edu.husc.library.dao.AdminUserDAO;
import vn.edu.husc.library.dao.RegistrationRequestDAO;
import vn.edu.husc.library.model.User;

import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.IOException;
import java.lang.reflect.Method;
import vn.edu.husc.library.config.DBConnection;
import vn.edu.husc.library.model.User;
import vn.edu.husc.library.model.OptionItem;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class AdminUserServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private AdminUserDAO adminUserDAO;
    private RegistrationRequestDAO registrationRequestDAO;

    @Override
    public void init() throws ServletException {
        adminUserDAO = new AdminUserDAO();
        registrationRequestDAO = new RegistrationRequestDAO();
    }

    private User getCurrentUser(HttpServletRequest request) {
		HttpSession session = request.getSession(false);

		if (session == null) {
			return null;
		}

		User user = (User) session.getAttribute("currentUser");

		if (user == null) {
			user = (User) session.getAttribute("user");
		}

		return user;
    }

    private boolean isAdmin(User user) {
        return user != null
                && user.getRoleCode() != null
                && "ADMIN".equalsIgnoreCase(user.getRoleCode());
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        User currentUser = getCurrentUser(request);

        if (!isAdmin(currentUser)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String action = request.getParameter("action");

        if (action == null || action.trim().isEmpty()) {
            action = "list";
        }

        if ("add".equalsIgnoreCase(action)
                || "form".equalsIgnoreCase(action)
                || "edit".equalsIgnoreCase(action)) {
            showForm(request, response);
            return;
        }

        if ("lock".equalsIgnoreCase(action)) {
            lockUser(request, response);
            return;
        }

        if ("unlock".equalsIgnoreCase(action)) {
            unlockUser(request, response);
            return;
        }

        if ("delete".equalsIgnoreCase(action)
                || "hide".equalsIgnoreCase(action)) {
            deleteUser(request, response);
            return;
        }

        listUsers(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        User currentUser = getCurrentUser(request);

        if (!isAdmin(currentUser)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String action = request.getParameter("action");

        if ("insert".equalsIgnoreCase(action)
                || "add".equalsIgnoreCase(action)) {
            insertUser(request, response);
            return;
        }

        if ("update".equalsIgnoreCase(action)
                || "edit".equalsIgnoreCase(action)) {
            updateUser(request, response);
            return;
        }

        if ("lock".equalsIgnoreCase(action)) {
            lockUser(request, response);
            return;
        }

        if ("unlock".equalsIgnoreCase(action)) {
            unlockUser(request, response);
            return;
        }

        if ("delete".equalsIgnoreCase(action)
                || "hide".equalsIgnoreCase(action)) {
            deleteUser(request, response);
            return;
        }

        response.sendRedirect(request.getContextPath() + "/admin/users");
    }

    private void listUsers(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        String success = (String) session.getAttribute("adminUserSuccess");
        String error = (String) session.getAttribute("adminUserError");

        session.removeAttribute("adminUserSuccess");
        session.removeAttribute("adminUserError");

        int pendingRegistrationCount = registrationRequestDAO.countPendingRequests();

        request.setAttribute("success", success);
        request.setAttribute("error", error);
        request.setAttribute("users", adminUserDAO.getAllUsers());
        request.setAttribute("pendingRegistrationCount", pendingRegistrationCount);

        request.getRequestDispatcher("/admin/users.jsp").forward(request, response);
    }

    private void showForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");

        if (idParam != null && !idParam.trim().isEmpty()) {
            int userId = parseInt(idParam, 0);

            if (userId > 0) {
                User userEdit = adminUserDAO.getUserById(userId);
                request.setAttribute("userEdit", userEdit);
                request.setAttribute("editUser", userEdit);
            }
        }

        request.setAttribute("roles", adminUserDAO.getRoles());
        request.getRequestDispatcher("/admin/user-form.jsp").forward(request, response);
    }

    private void insertUser(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {

        User user = getUserFromRequest(request);

        boolean success = adminUserDAO.insertUser(user);

        request.getSession().setAttribute(
                success ? "adminUserSuccess" : "adminUserError",
                success ? "Đã thêm người dùng mới." : "Thêm người dùng thất bại."
        );

        response.sendRedirect(request.getContextPath() + "/admin/users");
    }

    private void updateUser(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {

        User user = getUserFromRequest(request);

        int userId = parseInt(request.getParameter("userId"), 0);

        if (userId == 0) {
            userId = parseInt(request.getParameter("id"), 0);
        }

        setValue(user, "setUserId", userId);

        boolean success = adminUserDAO.updateUser(user);

        request.getSession().setAttribute(
                success ? "adminUserSuccess" : "adminUserError",
                success ? "Đã cập nhật người dùng." : "Cập nhật người dùng thất bại."
        );

        response.sendRedirect(request.getContextPath() + "/admin/users");
    }

    private void lockUser(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        int userId = parseInt(request.getParameter("id"), 0);

        boolean success = adminUserDAO.lockUser(userId);

        request.getSession().setAttribute(
                success ? "adminUserSuccess" : "adminUserError",
                success ? "Đã khóa tài khoản." : "Khóa tài khoản thất bại."
        );

        response.sendRedirect(request.getContextPath() + "/admin/users");
    }

    private void unlockUser(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        int userId = parseInt(request.getParameter("id"), 0);

        boolean success = adminUserDAO.unlockUser(userId);

        request.getSession().setAttribute(
                success ? "adminUserSuccess" : "adminUserError",
                success ? "Đã mở khóa tài khoản." : "Mở khóa tài khoản thất bại."
        );

        response.sendRedirect(request.getContextPath() + "/admin/users");
    }

    private void deleteUser(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        int userId = parseInt(request.getParameter("id"), 0);

        boolean success = adminUserDAO.deleteUser(userId);

        request.getSession().setAttribute(
                success ? "adminUserSuccess" : "adminUserError",
                success ? "Đã xóa tài khoản khỏi danh sách." : "Xóa tài khoản thất bại."
        );

        response.sendRedirect(request.getContextPath() + "/admin/users");
    }

    private User getUserFromRequest(HttpServletRequest request) {
        User user = new User();

        int userId = parseInt(request.getParameter("userId"), 0);

        if (userId == 0) {
            userId = parseInt(request.getParameter("id"), 0);
        }

        int roleId = parseInt(request.getParameter("roleId"), 0);

        String username = request.getParameter("username");
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");
        String status = request.getParameter("status");

        if (status == null || status.trim().isEmpty()) {
            status = "ACTIVE";
        }

        setValue(user, "setUserId", userId);
        setValue(user, "setRoleId", roleId);
        setValue(user, "setUsername", username);
        setValue(user, "setFullName", fullName);
        setValue(user, "setEmail", email);
        setValue(user, "setPassword", password);
        setValue(user, "setPhone", phone);
        setValue(user, "setAddress", address);
        setValue(user, "setStatus", status);

        return user;
    }

    private void setValue(Object object, String methodName, Object value) {
        if (object == null || methodName == null) {
            return;
        }

        try {
            Method method = object.getClass().getMethod(methodName, String.class);
            method.invoke(object, value == null ? null : String.valueOf(value));
            return;
        } catch (Exception ignored) {
        }

        try {
            Method method = object.getClass().getMethod(methodName, int.class);
            int intValue = 0;

            if (value != null) {
                intValue = Integer.parseInt(String.valueOf(value));
            }

            method.invoke(object, intValue);
            return;
        } catch (Exception ignored) {
        }

        try {
            Method method = object.getClass().getMethod(methodName, Integer.class);
            Integer intValue = null;

            if (value != null) {
                intValue = Integer.valueOf(String.valueOf(value));
            }

            method.invoke(object, intValue);
        } catch (Exception ignored) {
        }
    }

    private int parseInt(String value, int defaultValue) {
        try {
            if (value == null || value.trim().isEmpty()) {
                return defaultValue;
            }

            return Integer.parseInt(value.trim());
        } catch (Exception e) {
            return defaultValue;
        }
    }
    public List<OptionItem> getRoles() {
        List<OptionItem> roles = new ArrayList<>();

        String sql = "SELECT role_id, role_name "
                + "FROM roles "
                + "ORDER BY role_id";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()
        ) {
            while (rs.next()) {
                OptionItem item = new OptionItem(
                        rs.getInt("role_id"),
                        rs.getString("role_name")
                );

                roles.add(item);
            }

        } catch (Exception e) {
            System.out.println("Lỗi lấy danh sách vai trò!");
            e.printStackTrace();
        }

        return roles;
    }
    public boolean insertUser(User user) {
        String sql = "INSERT INTO users "
                + "(role_id, full_name, email, password, phone, status, username, created_at) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, GETDATE())";

        try (
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            int roleId = user.getRoleId();

            if (roleId <= 0) {
                roleId = 3;
            }

            String status = user.getStatus();

            if (status == null || status.trim().isEmpty()) {
                status = "ACTIVE";
            }

            String username = user.getUsername();

            if (username == null || username.trim().isEmpty()) {
                username = user.getEmail();
            }

            ps.setInt(1, roleId);
            ps.setString(2, user.getFullName());
            ps.setString(3, user.getEmail());
            ps.setString(4, user.getPassword());
            ps.setString(5, user.getPhone());
            ps.setString(6, status);
            ps.setString(7, username);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            System.out.println("Lỗi thêm người dùng!");
            e.printStackTrace();
        }

        return false;
    }
}
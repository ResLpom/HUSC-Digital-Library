package vn.edu.husc.library.servlet;

import vn.edu.husc.library.config.DBConnection;
import vn.edu.husc.library.model.User;

import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.IOException;
import java.lang.reflect.Method;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class LoginServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String account = trim(request.getParameter("account"));
        String password = trim(request.getParameter("password"));

        if (account.isEmpty()) {
            account = trim(request.getParameter("email"));
        }

        if (account.isEmpty() || password.isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập tài khoản và mật khẩu.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        User user = findUser(account, password);

        if (user == null) {
            request.setAttribute("error", "Tài khoản hoặc mật khẩu không đúng.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        String status = getValue(user, "getStatus");

        if (status == null || status.trim().isEmpty()) {
            status = "ACTIVE";
        }

        status = status.trim().toUpperCase();

        if ("PENDING".equals(status)) {
            request.setAttribute("error", "Tài khoản của bạn đang chờ admin xác thực. Vui lòng chờ duyệt.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        if ("REJECTED".equals(status)) {
            request.setAttribute("error", "Tài khoản đăng ký đã bị từ chối. Vui lòng kiểm tra lại thông tin hoặc liên hệ admin.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        if ("LOCKED".equals(status)) {
            request.setAttribute("error", "Tài khoản của bạn đang bị khóa. Vui lòng liên hệ admin.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        if ("DELETED".equals(status)
                || "INACTIVE".equals(status)) {
            request.setAttribute("error", "Tài khoản không còn hoạt động trong hệ thống.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        if (!"ACTIVE".equals(status)) {
            request.setAttribute("error", "Tài khoản chưa được phép đăng nhập.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        HttpSession session = request.getSession(true);

        session.setAttribute("currentUser", user);
        session.setAttribute("user", user);
        session.setAttribute("roleCode", getValue(user, "getRoleCode"));

        String roleCode = getValue(user, "getRoleCode");

        if ("ADMIN".equalsIgnoreCase(roleCode)) {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            return;
        }

        if ("MANAGER".equalsIgnoreCase(roleCode)) {
            response.sendRedirect(request.getContextPath() + "/manager/dashboard");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/index.jsp");
    }

    private User findUser(String account, String password) {
        Connection conn = null;

        try {
            conn = DBConnection.getConnection();

            boolean hasUsername = hasColumn(conn, "users", "username");
            boolean hasStudentCode = hasColumn(conn, "users", "student_code");
            boolean hasPhone = hasColumn(conn, "users", "phone");
            boolean hasAddress = hasColumn(conn, "users", "address");
            boolean hasStatus = hasColumn(conn, "users", "status");
            boolean hasDeletedAt = hasColumn(conn, "users", "deleted_at");
            boolean hasPassword = hasColumn(conn, "users", "password");
            boolean hasPasswordHash = hasColumn(conn, "users", "password_hash");

            boolean hasRolesTable = hasTable(conn, "roles");
            boolean hasRoleCode = hasRolesTable && hasColumn(conn, "roles", "role_code");
            boolean hasRoleName = hasRolesTable && hasColumn(conn, "roles", "role_name");

            StringBuilder sql = new StringBuilder();

            sql.append("SELECT TOP 1 ");
            sql.append("u.user_id AS user_id, ");
            sql.append(hasUsername ? "u.username AS username, " : "'' AS username, ");
            sql.append("u.full_name AS full_name, ");
            sql.append("u.email AS email, ");

            if (hasPassword) {
                sql.append("u.password AS login_password, ");
            } else if (hasPasswordHash) {
                sql.append("u.password_hash AS login_password, ");
            } else {
                sql.append("'' AS login_password, ");
            }

            sql.append(hasPhone ? "u.phone AS phone, " : "'' AS phone, ");
            sql.append(hasAddress ? "u.address AS address, " : "'' AS address, ");
            sql.append("u.role_id AS role_id, ");
            sql.append(hasStatus ? "ISNULL(u.status, 'ACTIVE') AS status, " : "'ACTIVE' AS status, ");

            if (hasRoleCode) {
                sql.append("r.role_code AS role_code, ");
            } else {
                sql.append("'' AS role_code, ");
            }

            if (hasRoleName) {
                sql.append("r.role_name AS role_name ");
            } else {
                sql.append("'' AS role_name ");
            }

            sql.append("FROM users u ");

            if (hasRolesTable) {
                sql.append("LEFT JOIN roles r ON u.role_id = r.role_id ");
            }

            sql.append("WHERE (u.email = ? ");

            if (hasUsername) {
                sql.append("OR u.username = ? ");
            }

            if (hasStudentCode) {
                sql.append("OR u.student_code = ? ");
            }

            sql.append(") ");

            if (hasDeletedAt) {
                sql.append("AND u.deleted_at IS NULL ");
            }

            sql.append("ORDER BY u.user_id ASC");

            PreparedStatement ps = conn.prepareStatement(sql.toString());

            int index = 1;

            ps.setString(index++, account);

            if (hasUsername) {
                ps.setString(index++, account);
            }

            if (hasStudentCode) {
                ps.setString(index++, account);
            }

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                String storedPassword = rs.getString("login_password");

                if (storedPassword == null) {
                    return null;
                }

                if (!storedPassword.trim().equals(password)) {
                    return null;
                }

                User user = new User();

                setValue(user, "setUserId", rs.getInt("user_id"));
                setValue(user, "setUsername", rs.getString("username"));
                setValue(user, "setFullName", rs.getString("full_name"));
                setValue(user, "setEmail", rs.getString("email"));
                setValue(user, "setPassword", storedPassword);
                setValue(user, "setPhone", rs.getString("phone"));
                setValue(user, "setAddress", rs.getString("address"));
                setValue(user, "setRoleId", rs.getInt("role_id"));
                setValue(user, "setRoleCode", rs.getString("role_code"));
                setValue(user, "setRoleName", rs.getString("role_name"));
                setValue(user, "setStatus", rs.getString("status"));

                return user;
            }

        } catch (Exception e) {
            System.out.println("Lỗi đăng nhập!");
            e.printStackTrace();

        } finally {
            try {
                if (conn != null) {
                    conn.close();
                }
            } catch (Exception ignored) {
            }
        }

        return null;
    }

    private boolean hasTable(Connection conn, String tableName) {
        String sql = "SELECT 1 "
                + "FROM INFORMATION_SCHEMA.TABLES "
                + "WHERE TABLE_NAME = ?";

        try (
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setString(1, tableName);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }

        } catch (Exception e) {
            return false;
        }
    }

    private boolean hasColumn(Connection conn, String tableName, String columnName) {
        String sql = "SELECT 1 "
                + "FROM INFORMATION_SCHEMA.COLUMNS "
                + "WHERE TABLE_NAME = ? "
                + "AND COLUMN_NAME = ?";

        try (
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setString(1, tableName);
            ps.setString(2, columnName);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }

        } catch (Exception e) {
            return false;
        }
    }

    private String getValue(Object object, String methodName) {
        if (object == null || methodName == null) {
            return "";
        }

        try {
            Method method = object.getClass().getMethod(methodName);
            Object value = method.invoke(object);

            return value == null ? "" : String.valueOf(value);
        } catch (Exception e) {
            return "";
        }
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

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }
}
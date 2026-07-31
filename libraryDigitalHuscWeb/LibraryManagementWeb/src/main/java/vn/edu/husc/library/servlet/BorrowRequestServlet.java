package vn.edu.husc.library.servlet;

import vn.edu.husc.library.dao.BorrowRequestDAO;
import vn.edu.husc.library.dao.EquipmentDAO;
import vn.edu.husc.library.model.BorrowRequest;
import vn.edu.husc.library.model.Equipment;
import vn.edu.husc.library.model.User;

import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Date;
import java.util.List;

public class BorrowRequestServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private BorrowRequestDAO borrowRequestDAO;
    private EquipmentDAO equipmentDAO;

    @Override
    public void init() throws ServletException {
        borrowRequestDAO = new BorrowRequestDAO();
        equipmentDAO = new EquipmentDAO();
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

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String path = request.getServletPath();

        if ("/my-borrow-requests".equals(path)) {
            showMyRequests(request, response);
            return;
        }

        showBorrowForm(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        createBorrowRequest(request, response);
    }

    private void showBorrowForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = getCurrentUser(request);

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        if (!"MEMBER".equalsIgnoreCase(currentUser.getRoleCode())) {
            response.sendRedirect(request.getContextPath() + "/index.jsp");
            return;
        }

        String equipmentIdParam = request.getParameter("equipmentId");

        if (equipmentIdParam == null || equipmentIdParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/equipments");
            return;
        }

        try {
            int equipmentId = Integer.parseInt(equipmentIdParam);
            Equipment equipment = equipmentDAO.getEquipmentById(equipmentId);

            if (equipment == null) {
                response.sendRedirect(request.getContextPath() + "/equipments");
                return;
            }

            request.setAttribute("equipment", equipment);

            if (!"AVAILABLE".equalsIgnoreCase(equipment.getStatus())) {
                request.setAttribute("error", "Thiết bị hiện không sẵn sàng để mượn.");
            }

            request.getRequestDispatcher("/borrow-request.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/equipments");
        }
    }

    private void createBorrowRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = getCurrentUser(request);

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        if (!"MEMBER".equalsIgnoreCase(currentUser.getRoleCode())) {
            response.sendRedirect(request.getContextPath() + "/index.jsp");
            return;
        }

        Equipment equipment = null;

        try {
            int userId = currentUser.getUserId();
            int equipmentId = Integer.parseInt(request.getParameter("equipmentId"));

            String borrowDateStr = request.getParameter("borrowDate");
            String expectedReturnDateStr = request.getParameter("expectedReturnDate");
            String purpose = request.getParameter("purpose");

            if (purpose == null) {
                purpose = "";
            }

            Date borrowDate = Date.valueOf(borrowDateStr);
            Date expectedReturnDate = Date.valueOf(expectedReturnDateStr);

            equipment = equipmentDAO.getEquipmentById(equipmentId);

            if (equipment == null || !"AVAILABLE".equalsIgnoreCase(equipment.getStatus())) {
                request.setAttribute("error", "Thiết bị hiện không sẵn sàng để mượn.");
                request.setAttribute("equipment", equipment);
                request.getRequestDispatcher("/borrow-request.jsp").forward(request, response);
                return;
            }

            boolean existed = borrowRequestDAO.hasPendingRequest(userId, equipmentId);

            if (existed) {
                request.setAttribute("error", "Bạn đã có yêu cầu mượn thiết bị này đang chờ xử lý.");
                request.setAttribute("equipment", equipment);
                request.getRequestDispatcher("/borrow-request.jsp").forward(request, response);
                return;
            }

            boolean success = borrowRequestDAO.createRequest(
                    userId,
                    equipmentId,
                    borrowDate,
                    expectedReturnDate,
                    purpose.trim()
            );

            if (success) {
                response.sendRedirect(request.getContextPath() + "/my-borrow-requests");
                return;
            }

            request.setAttribute("error", "Gửi yêu cầu mượn thất bại.");
            request.setAttribute("equipment", equipment);
            request.getRequestDispatcher("/borrow-request.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();

            request.setAttribute("error", "Dữ liệu yêu cầu mượn không hợp lệ.");

            if (equipment != null) {
                request.setAttribute("equipment", equipment);
            }

            request.getRequestDispatcher("/borrow-request.jsp").forward(request, response);
        }
    }

    private void showMyRequests(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = getCurrentUser(request);

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        List<BorrowRequest> requests = borrowRequestDAO.getRequestsByUserId(currentUser.getUserId());

        request.setAttribute("requests", requests);
        request.setAttribute("borrowRequests", requests);
        request.setAttribute("myRequests", requests);

        request.getRequestDispatcher("/my-borrow-requests.jsp").forward(request, response);
    }
}
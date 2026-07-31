package vn.edu.husc.library.servlet;

import vn.edu.husc.library.dao.BorrowRequestDAO;
import vn.edu.husc.library.model.BorrowRequest;
import vn.edu.husc.library.model.User;

import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

public class EquipmentHistoryServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private BorrowRequestDAO borrowRequestDAO;

    @Override
    public void init() throws ServletException {
        borrowRequestDAO = new BorrowRequestDAO();
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

        User currentUser = getCurrentUser(request);

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        List<BorrowRequest> equipmentHistories =
                borrowRequestDAO.getRequestsByUserId(currentUser.getUserId());

        request.setAttribute("equipmentHistories", equipmentHistories);
        request.getRequestDispatcher("/equipment-history.jsp").forward(request, response);
    }
}
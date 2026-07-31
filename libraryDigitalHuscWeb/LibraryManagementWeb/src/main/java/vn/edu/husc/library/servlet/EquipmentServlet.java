package vn.edu.husc.library.servlet;

import vn.edu.husc.library.dao.EquipmentDAO;
import vn.edu.husc.library.model.Equipment;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

public class EquipmentServlet extends HttpServlet {

    private EquipmentDAO equipmentDAO;

    @Override
    public void init() throws ServletException {
        equipmentDAO = new EquipmentDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String path = request.getServletPath();

        if ("/equipment-detail".equals(path)) {
            showDetail(request, response);
        } else {
            showList(request, response);
        }
    }

    private void showList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String keyword = request.getParameter("keyword");

        if (keyword == null) {
            keyword = "";
        }

        List<Equipment> equipments = equipmentDAO.searchEquipments(keyword.trim());

        request.setAttribute("equipments", equipments);
        request.setAttribute("keyword", keyword);

        request.getRequestDispatcher("/equipments.jsp").forward(request, response);
    }

    private void showDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");

        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/equipments");
            return;
        }

        try {
            int id = Integer.parseInt(idParam);

            Equipment equipment = equipmentDAO.getEquipmentById(id);

            if (equipment == null) {
                response.sendRedirect(request.getContextPath() + "/equipments");
                return;
            }

            request.setAttribute("equipment", equipment);
            request.getRequestDispatcher("/equipment-detail.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/equipments");
        }
    }
}
package vn.edu.husc.library.servlet;

import vn.edu.husc.library.dao.AdminDocumentDAO;
import vn.edu.husc.library.model.Document;
import vn.edu.husc.library.model.OptionItem;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.*;

public class AdminDocumentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private AdminDocumentDAO adminDocumentDAO;

    @Override
    public void init() throws ServletException {
        adminDocumentDAO = new AdminDocumentDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");

        if (action == null || action.trim().isEmpty()) {
            action = "list";
        }

        if ("form".equalsIgnoreCase(action)) {
            showForm(request, response);
            return;
        }

        if ("hide".equalsIgnoreCase(action) || "delete".equalsIgnoreCase(action)) {
            deleteDocument(request, response);
            return;
        }

        listDocuments(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");

        if ("insert".equalsIgnoreCase(action)) {
            insertDocument(request, response);
            return;
        }

        if ("update".equalsIgnoreCase(action)) {
            updateDocument(request, response);
            return;
        }

        if ("hide".equalsIgnoreCase(action) || "delete".equalsIgnoreCase(action)) {
            deleteDocument(request, response);
            return;
        }

        response.sendRedirect(request.getContextPath() + "/admin/documents");
    }

    private void listDocuments(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Document> documents = adminDocumentDAO.getAllDocuments();

        request.setAttribute("documents", documents);
        request.getRequestDispatcher("/admin/documents.jsp").forward(request, response);
    }

    private void showForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");

        if (idParam != null && !idParam.trim().isEmpty()) {
            try {
                int documentId = Integer.parseInt(idParam);
                Document document = adminDocumentDAO.getDocumentById(documentId);
                request.setAttribute("document", document);
            } catch (Exception e) {
                e.printStackTrace();
                request.getSession().setAttribute("adminDocumentError", "Mã tài liệu không hợp lệ.");
                response.sendRedirect(request.getContextPath() + "/admin/documents");
                return;
            }
        }

        loadDropdownData(request);

        request.getRequestDispatcher("/admin/document-form.jsp").forward(request, response);
    }

    private void insertDocument(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Document document = getDocumentFromRequest(request);

        boolean success = adminDocumentDAO.insertDocument(document);

        if (success) {
            request.getSession().setAttribute("adminDocumentSuccess", "Đã thêm tài liệu mới.");
            response.sendRedirect(request.getContextPath() + "/admin/documents");
            return;
        }

        request.setAttribute("error", "Thêm tài liệu thất bại!");
        request.setAttribute("document", document);
        loadDropdownData(request);
        request.getRequestDispatcher("/admin/document-form.jsp").forward(request, response);
    }

    private void updateDocument(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Document document = getDocumentFromRequest(request);

        String idParam = request.getParameter("documentId");

        if (idParam != null && !idParam.trim().isEmpty()) {
            try {
                document.setDocumentId(Integer.parseInt(idParam));
            } catch (Exception e) {
                request.setAttribute("error", "Mã tài liệu không hợp lệ!");
                request.setAttribute("document", document);
                loadDropdownData(request);
                request.getRequestDispatcher("/admin/document-form.jsp").forward(request, response);
                return;
            }
        }

        boolean success = adminDocumentDAO.updateDocument(document);

        if (success) {
            request.getSession().setAttribute("adminDocumentSuccess", "Đã cập nhật tài liệu.");
            response.sendRedirect(request.getContextPath() + "/admin/documents");
            return;
        }

        request.setAttribute("error", "Cập nhật tài liệu thất bại!");
        request.setAttribute("document", document);
        loadDropdownData(request);
        request.getRequestDispatcher("/admin/document-form.jsp").forward(request, response);
    }

    private void deleteDocument(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        try {
            int documentId = Integer.parseInt(request.getParameter("id"));

            boolean success = adminDocumentDAO.hideDocument(documentId);

            request.getSession().setAttribute(
                    success ? "adminDocumentSuccess" : "adminDocumentError",
                    success ? "Đã xóa tài liệu khỏi danh sách hiển thị." : "Không thể xóa tài liệu."
            );

        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("adminDocumentError", "Mã tài liệu không hợp lệ.");
        }

        response.sendRedirect(request.getContextPath() + "/admin/documents");
    }

    private void loadDropdownData(HttpServletRequest request) {
        List<OptionItem> categories = adminDocumentDAO.getCategories();
        List<OptionItem> types = adminDocumentDAO.getTypes();
        List<OptionItem> authors = adminDocumentDAO.getAuthors();
        List<OptionItem> publishers = adminDocumentDAO.getPublishers();

        request.setAttribute("categories", categories);
        request.setAttribute("types", types);
        request.setAttribute("authors", authors);
        request.setAttribute("publishers", publishers);
    }

    private Document getDocumentFromRequest(HttpServletRequest request) {
        Document document = new Document();

        document.setTitle(request.getParameter("title"));
        document.setDescription(request.getParameter("description"));
        document.setFilePath(request.getParameter("filePath"));
        document.setCoverImage(request.getParameter("coverImage"));

        String status = request.getParameter("status");

        if (status == null || status.trim().isEmpty()) {
            status = "ACTIVE";
        }

        document.setStatus(status);

        document.setCategoryId(parseInt(request.getParameter("categoryId"), 0));
        document.setTypeId(parseInt(request.getParameter("typeId"), 0));
        document.setPublishYear(parseInt(request.getParameter("publishYear"), 2024));

        Integer authorId = parseNullableInt(request.getParameter("authorId"));
        String newAuthorName = request.getParameter("newAuthorName");

        if ((authorId == null || authorId == 0)
                && newAuthorName != null
                && !newAuthorName.trim().isEmpty()) {

            newAuthorName = newAuthorName.trim();

            Integer existingAuthorId = adminDocumentDAO.findAuthorIdByName(newAuthorName);

            if (existingAuthorId != null) {
                authorId = existingAuthorId;
            } else {
                authorId = adminDocumentDAO.insertAuthorAndReturnId(newAuthorName);
            }
        }

        Integer publisherId = parseNullableInt(request.getParameter("publisherId"));
        String newPublisherName = request.getParameter("newPublisherName");

        if ((publisherId == null || publisherId == 0)
                && newPublisherName != null
                && !newPublisherName.trim().isEmpty()) {

            newPublisherName = newPublisherName.trim();

            Integer existingPublisherId = adminDocumentDAO.findPublisherIdByName(newPublisherName);

            if (existingPublisherId != null) {
                publisherId = existingPublisherId;
            } else {
                publisherId = adminDocumentDAO.insertPublisherAndReturnId(newPublisherName);
            }
        }

        document.setAuthorId(authorId);
        document.setPublisherId(publisherId);

        return document;
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

    private Integer parseNullableInt(String value) {
        try {
            if (value == null || value.trim().isEmpty()) {
                return null;
            }

            return Integer.valueOf(value.trim());
        } catch (Exception e) {
            return null;
        }
    }
}
package vn.edu.husc.library.servlet;

import vn.edu.husc.library.dao.DocumentDAO;
import vn.edu.husc.library.model.Document;
import vn.edu.husc.library.model.User;

import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

public class DocumentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private DocumentDAO documentDAO = new DocumentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");

        if (action == null || action.trim().isEmpty()) {
            action = "list";
        }

        if ("detail".equals(action)) {
            showDetail(request, response);
        } else if ("download".equals(action)) {
            downloadDocument(request, response);
        } else if ("favorite".equals(action)) {
            toggleFavorite(request, response);
        } else {
            listDocuments(request, response);
        }
    }

    private void listDocuments(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String keyword = request.getParameter("keyword");
        List<Document> documents;

        if (keyword != null && !keyword.trim().isEmpty()) {
            documents = documentDAO.searchDocuments(keyword.trim());
        } else {
            documents = documentDAO.getAllDocuments();
        }

        List<Document> featuredDocuments = documentDAO.getFeaturedDocuments();

        request.setAttribute("documents", documents);
        request.setAttribute("featuredDocuments", featuredDocuments);
        request.setAttribute("keyword", keyword);

        request.getRequestDispatcher("/documents.jsp").forward(request, response);
    }

    private void showDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");

        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/documents");
            return;
        }

        int documentId = Integer.parseInt(idParam);

        Document document = documentDAO.getDocumentById(documentId);

        if (document == null) {
            response.sendRedirect(request.getContextPath() + "/documents");
            return;
        }

        documentDAO.increaseViewCount(documentId);

        HttpSession session = request.getSession(false);
        User user = null;

        if (session != null) {
            user = (User) session.getAttribute("user");
        }

        boolean favorite = false;

        if (user != null) {
            documentDAO.addViewHistory(user.getUserId(), documentId);
            favorite = documentDAO.isFavorite(user.getUserId(), documentId);
        }

        List<Document> relatedDocuments = documentDAO.getRelatedDocuments(
                documentId,
                document.getCategoryId()
        );

        request.setAttribute("document", document);
        request.setAttribute("relatedDocuments", relatedDocuments);
        request.setAttribute("favorite", favorite);

        request.getRequestDispatcher("/document-detail.jsp").forward(request, response);
    }

    private void toggleFavorite(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String idParam = request.getParameter("id");

        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/documents");
            return;
        }

        int documentId = Integer.parseInt(idParam);
        User user = (User) session.getAttribute("user");

        boolean favorite = documentDAO.isFavorite(user.getUserId(), documentId);

        if (favorite) {
            documentDAO.removeFavorite(user.getUserId(), documentId);
        } else {
            documentDAO.addFavorite(user.getUserId(), documentId);
        }

        response.sendRedirect(request.getContextPath() + "/documents?action=detail&id=" + documentId);
    }

    private void downloadDocument(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String idParam = request.getParameter("id");

        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/documents");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/document-download?id=" + idParam.trim());
    }
}
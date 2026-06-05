<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, db_ayar.Baglanti" %>
<%
    String idParam = request.getParameter("id");
    if (idParam != null) {
        Connection conn = null;
        try {
            conn = Baglanti.getConnection();
            PreparedStatement ps = conn.prepareStatement("DELETE FROM recipes WHERE id=?");
            ps.setInt(1, Integer.parseInt(idParam));
            ps.executeUpdate();
            ps.close();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (conn != null) conn.close();
        }
    }
    response.sendRedirect("index.jsp");
%>
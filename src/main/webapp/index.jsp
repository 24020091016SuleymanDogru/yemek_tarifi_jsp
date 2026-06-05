<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, db_ayar.Baglanti" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Yemek Tarifleri</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: Arial, sans-serif; background: #f5f5f5; }
        .navbar { background: #d35400; padding: 14px 24px; display: flex; justify-content: space-between; align-items: center; }
        .navbar a { color: white; text-decoration: none; font-weight: bold; font-size: 18px; }
        .navbar .links a { color: white; margin-left: 20px; font-size: 14px; text-decoration: none; }
        .navbar .links a:hover { text-decoration: underline; }
        .container { max-width: 1100px; margin: 24px auto; padding: 0 16px; }
        .filter-row { display: flex; gap: 10px; margin-bottom: 20px; flex-wrap: wrap; align-items: center; }
        .filter-row a { padding: 6px 16px; border-radius: 20px; border: 1px solid #d35400; color: #d35400; text-decoration: none; font-size: 14px; background: white; }
        .filter-row a.active, .filter-row a:hover { background: #d35400; color: white; }
        .grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 18px; }
        .kart { background: white; border-radius: 10px; overflow: hidden; box-shadow: 0 2px 6px rgba(0,0,0,0.08); }
        .kart img { width: 100%; height: 160px; object-fit: cover; background: #eee; }
        .kart-no-img { width: 100%; height: 160px; background: #fde8d8; display: flex; align-items: center; justify-content: center; font-size: 52px; }
        .kart-body { padding: 12px; }
        .kart-body h3 { font-size: 15px; color: #2c2c2c; margin-bottom: 6px; }
        .kart-body .meta { font-size: 12px; color: #888; display: flex; justify-content: space-between; }
        .badge { background: #fde8d8; color: #d35400; font-size: 11px; padding: 2px 8px; border-radius: 10px; }
        .kart-body .actions { margin-top: 10px; display: flex; gap: 6px; }
        .btn { padding: 5px 12px; border-radius: 6px; font-size: 12px; text-decoration: none; border: none; cursor: pointer; }
        .btn-detail { background: #d35400; color: white; }
        .btn-edit { background: #f0f0f0; color: #333; }
        .btn-del { background: #ffe0e0; color: #c0392b; }
        .empty { text-align: center; color: #aaa; padding: 60px 0; font-size: 16px; }
        .add-btn { display: inline-block; padding: 9px 20px; background: #d35400; color: white; border-radius: 8px; text-decoration: none; font-size: 14px; margin-bottom: 16px; }
    </style>
</head>
<body>
<div class="navbar">
    <a href="index.jsp">🍲 Yemek Tarifleri</a>
    <div class="links">
        <a href="index.jsp">Ana Sayfa</a>
        <a href="tarifler.jsp">Tarif Ekle</a>
        <a href="alisveris.jsp">Alışveriş Listesi</a>
    </div>
</div>

<div class="container">
    <%
        String kategoriParam = request.getParameter("kategori");
        int seciliKategori = 0;
        if (kategoriParam != null) {
            try { seciliKategori = Integer.parseInt(kategoriParam); } catch (Exception e) {}
        }
    %>

    <!-- Kategori filtreleri -->
    <div class="filter-row">
        <a href="index.jsp" class="<%= seciliKategori == 0 ? "active" : "" %>">Tümü</a>
        <%
            Connection connKat = null;
            try {
                connKat = Baglanti.getConnection();
                Statement stmtKat = connKat.createStatement();
                ResultSet rsKat = stmtKat.executeQuery("SELECT id, category_name FROM categories ORDER BY id");
                while (rsKat.next()) {
                    int kid = rsKat.getInt("id");
                    String kname = rsKat.getString("category_name");
        %>
        <a href="index.jsp?kategori=<%= kid %>" class="<%= seciliKategori == kid ? "active" : "" %>"><%= kname %></a>
        <%
                }
                rsKat.close(); stmtKat.close();
            } catch (Exception e) { out.println("Kategori hatası: " + e.getMessage()); }
            finally { if (connKat != null) connKat.close(); }
        %>
        <a href="tarifler.jsp" class="add-btn" style="margin-left:auto;">+ Yeni Tarif</a>
    </div>

    <!-- Tarif kartları -->
    <div class="grid">
        <%
            Connection conn = null;
            try {
                conn = Baglanti.getConnection();
                String sql = "SELECT r.id, r.title, r.photo_url, r.prep_time_min, c.category_name, c.id as cat_id " +
                             "FROM recipes r JOIN categories c ON r.category_id = c.id";
                if (seciliKategori > 0) sql += " WHERE c.id = " + seciliKategori;
                sql += " ORDER BY r.created_at DESC";

                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery(sql);
                boolean found = false;
                while (rs.next()) {
                    found = true;
                    int rid = rs.getInt("id");
                    String title = rs.getString("title");
                    String photo = rs.getString("photo_url");
                    int sure = rs.getInt("prep_time_min");
                    String kat = rs.getString("category_name");
        %>
        <div class="kart">
            <% if (photo != null && !photo.isEmpty()) { %>
                <img src="<%= photo %>" alt="<%= title %>">
            <% } else { %>
                <div class="kart-no-img">🍽️</div>
            <% } %>
            <div class="kart-body">
                <h3><%= title %></h3>
                <div class="meta">
                    <span class="badge"><%= kat %></span>
                    <span><%= sure > 0 ? sure + " dk" : "-" %></span>
                </div>
                <div class="actions">
                    <a href="detay.jsp?id=<%= rid %>" class="btn btn-detail">Detay</a>
                    <a href="tarifler.jsp?id=<%= rid %>" class="btn btn-edit">Düzenle</a>
                    <a href="sil.jsp?id=<%= rid %>" class="btn btn-del" onclick="return confirm('Tarifi sil?')">Sil</a>
                </div>
            </div>
        </div>
        <%
                }
                if (!found) {
        %>
        <div class="empty" style="grid-column:1/-1">Henüz tarif eklenmemiş.</div>
        <%
                }
                rs.close(); stmt.close();
            } catch (Exception e) {
                out.println("<p style='color:red'>Hata: " + e.getMessage() + "</p>");
            } finally {
                if (conn != null) conn.close();
            }
        %>
    </div>
</div>
</body>
</html>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, db_ayar.Baglanti" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Tarif Detayı</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: Arial, sans-serif; background: #f5f5f5; }
        .navbar { background: #d35400; padding: 14px 24px; display: flex; justify-content: space-between; align-items: center; }
        .navbar a { color: white; text-decoration: none; font-weight: bold; font-size: 18px; }
        .navbar .links a { color: white; margin-left: 20px; font-size: 14px; text-decoration: none; }
        .container { max-width: 800px; margin: 30px auto; padding: 0 16px; }
        .hero { width: 100%; height: 300px; object-fit: cover; border-radius: 12px; margin-bottom: 24px; }
        .hero-placeholder { width: 100%; height: 300px; background: #fde8d8; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 80px; margin-bottom: 24px; }
        .badge { background: #fde8d8; color: #d35400; font-size: 13px; padding: 4px 12px; border-radius: 12px; display: inline-block; margin-bottom: 10px; }
        h1 { font-size: 28px; color: #2c2c2c; margin-bottom: 8px; }
        .meta { font-size: 14px; color: #888; margin-bottom: 20px; }
        .card { background: white; border-radius: 10px; padding: 22px; box-shadow: 0 2px 6px rgba(0,0,0,0.07); margin-bottom: 20px; }
        .card h2 { font-size: 16px; color: #d35400; margin-bottom: 14px; border-bottom: 1px solid #fde8d8; padding-bottom: 8px; }
        .ing-table { width: 100%; border-collapse: collapse; font-size: 14px; }
        .ing-table tr { border-bottom: 1px solid #f5f5f5; }
        .ing-table td { padding: 8px 4px; }
        .ing-table td:last-child { text-align: right; color: #888; }
        .step-item { display: flex; gap: 14px; margin-bottom: 16px; align-items: flex-start; }
        .step-num { min-width: 32px; height: 32px; background: #d35400; color: white; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 14px; font-weight: bold; flex-shrink: 0; }
        .step-text { font-size: 15px; color: #333; line-height: 1.6; padding-top: 5px; }
        .actions { display: flex; gap: 10px; margin-bottom: 24px; }
        .btn { padding: 9px 20px; border-radius: 8px; font-size: 14px; text-decoration: none; border: none; cursor: pointer; }
        .btn-edit { background: #f0f0f0; color: #333; }
        .btn-del { background: #ffebee; color: #c62828; }
        .btn-back { background: #d35400; color: white; }
        .desc { font-size: 15px; color: #555; line-height: 1.7; margin-bottom: 20px; }
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
    String idParam = request.getParameter("id");
    if (idParam == null) { response.sendRedirect("index.jsp"); return; }
    int rid = Integer.parseInt(idParam);
    Connection conn = Baglanti.getConnection();

    // Tarif bilgisi
    PreparedStatement ps = conn.prepareStatement(
        "SELECT r.*, c.category_name FROM recipes r JOIN categories c ON r.category_id = c.id WHERE r.id=?");
    ps.setInt(1, rid);
    ResultSet rs = ps.executeQuery();
    if (!rs.next()) { response.sendRedirect("index.jsp"); return; }

    String title    = rs.getString("title");
    String desc     = rs.getString("description");
    String photo    = rs.getString("photo_url");
    int    prep     = rs.getInt("prep_time_min");
    String katName  = rs.getString("category_name");
    rs.close(); ps.close();
%>

<!-- Fotoğraf -->
<% if (photo != null && !photo.isEmpty()) { %>
    <img src="<%= photo %>" class="hero" alt="<%= title %>">
<% } else { %>
    <div class="hero-placeholder">🍽️</div>
<% } %>

<!-- Başlık -->
<span class="badge"><%= katName %></span>
<h1><%= title %></h1>
<p class="meta">⏱ <%= prep > 0 ? prep + " dakika" : "Süre belirtilmemiş" %></p>

<% if (desc != null && !desc.isEmpty()) { %>
<p class="desc"><%= desc %></p>
<% } %>

<!-- Aksiyon butonları -->
<div class="actions">
    <a href="index.jsp" class="btn btn-back">← Geri</a>
    <a href="tarifler.jsp?id=<%= rid %>" class="btn btn-edit">✏️ Düzenle</a>
    <a href="sil.jsp?id=<%= rid %>" class="btn btn-del" onclick="return confirm('Bu tarifi silmek istediğinize emin misiniz?')">🗑 Sil</a>
</div>

<!-- Malzemeler -->
<div class="card">
    <h2>🧺 Malzemeler</h2>
    <table class="ing-table">
    <%
        PreparedStatement psI = conn.prepareStatement(
            "SELECT i.name, ri.amount, ri.unit_override FROM recipe_ingredients ri " +
            "JOIN ingredients i ON ri.ingredient_id = i.id WHERE ri.recipe_id=? ORDER BY i.name");
        psI.setInt(1, rid);
        ResultSet rsI = psI.executeQuery();
        boolean hasIng = false;
        while (rsI.next()) {
            hasIng = true;
            double amt = rsI.getDouble("amount");
            String unit = rsI.getString("unit_override");
    %>
        <tr>
            <td><%= rsI.getString("name") %></td>
            <td><%= amt > 0 ? amt : "" %> <%= unit != null ? unit : "" %></td>
        </tr>
    <%
        }
        if (!hasIng) { %><tr><td colspan="2" style="color:#aaa;">Malzeme eklenmemiş.</td></tr><% }
        rsI.close(); psI.close();
    %>
    </table>
</div>

<!-- Hazırlanış -->
<div class="card">
    <h2>👨‍🍳 Hazırlanış</h2>
    <%
        PreparedStatement psSt = conn.prepareStatement(
            "SELECT step_order, description FROM steps WHERE recipe_id=? ORDER BY step_order");
        psSt.setInt(1, rid);
        ResultSet rsSt = psSt.executeQuery();
        boolean hasStep = false;
        while (rsSt.next()) {
            hasStep = true;
    %>
    <div class="step-item">
        <div class="step-num"><%= rsSt.getInt("step_order") %></div>
        <div class="step-text"><%= rsSt.getString("description") %></div>
    </div>
    <%
        }
        if (!hasStep) { %><p style="color:#aaa;font-size:14px;">Adım eklenmemiş.</p><% }
        rsSt.close(); psSt.close();
        conn.close();
    %>
</div>

</div>
</body>
</html>
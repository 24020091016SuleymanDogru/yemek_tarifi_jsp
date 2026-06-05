<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, db_ayar.Baglanti" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Alışveriş Listesi</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: Arial, sans-serif; background: #f5f5f5; }
        .navbar { background: #d35400; padding: 14px 24px; display: flex; justify-content: space-between; align-items: center; }
        .navbar a { color: white; text-decoration: none; font-weight: bold; font-size: 18px; }
        .navbar .links a { color: white; margin-left: 20px; font-size: 14px; text-decoration: none; }
        .container { max-width: 700px; margin: 30px auto; padding: 0 16px; }
        .card { background: white; border-radius: 10px; padding: 24px; box-shadow: 0 2px 8px rgba(0,0,0,0.08); margin-bottom: 20px; }
        h2 { font-size: 20px; color: #d35400; margin-bottom: 16px; }
        .shop-item { display: flex; align-items: center; gap: 12px; padding: 10px 0; border-bottom: 1px solid #f0f0f0; }
        .shop-item:last-child { border-bottom: none; }
        .shop-item input[type=checkbox] { width: 18px; height: 18px; accent-color: #d35400; cursor: pointer; }
        .shop-item label { flex: 1; font-size: 15px; cursor: pointer; }
        .shop-item label.done { text-decoration: line-through; color: #bbb; }
        .shop-amount { font-size: 13px; color: #888; min-width: 80px; text-align: right; }
        .add-form { display: flex; gap: 8px; margin-top: 12px; }
        .add-form input { flex: 1; padding: 8px 12px; border: 1px solid #ddd; border-radius: 7px; font-size: 14px; }
        .add-form input.small { flex: 0 0 90px; }
        .btn-primary { padding: 9px 18px; background: #d35400; color: white; border: none; border-radius: 8px; font-size: 14px; cursor: pointer; }
        .btn-danger { padding: 6px 12px; background: #ffebee; color: #c62828; border: 1px solid #ffcdd2; border-radius: 6px; font-size: 13px; cursor: pointer; }
        .empty { color: #aaa; font-size: 14px; text-align: center; padding: 20px 0; }
        .tarif-sec { display: flex; gap: 8px; }
        .tarif-sec select { flex: 1; padding: 8px 12px; border: 1px solid #ddd; border-radius: 7px; font-size: 14px; }
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
    Connection conn = Baglanti.getConnection();

    // Tariften malzeme aktar
    String tarifId = request.getParameter("tarifId");
    if (tarifId != null && !tarifId.isEmpty()) {
        PreparedStatement psT = conn.prepareStatement(
            "SELECT i.name, ri.amount, ri.unit_override FROM recipe_ingredients ri " +
            "JOIN ingredients i ON ri.ingredient_id = i.id WHERE ri.recipe_id=?");
        psT.setInt(1, Integer.parseInt(tarifId));
        ResultSet rsT = psT.executeQuery();
        while (rsT.next()) {
            PreparedStatement ins = conn.prepareStatement(
                "INSERT INTO shopping_list (ingredient_id, amount, unit) " +
                "SELECT id, ?, ? FROM ingredients WHERE LOWER(name)=LOWER(?)");
            ins.setDouble(1, rsT.getDouble("amount"));
            ins.setString(2, rsT.getString("unit_override"));
            ins.setString(3, rsT.getString("name"));
            ins.executeUpdate(); ins.close();
        }
        rsT.close(); psT.close();
    }

    // Manuel ekle
    String yeniMalzeme = request.getParameter("malzeme");
    if (yeniMalzeme != null && !yeniMalzeme.trim().isEmpty()) {
        PreparedStatement insM = conn.prepareStatement(
            "INSERT INTO shopping_list (ingredient_id, amount, unit) " +
            "SELECT id, ?, ? FROM ingredients WHERE LOWER(name)=LOWER(?) LIMIT 1");
        double amt = 0;
        try { amt = Double.parseDouble(request.getParameter("miktar")); } catch (Exception e) {}
        insM.setDouble(1, amt);
        insM.setString(2, request.getParameter("birim"));
        insM.setString(3, yeniMalzeme.trim());
        int rows = insM.executeUpdate(); insM.close();
        if (rows == 0) {
            PreparedStatement insI = conn.prepareStatement("INSERT INTO ingredients (name) VALUES (?) RETURNING id");
            insI.setString(1, yeniMalzeme.trim());
            ResultSet rsI = insI.executeQuery(); rsI.next();
            int newIngId = rsI.getInt(1); insI.close();
            PreparedStatement insL = conn.prepareStatement(
                "INSERT INTO shopping_list (ingredient_id, amount, unit) VALUES (?,?,?)");
            insL.setInt(1, newIngId); insL.setDouble(2, amt);
            insL.setString(3, request.getParameter("birim"));
            insL.executeUpdate(); insL.close();
        }
    }

    // İşaretle / işareti kaldır
    String toggleId = request.getParameter("toggle");
    if (toggleId != null) {
        PreparedStatement pt = conn.prepareStatement(
            "UPDATE shopping_list SET is_checked = NOT is_checked WHERE id=?");
        pt.setInt(1, Integer.parseInt(toggleId)); pt.executeUpdate(); pt.close();
    }

    // Sil
    String silId = request.getParameter("sil");
    if (silId != null) {
        PreparedStatement ps2 = conn.prepareStatement("DELETE FROM shopping_list WHERE id=?");
        ps2.setInt(1, Integer.parseInt(silId)); ps2.executeUpdate(); ps2.close();
    }

    // Tümünü temizle
    if (request.getParameter("temizle") != null) {
        conn.createStatement().executeUpdate("DELETE FROM shopping_list WHERE is_checked=true");
    }
%>

<!-- Tariften malzeme aktar -->
<div class="card">
    <h2>🛒 Alışveriş Listesi</h2>
    <p style="font-size:13px;color:#888;margin-bottom:12px;">Bir tarifin malzemelerini otomatik ekle:</p>
    <form method="GET" class="tarif-sec">
        <select name="tarifId">
            <option value="">— Tarif seç —</option>
            <%
                Statement stR = conn.createStatement();
                ResultSet rsR = stR.executeQuery("SELECT id, title FROM recipes ORDER BY title");
                while (rsR.next()) {
            %>
            <option value="<%= rsR.getInt("id") %>"><%= rsR.getString("title") %></option>
            <%
                }
                rsR.close(); stR.close();
            %>
        </select>
        <button type="submit" class="btn-primary">Ekle</button>
    </form>
</div>

<!-- Manuel ekle -->
<div class="card">
    <h2>+ Manuel Ekle</h2>
    <form method="POST" class="add-form">
        <input type="text" name="malzeme" placeholder="Malzeme adı" required>
        <input type="text" class="small" name="miktar" placeholder="Miktar">
        <input type="text" class="small" name="birim" placeholder="Birim">
        <button type="submit" class="btn-primary">Ekle</button>
    </form>
</div>

<!-- Liste -->
<div class="card">
    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:12px;">
        <h2>📋 Liste</h2>
        <a href="alisveris.jsp?temizle=1" class="btn-danger">Alınanları Temizle</a>
    </div>
    <%
        Statement stL = conn.createStatement();
        ResultSet rsL = stL.executeQuery(
            "SELECT sl.id, i.name, sl.amount, sl.unit, sl.is_checked " +
            "FROM shopping_list sl JOIN ingredients i ON sl.ingredient_id = i.id ORDER BY sl.is_checked, sl.created_at");
        boolean anyItem = false;
        while (rsL.next()) {
            anyItem = true;
            int sid = rsL.getInt("id");
            boolean checked = rsL.getBoolean("is_checked");
    %>
    <div class="shop-item">
        <input type="checkbox" id="cb<%= sid %>" <%= checked ? "checked" : "" %>
               onchange="location='alisveris.jsp?toggle=<%= sid %>'">
        <label for="cb<%= sid %>" class="<%= checked ? "done" : "" %>"><%= rsL.getString("name") %></label>
        <span class="shop-amount">
            <%= rsL.getDouble("amount") > 0 ? rsL.getDouble("amount") + " " : "" %>
            <%= rsL.getString("unit") != null ? rsL.getString("unit") : "" %>
        </span>
        <a href="alisveris.jsp?sil=<%= sid %>" class="btn-danger">Sil</a>
    </div>
    <%
        }
        if (!anyItem) {
    %>
    <div class="empty">Liste boş. Yukarıdan tarif seçin veya malzeme ekleyin.</div>
    <% } %>
    <%
        rsL.close(); stL.close();
        if (conn != null) conn.close();
    %>
</div>
</div>
</body>
</html>
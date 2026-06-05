<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, db_ayar.Baglanti" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Tarif Ekle / Düzenle</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: Arial, sans-serif; background: #f5f5f5; }
        .navbar { background: #d35400; padding: 14px 24px; display: flex; justify-content: space-between; align-items: center; }
        .navbar a { color: white; text-decoration: none; font-weight: bold; font-size: 18px; }
        .navbar .links a { color: white; margin-left: 20px; font-size: 14px; text-decoration: none; }
        .container { max-width: 700px; margin: 30px auto; padding: 0 16px; }
        .card { background: white; border-radius: 10px; padding: 28px; box-shadow: 0 2px 8px rgba(0,0,0,0.08); }
        h2 { font-size: 20px; color: #d35400; margin-bottom: 20px; }
        .form-group { margin-bottom: 16px; }
        label { display: block; font-size: 13px; color: #555; margin-bottom: 5px; font-weight: bold; }
        input[type=text], input[type=number], select, textarea {
            width: 100%; padding: 9px 12px; border: 1px solid #ddd; border-radius: 7px; font-size: 14px; }
        textarea { min-height: 90px; resize: vertical; }
        .row { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
        .btn-primary { padding: 10px 24px; background: #d35400; color: white; border: none; border-radius: 8px; font-size: 15px; cursor: pointer; }
        .btn-secondary { padding: 10px 18px; background: #f0f0f0; color: #333; border: none; border-radius: 8px; font-size: 14px; cursor: pointer; text-decoration: none; display: inline-block; }
        .msg { padding: 10px 14px; border-radius: 7px; margin-bottom: 16px; font-size: 14px; }
        .msg.ok { background: #e8f5e9; color: #2e7d32; }
        .msg.err { background: #ffebee; color: #c62828; }
        .section-title { font-size: 13px; font-weight: bold; color: #888; text-transform: uppercase; letter-spacing: 0.5px; margin: 20px 0 10px; border-top: 1px solid #eee; padding-top: 16px; }
        .ing-row { display: flex; gap: 6px; margin-bottom: 6px; }
        .ing-row input { flex: 1; }
        .ing-row input.small { flex: 0 0 80px; }
        .ing-row button { padding: 0 10px; background: #ffebee; color: #c62828; border: 1px solid #ffcdd2; border-radius: 6px; cursor: pointer; font-size: 14px; }
        .add-link { font-size: 13px; color: #d35400; cursor: pointer; background: none; border: 1px dashed #d35400; padding: 5px 12px; border-radius: 6px; margin-top: 4px; }
        .step-row { display: flex; gap: 8px; margin-bottom: 8px; align-items: flex-start; }
        .step-num { min-width: 28px; height: 28px; background: #fde8d8; color: #d35400; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 13px; font-weight: bold; margin-top: 6px; }
        .step-row textarea { min-height: 60px; }
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
<div class="card">
<%
    String msg = "";
    String msgType = "";
    String idParam = request.getParameter("id");
    int editId = 0;
    if (idParam != null) {
        try { editId = Integer.parseInt(idParam); } catch (Exception e) {}
    }

    // KAYDET veya GÜNCELLE
    if ("POST".equals(request.getMethod())) {
        String title = request.getParameter("title");
        String desc = request.getParameter("description");
        String photo = request.getParameter("photo_url");
        String prepStr = request.getParameter("prep_time_min");
        String catStr = request.getParameter("category_id");
        int prep = 0, catId = 0;
        try { prep = Integer.parseInt(prepStr); } catch (Exception e) {}
        try { catId = Integer.parseInt(catStr); } catch (Exception e) {}

        Connection connS = null;
        try {
            connS = Baglanti.getConnection();
            int recipeId = editId;
            if (editId == 0) {
                PreparedStatement ps = connS.prepareStatement(
                    "INSERT INTO recipes (title, description, photo_url, prep_time_min, category_id) VALUES (?,?,?,?,?) RETURNING id");
                ps.setString(1, title); ps.setString(2, desc); ps.setString(3, photo);
                ps.setInt(4, prep); ps.setInt(5, catId);
                ResultSet rsId = ps.executeQuery();
                if (rsId.next()) recipeId = rsId.getInt(1);
                ps.close();
                msg = "Tarif başarıyla eklendi!"; msgType = "ok";
            } else {
                PreparedStatement ps = connS.prepareStatement(
                    "UPDATE recipes SET title=?, description=?, photo_url=?, prep_time_min=?, category_id=? WHERE id=?");
                ps.setString(1, title); ps.setString(2, desc); ps.setString(3, photo);
                ps.setInt(4, prep); ps.setInt(5, catId); ps.setInt(6, editId);
                ps.executeUpdate(); ps.close();
                msg = "Tarif güncellendi!"; msgType = "ok";
            }

            // Malzemeleri sil ve yeniden ekle
            PreparedStatement delIng = connS.prepareStatement("DELETE FROM recipe_ingredients WHERE recipe_id=?");
            delIng.setInt(1, recipeId); delIng.executeUpdate(); delIng.close();

            String[] ingNames = request.getParameterValues("ing_name");
            String[] ingAmounts = request.getParameterValues("ing_amount");
            String[] ingUnits = request.getParameterValues("ing_unit");
            if (ingNames != null) {
                for (int i = 0; i < ingNames.length; i++) {
                    if (ingNames[i] == null || ingNames[i].trim().isEmpty()) continue;
                    PreparedStatement findIng = connS.prepareStatement(
                        "SELECT id FROM ingredients WHERE LOWER(name)=LOWER(?)");
                    findIng.setString(1, ingNames[i].trim());
                    ResultSet rsIng = findIng.executeQuery();
                    int ingId;
                    if (rsIng.next()) {
                        ingId = rsIng.getInt(1);
                    } else {
                        PreparedStatement insIng = connS.prepareStatement(
                            "INSERT INTO ingredients (name) VALUES (?) RETURNING id");
                        insIng.setString(1, ingNames[i].trim());
                        ResultSet rsNew = insIng.executeQuery();
                        rsNew.next(); ingId = rsNew.getInt(1);
                        insIng.close();
                    }
                    findIng.close();
                    double amount = 0;
                    try { amount = Double.parseDouble(ingAmounts[i]); } catch (Exception e) {}
                    PreparedStatement insRI = connS.prepareStatement(
                        "INSERT INTO recipe_ingredients (recipe_id, ingredient_id, amount, unit_override) VALUES (?,?,?,?)");
                    insRI.setInt(1, recipeId); insRI.setInt(2, ingId);
                    insRI.setDouble(3, amount); insRI.setString(4, ingUnits[i]);
                    insRI.executeUpdate(); insRI.close();
                }
            }

            // Adımları sil ve yeniden ekle
            PreparedStatement delStep = connS.prepareStatement("DELETE FROM steps WHERE recipe_id=?");
            delStep.setInt(1, recipeId); delStep.executeUpdate(); delStep.close();
            String[] stepDescs = request.getParameterValues("step_desc");
            if (stepDescs != null) {
                for (int i = 0; i < stepDescs.length; i++) {
                    if (stepDescs[i] == null || stepDescs[i].trim().isEmpty()) continue;
                    PreparedStatement insStep = connS.prepareStatement(
                        "INSERT INTO steps (recipe_id, step_order, description) VALUES (?,?,?)");
                    insStep.setInt(1, recipeId); insStep.setInt(2, i+1);
                    insStep.setString(3, stepDescs[i].trim());
                    insStep.executeUpdate(); insStep.close();
                }
            }
        } catch (Exception e) {
            msg = "Hata: " + e.getMessage(); msgType = "err";
        } finally {
            if (connS != null) connS.close();
        }
    }

    // Düzenleme için mevcut veriyi çek
    String eTitle = "", eDesc = "", ePhoto = "";
    int ePrep = 0, eCatId = 0;
    if (editId > 0) {
        Connection connE = null;
        try {
            connE = Baglanti.getConnection();
            PreparedStatement psE = connE.prepareStatement("SELECT * FROM recipes WHERE id=?");
            psE.setInt(1, editId);
            ResultSet rsE = psE.executeQuery();
            if (rsE.next()) {
                eTitle = rsE.getString("title");
                eDesc = rsE.getString("description") != null ? rsE.getString("description") : "";
                ePhoto = rsE.getString("photo_url") != null ? rsE.getString("photo_url") : "";
                ePrep = rsE.getInt("prep_time_min");
                eCatId = rsE.getInt("category_id");
            }
            rsE.close(); psE.close();
        } catch (Exception e) { } finally { if (connE != null) connE.close(); }
    }
%>

<h2><%= editId > 0 ? "Tarifi Düzenle" : "Yeni Tarif Ekle" %></h2>

<% if (!msg.isEmpty()) { %><div class="msg <%= msgType %>"><%= msg %></div><% } %>

<form method="POST" action="tarifler.jsp<%= editId > 0 ? "?id=" + editId : "" %>">
    <div class="form-group">
        <label>Tarif Adı *</label>
        <input type="text" name="title" required value="<%= eTitle %>">
    </div>
    <div class="row">
        <div class="form-group">
            <label>Kategori *</label>
            <select name="category_id" required>
                <%
                    Connection connKat2 = null;
                    try {
                        connKat2 = Baglanti.getConnection();
                        Statement sKat = connKat2.createStatement();
                        ResultSet rsK = sKat.executeQuery("SELECT id, category_name FROM categories ORDER BY id");
                        while (rsK.next()) {
                            int kid = rsK.getInt("id");
                            String kname = rsK.getString("category_name");
                %>
                <option value="<%= kid %>" <%= eCatId == kid ? "selected" : "" %>><%= kname %></option>
                <%
                        }
                        rsK.close(); sKat.close();
                    } catch (Exception e) {} finally { if (connKat2 != null) connKat2.close(); }
                %>
            </select>
        </div>
        <div class="form-group">
            <label>Hazırlama Süresi (dakika)</label>
            <input type="number" name="prep_time_min" value="<%= ePrep %>" min="0">
        </div>
    </div>
    <div class="form-group">
        <label>Açıklama</label>
        <textarea name="description"><%= eDesc %></textarea>
    </div>
    <div class="form-group">
        <label>Fotoğraf URL</label>
        <input type="text" name="photo_url" placeholder="https://..." value="<%= ePhoto %>">
    </div>

    <div class="section-title">Malzemeler</div>
    <div id="ing-list">
        <%
            if (editId > 0) {
                Connection connIng = null;
                try {
                    connIng = Baglanti.getConnection();
                    PreparedStatement psIng = connIng.prepareStatement(
                        "SELECT i.name, ri.amount, ri.unit_override FROM recipe_ingredients ri " +
                        "JOIN ingredients i ON ri.ingredient_id = i.id WHERE ri.recipe_id=?");
                    psIng.setInt(1, editId);
                    ResultSet rsIng = psIng.executeQuery();
                    while (rsIng.next()) {
        %>
        <div class="ing-row">
            <input type="text" name="ing_name" placeholder="Malzeme adı" value="<%= rsIng.getString("name") %>">
            <input type="text" class="small" name="ing_amount" placeholder="Miktar" value="<%= rsIng.getDouble("amount") %>">
            <input type="text" class="small" name="ing_unit" placeholder="Birim" value="<%= rsIng.getString("unit_override") != null ? rsIng.getString("unit_override") : "" %>">
            <button type="button" onclick="this.parentElement.remove()">✕</button>
        </div>
        <%
                    }
                    rsIng.close(); psIng.close();
                } catch (Exception e) {} finally { if (connIng != null) connIng.close(); }
            } else {
        %>
        <div class="ing-row">
            <input type="text" name="ing_name" placeholder="Malzeme adı">
            <input type="text" class="small" name="ing_amount" placeholder="Miktar">
            <input type="text" class="small" name="ing_unit" placeholder="Birim">
            <button type="button" onclick="this.parentElement.remove()">✕</button>
        </div>
        <% } %>
    </div>
    <button type="button" class="add-link" onclick="addIng()">+ Malzeme Ekle</button>

    <div class="section-title">Hazırlanış Adımları</div>
    <div id="step-list">
        <%
            if (editId > 0) {
                Connection connSt = null;
                try {
                    connSt = Baglanti.getConnection();
                    PreparedStatement psSt = connSt.prepareStatement(
                        "SELECT step_order, description FROM steps WHERE recipe_id=? ORDER BY step_order");
                    psSt.setInt(1, editId);
                    ResultSet rsSt = psSt.executeQuery();
                    int sn = 1;
                    while (rsSt.next()) {
        %>
        <div class="step-row">
            <div class="step-num"><%= sn++ %></div>
            <textarea name="step_desc"><%= rsSt.getString("description") %></textarea>
            <button type="button" onclick="this.parentElement.remove(); numbSteps()" style="padding:4px 8px; background:#ffebee; color:#c62828; border:1px solid #ffcdd2; border-radius:6px; cursor:pointer; margin-top:6px;">✕</button>
        </div>
        <%
                    }
                    rsSt.close(); psSt.close();
                } catch (Exception e) {} finally { if (connSt != null) connSt.close(); }
            } else {
        %>
        <div class="step-row">
            <div class="step-num">1</div>
            <textarea name="step_desc" placeholder="Adım açıklaması..."></textarea>
            <button type="button" onclick="this.parentElement.remove(); numbSteps()" style="padding:4px 8px; background:#ffebee; color:#c62828; border:1px solid #ffcdd2; border-radius:6px; cursor:pointer; margin-top:6px;">✕</button>
        </div>
        <% } %>
    </div>
    <button type="button" class="add-link" onclick="addStep()">+ Adım Ekle</button>

    <div style="margin-top: 24px; display: flex; gap: 10px;">
        <button type="submit" class="btn-primary">💾 Kaydet</button>
        <a href="index.jsp" class="btn-secondary">İptal</a>
    </div>
</form>
</div>
</div>

<script>
function addIng() {
    const div = document.createElement('div');
    div.className = 'ing-row';
    div.innerHTML = '<input type="text" name="ing_name" placeholder="Malzeme adı">' +
        '<input type="text" class="small" name="ing_amount" placeholder="Miktar">' +
        '<input type="text" class="small" name="ing_unit" placeholder="Birim">' +
        '<button type="button" onclick="this.parentElement.remove()">✕</button>';
    document.getElementById('ing-list').appendChild(div);
}
function numbSteps() {
    document.querySelectorAll('.step-num').forEach((el, i) => el.textContent = i + 1);
}
function addStep() {
    const list = document.getElementById('step-list');
    const n = list.querySelectorAll('.step-row').length + 1;
    const div = document.createElement('div');
    div.className = 'step-row';
    div.innerHTML = '<div class="step-num">' + n + '</div>' +
        '<textarea name="step_desc" placeholder="Adım açıklaması..."></textarea>' +
        '<button type="button" onclick="this.parentElement.remove(); numbSteps()" style="padding:4px 8px; background:#ffebee; color:#c62828; border:1px solid #ffcdd2; border-radius:6px; cursor:pointer; margin-top:6px;">✕</button>';
    list.appendChild(div);
}
</script>
</body>
</html>
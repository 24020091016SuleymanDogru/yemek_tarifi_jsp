package db_ayar; // Paket adı klasörle aynı olmalı

import java.sql.Connection;
import java.sql.DriverManager;

public class Baglanti { // Class adı dosya adıyla aynı olmalı
    public static Connection getConnection() {
        Connection connection = null;
        try {
            Class.forName("org.postgresql.Driver");
            connection = DriverManager.getConnection(
                    "jdbc:postgresql://localhost:5432/yemek_tarif",
                    "postgres",
                    "suleyman" // Kendi şifreni yaz
            );
        } catch (Exception e) {
            e.printStackTrace();
        }
        return connection;
    }
}
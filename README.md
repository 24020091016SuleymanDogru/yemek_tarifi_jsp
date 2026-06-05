# 🍲 Yemek Tarifi Uygulaması
<img width="1919" height="1079" alt="image" src="https://github.com/user-attachments/assets/182375b9-ee3a-474e-b89d-68957773a3ee" />
<img width="1918" height="1079" alt="image" src="https://github.com/user-attachments/assets/0bff441a-a81e-4c87-88d8-527991cac960" />
<img width="1919" height="1079" alt="image" src="https://github.com/user-attachments/assets/a2c2106d-d8dc-4034-82c4-ba0949b597c0" />


JSP ve PostgreSQL kullanılarak geliştirilmiş web tabanlı yemek tarifi uygulaması.

## Özellikler
- Yemek tariflerini listeleme ve kategoriye göre filtreleme
- Tarif ekleme, düzenleme, silme (CRUD)
- Malzeme yönetimi
- Alışveriş listesi oluşturma

## Kurulum

### Gereksinimler
- Java 17+
- Apache Tomcat 10+
- PostgreSQL 14+
- IntelliJ IDEA

### Veritabanı Kurulumu
1. PostgreSQL'de `yemek_tarif` adında veritabanı oluşturun
2. `database.sql` dosyasını pgAdmin'de çalıştırın
3. `src/main/java/db_ayar/Baglanti.java` içindeki şifreyi güncelleyin:
```java
connection = DriverManager.getConnection(
    "jdbc:postgresql://localhost:5432/yemek_tarif",
    "postgres",
    "KENDI_SIFREN"  // <-- bunu değiştir
);
```

### Çalıştırma
1. IntelliJ'de projeyi açın
2. `lib/postgresql-42.7.11.jar` dosyasını Project Structure > Libraries'e ekleyin
3. Tomcat yapılandırmasını ayarlayın (port: 8081)
4. Run butonuna basın

## Ekranlar
- **Ana Sayfa** - Tarif listesi ve kategori filtresi
- **Tarif Ekle/Düzenle** - CRUD işlemleri
- **Tarif Detay** - Malzemeler ve hazırlanış adımları
- **Alışveriş Listesi** - Tariften otomatik liste oluşturma

import java.sql.*;
Class.forName("com.mysql.cj.jdbc.Driver");
try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/english_learning_mate?useUnicode=true&serverTimezone=Asia/Shanghai&useSSL=false&allowPublicKeyRetrieval=true", "root", "123456")) {
    try (Statement stmt = conn.createStatement()) {
        try (ResultSet rs = stmt.executeQuery("SHOW COLUMNS FROM word")) {
            while (rs.next()) {
                System.out.println("word." + rs.getString("Field") + " " + rs.getString("Type") + " default=" + rs.getString("Default"));
            }
        }
        try (ResultSet rs = stmt.executeQuery("SHOW COLUMNS FROM word_bank")) {
            while (rs.next()) {
                System.out.println("word_bank." + rs.getString("Field") + " " + rs.getString("Type") + " default=" + rs.getString("Default"));
            }
        }
        try (ResultSet rs = stmt.executeQuery("SELECT id,user_id,name,word_count,version,status FROM word_bank WHERE id = 8")) {
            while (rs.next()) {
                System.out.println("bank8 id=" + rs.getLong("id") + ", user_id=" + rs.getLong("user_id") + ", name=" + rs.getString("name") + ", word_count=" + rs.getInt("word_count") + ", version=" + rs.getInt("version") + ", status=" + rs.getInt("status"));
            }
        }
    }
}
/exit

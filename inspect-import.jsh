import java.nio.file.*;
import java.nio.charset.StandardCharsets;
import java.sql.*;
import java.util.*;
Class.forName("com.mysql.cj.jdbc.Driver");
var lines = Files.readAllLines(Path.of("import-test.txt"), StandardCharsets.UTF_8);
try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/english_learning_mate?useUnicode=true&serverTimezone=Asia/Shanghai&useSSL=false&allowPublicKeyRetrieval=true", "root", "123456")) {
    conn.setAutoCommit(false);
    try {
        var existing = new HashSet<String>();
        try (PreparedStatement ps = conn.prepareStatement("select english from word where word_bank_id = ? and status = 1")) {
            ps.setLong(1, 8L);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) existing.add(rs.getString(1).trim().toLowerCase(Locale.ROOT));
            }
        }
        int inserted = 0;
        for (String raw : lines) {
            String line = raw != null && !raw.isEmpty() && raw.charAt(0) == '\uFEFF' ? raw.substring(1) : raw;
            String trimmed = line == null ? "" : line.trim();
            if (trimmed.isEmpty()) continue;
            String[] parts = trimmed.contains(",") ? trimmed.split("\\s*,\\s*", 2) : trimmed.split("\\s+", 2);
            if (parts.length < 2) continue;
            String english = parts[0].trim();
            String chinese = parts[1].trim();
            if (english.isEmpty() || chinese.isEmpty()) continue;
            String key = english.toLowerCase(Locale.ROOT);
            if (existing.contains(key)) continue;
            try (PreparedStatement ps = conn.prepareStatement("insert into word(word_bank_id, english, chinese, status) values (?, ?, ?, 1)")) {
                ps.setLong(1, 8L);
                ps.setString(2, english);
                ps.setString(3, chinese);
                ps.executeUpdate();
                inserted++;
                existing.add(key);
            }
        }
        try (PreparedStatement ps = conn.prepareStatement("select count(*) from word where word_bank_id = ? and status = 1")) {
            ps.setLong(1, 8L);
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                System.out.println("inserted=" + inserted + ", counted=" + rs.getLong(1));
            }
        }
        try (PreparedStatement ps = conn.prepareStatement("update word_bank set word_count = ?, version = version + 1 where id = ? and version = ?")) {
            ps.setInt(1, 999);
            ps.setLong(2, 8L);
            ps.setInt(3, 0);
            System.out.println("word_bank updated rows=" + ps.executeUpdate());
        }
        conn.rollback();
        System.out.println("rollback done");
    } catch (Throwable t) {
        t.printStackTrace();
        conn.rollback();
    }
}
/exit

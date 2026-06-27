import java.sql.*;
public class TmpProfileDebug {
  public static void main(String[] args) throws Exception {
    Class.forName("com.mysql.cj.jdbc.Driver");
    try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/english_learning_mate?useUnicode=true&serverTimezone=Asia/Shanghai&useSSL=false&allowPublicKeyRetrieval=true", "root", "123456")) {
      try (Statement stmt = conn.createStatement()) {
        System.out.println("-- users --");
        try (ResultSet rs = stmt.executeQuery("SELECT id, username, email, role, status FROM user ORDER BY id LIMIT 20")) {
          while (rs.next()) {
            System.out.println(rs.getLong("id") + " | " + rs.getString("username") + " | " + rs.getString("email") + " | " + rs.getString("role") + " | status=" + rs.getInt("status"));
          }
        }
        System.out.println("-- user_study_plan exists --");
        try (ResultSet rs = stmt.executeQuery("SHOW TABLES LIKE 'user_study_plan'")) {
          System.out.println(rs.next());
        }
        System.out.println("-- user_study_plan rows --");
        try (ResultSet rs = stmt.executeQuery("SELECT id, user_id, study_session_size, allow_same_day_review FROM user_study_plan ORDER BY id LIMIT 20")) {
          while (rs.next()) {
            System.out.println(rs.getLong("id") + " | user_id=" + rs.getLong("user_id") + " | size=" + rs.getInt("study_session_size") + " | review=" + rs.getInt("allow_same_day_review"));
          }
        }
      }
    }
  }
}
import java.sql.*;
public class TmpInsertStudyPlan {
  public static void main(String[] args) throws Exception {
    Class.forName("com.mysql.cj.jdbc.Driver");
    try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/english_learning_mate?useUnicode=true&serverTimezone=Asia/Shanghai&useSSL=false&allowPublicKeyRetrieval=true", "root", "123456")) {
      try (PreparedStatement ps = conn.prepareStatement("INSERT INTO user_study_plan (user_id, study_session_size, allow_same_day_review) VALUES (?, ?, ?)")) {
        ps.setLong(1, 32L);
        ps.setInt(2, 20);
        ps.setInt(3, 1);
        int updated = ps.executeUpdate();
        System.out.println("updated=" + updated);
      }
    }
  }
}
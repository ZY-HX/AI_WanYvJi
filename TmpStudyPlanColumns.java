import java.sql.*;
public class TmpStudyPlanColumns {
  public static void main(String[] args) throws Exception {
    Class.forName("com.mysql.cj.jdbc.Driver");
    try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/english_learning_mate?useUnicode=true&serverTimezone=Asia/Shanghai&useSSL=false&allowPublicKeyRetrieval=true", "root", "123456")) {
      try (Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery("SHOW COLUMNS FROM user_study_plan")) {
        while (rs.next()) {
          System.out.println(rs.getString("Field") + " | " + rs.getString("Type") + " | default=" + rs.getString("Default"));
        }
      }
    }
  }
}
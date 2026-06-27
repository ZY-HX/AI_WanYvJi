import java.sql.*;
public class TmpProfileUserPlanCheck {
  public static void main(String[] args) throws Exception {
    Class.forName("com.mysql.cj.jdbc.Driver");
    try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/english_learning_mate?useUnicode=true&serverTimezone=Asia/Shanghai&useSSL=false&allowPublicKeyRetrieval=true", "root", "123456")) {
      try (PreparedStatement ps = conn.prepareStatement("SELECT id, username, email, role, status FROM user WHERE username = ?")) {
        ps.setString(1, "profiledebug42852");
        try (ResultSet rs = ps.executeQuery()) {
          while (rs.next()) {
            long id = rs.getLong("id");
            System.out.println("user=" + id + " | " + rs.getString("username") + " | " + rs.getString("email") + " | " + rs.getString("role") + " | status=" + rs.getInt("status"));
            try (PreparedStatement ps2 = conn.prepareStatement("SELECT id, user_id, study_session_size, allow_same_day_review FROM user_study_plan WHERE user_id = ?")) {
              ps2.setLong(1, id);
              try (ResultSet rs2 = ps2.executeQuery()) {
                boolean has = false;
                while (rs2.next()) {
                  has = true;
                  System.out.println("plan=" + rs2.getLong("id") + " | user_id=" + rs2.getLong("user_id") + " | size=" + rs2.getInt("study_session_size") + " | review=" + rs2.getInt("allow_same_day_review"));
                }
                if (!has) {
                  System.out.println("plan=NONE");
                }
              }
            }
          }
        }
      }
    }
  }
}
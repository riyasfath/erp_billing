/// All API paths in one place. Base URL comes from .env (EnvConfig.baseUrl).
class ApiEndpoints {
  ApiEndpoints._();

  // ---------- Auth ----------
  static const String adminLogin = '/accounts/admin/token/';

  // ---------- Dashboard ----------
  static const String academicDashboard = '/internship/dashboard/academic/';

  // ---------- Courses ----------
  static const String courses = '/internship/course/';
  static String courseById(int id) => '/internship/course/$id/';

  // ---------- Students ----------
  static const String students = '/internship/students/';
  static String studentProfile(int id) => '/internship/students/$id/profile/';
  static String studentCredentials(int id) =>
      '/internship/students/$id/credentials/';

  // ---------- Classes ----------
  static const String classes = '/internship/class/';
  static String classById(int id) => '/internship/class/$id/';
}
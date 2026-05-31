class ApiEndpoints {
  static const String baseUrl = "https://api.exitus.edu.pe/api/v1";

  // --- AUTENTICACIÓN ---
  static const String login = "$baseUrl/auth/login";
  static const String logout = "$baseUrl/auth/logout";
  static const String switchRole = "$baseUrl/auth/switch-role";

  // --- PERFIL DE USUARIO ---
  static const String studentProfile = "$baseUrl/profile/student";
  static const String teacherProfile = "$baseUrl/profile/teacher";
  static const String updateProfile = "$baseUrl/profile/update";
  static const String uploadAvatar = "$baseUrl/profile/avatar";

  // --- ASISTENCIAS ---
  static const String studentAttendance = "$baseUrl/attendance/student";
  static const String teacherAttendance = "$baseUrl/attendance/teacher";
  static const String submitAttendance = "$baseUrl/attendance/submit"; // Para que el profesor marque asistencia de alumnos

  // --- AULAS VIRTUALES ---
  static const String coursesList = "$baseUrl/classroom/courses";
  static const String courseDetails = "$baseUrl/classroom/course/{courseId}";
  static const String courseContent = "$baseUrl/classroom/course/{courseId}/content";
  static const String courseRubrics = "$baseUrl/classroom/course/{courseId}/rubrics";
  static const String courseDojo = "$baseUrl/classroom/course/{courseId}/dojo";
  static const String dojoBoard = "$baseUrl/classroom/dojo/{studentId}";
  static const String addDojoPoints = "$baseUrl/classroom/dojo/points";
  static const String sessionCreate = "$baseUrl/classroom/session/create";
  static const String toggleExpertMode = "$baseUrl/classroom/expert-mode";
  static const String rubricasList = "$baseUrl/classroom/rubricas";

  // --- MENSAJERÍA ---
  static const String messagesInbox = "$baseUrl/messages/inbox";
  static const String sendMessage = "$baseUrl/messages/send";
  static const String markMessageRead = "$baseUrl/messages/{messageId}/read";

  // --- FINANZAS / PENSIONES ---
  static const String pendingPensions = "$baseUrl/finance/pensions";
  static const String processPayment = "$baseUrl/finance/payment";

  // --- CENTRO DE DIGITALIZACIÓN / IMPRESIONES ---
  static const String printJobsList = "$baseUrl/digitacion/jobs";
  static const String submitPrintRequest = "$baseUrl/digitacion/request";
  static const String printJobStatusUpdate = "$baseUrl/digitacion/job/{jobId}/status";
}

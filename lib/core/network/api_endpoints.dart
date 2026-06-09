class ApiEndpoints {
  static const String baseUrl = "https://api.exitus.edu.pe/api/v1";

  // --- AUTENTICACIÓN ---
  static const String login = "$baseUrl/auth/login";
  static const String logout = "$baseUrl/auth/logout";
  static const String switchRole = "$baseUrl/auth/switch-role";
  static const String authMe = "$baseUrl/auth/me";

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
  static const String dojoStudentsList = "$baseUrl/classroom/dojo/students";
  static const String addDojoPoints = "$baseUrl/classroom/dojo/points";
  static const String toggleDojoPresence = "$baseUrl/classroom/dojo/{studentId}/presence";
  static const String deductDojoPoints = "$baseUrl/classroom/dojo/points/deduct";
  static const String sessionCreate = "$baseUrl/classroom/session/create";
  static const String toggleExpertMode = "$baseUrl/classroom/expert-mode";
  static const String rubricasList = "$baseUrl/classroom/rubricas";
  static const String classroomTasks = "$baseUrl/classroom/tasks";
  static const String submitTask = "$baseUrl/classroom/tasks/{taskId}/submit";
  static const String classroomGrades = "$baseUrl/classroom/grades";
  static const String gradeSubmission = "$baseUrl/classroom/submissions/{submissionId}/grade";

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
  static const String deletePrintRequest = "$baseUrl/digitacion/request/{id}";

  // --- RED SOCIAL / SOCIAL FEED ---
  static const String socialPosts = "$baseUrl/social/posts";
  static const String addSocialComment = "$baseUrl/social/posts/{postId}/comment";
  static const String toggleSocialReaction = "$baseUrl/social/posts/{postId}/reaction";

  // ─────────────────────────────────────────────────────────────────────────────
  // --- TÓPICO ESCOLAR ---
  // ─────────────────────────────────────────────────────────────────────────────

  // Dashboard / KPIs
  /// GET  → Retorna contadores del día: atendidos, en espera, stock OK, alertas activas.
  static const String topicoDashboard = "$baseUrl/topico/dashboard";

  // Pacientes en espera (cola de atención)
  /// GET  → Lista de pacientes actualmente en espera de ser atendidos.
  static const String topicoWaitingList = "$baseUrl/topico/waiting-list";

  /// POST → Agrega un alumno a la cola de espera (admitir paciente).
  ///        Body: { studentId, reason, description, entryTime }
  static const String topicoAdmitPatient = "$baseUrl/topico/waiting-list";

  /// DELETE → Elimina al paciente de la cola al darle de alta.
  ///          Path param: {patientId}
  static const String topicoRemoveFromWaiting = "$baseUrl/topico/waiting-list/{patientId}";

  // Búsqueda de alumnos (admitir paciente)
  /// GET  → Busca alumnos por nombre o DNI para el formulario de admisión.
  ///        Query params: ?q={query}
  static const String topicoSearchStudents = "$baseUrl/topico/students/search";

  // Atención clínica
  /// POST → Registra la atención clínica completa y da de alta al paciente.
  ///        Body: { patientId, temperature, bloodPressure, pulse,
  ///                observations, actions: [reposo, hidratacion, medicacion,
  ///                notificarPadres, derivar], closedAt }
  static const String topicoCloseAttention = "$baseUrl/topico/attentions";

  /// GET  → Obtiene el detalle de una atención específica.
  ///        Path param: {attentionId}
  static const String topicoAttentionDetail = "$baseUrl/topico/attentions/{attentionId}";

  // Expedientes clínicos
  /// GET  → Lista de expedientes de todos los alumnos con última atención.
  ///        Query params: ?q={nombre|grado} (búsqueda)
  static const String topicoExpedientes = "$baseUrl/topico/records";

  /// GET  → Expediente completo de un alumno: info clínica base + historial.
  ///        Path param: {studentId}
  static const String topicoExpedienteDetail = "$baseUrl/topico/records/{studentId}";

  /// GET  → Historial de consultas médicas de un alumno.
  ///        Path param: {studentId}
  static const String topicoHistorial = "$baseUrl/topico/records/{studentId}/history";

  // Control de stock / inventario
  /// GET  → Lista completa de insumos con nombre, cantidad y estado.
  static const String topicoStockList = "$baseUrl/topico/stock";

  /// PUT  → Actualiza la cantidad de un insumo específico (ej. tras escaneo QR).
  ///        Path param: {itemId}
  ///        Body: { qty, updatedBy }
  static const String topicoStockUpdate = "$baseUrl/topico/stock/{itemId}";

  /// POST → Registra el reabastecimiento de un insumo (escaneo de código QR/barras).
  ///        Body: { barcode, qtyAdded, scannedBy }
  static const String topicoStockScan = "$baseUrl/topico/stock/scan";

  /// GET  → Inventario extendido consolidado (todos los insumos con metadata completa).
  static const String topicoStockFull = "$baseUrl/topico/stock/full";

  // Alertas críticas
  /// GET  → Lista de alertas críticas activas (alergias, fiebre alta, etc.).
  static const String topicoAlerts = "$baseUrl/topico/alerts";

  /// PATCH → Marca una alerta como atendida/resuelta.
  ///         Path param: {alertId}
  ///         Body: { resolvedBy, resolvedAt, notes }
  static const String topicoResolveAlert = "$baseUrl/topico/alerts/{alertId}/resolve";

  // Auditoría legal
  /// GET  → Lista de registros clínicos firmados digitalmente.
  ///        Query params: ?from={date}&to={date}&studentId={id}
  static const String topicoAuditLogs = "$baseUrl/topico/audit-logs";

  /// GET  → Detalle de un registro de auditoría con hash criptográfico.
  ///        Path param: {logId}
  static const String topicoAuditLogDetail = "$baseUrl/topico/audit-logs/{logId}";

  /// POST → Crea/firma digitalmente un registro de auditoría al cerrar atención.
  ///        Body: { attentionId, studentId, nurseId, closedAt, hash }
  static const String topicoCreateAuditLog = "$baseUrl/topico/audit-logs";
}

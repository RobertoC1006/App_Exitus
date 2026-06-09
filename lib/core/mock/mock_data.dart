import 'package:app_exitus/features/auth/domain/entities/user.dart';
import 'package:app_exitus/core/network/api_endpoints.dart';
import 'package:app_exitus/core/network/api_logger.dart';

// Modelos de datos locales rápidos
class Student {
  final String id;
  final String fullName;
  final String avatarUrl;
  String attendanceStatus; // 'Presente', 'Falta', 'Tardanza'

  Student({
    required this.id,
    required this.fullName,
    required this.avatarUrl,
    this.attendanceStatus = 'Presente',
  });
}

class HomeworkSubmission {
  final String id;
  final String studentName;
  final String studentAvatar;
  final String title;
  final String description;
  final String submittedText;
  final String date;
  String status; // 'Pendiente', 'Calificado'
  String? grade;
  String? feedback;

  HomeworkSubmission({
    required this.id,
    required this.studentName,
    required this.studentAvatar,
    required this.title,
    required this.description,
    required this.submittedText,
    required this.date,
    this.status = 'Pendiente',
    this.grade,
    this.feedback,
  });
}

class ClassScheduleItem {
  final String time;
  final String subject;
  final String classroom;
  final String? teacher;
  final String? avatar;
  final String? status; // 'completed', 'active', 'pending'
  final bool? isLive;
  final double? progress;

  const ClassScheduleItem({
    required this.time,
    required this.subject,
    required this.classroom,
    this.teacher,
    this.avatar,
    this.status,
    this.isLive,
    this.progress,
  });
}

class DojoStudent {
  final int id;
  final String name;
  int points;
  bool present;
  final String dragonType; // 'glaciar', 'lava', 'rayo', 'brasa'

  DojoStudent({
    required this.id,
    required this.name,
    required this.points,
    required this.present,
    required this.dragonType,
  });
}

class SocialComment {
  final String author;
  final String avatar;
  final String text;

  SocialComment({
    required this.author,
    required this.avatar,
    required this.text,
  });
}

class SocialPost {
  final int id;
  final String publisher;
  final String avatar;
  final String time;
  final String tag;
  final String content;
  final String? img;
  int likes;
  int loves;
  int bravos;
  int insights;
  int haha;
  int sad;
  final Map<String, bool> userReactions;
  final List<SocialComment> comments;

  SocialPost({
    required this.id,
    required this.publisher,
    required this.avatar,
    required this.time,
    required this.tag,
    required this.content,
    this.img,
    this.likes = 0,
    this.loves = 0,
    this.bravos = 0,
    this.insights = 0,
    this.haha = 0,
    this.sad = 0,
    required this.userReactions,
    required this.comments,
  });
}

class InboxMessage {
  final String id;
  final String sender;
  final String subject;
  final String date;
  final String snippet;
  final String content;
  bool unread;
  final bool urgent;

  InboxMessage({
    required this.id,
    required this.sender,
    required this.subject,
    required this.date,
    required this.snippet,
    required this.content,
    this.unread = true,
    this.urgent = false,
  });
}

class PensionItem {
  final String id;
  final String month;
  String status; // 'paid', 'pending'
  final double price;
  String? paymentDate;
  String? dueDate;

  PensionItem({
    required this.id,
    required this.month,
    required this.status,
    required this.price,
    this.paymentDate,
    this.dueDate,
  });
}

class StudentTask {
  final String id;
  final String course;
  final String courseName;
  final String title;
  final String desc;
  final String due;
  String status; // 'pending', 'completed'
  int files;

  StudentTask({
    required this.id,
    required this.course,
    required this.courseName,
    required this.title,
    required this.desc,
    required this.due,
    required this.status,
    this.files = 0,
  });
}

class StudentGrade {
  final String course;
  final String code;
  final double val;
  final List<GradeDetail> details;

  StudentGrade({
    required this.course,
    required this.code,
    required this.val,
    required this.details,
  });
}

class GradeDetail {
  final String type;
  final double val;

  GradeDetail({
    required this.type,
    required this.val,
  });
}class PrintClassroomTarget {
  final String name;
  final int copies;
  const PrintClassroomTarget({required this.name, required this.copies});
}

class PrintRequest {
  final int id;
  final String ticketNumber;
  final String title;
  final String description;
  final String requester;
  final String date;
  final String colorMode;
  final String paperSize;
  String status; // 'pending', 'processing', 'ready', 'completed'
  final List<PrintClassroomTarget> classrooms;
  final String file;
  final String limitDate;
  final String instructions;
  final String finish;

  PrintRequest({
    required this.id,
    required this.ticketNumber,
    required this.title,
    required this.description,
    required this.requester,
    required this.date,
    required this.colorMode,
    required this.paperSize,
    required this.status,
    required this.classrooms,
    required this.file,
    required this.limitDate,
    required this.instructions,
    this.finish = 'Suelto',
  });

  String get documentName => title;
  int get pages => 1;
  int get copies => classrooms.fold<int>(0, (sum, c) => sum + c.copies);
  String get role => 'teacher';
  String get userName => requester;
}

class Rubrica {
  final int id;
  String title;
  final String type; // 'Sesión Alineada', 'Creación Libre'
  final String description;
  final String date;

  Rubrica({
    required this.id,
    required this.title,
    required this.type,
    required this.description,
    required this.date,
  });
}

class AttendanceLog {
  final String dayNum;
  final String dayName;
  final String month;
  final String schedule;
  final String tolerance;
  final String entry;
  final String exit;
  final String status; // 'PUNTUAL', 'TARDANZA', 'FALTA', 'SIN_REGISTRO'
  final String obs;

  const AttendanceLog({
    required this.dayNum,
    required this.dayName,
    required this.month,
    required this.schedule,
    required this.tolerance,
    required this.entry,
    required this.exit,
    required this.status,
    required this.obs,
  });
}

// Base de datos simulada en memoria (Singleton para persistencia en sesión)
class MockDatabase {
  static final MockDatabase _instance = MockDatabase._internal();
  factory MockDatabase() => _instance;
  MockDatabase._internal() {
    _initDojoStudents();
    _initSocialPosts();
    _initInboxMessages();
    _initPensions();
    _initTasks();
    _initGrades();
    _initDigitacionJobs();
    _initRubricas();
    _initAttendanceLogs();
    _initNurseData();
  }

  // Lista de usuarios registrados (Profesores, Administradores y Estudiantes)
  final List<User> users = [
    const User(
      id: 'nurse_01',
      username: 'rosa123',
      fullName: 'Lic. Rosa',
      email: 'rosa.enfermeria@exitus.edu.pe',
      role: 'enfermero',
      avatarUrl: 'https://images.unsplash.com/photo-1594824813573-246434de83fb?w=150',
      subjects: [],
    ),
    const User(
      id: 'teacher_01',
      username: 'profesor123',
      fullName: 'Nicole Sulay A.',
      email: 'nicole.sulay@exitus.edu.pe',
      role: 'teacher',
      avatarUrl: 'https://images.unsplash.com/photo-1544717305-2782549b5136?w=150', // Nicole avatar
      subjects: ['Tutoría - 4to B', 'Tech Savvy - 2do A', 'Tech Savvy - 5to A'],
    ),
    const User(
      id: 'admin_01',
      username: 'admin123',
      fullName: 'Franco Alexis B.',
      email: 'franco.alexis@exitus.edu.pe',
      role: 'admin',
      avatarUrl: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=150', // Franco avatar
      subjects: [],
    ),
    const User(
      id: 'admin_02',
      username: 'luis123',
      fullName: 'Prof. Luis Gonzaga Neira Ayala',
      email: 'luis.gonzaga@exitus.edu.pe',
      role: 'admin',
      avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
      subjects: [],
    ),
    const User(
      id: 'student_mateo',
      username: 'mateo123',
      fullName: 'Mateo Guerrero C.',
      email: 'mateo.guerrero@exitus.edu.pe',
      role: 'student',
      avatarUrl: 'https://images.unsplash.com/photo-1597586124394-fbd6ef244026?w=150',
      subjects: ['Matemática', 'Ciencias', 'Literatura', 'Historia', 'Inglés'],
    ),
    const User(
      id: 'student_sofia',
      username: 'sofia123',
      fullName: 'Sofía Guerrero C.',
      email: 'sofia.guerrero@exitus.edu.pe',
      role: 'student',
      avatarUrl: 'https://images.unsplash.com/photo-1544717305-2782549b5136?w=150',
      subjects: ['Matemática', 'Ciencias', 'Literatura', 'Inglés'],
    ),
    const User(
      id: 'parent_marco',
      username: 'marco123',
      fullName: 'Marco Guerrero',
      email: 'marco.guerrero@exitus.edu.pe',
      role: 'parent',
      avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
      subjects: [],
    ),
  ];

  // Contraseñas de usuarios (para simplificar el mock de login)
  final Map<String, String> userPasswords = {
    'rosa123': '12345678',
    'profesor123': '12345678',
    'admin123': '12345678',
    'luis123': '12345678',
    'mateo123': '12345678',
    'sofia123': '12345678',
    'marco123': '12345678',
  };

  void registerUser(User newUser, String password) {
    users.add(newUser);
    userPasswords[newUser.username] = password;
  }

  // Lista de alumnos de Matemática 5to A
  final List<Student> students5toA = [
    Student(id: 's1', fullName: 'Alvarez Quispe, Jose', avatarUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=100'),
    Student(id: 's2', fullName: 'Bustamante Diaz, María', avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100'),
    Student(id: 's3', fullName: 'Chavez Rojas, Carlos', avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100'),
    Student(id: 's4', fullName: 'Delgado Flores, Ana', avatarUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100'),
    Student(id: 's5', fullName: 'Espinoza Lopez, Juan', avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100'),
    Student(id: 's6', fullName: 'Flores Mendoza, Sofía', avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100'),
  ];

  // Lista de alumnos de Matemática 5to B
  final List<Student> students5toB = [
    Student(id: 's7', fullName: 'García Pérez, Luis', avatarUrl: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=100'),
    Student(id: 's8', fullName: 'Huaman Ortiz, Lucía', avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100'),
    Student(id: 's9', fullName: 'Ibañez Silva, Pedro', avatarUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=100'),
    Student(id: 's10', fullName: 'Jimenez Ruiz, Carmen', avatarUrl: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=100'),
  ];

  // Lista de tareas entregadas pendientes de calificar
  final List<HomeworkSubmission> submissions = [
    HomeworkSubmission(
      id: 'sub_01',
      studentName: 'Alvarez Quispe, Jose',
      studentAvatar: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=100',
      title: 'Práctica de Derivadas',
      description: 'Resolver los problemas de la página 45 sobre límites y derivadas parciales.',
      submittedText: 'Profesor, aquí le adjunto el desarrollo. Resolví los 5 primeros problemas. Tuve dudas en el 4 pero apliqué la regla de la cadena. Gracias.',
      date: '26 May, 09:15 PM',
    ),
    HomeworkSubmission(
      id: 'sub_02',
      studentName: 'Bustamante Diaz, María',
      studentAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100',
      title: 'Práctica de Derivadas',
      description: 'Resolver los problemas de la página 45 sobre límites y derivadas parciales.',
      submittedText: 'Adjunto foto del cuaderno con la resolución completa del tema de límites.',
      date: '26 May, 11:30 PM',
    ),
    HomeworkSubmission(
      id: 'sub_03',
      studentName: 'Chavez Rojas, Carlos',
      studentAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
      title: 'Práctica de Derivadas',
      description: 'Resolver los problemas de la página 45 sobre límites y derivadas parciales.',
      submittedText: 'Desarrollo del cuestionario sobre derivadas e interpretación geométrica.',
      date: '27 May, 07:10 AM',
    ),
    HomeworkSubmission(
      id: 'sub_04',
      studentName: 'Delgado Flores, Ana',
      studentAvatar: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100',
      title: 'Estática y Equilibrio',
      description: 'Diagramas de cuerpo libre para vigas en equilibrio mecánico.',
      submittedText: 'Aquí está mi trabajo de Física sobre diagramas de cuerpo libre.',
      date: '25 May, 04:30 PM',
      status: 'Calificado',
      grade: '18',
      feedback: 'Buen trabajo con los vectores. Ten cuidado con los signos de las fuerzas en el eje Y.',
    ),
  ];

  // Horario del docente
  final Map<String, List<ClassScheduleItem>> teacherSchedule = {
    'Lunes': [
      ClassScheduleItem(time: '08:00 AM - 09:30 AM', subject: 'Matemática - 5to A', classroom: 'Aula 301'),
      ClassScheduleItem(time: '09:45 AM - 11:15 AM', subject: 'Matemática - 5to B', classroom: 'Aula 302'),
    ],
    'Martes': [
      ClassScheduleItem(time: '11:30 AM - 01:00 PM', subject: 'Física - 4to A', classroom: 'Lab. Física'),
    ],
    'Miércoles': [
      ClassScheduleItem(time: '08:00 AM - 09:30 AM', subject: 'Matemática - 5to A', classroom: 'Aula 301'),
      ClassScheduleItem(time: '09:45 AM - 11:15 AM', subject: 'Matemática - 5to B', classroom: 'Aula 302'),
    ],
    'Jueves': [
      ClassScheduleItem(time: '11:30 AM - 01:00 PM', subject: 'Física - 4to A', classroom: 'Lab. Física'),
    ],
    'Viernes': [
      ClassScheduleItem(time: '08:00 AM - 09:30 AM', subject: 'Taller de Cálculo - 5to A', classroom: 'Aula 301'),
    ],
  };

  // Horarios para Estudiantes (Mateo y Sofía)
  final Map<String, List<ClassScheduleItem>> mateoSchedule = {
    'Lunes': [
      ClassScheduleItem(time: '08:00 AM - 09:30 AM', subject: 'Matemáticas', classroom: 'Aula 5° A', teacher: 'Prof. Roberto Carlos', avatar: 'https://images.unsplash.com/photo-1544717305-2782549b5136?w=100', status: 'completed'),
      ClassScheduleItem(time: '09:45 AM - 11:15 AM', subject: 'Física', classroom: 'Lab. Ciencias', teacher: 'Ing. Carlos Mendoza', avatar: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=100', status: 'completed'),
      ClassScheduleItem(time: '11:30 AM - 01:00 PM', subject: 'Literatura', classroom: 'Aula 5° A', teacher: 'Dra. Julia Mendoza', avatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100', status: 'pending'),
    ],
    'Martes': [
      ClassScheduleItem(time: '08:00 AM - 09:30 AM', subject: 'Historia', classroom: 'Aula 5° A', teacher: 'Prof. Carlos Fuentes', avatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100', status: 'completed'),
      ClassScheduleItem(time: '09:45 AM - 11:15 AM', subject: 'Inglés', classroom: 'Lab. Idiomas', teacher: 'Miss Sara Conner', avatar: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100', status: 'completed'),
    ],
    'Miércoles': [
      ClassScheduleItem(time: '08:00 AM - 09:30 AM', subject: 'Matemáticas', classroom: 'Aula 5° A', teacher: 'Prof. Roberto Carlos', avatar: 'https://images.unsplash.com/photo-1544717305-2782549b5136?w=100', status: 'active', isLive: true, progress: 0.65),
      ClassScheduleItem(time: '09:45 AM - 11:15 AM', subject: 'Ciencias', classroom: 'Lab. Química', teacher: 'Dr. Alberto Rossi', avatar: 'https://images.unsplash.com/photo-1537368910025-700350fe46c7?w=100', status: 'pending'),
      ClassScheduleItem(time: '11:30 AM - 01:00 PM', subject: 'Literatura', classroom: 'Aula 5° A', teacher: 'Dra. Julia Mendoza', avatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100', status: 'pending'),
    ],
    'Jueves': [
      ClassScheduleItem(time: '08:00 AM - 09:30 AM', subject: 'Historia', classroom: 'Aula 5° A', teacher: 'Prof. Carlos Fuentes', avatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100', status: 'pending'),
      ClassScheduleItem(time: '09:45 AM - 11:15 AM', subject: 'Inglés', classroom: 'Lab. Idiomas', teacher: 'Miss Sara Conner', avatar: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100', status: 'pending'),
    ],
    'Viernes': [
      ClassScheduleItem(time: '08:00 AM - 09:30 AM', subject: 'Matemáticas', classroom: 'Aula 5° A', teacher: 'Prof. Roberto Carlos', avatar: 'https://images.unsplash.com/photo-1544717305-2782549b5136?w=100', status: 'pending'),
      ClassScheduleItem(time: '09:45 AM - 11:15 AM', subject: 'Taller Computación', classroom: 'Lab. Cómputo', teacher: 'Ing. Sandro Silva', avatar: 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=100', status: 'pending'),
    ],
  };

  final Map<String, List<ClassScheduleItem>> sofiaSchedule = {
    'Lunes': [
      ClassScheduleItem(time: '08:00 AM - 09:30 AM', subject: 'Matemáticas', classroom: 'Aula 2° B', teacher: 'Prof. Carlos Oliva', avatar: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=100', status: 'completed'),
      ClassScheduleItem(time: '09:45 AM - 11:15 AM', subject: 'Literatura', classroom: 'Aula 2° B', teacher: 'Miss Ana María', avatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100', status: 'completed'),
    ],
    'Miércoles': [
      ClassScheduleItem(time: '08:00 AM - 09:30 AM', subject: 'Matemáticas', classroom: 'Aula 2° B', teacher: 'Prof. Carlos Oliva', avatar: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=100', status: 'active', isLive: true, progress: 0.4),
      ClassScheduleItem(time: '09:45 AM - 11:15 AM', subject: 'Ciencias', classroom: 'Aula 2° B', teacher: 'Miss Ana María', avatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100', status: 'pending'),
    ],
    'Viernes': [
      ClassScheduleItem(time: '08:00 AM - 09:30 AM', subject: 'Inglés', classroom: 'Lab. Primaria', teacher: 'Miss Sara Conner', avatar: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100', status: 'pending'),
    ],
  };

  // Listas de datos dinámicos inyectables
  final List<DojoStudent> dojoStudents = [];
  final List<SocialPost> socialPosts = [];
  final List<InboxMessage> mateoMessages = [];
  final List<InboxMessage> sofiaMessages = [];
  final List<InboxMessage> adminMessages = [];
  final List<PensionItem> mateoPensions = [];
  final List<PensionItem> sofiaPensions = [];
  final List<StudentTask> mateoTasks = [];
  final List<StudentTask> sofiaTasks = [];
  final List<StudentGrade> mateoGrades = [];
  final List<StudentGrade> sofiaGrades = [];
  final List<PrintRequest> digitacionJobs = [];
  final List<Rubrica> rubricasList = [];
  final List<AttendanceLog> mateoAttendanceLogs = [];
  final List<AttendanceLog> sofiaAttendanceLogs = [];
  final List<AttendanceLog> teacherAttendanceLogs = [];

  final List<Map<String, dynamic>> nurseWaitingPatients = [];
  final List<Map<String, dynamic>> nurseStockItems = [];
  final List<Map<String, dynamic>> nurseAlerts = [];
  final List<Map<String, dynamic>> nurseAuditLogs = [];

  void _initNurseData() {
    nurseWaitingPatients.addAll([
      {
        'id': 'p1',
        'name': 'Ana Torres Medina',
        'grade': '4° B Secundaria',
        'avatar': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100',
        'reason': 'Dolor de cabeza',
        'time': 'Hace 2 min',
        'entryTime': '09:22 a. m.',
        'dni': '76543211'
      },
      {
        'id': 'p2',
        'name': 'Diego Ramos León',
        'grade': '3° C Secundaria',
        'avatar': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=100',
        'reason': 'Golpe en recreo',
        'time': 'Hace 1 min',
        'entryTime': '09:23 a. m.',
        'dni': '76543212'
      },
    ]);

    nurseStockItems.addAll([
      {'name': 'Paracetamol 500mg', 'qty': 32, 'status': 'Stock OK'},
      {'name': 'Gasas estériles', 'qty': 15, 'status': 'Stock OK'},
      {'name': 'Alcohol 70%', 'qty': 7, 'status': 'Stock bajo'},
      {'name': 'Termómetros', 'qty': 2, 'status': 'Stock crítico'},
    ]);

    nurseAlerts.addAll([
      {
        'id': 'a1',
        'title': 'Alergia registrada',
        'student': 'Ana Torres Medina',
        'detail': 'Penicilina',
        'time': 'Registrada hoy, 09:15 a. m.'
      },
      {
        'id': 'a2',
        'title': 'Temperatura elevada',
        'student': 'Diego Ramos León',
        'detail': '39.2 °C',
        'time': 'Hace 8 min'
      },
    ]);

    nurseAuditLogs.addAll([
      {
        'id': '483',
        'student': 'Juan Pérez Romero',
        'date': '05/06/2026',
        'time': '10:32 a. m.',
        'status': 'Firmado'
      },
      {
        'id': '482',
        'student': 'Ana Torres Medina',
        'date': '05/06/2026',
        'time': '03:15 p. m.',
        'status': 'Firmado'
      },
      {
        'id': '481',
        'student': 'Diego Ramos León',
        'date': '05/06/2026',
        'time': '09:05 a. m.',
        'status': 'Pendiente revisión'
      },
    ]);
  }

  void _initDojoStudents() {
    final List<Map<String, dynamic>> raw = [
      {'id': 1, 'name': 'ACHA ABAD Jazin Alexander', 'points': 15, 'present': true, 'dragonType': 'brasa'},
      {'id': 2, 'name': 'AREVALO OTERO Paola Elizabeth', 'points': 7, 'present': true, 'dragonType': 'glaciar'},
      {'id': 3, 'name': 'CAMPOVERDE TEMOCHE Cesar Adriano', 'points': 10, 'present': true, 'dragonType': 'lava'},
      {'id': 4, 'name': 'CORONADO CHOZO Donna Beatriz', 'points': 10, 'present': true, 'dragonType': 'lava'},
      {'id': 5, 'name': 'COVEÑAS PEDRERA Vasco Alejandro', 'points': 8, 'present': true, 'dragonType': 'glaciar'},
      {'id': 6, 'name': 'CUEVA MORALES Elver Adriano', 'points': 15, 'present': true, 'dragonType': 'lava'},
      {'id': 7, 'name': 'De la cruz Alcantara Salvador', 'points': 9, 'present': true, 'dragonType': 'rayo'},
      {'id': 8, 'name': 'FIESTAS MORALES Angle De Los Angeles', 'points': 10, 'present': true, 'dragonType': 'rayo'},
      {'id': 9, 'name': 'GOMEZ BECERRA Mario Rafaelito', 'points': 8, 'present': true, 'dragonType': 'glaciar'},
      {'id': 10, 'name': 'GONZALEZ YARLEQUE Heinz Veintemilla', 'points': 13, 'present': false, 'dragonType': 'rayo'},
      {'id': 11, 'name': 'GUERRERO YARLEQUE May Farlan', 'points': 8, 'present': true, 'dragonType': 'rayo'},
      {'id': 12, 'name': 'HUAYAMA CHASQUERO Elmer Junior', 'points': 7, 'present': true, 'dragonType': 'glaciar'},
      {'id': 13, 'name': 'IPANAQUE GARCIA Jesus Emanuel', 'points': 9, 'present': true, 'dragonType': 'lava'},
      {'id': 14, 'name': 'IPANAQUE IPANAQUE Carlita Lisbeth', 'points': 8, 'present': true, 'dragonType': 'lava'},
      {'id': 15, 'name': 'JARAMILLO CHUMACERO Ana Belen', 'points': 5, 'present': true, 'dragonType': 'glaciar'},
      {'id': 16, 'name': 'JULCA FACUNDO Marycielo', 'points': 10, 'present': true, 'dragonType': 'rayo'},
      {'id': 17, 'name': 'LOZANO ARCA Richard Agustin', 'points': 12, 'present': true, 'dragonType': 'brasa'},
      {'id': 18, 'name': 'LUDEÑA CUBAS Pedro Sebastián', 'points': 17, 'present': true, 'dragonType': 'brasa'},
      {'id': 19, 'name': 'MORE ANCAJIMA Josue', 'points': 8, 'present': true, 'dragonType': 'rayo'},
      {'id': 20, 'name': 'MULATILLO UMBO Luciana', 'points': 10, 'present': true, 'dragonType': 'glaciar'},
      {'id': 21, 'name': 'NUÑEZ GUTIERREZ Xiomara Caroline', 'points': 10, 'present': true, 'dragonType': 'lava'},
      {'id': 22, 'name': 'OJEDA CASTRO Luis Enrique', 'points': 8, 'present': true, 'dragonType': 'lava'},
      {'id': 23, 'name': 'PEÑA HUACCHILLO Matheo Said', 'points': 7, 'present': true, 'dragonType': 'rayo'},
      {'id': 24, 'name': 'PUELLES ABAD Jair Arlevi', 'points': 4, 'present': false, 'dragonType': 'glaciar'},
      {'id': 25, 'name': 'ROJAS CUBAS Milagros Nataniel', 'points': 8, 'present': false, 'dragonType': 'glaciar'},
      {'id': 26, 'name': 'RUBIO MONTENEGRO Miguel Ignacio', 'points': 13, 'present': true, 'dragonType': 'rayo'},
      {'id': 27, 'name': 'RUEDA CARRION Luis Roberto', 'points': 10, 'present': true, 'dragonType': 'glaciar'},
      {'id': 28, 'name': 'SANCHEZ PACHERRES Jesus Gabriel', 'points': 8, 'present': true, 'dragonType': 'glaciar'},
      {'id': 29, 'name': 'SANDOVAL ROSAS Fabian Jesus', 'points': 12, 'present': true, 'dragonType': 'brasa'},
      {'id': 30, 'name': 'TUESTA PEÑA Christian Leonel', 'points': 9, 'present': true, 'dragonType': 'lava'},
      {'id': 31, 'name': 'YANGUA BENITES Ana Fabiana', 'points': 9, 'present': true, 'dragonType': 'glaciar'},
      {'id': 32, 'name': 'YOVERA SANDOVAL Jorge David', 'points': 8, 'present': false, 'dragonType': 'glaciar'},
      {'id': 33, 'name': 'YOVERA SILUPU Becky Lizbeth', 'points': 12, 'present': true, 'dragonType': 'brasa'},
      {'id': 34, 'name': 'GUERRERO C. Mateo', 'points': 14, 'present': true, 'dragonType': 'rayo'},
      {'id': 35, 'name': 'GUERRERO C. Sofía', 'points': 8, 'present': true, 'dragonType': 'glaciar'},
    ];
    for (var s in raw) {
      dojoStudents.add(DojoStudent(
        id: s['id'],
        name: s['name'],
        points: s['points'],
        present: s['present'],
        dragonType: s['dragonType'],
      ));
    }
  }

  void _initSocialPosts() {
    socialPosts.addAll([
      SocialPost(
        id: 1,
        publisher: 'Dirección Académica',
        avatar: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=80',
        time: 'Hace 2 horas',
        tag: 'Comunicado',
        content: 'Estimada comunidad educativa Exitus, les recordamos que este viernes 29 de mayo se llevará a cabo la primera reunión general de padres de familia para el reporte trimestral de progreso. Agradecemos su puntual asistencia en sus respectivas aulas.',
        img: 'https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=400',
        likes: 24,
        loves: 12,
        bravos: 8,
        insights: 3,
        userReactions: {'likes': true, 'loves': false, 'bravos': false, 'insights': false, 'haha': false, 'sad': false},
        comments: [
          SocialComment(author: 'Prof. Roberto Carlos', avatar: 'https://images.unsplash.com/photo-1544717305-2782549b5136?w=80', text: 'Entendido, estaré listo para recibir a los padres de 5to Sec.'),
          SocialComment(author: 'Ana Delgado Flores', avatar: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=80', text: 'Muchas gracias por la información.'),
        ],
      ),
      SocialPost(
        id: 2,
        publisher: 'Coordinación de Ciencias',
        avatar: 'https://images.unsplash.com/photo-1537368910025-700350fe46c7?w=80',
        time: 'Ayer',
        tag: 'Actividades',
        content: 'Felicitaciones a nuestros estudiantes de nivel secundaria que participaron en la feria de ciencias institucional. Los proyectos presentados demuestran un alto nivel de innovación tecnológica. ¡Orgullo Exitus!',
        img: 'https://images.unsplash.com/photo-1509062522246-3755977927d7?w=400',
        likes: 45,
        loves: 20,
        bravos: 15,
        insights: 10,
        userReactions: {'likes': false, 'loves': false, 'bravos': false, 'insights': false, 'haha': false, 'sad': false},
        comments: [
          SocialComment(author: 'Dr. Alberto Rossi', avatar: 'https://images.unsplash.com/photo-1537368910025-700350fe46c7?w=80', text: 'Excelente nivel de proyectos este año. ¡Felicitaciones a todos!'),
        ],
      ),
    ]);
  }

  void _initInboxMessages() {
    mateoMessages.addAll([
      InboxMessage(
        id: 'msg_m1',
        sender: 'Dirección Exitus',
        subject: 'SIMULACRO ACADÉMICO UNP 2026',
        date: '27 Mayo',
        snippet: 'Estimado Mateo, se te convoca a rendir el simulacro tipo admisión UNP...',
        content: 'Estimado Mateo, te informamos que este sábado 30 de mayo a las 8:00 AM se realizará el simulacro general tipo examen de admisión. Tu aula asignada es el Pabellón A - 204. No olvides traer tu credencial digital y lápiz 2B. Atentamente, Dirección Académica Exitus.',
        unread: true,
        urgent: true,
      ),
      InboxMessage(
        id: 'msg_m2',
        sender: 'Dra. Julia Mendoza (Tutora)',
        subject: 'Material de Apoyo: Taller de Convivencia',
        date: '26 Mayo',
        snippet: 'Hola Mateo, adjunto las lecturas seleccionadas para la sesión de...',
        content: 'Hola Mateo, te adjunto el material de lectura y el cuestionario reflexivo para el taller de tutoría y convivencia de esta semana. Por favor revísalo antes del viernes para participar activamente en clase. Saludos.',
        unread: true,
      ),
      InboxMessage(
        id: 'msg_m3',
        sender: 'Auxiliaría de Secundaria',
        subject: 'Justificación Aceptada - Inasistencia 20/05',
        date: '21 Mayo',
        snippet: 'Se ha registrado la justificación médica enviada por tus padres...',
        content: 'Estimado estudiante, te confirmamos que la solicitud de justificación por tu inasistencia del día 20 de mayo por motivos de salud ha sido aprobada por la dirección auxiliar de secundaria. Las tareas pendientes de esa fecha se prorrogan hasta el lunes.',
        unread: false,
      ),
    ]);

    sofiaMessages.addAll([
      InboxMessage(
        id: 'msg_s1',
        sender: 'Miss Ana María (Tutoría)',
        subject: 'Materiales para clase de Arte del viernes',
        date: '27 Mayo',
        snippet: 'Estimada Sofía, recuerda traer témperas, pinceles y una cartulina...',
        content: 'Hola Sofía, recuerda pedirle a tus papitos que te consigan témperas de colores primarios, pinceles delgados y una cartulina blanca de tamaño A4 para nuestro taller creativo de arte de este viernes. ¡Vamos a pintar mucho! Cariños.',
        unread: true,
      ),
      InboxMessage(
        id: 'msg_s2',
        sender: 'Auxiliaría de Primaria',
        subject: 'Control de Ingreso - Tarjeta QR Activada',
        date: '24 Mayo',
        snippet: 'Tu pase digital ha sido renovado correctamente para el mes de...',
        content: 'Hola Sofía, te informamos que tu código QR para el pase digital de ingreso a la portería del colegio ya está listo y actualizado en tu cuenta. Recuerda llevar tu credencial cargada en el celular de tus papitos al ingresar al colegio.',
        unread: false,
      ),
    ]);

    adminMessages.addAll([
      InboxMessage(
        id: 'msg_a1',
        sender: 'Auxiliaría General',
        subject: 'Reporte Diario de Incidencias y Asistencias',
        date: '27 Mayo',
        snippet: 'Se consolidó la asistencia de hoy. Nivel Inicial: 98%, Primaria: 95%...',
        content: 'Estimado Director, adjunto el reporte de asistencia general y las incidencias menores en portería de la fecha de hoy. Se registró un 96.4% de asistencia. Se derivaron 2 casos justificados de inasistencias en 5to de Secundaria.',
        unread: true,
        urgent: true,
      ),
      InboxMessage(
        id: 'msg_a2',
        sender: 'Departamento de Psicología',
        subject: 'Solicitudes de Derivación del Docente',
        date: '26 Mayo',
        snippet: 'Se registraron 3 nuevas derivaciones para seguimiento emocional...',
        content: 'Estimado Director, le informamos que a través del sistema Dojo los docentes han derivado 3 alumnos para evaluación de conducta y acompañamiento psicológico esta semana. Ya se están agendando las citas con los respectivos apoderados.',
        unread: false,
      ),
    ]);
  }

  void _initPensions() {
    mateoPensions.addAll([
      PensionItem(id: 'p_m1', month: 'Mayo 2026', status: 'pending', price: 420.00, dueDate: '31/05/2026'),
      PensionItem(id: 'p_m2', month: 'Abril 2026', status: 'paid', price: 420.00, paymentDate: '28/04/2026', dueDate: '30/04/2026'),
      PensionItem(id: 'p_m3', month: 'Marzo 2026', status: 'paid', price: 420.00, paymentDate: '27/03/2026', dueDate: '31/03/2026'),
    ]);

    sofiaPensions.addAll([
      PensionItem(id: 'p_s1', month: 'Mayo 2026', status: 'pending', price: 420.00, dueDate: '31/05/2026'),
      PensionItem(id: 'p_s2', month: 'Abril 2026', status: 'paid', price: 420.00, paymentDate: '29/04/2026', dueDate: '30/04/2026'),
      PensionItem(id: 'p_s3', month: 'Marzo 2026', status: 'paid', price: 420.00, paymentDate: '26/03/2026', dueDate: '31/03/2026'),
    ]);
  }

  void _initTasks() {
    mateoTasks.addAll([
      StudentTask(id: 't_m1', course: 'math', courseName: 'Matemáticas', title: 'Ejercicios de Trigonometría', desc: 'Desarrollar los problemas de identidades trigonométricas de la página 52 del libro de texto.', due: '29 de Mayo', status: 'pending'),
      StudentTask(id: 't_m2', course: 'science', courseName: 'Ciencias', title: 'Informe de Laboratorio - Célula', desc: 'Dibujar la estructura celular e identificar las partes del núcleo observadas en el microscopio.', due: '30 de Mayo', status: 'pending'),
      StudentTask(id: 't_m3', course: 'literature', courseName: 'Literatura', title: 'Ensayo Crítico sobre el Vanguardismo', desc: 'Escribir un ensayo de máximo 2 páginas analizando la obra de César Vallejo (Trilce).', due: '02 de Junio', status: 'pending'),
      StudentTask(id: 't_m4', course: 'history', courseName: 'Historia', title: 'Línea de Tiempo: Independencia del Perú', desc: 'Crear una infografía interactiva que muestre las corrientes libertadoras del sur y del norte.', due: '25 de Mayo', status: 'completed', files: 1),
    ]);

    sofiaTasks.addAll([
      StudentTask(id: 't_s1', course: 'math', courseName: 'Matemáticas', title: 'Sumas de Tres Cifras con Llevadas', desc: 'Completar la ficha de ejercicios prácticos enviada al cuaderno de trabajo.', due: '29 de Mayo', status: 'pending'),
      StudentTask(id: 't_s2', course: 'literature', courseName: 'Literatura', title: 'Lectura Comprensiva: El Principito', desc: 'Leer el capítulo 5 y responder las 3 preguntas impresas sobre los baobabs.', due: '22 de Mayo', status: 'completed', files: 1),
    ]);
  }

  void _initGrades() {
    mateoGrades.addAll([
      StudentGrade(course: 'Matemáticas', code: 'MAT-5', val: 18.0, details: [
        GradeDetail(type: 'Práctica 1', val: 17),
        GradeDetail(type: 'Práctica 2', val: 19),
        GradeDetail(type: 'Examen Trimestral', val: 18),
      ]),
      StudentGrade(course: 'Ciencias', code: 'CIE-5', val: 16.0, details: [
        GradeDetail(type: 'Laboratorio', val: 18),
        GradeDetail(type: 'Exposición', val: 14),
        GradeDetail(type: 'Prueba Escrita', val: 16),
      ]),
      StudentGrade(course: 'Literatura', code: 'LIT-5', val: 19.0, details: [
        GradeDetail(type: 'Ensayo', val: 19),
        GradeDetail(type: 'Control Lectura', val: 20),
        GradeDetail(type: 'Participación', val: 18),
      ]),
      StudentGrade(course: 'Historia', code: 'HIS-5', val: 17.0, details: [
        GradeDetail(type: 'Infografía', val: 16),
        GradeDetail(type: 'Participación', val: 18),
      ]),
      StudentGrade(course: 'Inglés', code: 'ING-5', val: 19.0, details: [
        GradeDetail(type: 'Speaking Test', val: 20),
        GradeDetail(type: 'Writing Test', val: 18),
      ]),
    ]);

    sofiaGrades.addAll([
      StudentGrade(course: 'Matemáticas', code: 'MAT-2', val: 19.0, details: [
        GradeDetail(type: 'Ficha de Sumas', val: 20),
        GradeDetail(type: 'Cálculo Mental', val: 18),
      ]),
      StudentGrade(course: 'Ciencias', code: 'CIE-2', val: 20.0, details: [
        GradeDetail(type: 'Planta de Porotos', val: 20),
        GradeDetail(type: 'Exposición', val: 20),
      ]),
      StudentGrade(course: 'Literatura', code: 'LIT-2', val: 18.0, details: [
        GradeDetail(type: 'Ficha El Principito', val: 18),
        GradeDetail(type: 'Dictado de Palabras', val: 18),
      ]),
      StudentGrade(course: 'Inglés', code: 'ING-2', val: 20.0, details: [
        GradeDetail(type: 'Vocabulary Game', val: 20),
      ]),
    ]);
  }

  void _initDigitacionJobs() {
    digitacionJobs.addAll([
      PrintRequest(
        id: 1045,
        ticketNumber: "DG-1045",
        title: "Examen de Física",
        description: "Impresión de exámenes bimestrales.",
        requester: "Nicole Sulay Alburqueque Arevalo",
        date: "18 May 2024",
        colorMode: "b/n",
        paperSize: "A4",
        status: "processing",
        classrooms: [const PrintClassroomTarget(name: "4° Secundaria A", copies: 35)],
        file: "Examen_Fisica_4SecA.pdf",
        limitDate: "2026-06-05",
        instructions: "Ninguna",
        finish: "Engrapado",
      ),
      PrintRequest(
        id: 1046,
        ticketNumber: "DG-1046",
        title: "Separata de Álgebra",
        description: "Ficha práctica de ejercicios teóricos.",
        requester: "Nicole Sulay Alburqueque Arevalo",
        date: "19 May 2024",
        colorMode: "b/n",
        paperSize: "A4",
        status: "pending",
        classrooms: [const PrintClassroomTarget(name: "3° Primaria B", copies: 28)],
        file: "Separata_Algebra_3PrB.pdf",
        limitDate: "2026-06-06",
        instructions: "Ninguna",
        finish: "Suelto",
      ),
      PrintRequest(
        id: 1047,
        ticketNumber: "DG-1047",
        title: "Guía de Lectura",
        description: "Material didáctico complementario.",
        requester: "Nicole Sulay Alburqueque Arevalo",
        date: "17 May 2024",
        colorMode: "b/n",
        paperSize: "A4",
        status: "ready",
        classrooms: [const PrintClassroomTarget(name: "2° Secundaria C", copies: 30)],
        file: "Guia_Lectura_2SecC.pdf",
        limitDate: "2026-06-04",
        instructions: "Anillar con espiral negro.",
        finish: "Anillado",
      ),
      PrintRequest(
        id: 1044,
        ticketNumber: "DG-1044",
        title: "Fichas de Trabajo",
        description: "Fichas para trabajo individual en clase.",
        requester: "Nicole Sulay Alburqueque Arevalo",
        date: "15 May 2024",
        colorMode: "b/n",
        paperSize: "A4",
        status: "completed",
        classrooms: [const PrintClassroomTarget(name: "1° Primaria A", copies: 25)],
        file: "Fichas_Trabajo_1PrA.pdf",
        limitDate: "2026-06-02",
        instructions: "Ninguna",
        finish: "Suelto",
      ),
      PrintRequest(
        id: 1043,
        ticketNumber: "DG-1043",
        title: "Examen de Historia",
        description: "Evaluación mensual de historia del Perú.",
        requester: "Nicole Sulay Alburqueque Arevalo",
        date: "14 May 2024",
        colorMode: "b/n",
        paperSize: "A4",
        status: "completed",
        classrooms: [const PrintClassroomTarget(name: "5° Secundaria B", copies: 32)],
        file: "Examen_Historia_5SecB.pdf",
        limitDate: "2026-06-01",
        instructions: "Ninguna",
        finish: "Engrapado",
      ),
    ]);
  }

  void _initRubricas() {
    rubricasList.addAll([
      Rubrica(id: 1, title: "Rúbrica: Test", type: "Sesión Alineada", description: "Sin descripción", date: "27/05/2026"),
      Rubrica(id: 2, title: "Rúbrica: Conociendo CSS en desarrollo web", type: "Creación Libre", description: "Evaluación formativa alineada a las competencias clave.", date: "26/05/2026"),
      Rubrica(id: 3, title: "Rúbrica: Test", type: "Sesión Alineada", description: "Sin descripción", date: "24/05/2026"),
      Rubrica(id: 4, title: "Test", type: "Creación Libre", description: "Sin descripción", date: "20/05/2026"),
    ]);
  }

  void _initAttendanceLogs() {
    mateoAttendanceLogs.addAll([
      const AttendanceLog(dayNum: "27", dayName: "Miércoles", month: "May 2026", schedule: "08:00 - 13:00", tolerance: "0 min. tolerancia", entry: "07:54", exit: "--:--", status: "PUNTUAL", obs: ""),
      const AttendanceLog(dayNum: "26", dayName: "Martes", month: "May 2026", schedule: "08:00 - 13:00", tolerance: "0 min. tolerancia", entry: "08:18", exit: "13:07", status: "TARDANZA", obs: ""),
      const AttendanceLog(dayNum: "25", dayName: "Lunes", month: "May 2026", schedule: "08:00 - 13:00", tolerance: "0 min. tolerancia", entry: "07:40", exit: "13:02", status: "PUNTUAL", obs: ""),
      const AttendanceLog(dayNum: "24", dayName: "Domingo", month: "May 2026", schedule: "Sin horario asignado", tolerance: "", entry: "--:--", exit: "--:--", status: "SIN_REGISTRO", obs: ""),
      const AttendanceLog(dayNum: "23", dayName: "Sábado", month: "May 2026", schedule: "Sin horario asignado", tolerance: "", entry: "--:--", exit: "--:--", status: "SIN_REGISTRO", obs: "Sin incidencias"),
      const AttendanceLog(dayNum: "22", dayName: "Viernes", month: "May 2026", schedule: "Sin horario asignado", tolerance: "", entry: "--:--", exit: "--:--", status: "FALTA", obs: ""),
      const AttendanceLog(dayNum: "21", dayName: "Jueves", month: "May 2026", schedule: "08:00 - 13:00", tolerance: "0 min. tolerancia", entry: "09:11", exit: "13:05", status: "TARDANZA", obs: ""),
      const AttendanceLog(dayNum: "20", dayName: "Miércoles", month: "May 2026", schedule: "08:00 - 13:00", tolerance: "0 min. tolerancia", entry: "08:45", exit: "13:08", status: "TARDANZA", obs: ""),
      const AttendanceLog(dayNum: "19", dayName: "Martes", month: "May 2026", schedule: "08:00 - 13:00", tolerance: "0 min. tolerancia", entry: "08:37", exit: "13:00", status: "TARDANZA", obs: ""),
      const AttendanceLog(dayNum: "18", dayName: "Lunes", month: "May 2026", schedule: "Sin horario asignado", tolerance: "", entry: "--:--", exit: "--:--", status: "FALTA", obs: ""),
      const AttendanceLog(dayNum: "17", dayName: "Domingo", month: "May 2026", schedule: "Sin horario asignado", tolerance: "", entry: "--:--", exit: "--:--", status: "SIN_REGISTRO", obs: ""),
      const AttendanceLog(dayNum: "16", dayName: "Sábado", month: "May 2026", schedule: "Sin horario asignado", tolerance: "", entry: "--:--", exit: "--:--", status: "SIN_REGISTRO", obs: "Sin incidencias"),
    ]);

    sofiaAttendanceLogs.addAll([
      const AttendanceLog(dayNum: "27", dayName: "Miércoles", month: "May 2026", schedule: "08:00 - 13:00", tolerance: "0 min. tolerancia", entry: "07:49", exit: "13:00", status: "PUNTUAL", obs: ""),
      const AttendanceLog(dayNum: "26", dayName: "Martes", month: "May 2026", schedule: "08:00 - 13:00", tolerance: "0 min. tolerancia", entry: "07:51", exit: "13:00", status: "PUNTUAL", obs: ""),
      const AttendanceLog(dayNum: "25", dayName: "Lunes", month: "May 2026", schedule: "08:00 - 13:00", tolerance: "0 min. tolerancia", entry: "07:45", exit: "13:02", status: "PUNTUAL", obs: ""),
      const AttendanceLog(dayNum: "24", dayName: "Domingo", month: "May 2026", schedule: "Sin horario asignado", tolerance: "", entry: "--:--", exit: "--:--", status: "SIN_REGISTRO", obs: ""),
      const AttendanceLog(dayNum: "23", dayName: "Sábado", month: "May 2026", schedule: "Sin horario asignado", tolerance: "", entry: "--:--", exit: "--:--", status: "SIN_REGISTRO", obs: "Sin incidencias"),
      const AttendanceLog(dayNum: "22", dayName: "Viernes", month: "May 2026", schedule: "Sin horario asignado", tolerance: "", entry: "--:--", exit: "--:--", status: "PUNTUAL", obs: ""),
    ]);

    teacherAttendanceLogs.addAll([
      const AttendanceLog(dayNum: "27", dayName: "Miércoles", month: "May 2026", schedule: "07:30 - 14:30", tolerance: "10 min. tolerancia", entry: "07:22", exit: "--:--", status: "PUNTUAL", obs: "Docente del día"),
      const AttendanceLog(dayNum: "26", dayName: "Martes", month: "May 2026", schedule: "07:30 - 14:30", tolerance: "10 min. tolerancia", entry: "07:39", exit: "14:35", status: "TARDANZA", obs: ""),
      const AttendanceLog(dayNum: "25", dayName: "Lunes", month: "May 2026", schedule: "07:30 - 14:30", tolerance: "10 min. tolerancia", entry: "07:25", exit: "14:30", status: "PUNTUAL", obs: ""),
      const AttendanceLog(dayNum: "24", dayName: "Domingo", month: "May 2026", schedule: "Sin horario asignado", tolerance: "", entry: "--:--", exit: "--:--", status: "SIN_REGISTRO", obs: ""),
      const AttendanceLog(dayNum: "23", dayName: "Sábado", month: "May 2026", schedule: "Sin horario asignado", tolerance: "", entry: "--:--", exit: "--:--", status: "SIN_REGISTRO", obs: ""),
      const AttendanceLog(dayNum: "22", dayName: "Viernes", month: "May 2026", schedule: "07:30 - 14:30", tolerance: "10 min. tolerancia", entry: "07:28", exit: "14:32", status: "PUNTUAL", obs: ""),
      const AttendanceLog(dayNum: "21", dayName: "Jueves", month: "May 2026", schedule: "07:30 - 14:30", tolerance: "10 min. tolerancia", entry: "07:24", exit: "14:31", status: "PUNTUAL", obs: ""),
    ]);
  }

  // Métodos de consulta y mutación
  List<DojoStudent> getDojoStudents() {
    ApiLogger.logCall(
      method: "GET",
      endpoint: ApiEndpoints.dojoStudentsList,
    );
    return dojoStudents;
  }

  bool addDojoPoint(int id) {
    ApiLogger.logCall(
      method: "POST",
      endpoint: ApiEndpoints.addDojoPoints,
      body: {"id": id, "points": 1},
    );
    final idx = dojoStudents.indexWhere((s) => s.id == id);
    if (idx != -1) {
      final currentPoints = dojoStudents[idx].points;
      dojoStudents[idx].points += 1;
      final newPoints = dojoStudents[idx].points;

      // Verificar si evolucionó de nivel (Huevo a Elemental, Elemental a Cachorro, Cachorro a Adulto)
      bool evolved = false;
      if (currentPoints < 5 && newPoints >= 5) evolved = true;
      if (currentPoints < 9 && newPoints >= 9) evolved = true;
      if (currentPoints < 12 && newPoints >= 12) evolved = true;
      return evolved;
    }
    return false;
  }

  void toggleDojoPresence(int id) {
    ApiLogger.logCall(
      method: "PATCH",
      endpoint: ApiEndpoints.toggleDojoPresence.replaceAll("{studentId}", id.toString()),
    );
    final idx = dojoStudents.indexWhere((s) => s.id == id);
    if (idx != -1) {
      dojoStudents[idx].present = !dojoStudents[idx].present;
    }
  }

  void deductDojoPoints(int studentId, String category) {
    ApiLogger.logCall(
      method: "POST",
      endpoint: ApiEndpoints.deductDojoPoints,
      body: {"studentId": studentId, "category": category},
    );
    final idx = dojoStudents.indexWhere((s) => s.id == studentId);
    if (idx != -1) {
      int penalty = 0;
      if (category == 'indisciplina') penalty = 2;
      if (category == 'tareas' || category == 'tardanza') penalty = 1;
      
      final current = dojoStudents[idx].points;
      dojoStudents[idx].points = (current - penalty).clamp(0, 999);
    }
  }

  List<SocialPost> getSocialPosts() {
    ApiLogger.logCall(
      method: "GET",
      endpoint: ApiEndpoints.socialPosts,
    );
    return socialPosts;
  }

  void addSocialComment(int postId, SocialComment comment) {
    ApiLogger.logCall(
      method: "POST",
      endpoint: ApiEndpoints.addSocialComment.replaceAll("{postId}", postId.toString()),
      body: {
        "author": comment.author,
        "avatar": comment.avatar,
        "text": comment.text,
      },
    );
    final idx = socialPosts.indexWhere((p) => p.id == postId);
    if (idx != -1) {
      socialPosts[idx].comments.add(comment);
    }
  }

  void toggleReaction(int postId, String type) {
    ApiLogger.logCall(
      method: "POST",
      endpoint: ApiEndpoints.toggleSocialReaction.replaceAll("{postId}", postId.toString()),
      body: {"type": type},
    );
    final idx = socialPosts.indexWhere((p) => p.id == postId);
    if (idx != -1) {
      final post = socialPosts[idx];
      final currentReaction = post.userReactions[type] ?? false;
      
      // Limpiar otras reacciones para simplificar
      for (var key in post.userReactions.keys) {
        if (key == type) {
          post.userReactions[key] = !currentReaction;
        } else {
          post.userReactions[key] = false;
        }
      }

      // Recalcular contadores simulados
      if (type == 'likes') post.likes += currentReaction ? -1 : 1;
      if (type == 'loves') post.loves += currentReaction ? -1 : 1;
      if (type == 'bravos') post.bravos += currentReaction ? -1 : 1;
      if (type == 'insights') post.insights += currentReaction ? -1 : 1;
      if (type == 'haha') post.haha += currentReaction ? -1 : 1;
      if (type == 'sad') post.sad += currentReaction ? -1 : 1;
    }
  }

  List<InboxMessage> getMessagesForUser(String userId) {
    ApiLogger.logCall(
      method: "GET",
      endpoint: ApiEndpoints.messagesInbox,
      queryParameters: {"userId": userId},
    );
    if (userId.contains('mateo')) return mateoMessages;
    if (userId.contains('sofia')) return sofiaMessages;
    return adminMessages;
  }

  void markMessageAsRead(String userId, String messageId) {
    ApiLogger.logCall(
      method: "PATCH",
      endpoint: ApiEndpoints.markMessageRead.replaceAll("{messageId}", messageId),
      body: {"userId": userId},
    );
    final list = getMessagesForUser(userId);
    final idx = list.indexWhere((m) => m.id == messageId);
    if (idx != -1) {
      list[idx].unread = false;
    }
  }

  List<PensionItem> getPensionsForUser(String userId) {
    ApiLogger.logCall(
      method: "GET",
      endpoint: ApiEndpoints.pendingPensions,
      queryParameters: {"userId": userId},
    );
    if (userId.contains('mateo')) return mateoPensions;
    if (userId.contains('sofia')) return sofiaPensions;
    return [];
  }

  void payPension(String userId, String pensionId) {
    ApiLogger.logCall(
      method: "POST",
      endpoint: ApiEndpoints.processPayment,
      body: {"userId": userId, "pensionId": pensionId},
    );
    final list = getPensionsForUser(userId);
    final idx = list.indexWhere((p) => p.id == pensionId);
    if (idx != -1) {
      list[idx].status = 'paid';
      list[idx].paymentDate = 'Pagado vía ExitusPay';
    }
  }

  List<StudentTask> getTasksForUser(String userId) {
    ApiLogger.logCall(
      method: "GET",
      endpoint: ApiEndpoints.classroomTasks,
      queryParameters: {"userId": userId},
    );
    if (userId.contains('mateo')) return mateoTasks;
    if (userId.contains('sofia')) return sofiaTasks;
    return [];
  }

  void submitTask(String userId, String taskId) {
    ApiLogger.logCall(
      method: "POST",
      endpoint: ApiEndpoints.submitTask.replaceAll("{taskId}", taskId),
      body: {"userId": userId},
    );
    final list = getTasksForUser(userId);
    final idx = list.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      list[idx].status = 'completed';
      list[idx].files = 1;
    }
  }

  List<StudentGrade> getGradesForUser(String userId) {
    ApiLogger.logCall(
      method: "GET",
      endpoint: ApiEndpoints.classroomGrades,
      queryParameters: {"userId": userId},
    );
    if (userId.contains('mateo')) return mateoGrades;
    if (userId.contains('sofia')) return sofiaGrades;
    return [];
  }

  List<Student> getStudentsForCourse(String courseName) {
    ApiLogger.logCall(
      method: "GET",
      endpoint: ApiEndpoints.courseDetails.replaceAll("{courseId}", courseName.replaceAll(' ', '_')),
    );
    if (courseName.contains('5to A')) {
      return students5toA;
    } else {
      return students5toB;
    }
  }

  void saveAttendance(String courseName, List<Student> updatedStudents) {
    ApiLogger.logCall(
      method: "POST",
      endpoint: ApiEndpoints.submitAttendance,
      body: {
        "course": courseName,
        "students": updatedStudents.map((s) => {"id": s.id, "status": s.attendanceStatus}).toList(),
      },
    );
    if (courseName.contains('5to A')) {
      students5toA.clear();
      students5toA.addAll(updatedStudents);
    } else {
      students5toB.clear();
      students5toB.addAll(updatedStudents);
    }
  }

  void gradeSubmission(String submissionId, String grade, String feedback) {
    ApiLogger.logCall(
      method: "POST",
      endpoint: ApiEndpoints.gradeSubmission.replaceAll("{submissionId}", submissionId),
      body: {"grade": grade, "feedback": feedback},
    );
    final idx = submissions.indexWhere((element) => element.id == submissionId);
    if (idx != -1) {
      final current = submissions[idx];
      submissions[idx] = HomeworkSubmission(
        id: current.id,
        studentName: current.studentName,
        studentAvatar: current.studentAvatar,
        title: current.title,
        description: current.description,
        submittedText: current.submittedText,
        date: current.date,
        status: 'Calificado',
        grade: grade,
        feedback: feedback,
      );
    }
  }

  // --- V2 METODOS CENTRO DE PRODUCCIÓN (DIGITACIÓN) ---
  List<PrintRequest> getPrintRequests() {
    ApiLogger.logCall(
      method: "GET",
      endpoint: ApiEndpoints.printJobsList,
    );
    return digitacionJobs;
  }

  void addPrintRequest(PrintRequest request) {
    ApiLogger.logCall(
      method: "POST",
      endpoint: ApiEndpoints.submitPrintRequest,
      body: {
        "id": request.id,
        "documentName": request.documentName,
        "pages": request.pages,
        "copies": request.copies,
        "role": request.role,
        "userName": request.userName,
      },
    );
    digitacionJobs.insert(0, request);
  }

  void updatePrintRequest(PrintRequest updated) {
    ApiLogger.logCall(
      method: "PATCH",
      endpoint: ApiEndpoints.printJobStatusUpdate.replaceAll("{jobId}", updated.id.toString()),
      body: {"status": updated.status},
    );
    final idx = digitacionJobs.indexWhere((j) => j.id == updated.id);
    if (idx != -1) {
      digitacionJobs[idx] = updated;
    }
  }

  void deletePrintRequest(int id) {
    ApiLogger.logCall(
      method: "DELETE",
      endpoint: ApiEndpoints.deletePrintRequest.replaceAll("{id}", id.toString()),
    );
    digitacionJobs.removeWhere((j) => j.id == id);
  }

  // --- V2 METODOS GESTIÓN DE RÚBRICAS ---
  List<Rubrica> getRubricas() {
    ApiLogger.logCall(
      method: "GET",
      endpoint: ApiEndpoints.rubricasList,
    );
    return rubricasList;
  }

  void addRubrica(Rubrica rubrica) {
    ApiLogger.logCall(
      method: "POST",
      endpoint: ApiEndpoints.rubricasList,
      body: {
        "id": rubrica.id,
        "title": rubrica.title,
        "type": rubrica.type,
        "description": rubrica.description,
        "date": rubrica.date,
      },
    );
    rubricasList.insert(0, rubrica);
  }

  void editRubrica(int id, String title) {
    ApiLogger.logCall(
      method: "PUT",
      endpoint: ApiEndpoints.rubricasList,
      body: {"id": id, "title": title},
    );
    final idx = rubricasList.indexWhere((r) => r.id == id);
    if (idx != -1) {
      rubricasList[idx].title = title;
    }
  }

  void deleteRubrica(int id) {
    ApiLogger.logCall(
      method: "DELETE",
      endpoint: ApiEndpoints.rubricasList,
      body: {"id": id},
    );
    rubricasList.removeWhere((r) => r.id == id);
  }

  // --- V2 METODOS ASISTENCIA MENSUAL ALUMNO ---
  List<AttendanceLog> getAttendanceLogsForUser(String userId) {
    final bool isTeacher = userId.contains('profesor') || userId.contains('teacher') || userId.contains('nicole');
    ApiLogger.logCall(
      method: "GET",
      endpoint: isTeacher ? ApiEndpoints.teacherAttendance : ApiEndpoints.studentAttendance,
      queryParameters: {"userId": userId},
    );
    if (userId.contains('mateo')) return mateoAttendanceLogs;
    if (userId.contains('sofia')) return sofiaAttendanceLogs;
    if (isTeacher) return teacherAttendanceLogs;
    return [];
  }

  // --- V2 METODOS DOJO CONDUCTA ---
  int derivarDojoStudent(int studentId, String category, String comment) {
    ApiLogger.logCall(
      method: "POST",
      endpoint: ApiEndpoints.addDojoPoints,
      body: {"studentId": studentId, "category": category, "comment": comment},
    );
    final idx = dojoStudents.indexWhere((s) => s.id == studentId);
    if (idx != -1) {
      final student = dojoStudents[idx];
      int penalty = 0;
      if (category == 'indisciplina') {
        penalty = 2;
      } else if (category == 'tardanza' || category == 'tareas') {
        penalty = 1;
      }
      student.points = (student.points - penalty).clamp(0, 999);
      return penalty;
    }
    return 0;
  }

  // --- V2 METODOS ALUMNO CURSO DETALLE ---
  List<Map<String, dynamic>> getCourseContent(String courseId) {
    ApiLogger.logCall(
      method: "GET",
      endpoint: ApiEndpoints.courseContent.replaceAll("{courseId}", courseId),
    );

    // Contenido dinámico por curso
    List<Map<String, dynamic>> items = [];
    
    if (courseId == 'c_chino') {
      items = [
        {'title': 'Saludos y presentaciones', 'type': 'pdf', 'info': 'PDF • 2.4 MB', 'url': 'saludos.pdf'},
        {'title': 'Pinyin: Vocales y tonos', 'type': 'pdf', 'info': 'PDF • 1.8 MB', 'url': 'pinyin.pdf'},
        {'title': 'Ejercicios de escritura', 'type': 'docx', 'info': 'DOCX • 3.1 MB', 'url': 'escritura.docx'},
        {'title': 'Video: Pronunciación básica', 'type': 'video', 'info': 'YouTube • 8:45 min', 'url': 'pronunciacion.mp4'},
        {'title': 'Intranet: Recursos adicionales', 'type': 'link', 'info': 'Enlace', 'url': 'https://intranet.exitus.edu.pe/cn'},
        {'title': 'Evaluación 1: Conversaciones', 'type': 'pdf', 'info': 'PDF • 1.2 MB', 'url': 'evaluacion1.pdf'},
      ];
    } else if (courseId == 'c_ingles') {
      items = [
        {'title': 'Unit 1: Welcome & Introductions', 'type': 'pdf', 'info': 'PDF • 1.5 MB', 'url': 'welcome.pdf'},
        {'title': 'Verb To Be: Grammar Guide', 'type': 'pdf', 'info': 'PDF • 1.2 MB', 'url': 'verb_to_be.pdf'},
        {'title': 'Worksheets: Personal Pronouns', 'type': 'docx', 'info': 'DOCX • 2.1 MB', 'url': 'pronouns.docx'},
        {'title': 'Speaking Challenge: Self-intro', 'type': 'video', 'info': 'YouTube • 5:30 min', 'url': 'speaking_intro.mp4'},
        {'title': 'Interactive Game: Vocabulary Check', 'type': 'link', 'info': 'Enlace', 'url': 'https://quizlet.com/exitus_en'},
        {'title': 'Unit 1 Exam: Writing Section', 'type': 'pdf', 'info': 'PDF • 1.0 MB', 'url': 'exam_u1.pdf'},
      ];
    } else if (courseId == 'c_algebra') {
      items = [
        {'title': 'Ficha 1: Ecuaciones lineales', 'type': 'pdf', 'info': 'PDF • 3.2 MB', 'url': 'ecuaciones.pdf'},
        {'title': 'Métodos de resolución de sistemas', 'type': 'pdf', 'info': 'PDF • 2.0 MB', 'url': 'sistemas.pdf'},
        {'title': 'Álgebra de Baldor: Ejercicios', 'type': 'docx', 'info': 'DOCX • 4.5 MB', 'url': 'baldor.docx'},
        {'title': 'Video: Resolución paso a paso', 'type': 'video', 'info': 'YouTube • 12:15 min', 'url': 'algebra_video.mp4'},
        {'title': 'Simulador de gráficas de funciones', 'type': 'link', 'info': 'Enlace', 'url': 'https://geogebra.org'},
        {'title': 'Evaluación Trimestral de Álgebra', 'type': 'pdf', 'info': 'PDF • 1.8 MB', 'url': 'evaluacion_algebra.pdf'},
      ];
    } else if (courseId == 'c_fisica') {
      items = [
        {'title': 'Introducción a Vectores en 2D', 'type': 'pdf', 'info': 'PDF • 2.8 MB', 'url': 'vectores.pdf'},
        {'title': 'Movimiento Rectilíneo Uniforme (MRU)', 'type': 'pdf', 'info': 'PDF • 1.5 MB', 'url': 'mru.pdf'},
        {'title': 'Guía de laboratorio: Dinámica', 'type': 'docx', 'info': 'DOCX • 3.0 MB', 'url': 'dinamica.docx'},
        {'title': 'Video: Experimento de caída libre', 'type': 'video', 'info': 'YouTube • 9:20 min', 'url': 'caida_libre.mp4'},
        {'title': 'Simulador virtual de fuerzas', 'type': 'link', 'info': 'Enlace', 'url': 'https://phet.colorado.edu'},
        {'title': 'Evaluación 1: Cinemática', 'type': 'pdf', 'info': 'PDF • 1.1 MB', 'url': 'eval_cinematica.pdf'},
      ];
    } else if (courseId == 'c_literatura') {
      items = [
        {'title': 'Lectura: El Vanguardismo en el Perú', 'type': 'pdf', 'info': 'PDF • 1.9 MB', 'url': 'vanguardismo.pdf'},
        {'title': 'César Vallejo y la obra Trilce', 'type': 'pdf', 'info': 'PDF • 1.4 MB', 'url': 'vallejo.pdf'},
        {'title': 'Ficha de Comprensión Lectora', 'type': 'docx', 'info': 'DOCX • 1.8 MB', 'url': 'comprension.docx'},
        {'title': 'Video: Análisis literario de Trilce', 'type': 'video', 'info': 'YouTube • 15:40 min', 'url': 'analisis_trilce.mp4'},
        {'title': 'Biblioteca Digital Exitus', 'type': 'link', 'info': 'Enlace', 'url': 'https://biblioteca.exitus.edu.pe'},
        {'title': 'Control de Lectura 1: Vanguardismo', 'type': 'pdf', 'info': 'PDF • 1.2 MB', 'url': 'control_vanguardia.pdf'},
      ];
    } else if (courseId == 'c_tech') {
      items = [
        {'title': 'Introducción a la Programación con Scratch', 'type': 'pdf', 'info': 'PDF • 4.0 MB', 'url': 'scratch_intro.pdf'},
        {'title': 'Algoritmos y pseudocódigo básico', 'type': 'pdf', 'info': 'PDF • 2.5 MB', 'url': 'algoritmos.pdf'},
        {'title': 'Reto: Crea tu primer juego interactivo', 'type': 'docx', 'info': 'DOCX • 2.8 MB', 'url': 'reto_juego.docx'},
        {'title': 'Video: ¿Qué es una variable y bucle?', 'type': 'video', 'info': 'YouTube • 10:10 min', 'url': 'concepts.mp4'},
        {'title': 'Plataforma Scratch Exitus', 'type': 'link', 'info': 'Enlace', 'url': 'https://scratch.mit.edu'},
        {'title': 'Evaluación 1: Lógica algorítmica', 'type': 'pdf', 'info': 'PDF • 1.3 MB', 'url': 'eval_logica.pdf'},
      ];
    } else if (courseId == 'c_trigo') {
      items = [
        {'title': 'Razones trigonométricas en triángulos', 'type': 'pdf', 'info': 'PDF • 2.5 MB', 'url': 'razones.pdf'},
        {'title': 'Ficha: Ángulos notables y aplicaciones', 'type': 'pdf', 'info': 'PDF • 1.8 MB', 'url': 'angulos.pdf'},
        {'title': 'Ejercicios resueltos de trigonometría', 'type': 'docx', 'info': 'DOCX • 3.2 MB', 'url': 'ejercicios.docx'},
        {'title': 'Video: Resolución de triángulos', 'type': 'video', 'info': 'YouTube • 11:30 min', 'url': 'triangulos.mp4'},
        {'title': 'Calculadora científica online', 'type': 'link', 'info': 'Enlace', 'url': 'https://desmos.com/scientific'},
        {'title': 'Práctica Calificada: Identidades', 'type': 'pdf', 'info': 'PDF • 1.5 MB', 'url': 'practica_identidades.pdf'},
      ];
    } else {
      // c_tutoria
      items = [
        {'title': 'Inteligencia emocional y autoconocimiento', 'type': 'pdf', 'info': 'PDF • 1.6 MB', 'url': 'inteligencia_emocional.pdf'},
        {'title': 'Normas de convivencia del aula', 'type': 'pdf', 'info': 'PDF • 1.2 MB', 'url': 'normas.pdf'},
        {'title': 'Taller: Mis metas personales este año', 'type': 'docx', 'info': 'DOCX • 2.0 MB', 'url': 'metas.docx'},
        {'title': 'Video: Trabajo en equipo y empatía', 'type': 'video', 'info': 'YouTube • 7:15 min', 'url': 'teamwork.mp4'},
        {'title': 'Portal Psicopedagógico Exitus', 'type': 'link', 'info': 'Enlace', 'url': 'https://psico.exitus.edu.pe'},
        {'title': 'Bitácora de reflexiones personales', 'type': 'pdf', 'info': 'PDF • 1.0 MB', 'url': 'bitacora.pdf'},
      ];
    }

    return [
      {
        'title': 'Primer Trimestre',
        'date': '05 Mar - 20 Jun',
        'status': 'En curso',
        'items': items,
      },
      {
        'title': 'Segundo Trimestre',
        'date': '21 Jun - 10 Sep',
        'status': 'Próximamente',
        'items': <Map<String, dynamic>>[],
      },
      {
        'title': 'Tercer Trimestre',
        'date': '11 Sep - 15 Dic',
        'status': 'Próximamente',
        'items': <Map<String, dynamic>>[],
      }
    ];
  }

  List<Rubrica> getRubricasForCourse(String courseId) {
    ApiLogger.logCall(
      method: "GET",
      endpoint: ApiEndpoints.courseRubrics.replaceAll("{courseId}", courseId),
    );

    if (courseId == 'c_chino') {
      return [
        Rubrica(id: 101, title: "Rúbrica: Exposición Oral en Chino Mandarín", type: "Sesión Alineada", description: "Evaluación de la correcta pronunciación de tonos y fluidez en el saludo formal.", date: "28/05/2026"),
        Rubrica(id: 102, title: "Rúbrica: Caligrafía Hanzi", type: "Creación Libre", description: "Orden correcto de trazos y legibilidad en los caracteres básicos.", date: "22/05/2026"),
      ];
    } else if (courseId == 'c_ingles') {
      return [
        Rubrica(id: 201, title: "Rúbrica: Speaking Task - Introduce Yourself", type: "Sesión Alineada", description: "Evaluation of vocabulary, grammar accuracy (verb to be), and pronunciation.", date: "29/05/2026"),
        Rubrica(id: 202, title: "Rúbrica: Reading & Writing Essay", type: "Creación Libre", description: "Structure, coherence, and correct use of personal pronouns in a short text.", date: "15/05/2026"),
      ];
    } else if (courseId == 'c_algebra' || courseId == 'c_trigo') {
      return [
        Rubrica(id: 301, title: "Rúbrica: Resolución de Problemas de Ecuaciones", type: "Sesión Alineada", description: "Evaluación del planteamiento paso a paso, despeje algebraico y verificación del resultado.", date: "27/05/2026"),
        Rubrica(id: 302, title: "Rúbrica: Proyecto de Graficación de Funciones", type: "Creación Libre", description: "Uso de Geogebra para modelar situaciones reales e interpretación de puntos críticos.", date: "20/05/2026"),
      ];
    } else if (courseId == 'c_fisica') {
      return [
        Rubrica(id: 401, title: "Rúbrica: Informe de Laboratorio de Cinemática", type: "Sesión Alineada", description: "Estructura del informe, análisis de errores, tablas de datos y conclusiones experimentales.", date: "25/05/2026"),
        Rubrica(id: 402, title: "Rúbrica: Exposición de Vectores en la Vida Real", type: "Creación Libre", description: "Uso de material didáctico, claridad y resolución de preguntas rápidas.", date: "18/05/2026"),
      ];
    } else if (courseId == 'c_literatura') {
      return [
        Rubrica(id: 501, title: "Rúbrica: Ensayo Crítico sobre el Vanguardismo", type: "Sesión Alineada", description: "Tesis definida, argumentos sólidos, citas del poemario Trilce y ortografía.", date: "29/05/2026"),
        Rubrica(id: 502, title: "Rúbrica: Recital Poético y Declamación", type: "Creación Libre", description: "Expresividad, modulación de voz, postura corporal e interpretación emotiva.", date: "21/05/2026"),
      ];
    } else if (courseId == 'c_tech') {
      return [
        Rubrica(id: 601, title: "Rúbrica: Algoritmo y Lógica de Juego en Scratch", type: "Sesión Alineada", description: "Uso adecuado de variables, estructuras condicionales y bucles infinitos.", date: "29/05/2026"),
        Rubrica(id: 602, title: "Rúbrica: Diseño e Interfaz UI/UX de Proyecto", type: "Creación Libre", description: "Estética limpia, paleta de colores coherente y facilidad de uso.", date: "23/05/2026"),
      ];
    } else {
      // c_tutoria
      return [
        Rubrica(id: 701, title: "Rúbrica: Proyecto de Vida y Metas Anuales", type: "Sesión Alineada", description: "Claridad en las metas planteadas, plan de acción realista y autoevaluación sincera.", date: "26/05/2026"),
        Rubrica(id: 702, title: "Rúbrica: Taller de Coexistencia y Empatía", type: "Creación Libre", description: "Nivel de participación, respeto por las opiniones ajenas y trabajo colaborativo.", date: "19/05/2026"),
      ];
    }
  }
}


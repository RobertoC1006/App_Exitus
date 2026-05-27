import 'package:app_exitus/features/auth/domain/entities/user.dart';

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

  const ClassScheduleItem({
    required this.time,
    required this.subject,
    required this.classroom,
  });
}

// Base de datos simulada en memoria (Singleton para persistencia en sesión)
class MockDatabase {
  static final MockDatabase _instance = MockDatabase._internal();
  factory MockDatabase() => _instance;
  MockDatabase._internal();

  // Lista de usuarios registrados (Profesores y Administradores)
  final List<User> users = [
    const User(
      id: 'teacher_01',
      username: 'profesor123',
      fullName: 'Prof. Roberto Carlos',
      email: 'roberto.carlos@exitus.edu.pe',
      role: 'teacher',
      avatarUrl: 'https://images.unsplash.com/photo-1544717305-2782549b5136?w=150',
      subjects: ['Matemática - 5to A', 'Matemática - 5to B', 'Física - 4to A'],
    ),
    const User(
      id: 'admin_01',
      username: 'admin123',
      fullName: 'Ing. Carlos Mendoza',
      email: 'carlos.mendoza@exitus.edu.pe',
      role: 'admin',
      avatarUrl: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=150',
      subjects: [],
    ),
  ];

  // Contraseñas de usuarios (para simplificar el mock de login)
  final Map<String, String> userPasswords = {
    'profesor123': '12345678',
    'admin123': '12345678',
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

  // Horario de clases del Profesor por día de la semana
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

  // Obtener alumnos por curso
  List<Student> getStudentsForCourse(String courseName) {
    if (courseName.contains('5to A')) {
      return students5toA;
    } else {
      return students5toB;
    }
  }

  // Guardar asistencia
  void saveAttendance(String courseName, List<Student> updatedStudents) {
    if (courseName.contains('5to A')) {
      students5toA.clear();
      students5toA.addAll(updatedStudents);
    } else {
      students5toB.clear();
      students5toB.addAll(updatedStudents);
    }
  }

  // Calificar una entrega de tarea
  void gradeSubmission(String submissionId, String grade, String feedback) {
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
}

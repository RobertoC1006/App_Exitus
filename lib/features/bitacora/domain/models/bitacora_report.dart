import 'package:flutter/foundation.dart';

/// Modelo de estudiante involucrado con su rol asignado y estado de notificación.
class InvolvedStudent {
  final String id;
  final String fullName;
  final String avatarUrl;
  final String classroom;
  String role; // 'Afectado' o 'Responsable'
  bool notifyParent;

  InvolvedStudent({
    required this.id,
    required this.fullName,
    required this.avatarUrl,
    required this.classroom,
    this.role = 'Responsable',
    this.notifyParent = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'avatarUrl': avatarUrl,
      'classroom': classroom,
      'role': role,
      'notifyParent': notifyParent,
    };
  }

  factory InvolvedStudent.fromJson(Map<String, dynamic> json) {
    return InvolvedStudent(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      avatarUrl: json['avatarUrl'] as String,
      classroom: json['classroom'] as String,
      role: json['role'] as String? ?? 'Responsable',
      notifyParent: json['notifyParent'] as bool? ?? true,
    );
  }

  InvolvedStudent copyWith({
    String? id,
    String? fullName,
    String? avatarUrl,
    String? classroom,
    String? role,
    bool? notifyParent,
  }) {
    return InvolvedStudent(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      classroom: classroom ?? this.classroom,
      role: role ?? this.role,
      notifyParent: notifyParent ?? this.notifyParent,
    );
  }
}

/// Modelo de reporte oficial de bitácora.
class BitacoraReport {
  final String id;
  final String type; // 'Conductual', 'Relacional', 'Física', 'Digital'
  final List<InvolvedStudent> involvedStudents;
  final String date;
  final String time;
  final String location;
  final String description;
  final List<String> selectedMeasures; // Medidas seleccionadas
  final Map<String, String> measureContexts; // Medida -> Contexto/Especificación (guardaremos con clave 'General')
  final Map<String, String> measureFollowUps; // Medida -> Seguimiento posterior (guardaremos con clave 'General')
  final bool isOfficial;
  final DateTime createdAt;

  BitacoraReport({
    required this.id,
    required this.type,
    required this.involvedStudents,
    required this.date,
    required this.time,
    required this.location,
    required this.description,
    required this.selectedMeasures,
    required this.measureContexts,
    required this.measureFollowUps,
    this.isOfficial = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'involvedStudents': involvedStudents.map((s) => s.toJson()).toList(),
      'date': date,
      'time': time,
      'location': location,
      'description': description,
      'selectedMeasures': selectedMeasures,
      'measureContexts': measureContexts,
      'measureFollowUps': measureFollowUps,
      'isOfficial': isOfficial,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BitacoraReport.fromJson(Map<String, dynamic> json) {
    return BitacoraReport(
      id: json['id'] as String,
      type: json['type'] as String,
      involvedStudents: (json['involvedStudents'] as List<dynamic>)
          .map((s) => InvolvedStudent.fromJson(s as Map<String, dynamic>))
          .toList(),
      date: json['date'] as String,
      time: json['time'] as String,
      location: json['location'] as String,
      description: json['description'] as String,
      selectedMeasures: List<String>.from(json['selectedMeasures'] as List<dynamic>? ?? []),
      measureContexts: Map<String, String>.from(json['measureContexts'] as Map? ?? {}),
      measureFollowUps: Map<String, String>.from(json['measureFollowUps'] as Map? ?? {}),
      isOfficial: json['isOfficial'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

// ============================================================================
// ==================== ENDPOINTS DE API (INTEGRACIÓN FUTURA) =================
// ============================================================================

class BitacoraApi {
  /// ENDPOINT: Guardar el registro de incidencia en la base de datos oficial
  /// URL de Destino: /api/v1/bitacoras/save
  /// Método: POST
  static Future<bool> saveOfficialIncidentReport(BitacoraReport report) async {
    debugPrint("-----------------------------------------------------------------");
    debugPrint("[API ENDPOINT] POST /api/v1/bitacoras/save");
    debugPrint("Enviando reporte con ID: ${report.id}");
    debugPrint("Tipo de incidencia: ${report.type}");
    debugPrint("Involucrados: ${report.involvedStudents.length} estudiantes");
    debugPrint("-----------------------------------------------------------------");
    
    // Simulación de latencia de red
    await Future.delayed(const Duration(milliseconds: 1500));
    return true; // Éxito
  }

  /// ENDPOINT: Optimizar y corregir el texto redactado por el profesor usando Gemini AI
  /// URL de Destino: /api/v1/ai/improve-text
  /// Método: POST
  /// Body: { "text": rawText, "type": incidentType }
  static Future<String> improveIncidentDescriptionWithAI(String rawText, String incidentType) async {
    debugPrint("-----------------------------------------------------------------");
    debugPrint("[API ENDPOINT] POST /api/v1/ai/improve-text");
    debugPrint("Texto crudo: '$rawText'");
    debugPrint("Tipo sugerido para contexto: '$incidentType'");
    debugPrint("-----------------------------------------------------------------");

    // Simulación de latencia de red de IA
    await Future.delayed(const Duration(milliseconds: 1800));

    if (rawText.trim().isEmpty) return "";

    // Simulación de una respuesta pulida por IA según el tipo
    switch (incidentType.toLowerCase()) {
      case 'conductual':
        return "Durante la sesión de aprendizaje, los estudiantes involucrados interrumpieron el normal desarrollo de la clase al arrojarse papeles de manera reiterada. A pesar de recibir llamadas de atención y advertencias verbales sobre las normas de comportamiento, persistieron en su actitud disruptiva, afectando la concentración del grupo.";
      case 'relacional':
        return "Se registró un conflicto de convivencia escolar entre los alumnos indicados. Se observó un intercambio de palabras hostiles y gestos despectivos mutuos que interrumpieron la armonía grupal. Se intervino de forma inmediata para mediar en la situación y restablecer el diálogo pacífico.";
      case 'física':
        return "Se suscitó un incidente de contacto físico desmedido en el patio de recreo. Los alumnos involucrados forcejearon y se empujaron mutuamente debido a una disputa por el uso de materiales de juego. Se intervino de inmediato para salvaguardar la integridad de ambos y disipar la confrontación.";
      case 'digital':
        return "Se detectó el uso inadecuado de dispositivos tecnológicos en horas de clase. Los estudiantes utilizaron teléfonos móviles y compartieron contenido multimedia no autorizado durante la explicación académica, desobedeciendo la política de uso de TIC del aula.";
      default:
        return "El estudiante mostró una conducta inapropiada que interrumpió el progreso pedagógico en el aula, desoyendo las reiteradas indicaciones del docente para retomar su trabajo escolar.";
    }
  }

  /// ENDPOINT: Optimizar y redactar de forma más profesional las medidas adoptadas usando Gemini AI
  /// URL de Destino: /api/v1/ai/improve-measures
  /// Método: POST
  /// Body: { "text": rawText }
  static Future<String> improveMeasuresDescriptionWithAI(String rawText) async {
    debugPrint("-----------------------------------------------------------------");
    debugPrint("[API ENDPOINT] POST /api/v1/ai/improve-measures");
    debugPrint("Texto crudo de medidas: '$rawText'");
    debugPrint("-----------------------------------------------------------------");

    // Simulación de latencia de red de IA
    await Future.delayed(const Duration(milliseconds: 1500));

    if (rawText.trim().isEmpty) return "";

    return "Se procedió a dialogar reflexivamente con los estudiantes involucrados sobre las consecuencias de sus acciones y el respeto mutuo. Posteriormente, se realizó un llamado de atención de carácter verbal y formal, procediendo con el registro correspondiente de la incidencia en la bitácora escolar para el seguimiento pertinente.";
  }

  /// ENDPOINT: Transcribir el flujo de audio del micrófono en tiempo real
  /// URL de Destino (Websocket): wss://api.exitus.edu.pe/v1/voice/transcribe
  /// Protocolo: Real-time Audio Streaming
  static Stream<String> transcribeVoiceToText() {
    debugPrint("-----------------------------------------------------------------");
    debugPrint("[API ENDPOINT] wss://api/v1/voice/transcribe (Conectando WebSocket...)");
    debugPrint("-----------------------------------------------------------------");

    // Palabras simuladas que se van agregando progresivamente en tiempo real
    final List<String> simulatedWords = [
      "Durante", " la", " clase,", " los", " alumnos", " se", " lanzaron",
      " papeles", " entre", " ellos", " y", " no", " prestaron", " atención",
      " a", " la", " explicación.", " A", " pesar", " de", " las", " advertencias,",
      " continuaron", " interrumpiendo."
    ];

    return Stream.periodic(const Duration(milliseconds: 200), (index) {
      if (index >= simulatedWords.length) return "";
      // Retorna la frase consolidada hasta el índice actual
      return simulatedWords.take(index + 1).join();
    }).take(simulatedWords.length);
  }

  /// ENDPOINT: Notificar al padre o apoderado a través de la API oficial de WhatsApp
  /// URL de Destino: /api/v1/notifications/whatsapp/send
  /// Método: POST
  /// Body: { "student_id": id, "phone": parentPhone, "template": "incident_alert", "params": [...] }
  static Future<bool> sendWhatsAppNotification({
    required String studentId,
    required String studentName,
    required String incidentType,
    required String date,
  }) async {
    debugPrint("-----------------------------------------------------------------");
    debugPrint("[API ENDPOINT] POST /api/v1/notifications/whatsapp/send");
    debugPrint("Destinatario: Apoderado del alumno $studentName (ID: $studentId)");
    debugPrint("Detalles: Incidencia $incidentType del día $date");
    debugPrint("-----------------------------------------------------------------");

    // Simulación de latencia de envío
    await Future.delayed(const Duration(milliseconds: 800));
    return true; // Notificación enviada con éxito
  }
}

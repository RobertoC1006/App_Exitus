import 'package:flutter/services.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  /// Reproduce un sonido de campana/clic para la retroalimentación de puntos del Dojo
  Future<void> playBellSound() async {
    try {
      // Reproducir sonido de clic del sistema como feedback auditivo inmediato y libre de dependencias
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      print('Error al reproducir el sonido: $e');
    }
  }
}

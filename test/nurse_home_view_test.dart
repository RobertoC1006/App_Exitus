import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_exitus/features/dashboard/presentation/widgets/topico/nurse_home_view.dart';

class FakeHttpClient extends Fake implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    return FakeHttpClientRequest();
  }

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    return FakeHttpClientRequest();
  }
}

class FakeHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  final HttpHeaders headers = FakeHttpHeaders();

  @override
  Future<HttpClientResponse> close() async {
    return FakeHttpClientResponse();
  }
}

class FakeHttpHeaders extends Fake implements HttpHeaders {}

class FakeHttpClientResponse extends Fake implements HttpClientResponse {
  static final List<int> _transparentImage = [
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
    0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
    0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
    0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
    0x42, 0x60, 0x82,
  ];

  @override
  int get statusCode => 200;

  @override
  int get contentLength => _transparentImage.length;

  @override
  HttpClientResponseCompressionState get compressionState => HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([_transparentImage]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

void main() {
  testWidgets('NurseHomeView renders layout and items from the reference design', (WidgetTester tester) async {
    debugNetworkImageHttpClientProvider = () => FakeHttpClient();

    try {
      await tester.pumpWidget(
        const MaterialApp(
          home: NurseHomeView(),
        ),
      );

      // Verify Welcome Header
      expect(find.text('Hola, Lic. Rosa 👋'), findsOneWidget);
      expect(find.text('Turno Mañana'), findsOneWidget);

      // Verify Status Banner
      expect(find.text('Atención requerida'), findsOneWidget); // Default hasAlerts is true in mock database

      // Verify KPI Cards
      expect(find.text('Atendidos hoy'), findsOneWidget);
      expect(find.text('En espera'), findsOneWidget);
      expect(find.text('Stock OK'), findsOneWidget);
      expect(find.text('Alertas críticas'), findsOneWidget);

      // Verify Patients in Waiting List
      expect(find.text('Ana Torres Medina'), findsOneWidget);
      expect(find.text('Diego Ramos León'), findsOneWidget);
      expect(find.text('2 min esperando'), findsOneWidget);
      expect(find.text('Llegó hace 1 min'), findsOneWidget);

      // Verify Quick Actions Section
      expect(find.text('Acciones rápidas'), findsOneWidget);
      expect(find.text('Admitir\nPaciente'), findsOneWidget);
      expect(find.text('Expedientes\nClínicos'), findsOneWidget);
      expect(find.text('Inventario\nStock'), findsOneWidget);
      expect(find.text('Alertas\nCríticas'), findsOneWidget);

    } finally {
      debugNetworkImageHttpClientProvider = null;
    }
  });
}

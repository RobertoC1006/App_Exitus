import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_exitus/features/profile/presentation/widgets/nurse_profile_view.dart';
import 'package:app_exitus/features/auth/domain/entities/user.dart';

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
  testWidgets('NurseProfileView role switch tap invokes callback post-frame', (WidgetTester tester) async {
    debugNetworkImageHttpClientProvider = () => FakeHttpClient();

    try {
      String? changedRole;

      final user = User(
        id: 'rosa123',
        username: 'rosa123',
        fullName: 'Lic. Rosa',
        email: 'rosa@exitus.edu.pe',
        role: 'enfermero',
        avatarUrl: 'https://images.unsplash.com/photo-1597586124394-fbd6ef244026?w=150',
        subjects: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NurseProfileView(
              currentUser: user,
              onLogout: () {},
              onRoleChanged: (newRole) {
                changedRole = newRole;
              },
            ),
          ),
        ),
      );

      // Verify it renders the switcher cards
      expect(find.text('Tópico / Salud'), findsOneWidget);
      expect(find.text('Biblioteca'), findsOneWidget);

      // Tap on 'Biblioteca' card
      await tester.tap(find.text('Biblioteca'));
      
      // Verify that the callback is NOT run synchronously immediately during tap dispatch
      expect(changedRole, isNull);

      // Pump to process the post-frame callbacks
      await tester.pump();
      
      // Verify it now has run the callback after the frame finished
      expect(changedRole, 'bibliotecario');
    } finally {
      debugNetworkImageHttpClientProvider = null;
    }
  });
}

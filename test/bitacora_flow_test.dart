import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_exitus/features/bitacora/presentation/screens/new_bitacora_flow.dart';

void main() {
  testWidgets('NewBitacoraFlow full flow test up to Step 3', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: NewBitacoraFlow(),
      ),
    );

    // Verify we are at Step 1 (Incident Type)
    expect(find.text('¿Qué tipo de incidencia quieres registrar?'), findsOneWidget);

    // Tap on the first incident type card "Conductual" to auto-advance to Step 2
    await tester.tap(find.text('Conductual'));
    await tester.pumpAndSettle();

    // Verify we are at Step 2 (Involved Students)
    expect(find.text('¿Quiénes estuvieron involucrados?'), findsOneWidget);

    // To make Step 2 valid, we select a student and fill in the location
    // Scroll down to bring students list into view
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -250));
    await tester.pumpAndSettle();

    // Select student "Luis Valdiviezo Whitehead"
    await tester.tap(find.text('Luis Valdiviezo Whitehead'));
    await tester.pumpAndSettle();

    // Enter location
    await tester.enterText(find.byType(TextField).first, 'Aula 4° B');
    await tester.pumpAndSettle();

    // Click "Siguiente" button
    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();

    // Verify we are at Step 3 (Description AI)
    expect(find.text('Cuéntanos qué pasó'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_exitus/features/bitacora/presentation/widgets/step_description_ai.dart';
import 'package:app_exitus/features/bitacora/presentation/widgets/step_measures.dart';

void main() {
  testWidgets('StepDescriptionAI renders without crashes', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StepDescriptionAI(
            description: '',
            onDescriptionChanged: (val) {},
            incidentType: 'Conductual',
          ),
        ),
      ),
    );

    // Verify it builds successfully
    expect(find.text('Cuéntanos qué pasó'), findsOneWidget);
  });

  testWidgets('StepMeasures renders options and general details card', (WidgetTester tester) async {
    List<String> selectedMeasures = ['Conversación con estudiantes'];
    Map<String, String> contexts = {};
    Map<String, String> followUps = {};

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StepMeasures(
            selectedMeasures: selectedMeasures,
            onMeasuresChanged: (val) {
              selectedMeasures = val;
            },
            measureContexts: contexts,
            onContextsChanged: (val) {
              contexts = val;
            },
            measureFollowUps: followUps,
            onFollowUpsChanged: (val) {
              followUps = val;
            },
          ),
        ),
      ),
    );

    // Verify Title
    expect(find.text('¿Qué medidas adoptaste?'), findsOneWidget);

    // Verify that the general details section title is visible since we have selected measures
    expect(find.text('DETALLES DE MEDIDAS ADOPTADAS'), findsOneWidget);
    expect(find.text('Detalles Generales'), findsOneWidget);

    // Verify text field label
    expect(find.text('Especificación / Contexto de las medidas (Opcional)'), findsOneWidget);

    // Verify the "Siguiente (Seguimiento)" button is present
    expect(find.text('Siguiente (Seguimiento)'), findsOneWidget);
  });
}

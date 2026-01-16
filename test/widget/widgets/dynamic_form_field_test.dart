import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:saarciflex_app/presentation/features/simulation/widgets/dynamic_form_field.dart';
import 'package:saarciflex_app/data/models/critere_tarification_model.dart';
import '../../helpers/widget_test_helpers.dart';

void main() {
  group('DynamicFormField', () {
    testWidgets('affiche un champ texte pour TypeCritere.texte', (WidgetTester tester) async {
      final critere = CritereTarification(
        id: '1',
        produitId: 'prod1',
        nom: 'nom',
        type: TypeCritere.texte,
        ordre: 1,
        obligatoire: true,
        valeurs: [],
      );

      await tester.pumpWidget(
        WidgetTestHelpers.createSimpleTestApp(
          DynamicFormField(
            critere: critere,
            valeur: null,
            onChanged: (value) {},
          ),
        ),
      );

      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('affiche un champ numérique pour TypeCritere.numerique', (WidgetTester tester) async {
      final critere = CritereTarification(
        id: '1',
        produitId: 'prod1',
        nom: 'capital',
        type: TypeCritere.numerique,
        ordre: 1,
        obligatoire: true,
        valeurs: [],
      );

      await tester.pumpWidget(
        WidgetTestHelpers.createSimpleTestApp(
          DynamicFormField(
            critere: critere,
            valeur: null,
            onChanged: (value) {},
          ),
        ),
      );

      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('affiche un dropdown pour TypeCritere.categoriel', (WidgetTester tester) async {
      final critere = CritereTarification(
        id: '1',
        produitId: 'prod1',
        nom: 'type',
        type: TypeCritere.categoriel,
        ordre: 1,
        obligatoire: true,
        valeurs: [
          ValeurCritere(id: '1', valeur: 'option1', ordre: 1),
          ValeurCritere(id: '2', valeur: 'option2', ordre: 2),
        ],
      );

      await tester.pumpWidget(
        WidgetTestHelpers.createSimpleTestApp(
          DynamicFormField(
            critere: critere,
            valeur: null,
            onChanged: (value) {},
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      // Le dropdown devrait être présent (utilise DropdownButton dans un DropdownButtonHideUnderline)
      // Vérifions d'abord le conteneur, puis le DropdownButton
      expect(find.byType(DropdownButtonHideUnderline), findsOneWidget);
      expect(find.byType(DropdownButton<String>), findsOneWidget);
    });

    testWidgets('affiche une checkbox pour TypeCritere.booleen', (WidgetTester tester) async {
      final critere = CritereTarification(
        id: '1',
        produitId: 'prod1',
        nom: 'accepte',
        type: TypeCritere.booleen,
        ordre: 1,
        obligatoire: true,
        valeurs: [],
      );

      await tester.pumpWidget(
        WidgetTestHelpers.createSimpleTestApp(
          DynamicFormField(
            critere: critere,
            valeur: false,
            onChanged: (value) {},
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      // Pour les booléens, utilise SwitchListTile, pas Checkbox
      expect(find.byType(SwitchListTile), findsOneWidget);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:saarciflex_app/presentation/features/auth/screens/signup_screen.dart';
import 'package:saarciflex_app/presentation/features/auth/viewmodels/auth_viewmodel.dart';
import '../../helpers/widget_test_helpers.dart';

void main() {
  group('SignupScreen', () {
    testWidgets('affiche tous les champs du formulaire', (WidgetTester tester) async {
      final viewModel = AuthViewModel();
      
      await tester.pumpWidget(
        WidgetTestHelpers.createTestApp(
          child: const SignupScreen(),
          authViewModel: viewModel,
        ),
      );

      expect(find.text('Nom complet'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Mot de passe'), findsOneWidget);
      expect(find.text('Confirmer le mot de passe'), findsOneWidget);
    });

    testWidgets('affiche la checkbox CGU', (WidgetTester tester) async {
      final viewModel = AuthViewModel();
      
      await tester.pumpWidget(
        WidgetTestHelpers.createTestApp(
          child: const SignupScreen(),
          authViewModel: viewModel,
        ),
      );

      expect(find.byType(Checkbox), findsOneWidget);
    });

    testWidgets('affiche le bouton d\'inscription', (WidgetTester tester) async {
      final viewModel = AuthViewModel();
      
      await tester.pumpWidget(
        WidgetTestHelpers.createTestApp(
          child: const SignupScreen(),
          authViewModel: viewModel,
        ),
      );

      expect(find.text('Créer mon compte'), findsOneWidget);
    });

    testWidgets('permet de saisir tous les champs', (WidgetTester tester) async {
      final viewModel = AuthViewModel();
      
      await tester.pumpWidget(
        WidgetTestHelpers.createTestApp(
          child: const SignupScreen(),
          authViewModel: viewModel,
        ),
      );

      final textFields = find.byType(TextFormField);
      expect(textFields, findsAtLeastNWidgets(4));
    });
  });
}

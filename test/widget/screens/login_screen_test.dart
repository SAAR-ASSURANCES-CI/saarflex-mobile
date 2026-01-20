import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:saarciflex_app/presentation/features/auth/screens/login_screen.dart';
import 'package:saarciflex_app/presentation/features/auth/viewmodels/auth_viewmodel.dart';
import '../../helpers/widget_test_helpers.dart';

void main() {
  group('LoginScreen', () {
    testWidgets('affiche les champs email et password', (WidgetTester tester) async {
      final viewModel = AuthViewModel();
      
      await tester.pumpWidget(
        WidgetTestHelpers.createTestApp(
          child: const LoginScreen(),
          authViewModel: viewModel,
        ),
      );

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Mot de passe'), findsOneWidget);
      expect(find.text('Se connecter'), findsWidgets);
    });

    testWidgets('affiche le header avec logo et titre', (WidgetTester tester) async {
      final viewModel = AuthViewModel();
      
      await tester.pumpWidget(
        WidgetTestHelpers.createTestApp(
          child: const LoginScreen(),
          authViewModel: viewModel,
        ),
      );

      expect(find.text('Bon retour !'), findsOneWidget);
      expect(find.text('Connectez-vous à votre compte SAAR'), findsOneWidget);
    });

    testWidgets('affiche le bouton de navigation vers signup', (WidgetTester tester) async {
      final viewModel = AuthViewModel();
      
      await tester.pumpWidget(
        WidgetTestHelpers.createTestApp(
          child: const LoginScreen(),
          authViewModel: viewModel,
        ),
      );

      expect(find.text('Créer un compte'), findsOneWidget);
    });

    testWidgets('affiche le lien mot de passe oublié', (WidgetTester tester) async {
      final viewModel = AuthViewModel();
      
      await tester.pumpWidget(
        WidgetTestHelpers.createTestApp(
          child: const LoginScreen(),
          authViewModel: viewModel,
        ),
      );

      expect(find.text('Mot de passe oublié ?'), findsOneWidget);
    });

    testWidgets('permet de saisir email et password', (WidgetTester tester) async {
      final viewModel = AuthViewModel();
      
      await tester.pumpWidget(
        WidgetTestHelpers.createTestApp(
          child: const LoginScreen(),
          authViewModel: viewModel,
        ),
      );

      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;

      await tester.enterText(emailField, 'test@test.com');
      await tester.enterText(passwordField, 'password123');
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(emailField, findsOneWidget);
      expect(passwordField, findsOneWidget);
    });

    testWidgets('affiche le bouton de basculement visibilité password', (WidgetTester tester) async {
      final viewModel = AuthViewModel();
      
      await tester.pumpWidget(
        WidgetTestHelpers.createTestApp(
          child: const LoginScreen(),
          authViewModel: viewModel,
        ),
      );

      final visibilityIcon = find.byIcon(Icons.visibility);
      final visibilityOffIcon = find.byIcon(Icons.visibility_off);
      expect(
        visibilityIcon.evaluate().isNotEmpty || visibilityOffIcon.evaluate().isNotEmpty,
        true,
      );
    });
  });
}

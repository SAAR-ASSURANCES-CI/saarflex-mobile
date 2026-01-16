import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:saarciflex_app/presentation/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:saarciflex_app/presentation/features/products/viewmodels/product_viewmodel.dart';
import 'package:saarciflex_app/presentation/features/simulation/viewmodels/simulation_viewmodel.dart';
import 'package:saarciflex_app/core/constants/colors.dart';

/// Helpers pour les tests de widgets
class WidgetTestHelpers {
  /// Crée un MaterialApp avec Provider pour les tests
  static Widget createTestApp({
    required Widget child,
    AuthViewModel? authViewModel,
    ProductViewModel? productViewModel,
    SimulationViewModel? simulationViewModel,
  }) {
    return MultiProvider(
      providers: [
        if (authViewModel != null)
          ChangeNotifierProvider<AuthViewModel>.value(value: authViewModel),
        if (productViewModel != null)
          ChangeNotifierProvider<ProductViewModel>.value(value: productViewModel),
        if (simulationViewModel != null)
          ChangeNotifierProvider<SimulationViewModel>.value(
            value: simulationViewModel,
          ),
      ],
      child: MaterialApp(
        title: 'Test App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: AppColors.primary,
          colorScheme: ColorScheme.light(
            primary: AppColors.primary,
            secondary: AppColors.secondary,
            surface: AppColors.white,
          ),
        ),
        home: child,
      ),
    );
  }

  /// Crée un MaterialApp simple sans Provider
  static Widget createSimpleTestApp(Widget child) {
    return MaterialApp(
      title: 'Test App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: AppColors.primary,
      ),
      home: Scaffold(body: child),
    );
  }

  /// Crée un Scaffold avec MaterialApp pour les tests
  static Widget createTestScaffold({
    required Widget body,
    AppBar? appBar,
  }) {
    return MaterialApp(
      home: Scaffold(
        appBar: appBar,
        body: body,
      ),
    );
  }

  /// Attend que le widget soit complètement rendu
  static Future<void> pumpAndSettle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();
  }

  /// Trouve un widget par son type et texte
  static Finder findWidgetByText(String text) {
    return find.text(text);
  }

  /// Trouve un widget par sa clé
  static Finder findWidgetByKey(Key key) {
    return find.byKey(key);
  }

  /// Trouve un widget par son type
  static Finder findWidgetByType<T>() {
    return find.byType(T);
  }

  /// Vérifie qu'un widget existe
  static bool widgetExists(WidgetTester tester, Finder finder) {
    return finder.evaluate().isNotEmpty;
  }

  /// Tape sur un widget
  static Future<void> tapWidget(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pump();
  }

  /// Entre du texte dans un champ
  static Future<void> enterText(
    WidgetTester tester,
    Finder finder,
    String text,
  ) async {
    await tester.enterText(finder, text);
    await tester.pump();
  }

  /// Fait défiler jusqu'à trouver un widget
  static Future<void> scrollUntilVisible(
    WidgetTester tester,
    Finder finder, {
    double delta = 100,
    Duration scrollDuration = const Duration(milliseconds: 100),
  }) async {
    while (finder.evaluate().isEmpty) {
      await tester.drag(find.byType(Scrollable), Offset(0, -delta));
      await tester.pump(scrollDuration);
    }
  }
}

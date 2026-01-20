import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:saarciflex_app/presentation/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:saarciflex_app/presentation/features/products/viewmodels/product_viewmodel.dart';
import 'package:saarciflex_app/presentation/features/simulation/viewmodels/simulation_viewmodel.dart';
import 'package:saarciflex_app/core/constants/colors.dart';

class WidgetTestHelpers {
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

  static Future<void> pumpAndSettle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();
  }

  static Finder findWidgetByText(String text) {
    return find.text(text);
  }

  static Finder findWidgetByKey(Key key) {
    return find.byKey(key);
  }

  static Finder findWidgetByType<T>() {
    return find.byType(T);
  }

  static bool widgetExists(WidgetTester tester, Finder finder) {
    return finder.evaluate().isNotEmpty;
  }

  static Future<void> tapWidget(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pump();
  }

  static Future<void> enterText(
    WidgetTester tester,
    Finder finder,
    String text,
  ) async {
    await tester.enterText(finder, text);
    await tester.pump();
  }

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

# Guide des Tests - SAARFLEX Mobile

## 📋 Table des matières
1. [Exécuter les tests](#exécuter-les-tests)
2. [Structure des tests](#structure-des-tests)
3. [Ajouter de nouveaux tests](#ajouter-de-nouveaux-tests)
4. [Exemples pratiques](#exemples-pratiques)
5. [Bonnes pratiques](#bonnes-pratiques)

---

## 🚀 Exécuter les tests

### Exécuter tous les tests
```bash
flutter test
```

### Exécuter un fichier de test spécifique
```bash
flutter test test/unit/utils/error_handler_test.dart
```

### Exécuter un test spécifique par nom
```bash
flutter test --plain-name "ErrorHandler handleAuthError"
```

### Exécuter tous les tests unitaires
```bash
flutter test test/unit
```

### Exécuter tous les tests de widgets
```bash
flutter test test/widget
```

### Exécuter avec couverture de code
```bash
flutter test --coverage
```

### Exécuter avec rapport détaillé
```bash
flutter test --reporter expanded
```

---

## 📁 Structure des tests

```
test/
├── helpers/                    # Utilitaires pour les tests
│   ├── test_helpers.dart       # Helpers pour tests unitaires
│   └── widget_test_helpers.dart # Helpers pour tests de widgets
├── mocks/                      # Mocks pour les dépendances
│   └── mocks.dart              # Classes mockées
├── unit/                       # Tests unitaires
│   ├── services/               # Tests des services
│   ├── utils/                  # Tests des utilitaires
│   └── viewmodels/             # Tests des ViewModels
├── widget/                     # Tests de widgets
│   ├── screens/                # Tests des écrans
│   └── widgets/                # Tests des widgets réutilisables
└── integration/                # Tests d'intégration
    ├── auth_flow_test.dart
    ├── simulation_flow_test.dart
    └── souscription_flow_test.dart
```

---

## ✍️ Ajouter de nouveaux tests

### 1. Test unitaire - Exemple simple

Créez un fichier dans `test/unit/` :

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:saarciflex_app/votre_module/votre_classe.dart';

void main() {
  group('VotreClasse', () {
    test('description du test', () {
      // Arrange (Préparer)
      final instance = VotreClasse();
      
      // Act (Agir)
      final result = instance.maMethode();
      
      // Assert (Vérifier)
      expect(result, expectedValue);
    });
  });
}
```

### 2. Test unitaire avec mocks

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:saarciflex_app/votre_module/votre_service.dart';
import '../../mocks/mocks.dart';

void main() {
  late MockVotreRepository mockRepository;
  late VotreService service;

  setUp(() {
    mockRepository = MockVotreRepository();
    service = VotreService(mockRepository);
  });

  test('test avec mock', () async {
    // Configurer le mock
    when(mockRepository.getData())
        .thenAnswer((_) async => 'données de test');

    // Exécuter
    final result = await service.fetchData();

    // Vérifier
    expect(result, 'données de test');
    verify(mockRepository.getData()).called(1);
  });
}
```

### 3. Test de widget

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:saarciflex_app/votre_widget.dart';
import '../helpers/widget_test_helpers.dart';

void main() {
  testWidgets('description du test de widget', (WidgetTester tester) async {
    // Créer le widget
    await tester.pumpWidget(
      WidgetTestHelpers.createSimpleTestApp(
        VotreWidget(),
      ),
    );

    // Vérifier que le widget s'affiche
    expect(find.text('Texte attendu'), findsOneWidget);
    
    // Interagir avec le widget
    await tester.tap(find.byType(Button));
    await tester.pumpAndSettle();
    
    // Vérifier le résultat
    expect(find.text('Nouveau texte'), findsOneWidget);
  });
}
```

### 4. Test avec ViewModel

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:saarciflex_app/presentation/features/auth/viewmodels/auth_viewmodel.dart';

void main() {
  late AuthViewModel viewModel;

  setUp(() {
    viewModel = AuthViewModel();
  });

  test('test du ViewModel', () {
    expect(viewModel.isLoading, false);
    expect(viewModel.isLoggedIn, false);
  });
}
```

---

## 📚 Exemples pratiques

### Exemple 1 : Tester une fonction utilitaire

```dart
// test/unit/utils/mon_utilitaire_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:saarciflex_app/core/utils/mon_utilitaire.dart';

void main() {
  group('MonUtilitaire', () {
    test('formate correctement un nombre', () {
      expect(MonUtilitaire.formatNumber(1000), '1 000');
      expect(MonUtilitaire.formatNumber(0), '0');
    });

    test('valide un email', () {
      expect(MonUtilitaire.isValidEmail('test@test.com'), true);
      expect(MonUtilitaire.isValidEmail('invalid'), false);
    });
  });
}
```

### Exemple 2 : Tester un service avec API

```dart
// test/unit/services/mon_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:saarciflex_app/data/services/mon_service.dart';
import '../../mocks/mocks.dart';

void main() {
  late MockApiService mockApi;
  late MonService service;

  setUp(() {
    mockApi = MockApiService();
    service = MonService(mockApi);
  });

  test('récupère les données avec succès', () async {
    when(mockApi.get('/endpoint'))
        .thenAnswer((_) async => {'data': 'test'});

    final result = await service.fetchData();

    expect(result, isNotNull);
    verify(mockApi.get('/endpoint')).called(1);
  });

  test('gère les erreurs API', () async {
    when(mockApi.get('/endpoint'))
        .thenThrow(ApiException('Erreur', 500));

    expect(() => service.fetchData(), throwsA(isA<ApiException>()));
  });
}
```

### Exemple 3 : Tester un écran complet

```dart
// test/widget/screens/mon_ecran_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:saarciflex_app/presentation/features/mon_ecran.dart';
import '../../helpers/widget_test_helpers.dart';

void main() {
  testWidgets('affiche tous les éléments de l\'écran', (tester) async {
    await tester.pumpWidget(
      WidgetTestHelpers.createSimpleTestApp(MonEcran()),
    );

    // Vérifier les éléments
    expect(find.text('Titre'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('permet de remplir le formulaire', (tester) async {
    await tester.pumpWidget(
      WidgetTestHelpers.createSimpleTestApp(MonEcran()),
    );

    // Remplir les champs
    await tester.enterText(find.byType(TextField).first, 'Valeur 1');
    await tester.enterText(find.byType(TextField).last, 'Valeur 2');
    await tester.pump();

    // Vérifier les valeurs
    expect(find.text('Valeur 1'), findsOneWidget);
    expect(find.text('Valeur 2'), findsOneWidget);
  });
}
```

---

## ✅ Bonnes pratiques

### 1. Nommage des tests
- Utilisez des descriptions claires : `'retourne true quand les données sont valides'`
- Utilisez `group()` pour organiser les tests liés
- Un test = une assertion principale

### 2. Structure AAA (Arrange-Act-Assert)
```dart
test('exemple', () {
  // Arrange : Préparer les données
  final input = 'test';
  
  // Act : Exécuter l'action
  final result = maFonction(input);
  
  // Assert : Vérifier le résultat
  expect(result, expectedValue);
});
```

### 3. Utiliser les helpers
```dart
// Utilisez les helpers existants
import '../../helpers/test_helpers.dart';

final user = TestHelpers.createTestUser();
final authResponse = TestHelpers.createTestAuthResponse();
```

### 4. Tests isolés
- Chaque test doit être indépendant
- Utilisez `setUp()` et `tearDown()` pour la configuration
- N'utilisez pas de variables globales partagées

### 5. Tests rapides
- Les tests unitaires doivent être très rapides (< 1ms)
- Les tests de widgets peuvent être plus lents mais < 100ms
- Évitez les opérations I/O réelles dans les tests unitaires

### 6. Couverture de code
```bash
# Générer le rapport de couverture
flutter test --coverage

# Voir le rapport (nécessite lcov)
genhtml coverage/lcov.info -o coverage/html
```

---

## 🔧 Commandes utiles

### Voir les tests qui échouent
```bash
flutter test --reporter expanded
```

### Exécuter en mode watch (re-exécute automatiquement)
```bash
flutter test --reporter expanded --watch
```

### Exécuter seulement les tests modifiés
```bash
flutter test --changed
```

### Exclure certains tests
```bash
flutter test --exclude-tags slow
```

---

## 📖 Ressources

- [Documentation Flutter Testing](https://docs.flutter.dev/testing)
- [Mockito Documentation](https://pub.dev/packages/mockito)
- [Widget Testing Guide](https://docs.flutter.dev/cookbook/testing/widget)

---

## 🆘 Dépannage

### Les tests ne trouvent pas les imports
```bash
flutter pub get
flutter clean
flutter pub get
```

### Erreurs avec les mocks
Les mocks sont générés manuellement dans `test/mocks/mocks.dart`. 
Si vous ajoutez de nouveaux mocks, créez-les manuellement.

### Tests de widgets qui échouent
- Vérifiez que vous utilisez `WidgetTestHelpers.createSimpleTestApp()` ou `createTestApp()`
- Utilisez `await tester.pumpAndSettle()` après les interactions
- Vérifiez que les widgets sont bien rendus avec `pumpWidget()`

---

**Bon test ! 🎉**

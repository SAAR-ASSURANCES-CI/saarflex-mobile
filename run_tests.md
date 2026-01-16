# 🧪 Commandes Recommandées pour Exécuter les Tests

## ✅ Résultat Actuel
**141 tests passent, 0 échec** ✨

---

## 🚀 Commandes Essentielles (Recommandées)

### 1. **Exécuter TOUS les tests** (Recommandé pour CI/CD)
```bash
flutter test
```
**Quand l'utiliser :** Avant de commit, dans CI/CD, vérification complète

### 2. **Exécuter avec rapport détaillé** (Recommandé pour développement)
```bash
flutter test --reporter expanded
```
**Quand l'utiliser :** Pendant le développement pour voir chaque test en détail

### 3. **Exécuter un fichier spécifique** (Recommandé pour tests rapides)
```bash
flutter test test/unit/utils/error_handler_test.dart
```
**Quand l'utiliser :** Quand vous travaillez sur un module spécifique

### 4. **Exécuter par catégorie** (Recommandé pour organisation)

#### Tests unitaires uniquement
```bash
flutter test test/unit
```

#### Tests de widgets uniquement
```bash
flutter test test/widget
```

#### Tests d'intégration uniquement
```bash
flutter test test/integration
```

### 5. **Exécuter un test spécifique par nom** (Recommandé pour debug)
```bash
flutter test --plain-name "ErrorHandler"
```
**Quand l'utiliser :** Pour déboguer un test spécifique qui échoue

### 6. **Exécuter avec couverture de code** (Recommandé pour analyse)
```bash
flutter test --coverage
```
**Quand l'utiliser :** Pour générer un rapport de couverture de code

---

## 📊 Workflow Recommandé par Scénario

### Scénario 1 : Développement quotidien
```bash
# 1. Exécuter les tests du module sur lequel vous travaillez
flutter test test/unit/utils/error_handler_test.dart

# 2. Si tout passe, exécuter tous les tests avant de commit
flutter test --reporter expanded
```

### Scénario 2 : Avant un commit
```bash
# Exécuter tous les tests avec détails
flutter test --reporter expanded
```

### Scénario 3 : Debug d'un test qui échoue
```bash
# Exécuter uniquement le test problématique
flutter test --plain-name "nom_du_test" --reporter expanded
```

### Scénario 4 : Analyse de couverture
```bash
# Générer le rapport de couverture
flutter test --coverage

# Visualiser (nécessite lcov installé)
genhtml coverage/lcov.info -o coverage/html
```

### Scénario 5 : Tests rapides pendant le développement
```bash
# Exécuter seulement les tests unitaires (plus rapides)
flutter test test/unit
```

---

## 🎯 Commandes Avancées

### Exécuter en mode watch (re-exécute automatiquement)
```bash
flutter test --reporter expanded --watch
```

### Exécuter seulement les tests modifiés
```bash
flutter test --changed
```

### Exclure certains tests (par tag)
```bash
flutter test --exclude-tags slow
```

### Exécuter avec timeout personnalisé
```bash
flutter test --timeout 30s
```

---

## 📈 Statistiques Actuelles

- **Tests unitaires :** 107 tests
- **Tests de widgets :** 26 tests  
- **Tests d'intégration :** 8 tests
- **Total :** 141 tests
- **Taux de réussite :** 100% ✅

---

## 💡 Astuces

1. **Utilisez `--reporter expanded`** pour voir les détails de chaque test
2. **Exécutez les tests unitaires** (`test/unit`) pour des tests rapides
3. **Exécutez tous les tests** avant chaque commit
4. **Utilisez `--plain-name`** pour déboguer un test spécifique
5. **Générez la couverture** régulièrement pour identifier les zones non testées

---

## 🔧 Dépannage

### Si les tests ne trouvent pas les imports
```bash
flutter pub get
flutter clean
flutter pub get
```

### Si les tests sont lents
- Exécutez seulement `test/unit` pour les tests rapides
- Utilisez `--changed` pour exécuter seulement les tests modifiés

### Si un test échoue
```bash
# Exécuter avec détails pour voir l'erreur
flutter test --reporter expanded --plain-name "nom_du_test"
```

---

**Bon test ! 🎉**

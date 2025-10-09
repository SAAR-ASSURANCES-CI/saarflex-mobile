# 🏗️ Architecture Flutter - Saarflex Mobile

## 📁 Structure des Dossiers (DÉFINITIVE)

```
lib/
├── core/                           # 🔧 Configuration globale
│   ├── constants/                  # Constantes de l'application
│   │   ├── api_constants.dart      # URLs et endpoints API
│   │   ├── colors.dart             # Couleurs de l'app
│   │   └── app_constants.dart      # Constantes générales
│   ├── theme/                      # Thèmes et styles
│   │   ├── app_theme.dart          # Thème principal
│   │   └── text_styles.dart        # Styles de texte
│   └── utils/                      # Utilitaires partagés
│       ├── logger.dart             # Système de logs
│       ├── validators.dart         # Validateurs
│       └── helpers.dart            # Fonctions utilitaires
│
├── data/                           # 📊 Couche de données
│   ├── models/                     # Modèles de données
│   │   ├── user_model.dart         # Modèle utilisateur
│   │   ├── product_model.dart      # Modèle produit
│   │   └── contract_model.dart     # Modèle contrat
│   ├── services/                    # Services API
│   │   ├── api_service.dart        # Service API principal
│   │   ├── auth_service.dart       # Service d'authentification
│   │   └── user_service.dart       # Service utilisateur
│   └── repositories/               # Repositories (optionnel)
│       ├── user_repository.dart    # Repository utilisateur
│       └── product_repository.dart # Repository produit
│
├── presentation/                   # 🎨 Interface utilisateur
│   ├── features/                   # Fonctionnalités par domaine
│   │   ├── auth/                   # Authentification
│   │   │   ├── screens/           # Écrans d'auth
│   │   │   │   ├── login_screen.dart
│   │   │   │   ├── signup_screen.dart
│   │   │   │   └── reset_password_screen.dart
│   │   │   ├── viewmodels/        # ViewModels d'auth
│   │   │   │   └── auth_viewmodel.dart
│   │   │   └── widgets/           # Widgets spécifiques
│   │   │       ├── login_form.dart
│   │   │       └── password_field.dart
│   │   ├── products/              # Produits
│   │   │   ├── screens/
│   │   │   ├── viewmodels/
│   │   │   └── widgets/
│   │   ├── profile/               # Profil utilisateur
│   │   │   ├── screens/
│   │   │   ├── viewmodels/
│   │   │   └── widgets/
│   │   └── contracts/             # Contrats
│   │       ├── screens/
│   │       ├── viewmodels/
│   │       └── widgets/
│   │
│   └── shared/                     # Composants partagés
│       ├── widgets/               # Widgets réutilisables
│       │   ├── custom_button.dart
│       │   ├── loading_widget.dart
│       │   └── error_widget.dart
│       └── screens/               # Écrans partagés
│           ├── loading_screen.dart
│           └── error_screen.dart
│
└── main.dart                       # Point d'entrée de l'application
```

## 🎯 Règles d'Architecture (IMMUABLES)

### 1. Séparation des Responsabilités

| Dossier | Responsabilité | Ne doit PAS contenir |
|---------|----------------|---------------------|
| `core/` | Configuration globale | Logique métier, UI |
| `data/` | Gestion des données | Widgets, ViewModels |
| `presentation/` | Interface utilisateur | Logique API, modèles |

### 2. Règles de Nommage (OBLIGATOIRES)

```dart
// ✅ FICHIERS : snake_case
user_model.dart
auth_viewmodel.dart
login_screen.dart

// ✅ CLASSES : PascalCase
class UserModel { }
class AuthViewModel { }
class LoginScreen { }

// ✅ VARIABLES : camelCase
String userName = '';
bool isLoading = false;

// ✅ CONSTANTES : UPPER_SNAKE_CASE
const String API_BASE_URL = 'https://api.example.com';
const Color PRIMARY_COLOR = Colors.blue;
```

### 3. Structure d'un Feature (MODÈLE OBLIGATOIRE)

```
features/[nom_feature]/
├── screens/                    # Écrans de la fonctionnalité
│   ├── [nom]_screen.dart
│   └── [nom]_detail_screen.dart
├── viewmodels/                 # Logique de présentation
│   └── [nom]_viewmodel.dart
└── widgets/                    # Widgets spécifiques
    ├── [nom]_widget.dart
    └── [nom]_form.dart
```

## 📋 Conventions de Code

### 1. Imports (Ordre obligatoire)
```dart
// 1. Imports Flutter/Dart
import 'package:flutter/material.dart';
import 'dart:async';

// 2. Imports packages tiers
import 'package:provider/provider.dart';
import 'package:http/http.dart';

// 3. Imports internes (par ordre alphabétique)
import 'package:saarflex_app/core/constants/colors.dart';
import 'package:saarflex_app/data/models/user_model.dart';
import 'package:saarflex_app/presentation/features/auth/viewmodels/auth_viewmodel.dart';
```

### 2. Structure d'un ViewModel
```dart
class AuthViewModel extends ChangeNotifier {
  // 1. Variables privées
  bool _isLoading = false;
  User? _currentUser;
  String? _errorMessage;

  // 2. Getters publics
  bool get isLoading => _isLoading;
  User? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;

  // 3. Méthodes publiques
  Future<bool> login(String email, String password) async {
    // Implementation
  }

  // 4. Méthodes privées
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
```

### 3. Structure d'un Screen
```dart
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        return Scaffold(
          // UI implementation
        );
      },
    );
  }
}
```

## 🚫 Interdictions (À NE JAMAIS FAIRE)

1. **Ne jamais** mettre de logique API dans les ViewModels
2. **Ne jamais** mettre de widgets dans le dossier `data/`
3. **Ne jamais** mettre de modèles dans `presentation/`
4. **Ne jamais** mélanger les responsabilités dans un même fichier
5. **Ne jamais** créer des dépendances circulaires

## ✅ Bonnes Pratiques (À TOUJOURS RESPECTER)

1. **Un fichier = Une responsabilité**
2. **Nommage cohérent** dans tout le projet
3. **Séparation claire** entre les couches
4. **Documentation** des méthodes publiques
5. **Tests** pour chaque ViewModel

## 📝 Notes Importantes

- Cette architecture est **DÉFINITIVE** pour ce projet
- Tous les nouveaux développeurs doivent respecter cette structure
- En cas de doute, consulter ce document
- Cette architecture évolue avec le projet mais les principes restent

---
**Date de création :** $(date)
**Version :** 1.0
**Statut :** DÉFINITIVE

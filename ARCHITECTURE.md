# 🏗️ Architecture Flutter - Saarciflex Mobile

## 🧠 LOGIQUE ARCHITECTURALE DE L'APPLICATION

### 🎯 Principe Fondamental
L'architecture de Saarciflex Mobile suit le **principe de séparation des responsabilités** avec une approche **feature-based** qui garantit :
- **Maintenabilité** : Chaque composant a une responsabilité unique
- **Évolutivité** : Ajout de nouvelles fonctionnalités sans impact
- **Testabilité** : Isolation des composants pour des tests ciblés
- **Collaboration** : Équipes peuvent travailler en parallèle

### 🔄 Flux de Données (Data Flow)
```
UI (Screens) → ViewModels → Repositories → Services → API
     ↑              ↓           ↓          ↓
   States    ←  Business Logic ← Data Access ← External
```

**Explication du flux :**
1. **UI** : Affiche les données et capture les interactions utilisateur
2. **ViewModels** : Gèrent l'état UI et orchestrent les actions
3. **Repositories** : Abstraction de l'accès aux données
4. **Services** : Logique métier et appels API
5. **API** : Source externe des données

### 🏗️ Couches Architecturales

#### **1. 🎨 Couche Présentation (UI Layer)**
- **Responsabilité** : Interface utilisateur et expérience utilisateur
- **Composants** : Screens, ViewModels, Widgets
- **Principe** : Seulement logique UI, pas de logique métier

#### **2. 📊 Couche Données (Data Layer)**
- **Responsabilité** : Gestion des données et accès aux sources
- **Composants** : Services, Repositories, Models
- **Principe** : Abstraction de l'accès aux données

#### **3. 🔧 Couche Core (Core Layer)**
- **Responsabilité** : Configuration globale et utilitaires
- **Composants** : Constants, Utils, Theme, Logger
- **Principe** : Fonctionnalités partagées et configuration

### 🎯 Avantages de cette Architecture

#### **✅ Séparation Claire**
- Chaque couche a un rôle précis
- Pas de mélange des responsabilités
- Facilite la maintenance

#### **✅ Évolutivité**
- Ajout de nouvelles features sans impact
- Modification d'une couche sans affecter les autres
- Support de l'équipe élargie

#### **✅ Testabilité**
- Tests unitaires par couche
- Mocking facile des dépendances
- Tests d'intégration ciblés

#### **✅ Réutilisabilité**
- Composants réutilisables entre features
- Services partagés
- Utils centralisés

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
│       ├── validators.dart         # Validateurs généraux
│       ├── helpers.dart            # Fonctions utilitaires
│       ├── error_handler.dart      # Gestion centralisée des erreurs
│       ├── data_formatters.dart    # Formatage des données
│       ├── simulation_validators.dart # Validateurs simulation
│       ├── profile_validators.dart # Validateurs profil
│       └── file_validators.dart    # Validateurs fichiers
│
├── data/                           # 📊 Couche de données
│   ├── models/                     # Modèles de données
│   │   ├── user_model.dart         # Modèle utilisateur
│   │   ├── product_model.dart      # Modèle produit
│   │   └── contract_model.dart     # Modèle contrat
│   ├── services/                    # Services API
│   │   ├── api_service.dart        # Service API principal (HTTP seulement)
│   │   ├── auth_service.dart       # Service d'authentification
│   │   ├── user_service.dart       # Service utilisateur
│   │   ├── profile_service.dart    # Service profil utilisateur
│   │   ├── simulation_service.dart # Service simulation
│   │   ├── validation_service.dart # Service validation
│   │   └── file_upload_service.dart # Service upload fichiers
│   └── repositories/               # Repositories (OBLIGATOIRE)
│       ├── auth_repository.dart    # Repository authentification
│       ├── user_repository.dart    # Repository utilisateur
│       ├── profile_repository.dart # Repository profil
│       ├── simulation_repository.dart # Repository simulation
│       └── contract_repository.dart # Repository contrats
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

| Dossier | Responsabilité | Ne doit PAS contenir | Exemple concret |
|---------|----------------|---------------------|-----------------|
| `core/` | Configuration globale | Logique métier, UI | `AppColors`, `Logger`, `Validators` |
| `data/` | Gestion des données | Widgets, ViewModels | `ApiService`, `UserModel`, `AuthRepository` |
| `presentation/` | Interface utilisateur | Logique API, modèles | `LoginScreen`, `AuthViewModel`, `CustomButton` |

### 1.1 Logique de Communication entre Couches

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   PRESENTATION  │───▶│      DATA       │───▶│      CORE       │
│                 │    │                 │    │                 │
│ • Screens       │    │ • Services      │    │ • Constants     │
│ • ViewModels    │    │ • Repositories  │    │ • Utils         │
│ • Widgets       │    │ • Models        │    │ • Logger        │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
   État UI/UX              Logique Métier           Configuration
```

**Règles de communication :**
- **Presentation → Data** : ViewModels appellent les Repositories
- **Data → Core** : Services utilisent les Utils et Constants
- **Pas de communication inverse** : Core ne connaît pas Data, Data ne connaît pas Presentation

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

### 3.1 Logique d'un Feature Complet

```
┌─────────────────────────────────────────────────────────────┐
│                    FEATURE: AUTHENTICATION                  │
├─────────────────────────────────────────────────────────────┤
│  PRESENTATION LAYER                                         │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐│
│  │   Screens       │  │   ViewModels    │  │    Widgets      ││
│  │                 │  │                 │  │                 ││
│  │ • LoginScreen   │  │ • AuthViewModel │  │ • LoginForm     ││
│  │ • SignupScreen  │  │                 │  │ • PasswordField ││
│  │ • ResetScreen   │  │                 │  │ • ActionCard    ││
│  └─────────────────┘  └─────────────────┘  └─────────────────┘│
│           │                     │                     │      │
│           └─────────────────────┼─────────────────────┘      │
│                                 │                          │
│  DATA LAYER                     │                          │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐│
│  │   Services       │  │  Repositories   │  │     Models      ││
│  │                 │  │                 │  │                 ││
│  │ • AuthService   │  │ • AuthRepository│  │ • UserModel     ││
│  │ • UserService   │  │ • UserRepository│  │ • AuthResponse  ││
│  └─────────────────┘  └─────────────────┘  └─────────────────┘│
│           │                     │                     │      │
│           └─────────────────────┼─────────────────────┘      │
│                                 │                          │
│  CORE LAYER                     │                          │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐│
│  │   Constants     │  │     Utils       │  │     Theme       ││
│  │                 │  │                 │  │                 ││
│  │ • ApiConstants  │  │ • ErrorHandler  │  │ • AppTheme      ││
│  │ • AppConstants  │  │ • Validators    │  │ • TextStyles    ││
│  └─────────────────┘  └─────────────────┘  └─────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

**Flux de données dans un Feature :**
1. **Screen** → Capture l'interaction utilisateur
2. **ViewModel** → Traite l'action et met à jour l'état
3. **Repository** → Abstraction de l'accès aux données
4. **Service** → Logique métier et appels API
5. **Model** → Représentation des données
6. **Utils** → Fonctions utilitaires partagées

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
import 'package:saarciflex_app/core/constants/colors.dart';
import 'package:saarciflex_app/data/models/user_model.dart';
import 'package:saarciflex_app/presentation/features/auth/viewmodels/auth_viewmodel.dart';
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
6. **Ne jamais** mettre de logique métier dans les ViewModels
7. **Ne jamais** mettre de formatage de données dans les ViewModels
8. **Ne jamais** mettre de validation métier dans les ViewModels

## ✅ Bonnes Pratiques (À TOUJOURS RESPECTER)

1. **Un fichier = Une responsabilité**
2. **Nommage cohérent** dans tout le projet
3. **Séparation claire** entre les couches
4. **Documentation** des méthodes publiques
5. **Tests** pour chaque ViewModel
6. **ViewModels** : Seulement logique UI et états
7. **Services** : Logique métier et accès aux données
8. **Repositories** : Abstraction de l'accès aux données
9. **Utils** : Fonctions utilitaires réutilisables

## 🔄 ÉVOLUTION DE L'ARCHITECTURE (REFACTORISATION)

### 📋 Problèmes identifiés et solutions

#### ❌ Problèmes actuels :
1. **ApiService** : Mélange logique métier + accès aux données + formatage
2. **ViewModels** : Contiennent logique métier + validation + formatage
3. **Services manquants** : Pas de séparation des responsabilités
4. **Repositories manquants** : Accès direct aux services depuis les ViewModels

#### ✅ Solutions implémentées :
1. **Services spécialisés** : Chaque service a une responsabilité unique
2. **Repositories obligatoires** : Abstraction de l'accès aux données
3. **ViewModels simplifiés** : Seulement logique UI et états
4. **Utils spécialisés** : Validation et formatage centralisés

### 🎯 Plan de refactorisation (par phases)

#### Phase 1 - Services manquants (PRIORITÉ)
- [ ] Créer `AuthService` - Logique d'authentification
- [ ] Créer `ProfileService` - Logique profil utilisateur  
- [ ] Créer `ValidationService` - Logique de validation
- [ ] Créer `FileUploadService` - Upload de fichiers
- [ ] Créer `ErrorHandler` - Gestion centralisée des erreurs

#### Phase 2 - Repositories (OBLIGATOIRE)
- [ ] Créer `AuthRepository` - Abstraction auth
- [ ] Créer `ProfileRepository` - Abstraction profil
- [ ] Créer `SimulationRepository` - Abstraction simulation
- [ ] Créer `ContractRepository` - Abstraction contrats

#### Phase 3 - Simplification ViewModels
- [ ] Simplifier `AuthViewModel` - Seulement logique UI
- [ ] Simplifier `SimulationViewModel` - Seulement logique UI
- [ ] Simplifier `ProfileViewModel` - Seulement logique UI

#### Phase 4 - Utils spécialisés
- [ ] Créer `DataFormatters` - Formatage des données
- [ ] Créer `SimulationValidators` - Validation simulation
- [ ] Créer `ProfileValidators` - Validation profil
- [ ] Créer `FileValidators` - Validation fichiers

## 🎯 RÉSUMÉ DE LA LOGIQUE ARCHITECTURALE

### 🧠 Principe Central
**"Chaque composant a une responsabilité unique et bien définie"**

### 🔄 Flux de Données Simplifié
```
Utilisateur → Screen → ViewModel → Repository → Service → API
     ↑         ↑         ↑           ↑          ↑
   Action    État UI   Logique    Abstraction  Métier
```

### 🏗️ Avantages Concrets
1. **Maintenance** : Bug dans une couche = impact limité
2. **Évolution** : Nouvelle feature = ajout sans modification
3. **Tests** : Chaque couche testable indépendamment
4. **Équipe** : Développeurs peuvent travailler en parallèle
5. **Performance** : Optimisations ciblées par couche

### 📊 Métriques de Qualité
- **Couplage** : Faible entre les couches
- **Cohésion** : Élevée dans chaque composant
- **Réutilisabilité** : Composants partagés
- **Testabilité** : Isolation des responsabilités

## 📝 Notes Importantes

- Cette architecture est **ÉVOLUTIVE** pour ce projet
- Tous les nouveaux développeurs doivent respecter cette structure
- En cas de doute, consulter ce document
- Cette architecture évolue avec le projet et les besoins

---
**Date de création :** $(date)
**Version :** 2.0
**Statut :** ÉVOLUTIVE (Refactorisation en cours)
**Dernière mise à jour :** $(date)

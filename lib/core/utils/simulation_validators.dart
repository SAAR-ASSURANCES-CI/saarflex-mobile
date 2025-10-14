/// Utilitaires de validation spécialisés pour la simulation
class SimulationValidators {
  /// Valide les informations de l'assuré
  static ValidationResult validateAssureInfo(
    Map<String, dynamic> informations,
  ) {
    final errors = <String, String>{};

    // Validation du nom complet
    final nomComplet = informations['nom_complet']?.toString().trim();
    if (nomComplet == null || nomComplet.isEmpty) {
      errors['nom_complet'] = 'Le nom complet est obligatoire';
    } else if (nomComplet.length < 2) {
      errors['nom_complet'] = 'Le nom doit contenir au moins 2 caractères';
    }

    // Validation de la date de naissance
    final dateNaissance = informations['date_naissance']?.toString();
    if (dateNaissance != null && dateNaissance.isNotEmpty) {
      final date = DateTime.tryParse(dateNaissance);
      if (date == null) {
        errors['date_naissance'] = 'Format de date invalide';
      } else {
        final age = DateTime.now().year - date.year;
        if (age < 18) {
          errors['date_naissance'] = 'L\'âge minimum est de 18 ans';
        } else if (age > 100) {
          errors['date_naissance'] = 'L\'âge maximum est de 100 ans';
        }
      }
    }

    // Validation du téléphone
    final telephone = informations['telephone']?.toString().trim();
    if (telephone != null && telephone.isNotEmpty) {
      if (!_isValidPhoneNumber(telephone)) {
        errors['telephone'] = 'Format de téléphone invalide';
      }
    }

    // Validation de l'email (optionnel)
    final email = informations['email']?.toString().trim();
    if (email != null && email.isNotEmpty) {
      if (!_isValidEmail(email)) {
        errors['email'] = 'Format d\'email invalide';
      }
    }

    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  /// Valide les critères de simulation
  static ValidationResult validateCriteres(
    Map<String, dynamic> criteres,
    List<String> criteresObligatoires,
  ) {
    final errors = <String, String>{};

    for (final critere in criteresObligatoires) {
      final valeur = criteres[critere];
      if (valeur == null || valeur.toString().trim().isEmpty) {
        errors[critere] = 'Ce critère est obligatoire';
      }
    }

    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  /// Valide les informations de sauvegarde
  static ValidationResult validateSaveInfo({
    required String devisId,
    String? nomPersonnalise,
    String? notes,
  }) {
    final errors = <String, String>{};

    if (devisId.trim().isEmpty) {
      errors['devis_id'] = 'L\'ID du devis est obligatoire';
    }

    if (nomPersonnalise != null && nomPersonnalise.trim().isNotEmpty) {
      if (nomPersonnalise.trim().length < 2) {
        errors['nom_personnalise'] =
            'Le nom doit contenir au moins 2 caractères';
      } else if (nomPersonnalise.trim().length > 100) {
        errors['nom_personnalise'] =
            'Le nom ne peut pas dépasser 100 caractères';
      }
    }

    if (notes != null && notes.trim().isNotEmpty) {
      if (notes.trim().length > 500) {
        errors['notes'] = 'Les notes ne peuvent pas dépasser 500 caractères';
      }
    }

    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  /// Vérifie si un numéro de téléphone est valide
  static bool _isValidPhoneNumber(String phone) {
    // Supprimer tous les espaces et caractères non numériques
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');

    // Vérifier que c'est un numéro camerounais valide
    if (cleaned.length == 9 && cleaned.startsWith('6')) {
      return true;
    }

    // Vérifier que c'est un numéro international valide
    if (cleaned.length >= 10 && cleaned.length <= 15) {
      return true;
    }

    return false;
  }

  /// Vérifie si un email est valide
  static bool _isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }
}

/// Résultat de validation
class ValidationResult {
  final bool isValid;
  final Map<String, String> errors;

  const ValidationResult({required this.isValid, required this.errors});

  /// Retourne le premier message d'erreur
  String? get firstError {
    if (errors.isEmpty) return null;
    return errors.values.first;
  }

  /// Retourne tous les messages d'erreur
  List<String> get allErrors => errors.values.toList();
}

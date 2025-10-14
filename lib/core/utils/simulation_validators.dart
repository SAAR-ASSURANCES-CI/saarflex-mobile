/// Utilitaires de validation spécialisés pour la simulation
class SimulationValidators {
  static ValidationResult validateAssureInfo(
    Map<String, dynamic> informations,
  ) {
    final errors = <String, String>{};

    final nomComplet = informations['nom_complet']?.toString().trim();
    if (nomComplet == null || nomComplet.isEmpty) {
      errors['nom_complet'] = 'Le nom complet est obligatoire';
    } else if (nomComplet.length < 2) {
      errors['nom_complet'] = 'Le nom doit contenir au moins 2 caractères';
    }

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

    final telephone = informations['telephone']?.toString().trim();
    if (telephone != null && telephone.isNotEmpty) {
      if (!_isValidPhoneNumber(telephone)) {
        errors['telephone'] = 'Format de téléphone invalide';
      }
    }

    final email = informations['email']?.toString().trim();
    if (email != null && email.isNotEmpty) {
      if (!_isValidEmail(email)) {
        errors['email'] = 'Format d\'email invalide';
      }
    }

    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }

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

  static bool _isValidPhoneNumber(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');

    if (cleaned.length == 9 && cleaned.startsWith('6')) {
      return true;
    }

    if (cleaned.length >= 10 && cleaned.length <= 15) {
      return true;
    }

    return false;
  }

  static bool _isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }
}

class ValidationResult {
  final bool isValid;
  final Map<String, String> errors;

  const ValidationResult({required this.isValid, required this.errors});

  String? get firstError {
    if (errors.isEmpty) return null;
    return errors.values.first;
  }

  List<String> get allErrors => errors.values.toList();
}

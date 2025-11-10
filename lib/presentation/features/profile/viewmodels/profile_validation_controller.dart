import 'package:saarflex_app/core/utils/error_handler.dart';

class ProfileValidationController {
  static Map<String, String?> validateChangedFields({
    required String firstName,
    required String email,
    required String phone,
    required String? selectedGender,
    required String? selectedIdType,
    required DateTime? selectedBirthDate,
    required DateTime? selectedExpirationDate,
    required Map<String, dynamic> originalData,
  }) {
    Map<String, String?> errors = {};

    if (firstName.trim() != originalData['nom']) {
      final nameError = ErrorHandler.validateName(firstName);
      if (nameError != null) {
        errors['nom'] = nameError;
      }
    }

    if (email.trim() != originalData['email']) {
      final emailError = ErrorHandler.validateEmail(email);
      if (emailError != null) {
        errors['email'] = emailError;
      }
    }

    if (phone.trim() != originalData['telephone']) {
      final phoneError = ErrorHandler.validatePhone(phone);
      if (phoneError != null) {
        errors['telephone'] = phoneError;
      }
    }

    if (selectedGender != originalData['sexe']) {
      if (selectedGender == null) {
        errors['sexe'] = 'Veuillez sélectionner votre sexe';
      }
    }

    if (selectedIdType != originalData['type_piece_identite']) {
      if (selectedIdType == null) {
        errors['type_piece_identite'] =
            'Veuillez sélectionner le type de pièce';
      }
    }

    if (!_areDatesEqual(selectedBirthDate, originalData['date_naissance'])) {
      if (selectedBirthDate != null) {
        final now = DateTime.now();
        final minAge = DateTime(now.year - 120, now.month, now.day);
        final maxAge = DateTime(now.year - 16, now.month, now.day);

        if (selectedBirthDate.isAfter(maxAge)) {
          errors['date_naissance'] = 'Vous devez avoir au moins 16 ans';
        } else if (selectedBirthDate.isBefore(minAge)) {
          errors['date_naissance'] = 'Date de naissance invalide';
        }
      }
    }

    if (!_areDatesEqual(
      selectedExpirationDate,
      originalData['date_expiration_piece_identite'],
    )) {
      if (selectedExpirationDate != null) {
        final now = DateTime.now();
        if (selectedExpirationDate.isBefore(now)) {
          errors['date_expiration_piece_identite'] =
              'La date d\'expiration ne peut pas être dans le passé';
        }
      }
    }

    return errors;
  }

  static bool _areDatesEqual(DateTime? date1, DateTime? date2) {
    if (date1 == null && date2 == null) return true;
    if (date1 == null || date2 == null) return false;
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}

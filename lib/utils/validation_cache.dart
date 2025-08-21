import 'dart:async';

class ValidationCache {
  static final Map<String, bool> _emailValidationCache = {};
  static final Map<String, List<String>> _passwordValidationCache = {};
  static final Map<String, bool> _nameValidationCache = {};
  static final Map<String, bool> _phoneValidationCache = {};

  static final Map<String, Timer> _debounceTimers = {};

  static String? validateEmailOptimized(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'L\'email est obligatoire';
    }

    final cleanEmail = email.trim().toLowerCase();
    
    if (_emailValidationCache.containsKey(cleanEmail)) {
      return _emailValidationCache[cleanEmail]! ? null : 'Format d\'email invalide';
    }

    bool isValid = _isValidEmailFormat(cleanEmail);
    
    _emailValidationCache[cleanEmail] = isValid;
    
    return isValid ? null : 'Format d\'email invalide (exemple: nom@domaine.com)';
  }

  static List<String> validatePasswordOptimized(String? password) {
    if (password == null || password.isEmpty) {
      return ['Le mot de passe est obligatoire'];
    }

    if (_passwordValidationCache.containsKey(password)) {
      return _passwordValidationCache[password]!;
    }

    List<String> errors = [];

    bool hasLower = false;
    bool hasUpper = false;
    bool hasDigit = false;
    bool hasSpecial = false;

    for (int i = 0; i < password.length; i++) {
      final char = password.codeUnitAt(i);
      
      if (char >= 97 && char <= 122) hasLower = true;     
      else if (char >= 65 && char <= 90) hasUpper = true;   
      else if (char >= 48 && char <= 57) hasDigit = true;   
      else if (_isSpecialChar(char)) hasSpecial = true;
    }

    if (password.length < 8) {
      errors.add('Le mot de passe doit contenir au moins 8 caractères');
    }
    if (!hasLower) {
      errors.add('Le mot de passe doit contenir au moins une minuscule');
    }
    if (!hasUpper) {
      errors.add('Le mot de passe doit contenir au moins une majuscule');
    }
    if (!hasDigit) {
      errors.add('Le mot de passe doit contenir au moins un chiffre');
    }
    if (!hasSpecial) {
      errors.add('Le mot de passe doit contenir un caractère spécial');
    }

    _passwordValidationCache[password] = errors;
    
    return errors;
  }

  static String? validateNameOptimized(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'Le nom est obligatoire';
    }

    final cleanName = name.trim();
    
    if (_nameValidationCache.containsKey(cleanName)) {
      return _nameValidationCache[cleanName]! ? null : 'Nom invalide';
    }

    bool isValid = cleanName.length >= 2 && 
                   cleanName.length <= 50 &&
                   _hasLetter(cleanName);

    _nameValidationCache[cleanName] = isValid;

    if (!isValid) {
      if (cleanName.length < 2) return 'Le nom doit contenir au moins 2 caractères';
      if (cleanName.length > 50) return 'Le nom ne peut pas dépasser 50 caractères';
      return 'Le nom doit contenir au moins une lettre';
    }

    return null;
  }

  static String? validatePhoneOptimized(String? phone) {
    if (phone == null || phone.trim().isEmpty) {
      return 'Le numéro de téléphone est obligatoire';
    }

    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    
    if (_phoneValidationCache.containsKey(cleanPhone)) {
      return _phoneValidationCache[cleanPhone]! ? null : 'Numéro invalide';
    }

    bool isValid = cleanPhone.length >= 10 && 
                   cleanPhone.length <= 15 &&
                   _isNumeric(cleanPhone);

    _phoneValidationCache[cleanPhone] = isValid;

    if (!isValid) {
      if (cleanPhone.length < 10) return 'Le numéro doit contenir au moins 10 chiffres';
      if (cleanPhone.length > 15) return 'Le numéro ne doit pas dépasser 15 chiffres';
      return 'Le numéro ne doit contenir que des chiffres';
    }

    return null;
  }

  static void debounceValidation(String key, Function callback, {Duration delay = const Duration(milliseconds: 300)}) {
    _debounceTimers[key]?.cancel();
    
    _debounceTimers[key] = Timer(delay, () {
      callback();
      _debounceTimers.remove(key);
    });
  }

  static void clearCaches() {
    _emailValidationCache.clear();
    _passwordValidationCache.clear();
    _nameValidationCache.clear();
    _phoneValidationCache.clear();
  }

  static bool _isValidEmailFormat(String email) {
    final atIndex = email.indexOf('@');
    if (atIndex <= 0 || atIndex >= email.length - 1) return false;
    
    final dotIndex = email.lastIndexOf('.');
    if (dotIndex <= atIndex + 1 || dotIndex >= email.length - 1) return false;
    
    return true;
  }

  static bool _isSpecialChar(int charCode) {
    return charCode == 64 || charCode == 36 || charCode == 33 || 
           charCode == 37 || charCode == 42 || charCode == 63 || 
           charCode == 38;
  }

  static bool _hasLetter(String text) {
    for (int i = 0; i < text.length; i++) {
      final char = text.codeUnitAt(i);
      if ((char >= 65 && char <= 90) || (char >= 97 && char <= 122) ||
          (char >= 192 && char <= 255)) { 
        return true;
      }
    }
    return false;
  }

  static bool _isNumeric(String text) {
    for (int i = 0; i < text.length; i++) {
      final char = text.codeUnitAt(i);
      if (char < 48 || char > 57) return false;
    }
    return true;
  }
}
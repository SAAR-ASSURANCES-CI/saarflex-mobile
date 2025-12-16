import 'package:saarciflex_app/data/services/api_service.dart';
import 'package:saarciflex_app/data/models/user_model.dart';

class UserService {
  final ApiService _apiService = ApiService();

  Future<User> getUserProfile() async {
    try {
      final user = await _apiService.getUserProfile();
      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<User> updateProfile(Map<String, dynamic> updates) async {
    try {
      final updatedUser = await _apiService.updateProfile(updates);
      return updatedUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> checkProfileStatus() async {
    try {
      final isComplete = await _apiService.checkProfileStatus();
      return isComplete;
    } catch (e) {
      return false;
    }
  }

  Future<User> updateUserField(String fieldName, dynamic value) async {
    try {
      final updates = {fieldName: value};
      final updatedUser = await _apiService.updateProfile(updates);
      return updatedUser;
    } catch (e) {
      rethrow;
    }
  }

  bool hasRole(User user, TypeUtilisateur role) {
    try {
      final hasRole = user.typeUtilisateur == role;
      return hasRole;
    } catch (e) {
      return false;
    }
  }

  bool canAccess(User user, List<TypeUtilisateur> allowedRoles) {
    try {
      final canAccess = allowedRoles.contains(user.typeUtilisateur);
      return canAccess;
    } catch (e) {
      return false;
    }
  }

  bool hasCompleteIdentityDocuments(User user) {
    try {
      final hasDocuments =
          user.frontDocumentPath != null &&
          user.frontDocumentPath!.isNotEmpty &&
          user.backDocumentPath != null &&
          user.backDocumentPath!.isNotEmpty;
      return hasDocuments;
    } catch (e) {
      return false;
    }
  }

  Future<User> refreshUserData() async {
    try {
      final user = await _apiService.getUserProfile();
      return user;
    } catch (e) {
      rethrow;
    }
  }

  bool validateUserData(Map<String, dynamic> userData) {
    try {
      final requiredFields = ['nom', 'email', 'telephone'];

      for (final field in requiredFields) {
        if (userData[field] == null ||
            userData[field].toString().trim().isEmpty) {
          return false;
        }
      }

      final email = userData['email']?.toString() ?? '';
      if (!_isValidEmail(email)) {
        return false;
      }

      final telephone = userData['telephone']?.toString() ?? '';
      if (!_isValidPhone(telephone)) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    return cleanPhone.length >= 8 && cleanPhone.length <= 15;
  }
}

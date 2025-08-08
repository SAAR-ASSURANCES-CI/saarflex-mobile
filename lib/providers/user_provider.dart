import 'package:flutter/material.dart';
import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadUserData() async {
    if (_user != null) return;

    _isLoading = true;
    notifyListeners();

    try {
   
      await Future.delayed(const Duration(seconds: 1));
      _user = User(
        id: 'user-123',
        name: 'Jean KOUAME',
        email: 'jean.kouame@email.com',
        phone: '+2250701234567',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des données utilisateur';
      debugPrint('Error loading user data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    if (_user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
     
      await Future.delayed(const Duration(seconds: 1));
      _user = _user!.copyWith(
        name: updates['name'] ?? _user!.name,
        email: updates['email'] ?? _user!.email,
        phone: updates['phone'] ?? _user!.phone,
        updatedAt: DateTime.now(),
      );
      
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Erreur lors de la mise à jour du profil';
      debugPrint('Error updating user profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearUserData() {
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }
}
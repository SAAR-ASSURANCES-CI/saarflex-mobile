import 'package:flutter/material.dart';
import 'package:saarflex_app/data/models/user_model.dart';
import 'package:saarflex_app/data/repositories/profile_repository.dart';
import 'package:saarflex_app/data/services/file_upload_service.dart';
import 'package:saarflex_app/core/utils/error_handler.dart';


class ProfileViewModel with ChangeNotifier {

  final ProfileRepository _profileRepository = ProfileRepository();
  final FileUploadService _fileUploadService = FileUploadService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;


  Future<User?> refreshUserProfile() async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _profileRepository.getUserProfile();
      _setLoading(false);
      return user;
    } catch (e) {
      _setError(ErrorHandler.handleProfileError(e));
      _setLoading(false);
      return null;
    }
  }


  Future<bool> updateSpecificField(String field, dynamic value) async {
    _setLoading(true);
    _clearError();

    try {
      await _profileRepository.updateProfileField(field, value);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(ErrorHandler.handleProfileError(e));
      _setLoading(false);
      return false;
    }
  }


  Future<bool> uploadAvatar(String imagePath) async {
    _setLoading(true);
    _clearError();

    try {
      await _fileUploadService.uploadAvatar(imagePath);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(ErrorHandler.handleUploadError(e));
      _setLoading(false);
      return false;
    }
  }


  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    _setLoading(true);
    _clearError();

    try {
      await _profileRepository.updateProfile(profileData);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(ErrorHandler.handleProfileError(e));
      _setLoading(false);
      return false;
    }
  }


  Future<bool> uploadIdentityDocument(
    String imagePath,
    String documentType,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      await _fileUploadService.uploadIdentityDocumentFromPath(
        imagePath,
        documentType,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(ErrorHandler.handleUploadError(e));
      _setLoading(false);
      return false;
    }
  }


  Map<String, String> validateProfileData(Map<String, dynamic> data) {
    return _profileRepository.validateProfileData(data);
  }


  bool isProfileComplete(User user) {
    return _profileRepository.isProfileComplete(user);
  }


  void clearUserData() {
    _clearError();
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

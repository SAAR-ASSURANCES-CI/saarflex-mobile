import 'package:saarciflex_app/data/models/user_model.dart';
import 'package:saarciflex_app/data/services/user_service.dart';
import 'package:saarciflex_app/data/services/profile_service.dart';
import 'package:saarciflex_app/data/services/file_upload_service.dart';
import 'package:saarciflex_app/core/utils/storage_helper.dart';

class ProfileRepository {
  final UserService _userService;
  final ProfileService _profileService;
  final FileUploadService _fileUploadService;

  ProfileRepository({
    UserService? userService,
    ProfileService? profileService,
    FileUploadService? fileUploadService,
  })  : _userService = userService ?? UserService(),
        _profileService = profileService ?? ProfileService(),
        _fileUploadService = fileUploadService ?? FileUploadService();

  Future<User> getUserProfile() async {
    try {
      return await _userService.getUserProfile();
    } catch (e) {
      rethrow;
    }
  }

  Future<User> updateProfileField(String field, dynamic value) async {
    try {
      return await _userService.updateUserField(field, value);
    } catch (e) {
      rethrow;
    }
  }

  Future<User> updateProfile(Map<String, dynamic> profileData) async {
    try {
      return await _userService.updateProfile(profileData);
    } catch (e) {
      rethrow;
    }
  }

  Map<String, String> validateProfileData(Map<String, dynamic> data) {
    return _profileService.validateProfileData(data);
  }

  bool isProfileComplete(User user) {
    return _profileService.isProfileComplete(user);
  }

  Future<Map<String, String>> uploadIdentityImages({
    required String rectoPath,
    required String versoPath,
  }) async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) {
        throw Exception('Token d\'authentification manquant');
      }

      return await _fileUploadService.uploadBothImages(
        rectoPath: rectoPath,
        versoPath: versoPath,
        authToken: token,
      );
    } catch (e) {
      rethrow;
    }
  }
}


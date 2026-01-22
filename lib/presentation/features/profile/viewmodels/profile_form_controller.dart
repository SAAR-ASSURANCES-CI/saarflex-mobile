import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:saarciflex_app/presentation/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:saarciflex_app/presentation/features/profile/viewmodels/profile_validation_controller.dart';
import 'package:saarciflex_app/data/services/file_upload_service.dart';
import 'package:saarciflex_app/data/repositories/profile_repository.dart';
import 'package:saarciflex_app/core/utils/error_handler.dart';


class ProfileFormController extends ChangeNotifier {
  final FileUploadService _fileUploadService = FileUploadService();
  final ProfileRepository _profileRepository = ProfileRepository();

  final _firstNameController = TextEditingController();
  final _birthPlaceController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _professionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _idNumberController = TextEditingController();

  String? _selectedGender;
  String? _selectedIdType;
  DateTime? _selectedBirthDate;
  DateTime? _selectedExpirationDate;

  XFile? _rectoImage;
  XFile? _versoImage;
  String? _rectoImagePath;
  String? _versoImagePath;
  bool _isUploadingRecto = false;
  bool _isUploadingVerso = false;
  
  XFile? _avatarImage;
  String? _avatarImagePath;
  bool _isUploadingAvatar = false;

  bool _isLoading = false;
  bool _hasChanges = false;
  Map<String, dynamic> _originalData = {};
  Map<String, String?> _fieldErrors = {};

  final List<String> _genderOptions = ['Masculin', 'Féminin'];
  final List<String> _idTypeOptions = [
    'Carte Nationale d\'Identité',
    'Passeport',
  ];

  TextEditingController get firstNameController => _firstNameController;
  TextEditingController get birthPlaceController => _birthPlaceController;
  TextEditingController get nationalityController => _nationalityController;
  TextEditingController get professionController => _professionController;
  TextEditingController get phoneController => _phoneController;
  TextEditingController get emailController => _emailController;
  TextEditingController get addressController => _addressController;
  TextEditingController get idNumberController => _idNumberController;

  String? get selectedGender => _selectedGender;
  String? get selectedIdType => _selectedIdType;
  DateTime? get selectedBirthDate => _selectedBirthDate;
  DateTime? get selectedExpirationDate => _selectedExpirationDate;

  XFile? get rectoImage => _rectoImage;
  XFile? get versoImage => _versoImage;
  String? get rectoImagePath => _rectoImagePath;
  String? get versoImagePath => _versoImagePath;
  bool get isUploadingRecto => _isUploadingRecto;
  bool get isUploadingVerso => _isUploadingVerso;
  
  XFile? get avatarImage => _avatarImage;
  String? get avatarImagePath => _avatarImagePath;
  bool get isUploadingAvatar => _isUploadingAvatar;

  bool get isLoading => _isLoading;
  bool get hasChanges => _hasChanges;
  Map<String, String?> get fieldErrors => _fieldErrors;

  List<String> get genderOptions => _genderOptions;
  List<String> get idTypeOptions => _idTypeOptions;
  Map<String, dynamic> get originalData => _originalData;

  ProfileFormController() {
    _addListeners();
  }

  void _addListeners() {
    _firstNameController.addListener(_checkForChanges);
    _birthPlaceController.addListener(_checkForChanges);
    _nationalityController.addListener(_checkForChanges);
    _professionController.addListener(_checkForChanges);
    _phoneController.addListener(_checkForChanges);
    _emailController.addListener(_checkForChanges);
    _addressController.addListener(_checkForChanges);
    _idNumberController.addListener(_checkForChanges);
  }

  void _checkForChanges() {
    final currentData = {
      'nom': _firstNameController.text.trim(),
      'email': _emailController.text.trim(),
      'telephone': _phoneController.text.trim(),
      'lieu_naissance': _birthPlaceController.text.trim(),
      'nationalite': _nationalityController.text.trim(),
      'profession': _professionController.text.trim(),
      'adresse': _addressController.text.trim(),
      'numero_piece_identite': _idNumberController.text.trim(),
      'sexe': _selectedGender,
      'type_piece_identite': _selectedIdType,
      'date_naissance': _selectedBirthDate,
      'date_expiration_piece_identite': _selectedExpirationDate,
    };

    bool hasChanged = false;

    for (String key in currentData.keys) {
      if (key == 'date_naissance' || key == 'date_expiration_piece_identite') {
        if (!_areDatesEqual(
          currentData[key] as DateTime?,
          _originalData[key] as DateTime?,
        )) {
          hasChanged = true;
          break;
        }
      } else if (currentData[key] != _originalData[key]) {
        hasChanged = true;
        break;
      }
    }

    final hasNewRecto = _rectoImage != null;
    final hasNewVerso = _versoImage != null;
    final hasNewAvatar = _avatarImage != null;

    if (!hasChanged && (hasNewRecto || hasNewVerso || hasNewAvatar)) {
      hasChanged = true;
    }

    if (_hasChanges != hasChanged) {
      _hasChanges = hasChanged;
      _fieldErrors.clear();
    }

    notifyListeners();
  }

  bool _areDatesEqual(DateTime? date1, DateTime? date2) {
    if (date1 == null && date2 == null) return true;
    if (date1 == null || date2 == null) return false;
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void loadUserData(BuildContext context) {
    final authProvider = context.read<AuthViewModel>();
    final user = authProvider.currentUser;

    if (user != null) {
      _firstNameController.text = user.nom;
      _emailController.text = user.email;
      _phoneController.text = user.telephone ?? '';
      _birthPlaceController.text = user.birthPlace ?? '';
      _nationalityController.text = user.nationality ?? '';
      _professionController.text = user.profession ?? '';
      _addressController.text = user.address ?? '';
      _idNumberController.text = user.identityNumber ?? '';

      _selectedBirthDate = user.birthDate;
      _selectedExpirationDate = user.identityExpirationDate;

      if (user.gender != null && user.gender!.isNotEmpty) {
        _selectedGender = user.gender == 'masculin' ? 'Masculin' : 'Féminin';
      }

      if (user.identityType != null && user.identityType!.isNotEmpty) {
        _selectedIdType = _getTypePieceIdentiteLabel(user.identityType!);
      } else {
        _selectedIdType = null;
      }

      _originalData = {
        'nom': user.nom,
        'email': user.email,
        'telephone': user.telephone ?? '',
        'lieu_naissance': user.birthPlace ?? '',
        'nationalite': user.nationality ?? '',
        'profession': user.profession ?? '',
        'adresse': user.address ?? '',
        'numero_piece_identite': user.identityNumber ?? '',
        'sexe': _selectedGender,
        'type_piece_identite': _selectedIdType,
        'date_naissance': user.birthDate,
        'date_expiration_piece_identite': user.identityExpirationDate,
      };

      _checkForChanges();
    }
  }

  String _getTypePieceIdentiteLabel(String type) {
    switch (type.toLowerCase()) {
      case 'cni':
        return 'Carte Nationale d\'Identité';
      case 'passport':
        return 'Passeport';
      default:
        return 'Carte Nationale d\'Identité';
    }
  }

  void updateGender(String? value) {
    _selectedGender = value;
    _checkForChanges();
  }

  void updateIdType(String? value) {
    _selectedIdType = value;
    _checkForChanges();
  }

  void updateBirthDate(DateTime? date) {
    _selectedBirthDate = date;
    _checkForChanges();
  }

  void updateExpirationDate(DateTime? date) {
    _selectedExpirationDate = date;
    _checkForChanges();
  }

  void checkForChanges() {
    _checkForChanges();
  }


  Future<void> pickImage(bool isRecto, BuildContext context) async {
    try {
      final imagePicker = ImagePicker();
      final image = await imagePicker.pickImage(source: ImageSource.gallery);

      if (image != null) {

        await _fileUploadService.validateXFile(image);

        if (isRecto) {
          _rectoImage = image;
          _rectoImagePath = image.path;
          _isUploadingRecto = true;
        } else {
          _versoImage = image;
          _versoImagePath = image.path;
          _isUploadingVerso = true;
        }
        notifyListeners();

        await _uploadImage(image.path, isRecto, context);
      }
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.showErrorSnackBar(
          context,
          ErrorHandler.handleUploadError(e),
        );
      }
    }
  }

  Future<void> pickAvatar(BuildContext context, ImageSource source) async {
    try {
      final imagePicker = ImagePicker();
      final image = await imagePicker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 95,
      );

      if (image != null) {
        await _fileUploadService.validateXFile(image);
        
        _avatarImage = image;
        _avatarImagePath = image.path;
        _isUploadingAvatar = true;
        notifyListeners();

        await _uploadAvatar(context);
      }
    } catch (e) {
      ErrorHandler.showErrorSnackBar(
        context,
        ErrorHandler.handleUploadError(e),
      );
      _isUploadingAvatar = false;
      notifyListeners();
    }
  }

  Future<void> _uploadAvatar(BuildContext context) async {
    try {
      if (_avatarImagePath == null) return;

      final authProvider = context.read<AuthViewModel>();
      
      await _fileUploadService.uploadAvatar(_avatarImagePath!);
      authProvider.markAvatarUploaded();
      await authProvider.loadUserProfile();
      authProvider.forceAvatarRefresh();
      await Future.delayed(const Duration(milliseconds: 100));
      
      notifyListeners();

      if (context.mounted) {
        ErrorHandler.showSuccessSnackBar(
          context,
          'Photo de profil mise à jour avec succès.',
        );
      }
      
      _checkForChanges();
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.showErrorSnackBar(
          context,
          ErrorHandler.handleUploadError(e),
        );
      }
    } finally {
      _isUploadingAvatar = false;
      notifyListeners();
    }
  }

  Future<void> deleteAvatar(BuildContext context) async {
    try {
      final authProvider = context.read<AuthViewModel>();
      await authProvider.loadUserProfile();

      _avatarImage = null;
      _avatarImagePath = null;
      _checkForChanges();
      
      if (context.mounted) {
        ErrorHandler.showSuccessSnackBar(
          context,
          'Photo de profil supprimée.',
        );
      }
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.showErrorSnackBar(
          context,
          ErrorHandler.handleProfileError(e),
        );
      }
    }
  }


  Future<void> _uploadImage(
    String imagePath,
    bool isRecto,
    BuildContext context,
  ) async {
    try {
      if (_rectoImage != null && _versoImage != null) {
        await _uploadBothImages(context);
      } else {

        if (context.mounted) {
          final message = isRecto
              ? 'Veuillez maintenant sélectionner l\'image verso'
              : 'Veuillez maintenant sélectionner l\'image recto';
          ErrorHandler.showSuccessSnackBar(context, message);
        }
      }
      _checkForChanges();
    } catch (e) {
      ErrorHandler.showErrorSnackBar(
        context,
        ErrorHandler.handleUploadError(e),
      );
    } finally {
      if (isRecto) {
        _isUploadingRecto = false;
      } else {
        _isUploadingVerso = false;
      }
      notifyListeners();
    }
  }


  Future<void> _uploadBothImages(BuildContext context) async {
    if (_rectoImage == null || _versoImage == null) {
      ErrorHandler.showErrorSnackBar(
        context,
        'Veuillez sélectionner les deux images avant l\'upload',
      );
      return;
    }

    try {
      _isUploadingRecto = true;
      _isUploadingVerso = true;
      notifyListeners();

      final result = await _profileRepository.uploadIdentityImages(
        rectoPath: _rectoImagePath!,
        versoPath: _versoImagePath!,
      );

      final authProvider = context.read<AuthViewModel>();
      authProvider.updateUserField('frontDocumentPath', result['recto_path']);
      authProvider.updateUserField('backDocumentPath', result['verso_path']);

      if (context.mounted) {
        ErrorHandler.showSuccessSnackBar(
          context,
          'Images uploadées avec succès !',
        );
      }
      _checkForChanges();
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.showErrorSnackBar(
          context,
          ErrorHandler.handleUploadError(e),
        );
      }
    } finally {
      _isUploadingRecto = false;
      _isUploadingVerso = false;
      notifyListeners();
    }
  }

  Map<String, String?> validateChangedFields() {
    return ProfileValidationController.validateChangedFields(
      firstName: _firstNameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      selectedGender: _selectedGender,
      selectedIdType: _selectedIdType,
      selectedBirthDate: _selectedBirthDate,
      selectedExpirationDate: _selectedExpirationDate,
      originalData: _originalData,
    );
  }

  Future<void> saveProfile(BuildContext context) async {
    _isLoading = true;
    _fieldErrors.clear();
    notifyListeners();

    try {
      final errors = validateChangedFields();

      if (errors.isNotEmpty) {
        _fieldErrors = errors;
        _isLoading = false;
        notifyListeners();
        if (context.mounted) {
          ErrorHandler.showErrorSnackBar(
            context,
            'Veuillez corriger les erreurs ci-dessus',
          );
        }
        return;
      }

      final authProvider = context.read<AuthViewModel>();
      final Map<String, dynamic> profileData = {};

      if (_firstNameController.text.trim() != _originalData['nom']) {
        profileData['nom'] = _firstNameController.text.trim();
      }

      if (_emailController.text.trim() != _originalData['email']) {
        profileData['email'] = _emailController.text.trim();
      }

      if (_phoneController.text.trim() != _originalData['telephone']) {
        profileData['telephone'] = _phoneController.text.trim();
      }

      if (_birthPlaceController.text.trim() !=
          _originalData['lieu_naissance']) {
        profileData['lieu_naissance'] = _birthPlaceController.text.trim();
      }

      if (_nationalityController.text.trim() != _originalData['nationalite']) {
        profileData['nationalite'] = _nationalityController.text.trim();
      }

      if (_professionController.text.trim() != _originalData['profession']) {
        profileData['profession'] = _professionController.text.trim();
      }

      if (_addressController.text.trim() != _originalData['adresse']) {
        profileData['adresse'] = _addressController.text.trim();
      }

      if (_idNumberController.text.trim() !=
          _originalData['numero_piece_identite']) {
        profileData['numero_piece_identite'] = _idNumberController.text.trim();
      }

      if (_selectedGender != _originalData['sexe']) {
        String backendGender = '';
        if (_selectedGender == 'Masculin') {
          backendGender = 'masculin';
        } else if (_selectedGender == 'Féminin') {
          backendGender = 'feminin';
        }

        if (backendGender.isNotEmpty) {
          profileData['sexe'] = backendGender;
        } else if (_selectedGender == null) {
          profileData['sexe'] = null;
        }
      }

      if (_selectedIdType != _originalData['type_piece_identite']) {
        String backendIdType = '';
        if (_selectedIdType == 'Carte Nationale d\'Identité') {
          backendIdType = 'cni';
        } else if (_selectedIdType == 'Passeport') {
          backendIdType = 'passport';
        }

        if (backendIdType.isNotEmpty) {
          profileData['type_piece_identite'] = backendIdType;
        }
      }

      if (!_areDatesEqual(
        _selectedBirthDate,
        _originalData['date_naissance'],
      )) {
        if (_selectedBirthDate != null) {
          profileData['date_naissance'] = _formatDate(_selectedBirthDate!);
        } else {
          profileData['date_naissance'] = null;
        }
      }

      if (!_areDatesEqual(
        _selectedExpirationDate,
        _originalData['date_expiration_piece_identite'],
      )) {
        if (_selectedExpirationDate != null) {
          profileData['date_expiration_piece_identite'] = _formatDate(
            _selectedExpirationDate!,
          );
        } else {
          profileData['date_expiration_piece_identite'] = null;
        }
      }

      final hasUploadedImages = _rectoImage != null || _versoImage != null || _avatarImage != null;
      
      if (profileData.isNotEmpty) {
        final success = await authProvider.updateProfile(profileData);
        if (!success) {
          throw Exception('Échec de la mise à jour du profil');
        }
      } else if (hasUploadedImages) {
      } else {
        _hasChanges = false;
        _isLoading = false;
        notifyListeners();
        return;
      }

      await authProvider.loadUserProfile();
      
      if (context.mounted) {
        loadUserData(context);
        ErrorHandler.showSuccessSnackBar(
          context,
          'Profil mis à jour avec succès !',
        );
      }

      _hasChanges = false;
      _rectoImage = null;
      _versoImage = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.showErrorSnackBar(
          context,
          'Erreur lors de la sauvegarde: ${e.toString()}',
        );
      }
      _isLoading = false;
      notifyListeners();
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
  }

  String? getBackendIdentityType(String? selectedIdType) {
    if (selectedIdType == null) return null;

    switch (selectedIdType) {
      case 'Carte Nationale d\'Identité':
        return 'carte_identite';
      case 'Passeport':
        return 'passeport';
      default:
        return null;
    }
  }

  @override
  void dispose() {
    _firstNameController.removeListener(_checkForChanges);
    _birthPlaceController.removeListener(_checkForChanges);
    _nationalityController.removeListener(_checkForChanges);
    _professionController.removeListener(_checkForChanges);
    _phoneController.removeListener(_checkForChanges);
    _emailController.removeListener(_checkForChanges);
    _addressController.removeListener(_checkForChanges);
    _idNumberController.removeListener(_checkForChanges);

    _firstNameController.dispose();
    _birthPlaceController.dispose();
    _nationalityController.dispose();
    _professionController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _idNumberController.dispose();
    super.dispose();
  }
}

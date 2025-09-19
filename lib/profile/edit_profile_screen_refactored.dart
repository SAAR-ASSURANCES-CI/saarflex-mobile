import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../models/product_model.dart';
import '../providers/auth_provider.dart';
import '../screens/simulation/simulation_screen.dart';
import '../widgets/profile/personal_info_section.dart';
import '../widgets/profile/identity_section.dart';
import '../widgets/profile/document_upload_section.dart';

class EditProfileScreenRefactored extends StatefulWidget {
  final VoidCallback? onProfileCompleted;
  final Product? produit;

  const EditProfileScreenRefactored({
    super.key,
    this.onProfileCompleted,
    this.produit,
  });

  @override
  State<EditProfileScreenRefactored> createState() =>
      _EditProfileScreenRefactoredState();
}

class _EditProfileScreenRefactoredState
    extends State<EditProfileScreenRefactored> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _firstNameController = TextEditingController();
  final _birthPlaceController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _professionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _idNumberController = TextEditingController();

  // State variables
  String? _selectedGender;
  String? _selectedIdType;
  DateTime? _selectedBirthDate;
  DateTime? _selectedExpirationDate;
  XFile? _rectoImage;
  XFile? _versoImage;
  bool _isUploadingRecto = false;
  bool _isUploadingVerso = false;
  bool _isLoading = false;
  bool _hasChanges = false;
  Map<String, dynamic> _originalData = {};
  Map<String, String?> _fieldErrors = {};

  // Constants
  final List<String> _genderOptions = ['Masculin', 'Féminin'];
  final List<String> _idTypeOptions = [
    'Carte Nationale d\'Identité',
    'Passeport',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
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
    final currentData = _getCurrentFormData();
    bool hasChanged = _hasDataChanged(currentData);

    if (_hasChanges != hasChanged) {
      setState(() {
        _hasChanges = hasChanged;
      });
    }
  }

  Map<String, dynamic> _getCurrentFormData() {
    return {
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
  }

  bool _hasDataChanged(Map<String, dynamic> currentData) {
    for (String key in currentData.keys) {
      if (key == 'date_naissance' || key == 'date_expiration_piece_identite') {
        if (!_areDatesEqual(
          currentData[key] as DateTime?,
          _originalData[key] as DateTime?,
        )) {
          return true;
        }
      } else if (currentData[key] != _originalData[key]) {
        return true;
      }
    }
    return false;
  }

  bool _areDatesEqual(DateTime? date1, DateTime? date2) {
    if (date1 == null && date2 == null) return true;
    if (date1 == null || date2 == null) return false;
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Future<void> _loadUserData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user != null) {
      _populateFormWithUserData(user);
      _setOriginalData(user);
    }
  }

  void _populateFormWithUserData(user) {
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
  }

  void _setOriginalData(user) {
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
  }

  String _getTypePieceIdentiteLabel(String type) {
    switch (type.toLowerCase()) {
      case 'carte_nationale':
      case 'cni':
        return 'Carte Nationale d\'Identité';
      case 'passeport':
        return 'Passeport';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return _buildBody(authProvider);
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.primary),
        onPressed: () => _handleBackNavigation(),
      ),
      title: Text(
        "Modifier le profil",
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      actions: [
        if (_hasChanges)
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  )
                : Text(
                    "Sauvegarder",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
          ),
      ],
    );
  }

  Widget _buildBody(AuthProvider authProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildPersonalInfoSection(),
            const SizedBox(height: 20),
            _buildIdentitySection(),
            const SizedBox(height: 20),
            _buildDocumentUploadSection(authProvider),
            const SizedBox(height: 32),
            _buildActionButtons(authProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return PersonalInfoSection(
      firstNameController: _firstNameController,
      emailController: _emailController,
      phoneController: _phoneController,
      birthPlaceController: _birthPlaceController,
      nationalityController: _nationalityController,
      professionController: _professionController,
      addressController: _addressController,
      selectedGender: _selectedGender,
      selectedBirthDate: _selectedBirthDate,
      genderOptions: _genderOptions,
      fieldErrors: _fieldErrors,
      onGenderChanged: (gender) {
        setState(() {
          _selectedGender = gender;
        });
        _checkForChanges();
      },
      onBirthDateChanged: (date) {
        setState(() {
          _selectedBirthDate = date;
        });
        _checkForChanges();
      },
    );
  }

  Widget _buildIdentitySection() {
    return IdentitySection(
      idNumberController: _idNumberController,
      selectedIdType: _selectedIdType,
      selectedExpirationDate: _selectedExpirationDate,
      idTypeOptions: _idTypeOptions,
      fieldErrors: _fieldErrors,
      onIdTypeChanged: (type) {
        setState(() {
          _selectedIdType = type;
        });
        _checkForChanges();
      },
      onExpirationDateChanged: (date) {
        setState(() {
          _selectedExpirationDate = date;
        });
        _checkForChanges();
      },
    );
  }

  String? _getBackendIdentityType(String? selectedIdType) {
    if (selectedIdType == null) return null;

    // Convertir le label affiché en type backend
    switch (selectedIdType) {
      case 'Carte Nationale d\'Identité':
        return 'carte_identite';
      case 'Passeport':
        return 'passeport';
      default:
        return null;
    }
  }

  Widget _buildDocumentUploadSection(AuthProvider authProvider) {
    // Convertir _selectedIdType en type backend pour la réactivité
    final currentIdentityType = _getBackendIdentityType(_selectedIdType);

    return DocumentUploadSection(
      user: authProvider.currentUser,
      rectoImage: _rectoImage,
      versoImage: _versoImage,
      isUploadingRecto: _isUploadingRecto,
      isUploadingVerso: _isUploadingVerso,
      onImagePicked: (isRecto) => _pickImage(isRecto),
      onImageDeleted: (isRecto) => _deleteImage(isRecto),
      identityType: currentIdentityType, // Nouveau paramètre pour la réactivité
    );
  }

  Widget _buildActionButtons(AuthProvider authProvider) {
    return Column(
      children: [
        if (widget.produit != null) ...[
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : () => _navigateToSimulation(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                "Continuer vers la simulation",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => _handleBackNavigation(),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "Annuler",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage(bool isRecto) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        if (isRecto) {
          _rectoImage = image;
        } else {
          _versoImage = image;
        }
      });
      _checkForChanges();
    }
  }

  void _deleteImage(bool isRecto) {
    setState(() {
      if (isRecto) {
        _rectoImage = null;
      } else {
        _versoImage = null;
      }
    });
    _checkForChanges();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final updates = _getCurrentFormData();

      // Remove null values
      updates.removeWhere((key, value) => value == null || value == '');

      final success = await authProvider.updateProfile(updates);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Profil mis à jour avec succès',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: AppColors.success,
          ),
        );

        if (widget.onProfileCompleted != null) {
          widget.onProfileCompleted!();
        }

        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erreur lors de la mise à jour',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToSimulation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SimulationScreen(
          produit: widget.produit!,
          assureEstSouscripteur: true,
        ),
      ),
    );
  }

  void _handleBackNavigation() {
    if (_hasChanges) {
      _showUnsavedChangesDialog();
    } else {
      Navigator.pop(context);
    }
  }

  void _showUnsavedChangesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Modifications non sauvegardées',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Vous avez des modifications non sauvegardées. Voulez-vous vraiment quitter ?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: GoogleFonts.poppins(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close screen
            },
            child: Text(
              'Quitter',
              style: GoogleFonts.poppins(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
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

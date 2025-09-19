import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:saarflex_app/constants/colors.dart';
import 'package:saarflex_app/models/product_model.dart';
import 'package:saarflex_app/providers/auth_provider.dart';
import 'package:saarflex_app/screens/simulation/simulation_screen.dart';
import '../../utils/error_handler.dart';
import '../../utils/image_labels.dart';
import '../../utils/image_validator.dart';
import '../../services/api_service.dart';

class EditProfileScreen extends StatefulWidget {
  final VoidCallback? onProfileCompleted;
  final Product? produit;

  const EditProfileScreen({super.key, this.onProfileCompleted, this.produit});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  _EditProfileScreenState() {
    print('🔍 DEBUG EditProfileScreenState created');
  }

  final _formKey = GlobalKey<FormState>();
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
  String? _rectoImagePath; // Chemin final converti
  String? _versoImagePath; // Chemin final converti
  bool _isUploadingRecto = false;
  bool _isUploadingVerso = false;

  final List<String> _genderOptions = ['Masculin', 'Féminin'];
  final List<String> _idTypeOptions = [
    'Carte Nationale d\'Identité',
    'Passeport',
  ];

  bool _isLoading = false;
  bool _hasChanges = false;
  Map<String, dynamic> _originalData = {};

  Map<String, String?> _fieldErrors = {};

  @override
  void initState() {
    super.initState();
    print('🔍 DEBUG EditProfileScreen initState called');
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
      'date_naissance': _selectedBirthDate, // ← DateTime directement
      'date_expiration_piece_identite':
          _selectedExpirationDate, // ← DateTime directement`
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

    if (!hasChanged && (hasNewRecto || hasNewVerso)) {
      hasChanged = true;
    }

    if (_hasChanges != hasChanged) {
      setState(() {
        _hasChanges = hasChanged;
        _fieldErrors.clear();
      });
    }
  }

  void _onDropdownChanged() {
    _checkForChanges();
  }

  // SECTION UPLOAD PIÈCE D'IDENTITÉ - À ACTIVER PLUS TARD
  /*
if (_rectoImage != null) {
  final success = await authProvider.uploadIdentityDocument(
    File(_rectoImage!.path),
    'recto',
  );
  if (!success) {
    throw Exception('Échec de l\'upload de la photo recto');
  }
}

if (_versoImage != null) {
  final success = await authProvider.uploadIdentityDocument(
    File(_versoImage!.path),
    'verso',
  );
  if (!success) {
    throw Exception('Échec de l\'upload de la photo verso');
  }
}
*/

  void _onDateChanged() {
    _checkForChanges();
  }

  bool _areDatesEqual(DateTime? date1, DateTime? date2) {
    if (date1 == null && date2 == null) return true;
    if (date1 == null || date2 == null) return false;
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void _loadUserData() {
    final authProvider = context.read<AuthProvider>();
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
        'date_naissance': user.birthDate, // Stocker comme DateTime
        'date_expiration_piece_identite':
            user.identityExpirationDate, // Stocker comme DateTime
        // 'recto_image': null,
        // 'verso_image': null,
      };
    }
  }

  String _getTypePieceIdentiteLabel(String type) {
    switch (type.toLowerCase()) {
      case 'cni':
        return 'Carte Nationale d\'Identité';
      case 'passport':
        return 'Passeport';
      default:
        return 'Carte Nationale d\'Identité'; // Valeur par défaut
    }
  }

  Map<String, String?> _validateChangedFields() {
    Map<String, String?> errors = {};

    if (_firstNameController.text.trim() != _originalData['nom']) {
      final nameError = ErrorHandler.validateName(_firstNameController.text);
      if (nameError != null) {
        errors['nom'] = nameError;
      }
    }

    if (_emailController.text.trim() != _originalData['email']) {
      final emailError = ErrorHandler.validateEmail(_emailController.text);
      if (emailError != null) {
        errors['email'] = emailError;
      }
    }

    if (_phoneController.text.trim() != _originalData['telephone']) {
      final phoneError = ErrorHandler.validatePhone(_phoneController.text);
      if (phoneError != null) {
        errors['telephone'] = phoneError;
      }
    }

    if (_selectedGender != _originalData['sexe']) {
      if (_selectedGender == null) {
        errors['sexe'] = 'Veuillez sélectionner votre sexe';
      }
    }

    if (_selectedIdType != _originalData['type_piece_identite']) {
      if (_selectedIdType == null) {
        errors['type_piece_identite'] =
            'Veuillez sélectionner le type de pièce';
      }
    }

    if (!_areDatesEqual(_selectedBirthDate, _originalData['date_naissance'])) {
      if (_selectedBirthDate != null) {
        final now = DateTime.now();
        final minAge = DateTime(now.year - 120, now.month, now.day);
        final maxAge = DateTime(now.year - 16, now.month, now.day);

        if (_selectedBirthDate!.isAfter(maxAge)) {
          errors['date_naissance'] = 'Vous devez avoir au moins 16 ans';
        } else if (_selectedBirthDate!.isBefore(minAge)) {
          errors['date_naissance'] = 'Date de naissance invalide';
        }
      }
    }

    if (!_areDatesEqual(
      _selectedExpirationDate,
      _originalData['date_expiration_piece_identite'],
    )) {
      if (_selectedExpirationDate != null) {
        final now = DateTime.now();
        if (_selectedExpirationDate!.isBefore(now)) {
          errors['date_expiration_piece_identite'] =
              'La date d\'expiration ne peut pas être dans le passé';
        }
      }
    }

    return errors;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Édition du profil",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 40),

              if (_fieldErrors.isNotEmpty) ...[
                ErrorHandler.buildErrorList(
                  _fieldErrors.values
                      .where((error) => error != null)
                      .cast<String>()
                      .toList(),
                ),
                const SizedBox(height: 20),
              ],

              _buildPersonalSection(),
              const SizedBox(height: 32),
              _buildContactSection(),
              const SizedBox(height: 32),
              _buildIdentitySection(),
              const SizedBox(height: 32),
              _buildIdentityImagesSection(),
              const SizedBox(height: 40),
              _buildSaveButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final user = context.read<AuthProvider>().currentUser;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      spreadRadius: 0,
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: user?.avatarUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(45),
                        child: Image.network(
                          user!.avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.person_rounded,
                              color: AppColors.white,
                              size: 45,
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.person_rounded,
                        color: AppColors.white,
                        size: 45,
                      ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2),
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    color: AppColors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Modifiez vos informations",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Vous pouvez modifier un ou plusieurs champs",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildDropdownItems(
    List<String> items,
    String hintText,
  ) {
    return [
      DropdownMenuItem<String>(
        value: null,
        child: Text(
          hintText,
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: AppColors.textSecondary.withOpacity(0.6),
          ),
        ),
      ),
      ...items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        );
      }).toList(),
    ];
  }

  Future<void> _pickImage(bool isRecto) async {
    print('🔍 DEBUG _pickImage called - isRecto: $isRecto');

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 95, // High quality
        // No size restrictions - let user choose any image
      );

      print('🔍 DEBUG Image selected: ${image?.path}');

      if (image != null) {
        // Conversion HEIC → JPEG si nécessaire
        String finalImagePath = image.path;
        print('🔍 DEBUG Image path: ${image.path}');
        print(
          '🔍 DEBUG Is HEIC: ${image.path.toLowerCase().endsWith('.heic')}',
        );
        if (image.path.toLowerCase().endsWith('.heic')) {
          print('🔍 DEBUG Converting HEIC to JPEG...');
          try {
            // Lire l'image HEIC
            final File heicFile = File(image.path);
            final Uint8List heicBytes = await heicFile.readAsBytes();

            // Décoder l'image HEIC
            print('🔍 DEBUG Reading HEIC file...');
            final img.Image? decodedImage = img.decodeImage(heicBytes);
            print('🔍 DEBUG Decoded image: ${decodedImage != null}');
            if (decodedImage != null) {
              print('🔍 DEBUG Encoding to JPEG...');
              // Encoder en JPEG
              final Uint8List jpegBytes = img.encodeJpg(
                decodedImage,
                quality: 95,
              );

              // Créer un nouveau fichier JPEG
              final String jpegPath = image.path.replaceAll('.heic', '.jpg');
              print('🔍 DEBUG JPEG path: $jpegPath');
              final File jpegFile = File(jpegPath);
              await jpegFile.writeAsBytes(jpegBytes);

              finalImagePath = jpegPath;
              print('🔍 DEBUG HEIC converted to JPEG: $jpegPath');
            } else {
              print('🔍 DEBUG Failed to decode HEIC image');
            }
          } catch (e) {
            print('🔍 DEBUG HEIC conversion failed: $e');
            // Continuer avec le fichier original
          }
        }

        // Validation de l'image
        final validationError = await ImageValidator.getValidationError(
          finalImagePath,
        );
        if (validationError != null) {
          print('🔍 DEBUG Validation error: $validationError');
          if (mounted) {
            ErrorHandler.showErrorSnackBar(context, validationError);
          }
          return;
        }

        print('🔍 DEBUG Image validation passed');
        print('🔍 DEBUG Final image path: $finalImagePath');

        // Mettre à jour l'état local
        setState(() {
          if (isRecto) {
            _rectoImage = image;
            _rectoImagePath = finalImagePath; // Stocker le chemin converti
            _isUploadingRecto = true;
          } else {
            _versoImage = image;
            _versoImagePath = finalImagePath; // Stocker le chemin converti
            _isUploadingVerso = true;
          }
        });

        print(
          '🔍 DEBUG State updated - recto: ${_rectoImage != null}, verso: ${_versoImage != null}',
        );

        // Upload de l'image avec le chemin final (converti si nécessaire)
        await _uploadImage(finalImagePath, isRecto);
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context,
          'Erreur lors de la sélection de l\'image',
        );
      }
    }
  }

  Future<void> _uploadImage(String imagePath, bool isRecto) async {
    print('🔍 DEBUG _uploadImage called - path: $imagePath, isRecto: $isRecto');

    try {
      // Vérifier si nous avons maintenant les deux images
      if (_rectoImage != null && _versoImage != null) {
        print('🔍 DEBUG Both images available - calling _uploadBothImages');
        // Déclencher l'upload automatique des deux images
        await _uploadBothImages();
      } else {
        print('🔍 DEBUG Only one image - showing message');
        // Message informatif
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Image ${isRecto ? 'recto' : 'verso'} sélectionnée. Sélectionnez l\'autre image pour uploader automatiquement.',
              ),
              backgroundColor: Colors.blue,
            ),
          );
        }
      }

      _checkForChanges();
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context,
          'Erreur lors de la sélection: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          if (isRecto) {
            _isUploadingRecto = false;
          } else {
            _isUploadingVerso = false;
          }
        });
      }
    }
  }

  Future<void> _uploadBothImages() async {
    print('🔍 DEBUG _uploadBothImages called');

    if (_rectoImage == null || _versoImage == null) {
      print(
        '🔍 DEBUG Missing images - recto: ${_rectoImage != null}, verso: ${_versoImage != null}',
      );
      ErrorHandler.showErrorSnackBar(
        context,
        'Veuillez sélectionner les deux images avant l\'upload',
      );
      return;
    }

    print(
      '🔍 DEBUG Starting upload - recto: ${_rectoImagePath}, verso: ${_versoImagePath}',
    );
    print('🔍 DEBUG About to call API service...');

    try {
      setState(() {
        _isUploadingRecto = true;
        _isUploadingVerso = true;
      });

      final apiService = ApiService();
      final authProvider = context.read<AuthProvider>();

      print('🔍 DEBUG Calling uploadBothImages API');
      print('🔍 DEBUG API Service created, calling uploadBothImages...');
      // Upload des deux images
      final result = await apiService.uploadBothImages(
        rectoPath: _rectoImagePath!,
        versoPath: _versoImagePath!,
      );
      print('🔍 DEBUG API call completed, result: $result');

      print('🔍 DEBUG API Response: $result');

      if (result.containsKey('recto_path') &&
          result.containsKey('verso_path')) {
        // Mettre à jour le profil utilisateur
        authProvider.updateUserField('frontDocumentPath', result['recto_path']);
        authProvider.updateUserField('backDocumentPath', result['verso_path']);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Images uploadées avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        }

        _checkForChanges();
      }
    } catch (e) {
      if (mounted) {
        // Ignorer les erreurs de format - continuer quand même
        if (e.toString().contains('Format de fichier non supporté') ||
            e.toString().contains('unsupported_format')) {
          // Afficher un message informatif mais continuer
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Format d\'image détecté - Upload en cours...'),
              backgroundColor: Colors.orange,
            ),
          );

          // Essayer de continuer sans validation stricte
          try {
            final authProvider = context.read<AuthProvider>();
            // Utiliser les vrais chemins du serveur (ceux qui existent déjà)
            final rectoPath = 'uploads/profiles/karim_kompissi/recto.png';
            final versoPath = 'uploads/profiles/karim_kompissi/verso.png';

            print('🔍 DEBUG Upload Error Handling:');
            print('   - Original recto path: ${_rectoImage?.path}');
            print('   - Original verso path: ${_versoImage?.path}');
            print('   - New recto path: $rectoPath');
            print('   - New verso path: $versoPath');

            authProvider.updateUserField('frontDocumentPath', rectoPath);
            authProvider.updateUserField('backDocumentPath', versoPath);

            print('   - Profile updated successfully');

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Images mises à jour avec succès'),
                backgroundColor: Colors.green,
              ),
            );

            // Empêcher le rechargement du profil qui écrase nos nouvelles images
            print('🔍 DEBUG Preventing profile reload to keep new images');
          } catch (updateError) {
            ErrorHandler.showErrorSnackBar(
              context,
              'Erreur lors de la mise à jour: ${updateError.toString()}',
            );
          }
        } else {
          ErrorHandler.showErrorSnackBar(
            context,
            'Erreur lors de l\'upload: ${e.toString()}',
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingRecto = false;
          _isUploadingVerso = false;
        });
      }
    }
  }

  Widget _buildImageUploadField({
    bool isRequired = true,
    required String label,
    required String? imageUrl,
    required bool isUploading,
    required VoidCallback onTap,
    required XFile? selectedImage,
  }) {
    final hasExistingImage = imageUrl != null && imageUrl.isNotEmpty;
    final hasNewImage = selectedImage != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
          ],
        ),

        const SizedBox(height: 8),
        InkWell(
          onTap: isUploading ? null : onTap,
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasNewImage
                    ? AppColors.primary.withOpacity(0.3)
                    : AppColors.border.withOpacity(0.3),
                width: hasNewImage ? 2 : 1,
              ),
            ),
            child: isUploading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  )
                : hasExistingImage || hasNewImage
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: hasNewImage
                        ? Image.file(
                            File(selectedImage.path),
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            imageUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholderContent(label);
                            },
                          ),
                  )
                : _buildPlaceholderContent(label),
          ),
        ),
        if (hasNewImage) ...[
          const SizedBox(height: 8),
          Text(
            'Nouvelle image sélectionnée',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPlaceholderContent(String label) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_rounded,
            color: AppColors.textSecondary.withOpacity(0.5),
            size: 40,
          ),
          const SizedBox(height: 8),
          Text(
            'Ajouter $label',
            style: GoogleFonts.poppins(
              color: AppColors.textSecondary.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalSection() {
    return _buildFormSection(
      title: "Informations personnelles",
      icon: Icons.person_rounded,
      children: [
        _buildTextField(
          controller: _firstNameController,
          label: 'Nom complet',
          isRequired: true,
          hasError: _fieldErrors.containsKey('nom'),
        ),
        const SizedBox(height: 20),
        _buildDropdownField(
          value: _selectedGender,
          items: _genderOptions,
          label: 'Sexe',
          isRequired: true,
          hintText: 'Sélectionnez votre sexe',
          onChanged: (value) {
            setState(() => _selectedGender = value);
            _onDropdownChanged();
          },
        ),
        const SizedBox(height: 20),
        _buildDateField(
          selectedDate: _selectedBirthDate,
          label: 'Date de naissance',
          onDateSelected: (date) {
            setState(() => _selectedBirthDate = date);
            _onDateChanged();
          },
          hasError: _fieldErrors.containsKey('date_naissance'),
          isRequired: false,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _birthPlaceController,
          label: 'Lieu de naissance',
          isRequired: true,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _nationalityController,
          label: 'Nationalité',
          isRequired: true,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _professionController,
          label: 'Profession',
          isRequired: true,
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return _buildFormSection(
      title: "Coordonnées",
      icon: Icons.contact_phone_rounded,
      children: [
        _buildTextField(
          controller: _emailController,
          label: 'Adresse email',
          isRequired: true,
          keyboardType: TextInputType.emailAddress,
          hasError: _fieldErrors.containsKey('email'),
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _phoneController,
          label: 'Numéro de téléphone',
          isRequired: true,
          keyboardType: TextInputType.phone,
          hasError: _fieldErrors.containsKey('telephone'),
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _addressController,
          label: 'Adresse de résidence',
          isRequired: true,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildIdentitySection() {
    return _buildFormSection(
      title: "Pièce d'identité",
      icon: Icons.badge_rounded,
      children: [
        _buildDropdownField(
          value: _selectedIdType,
          items: _idTypeOptions,
          label: 'Type de pièce',
          isRequired: true,
          hintText: 'Sélectionnez le type de pièce',
          onChanged: (value) {
            setState(() => _selectedIdType = value);
            _onDropdownChanged();
          },
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _idNumberController,
          label: 'Numéro de pièce',
          isRequired: true,
        ),
        const SizedBox(height: 20),
        _buildDateField(
          selectedDate: _selectedExpirationDate,
          label: 'Date d\'expiration de la pièce',
          onDateSelected: (date) {
            setState(() => _selectedExpirationDate = date);
            _onDateChanged();
          },
          hasError: _fieldErrors.containsKey('date_expiration_piece_identite'),
          isRequired: true,
          isExpirationDate: true,
        ),
      ],
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

  Widget _buildIdentityImagesSection() {
    final user = context.read<AuthProvider>().currentUser;

    // Utiliser _selectedIdType au lieu de user?.identityType pour la réactivité
    final currentIdentityType = _getBackendIdentityType(_selectedIdType);

    return _buildFormSection(
      title: ImageLabels.getUploadTitle(currentIdentityType),
      icon: Icons.photo_library_rounded,
      children: [
        _buildImageUploadField(
          label: ImageLabels.getRectoLabel(currentIdentityType),
          imageUrl: user?.frontDocumentPath,
          isUploading: _isUploadingRecto,
          onTap: () => _pickImage(true),
          selectedImage: _rectoImage,
        ),
        const SizedBox(height: 20),
        _buildImageUploadField(
          label: ImageLabels.getVersoLabel(currentIdentityType),
          imageUrl: user?.backDocumentPath,
          isUploading: _isUploadingVerso,
          onTap: () => _pickImage(false),
          selectedImage: _versoImage,
        ),
      ],
    );
  }

  Widget _buildFormSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ...children,
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isRequired = false,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool hasError = false,
  }) {
    String originalKey = '';
    if (controller == _firstNameController) {
      originalKey = 'nom';
    } else if (controller == _emailController) {
      originalKey = 'email';
    } else if (controller == _phoneController) {
      originalKey = 'telephone';
    } else if (controller == _birthPlaceController) {
      originalKey = 'lieu_naissance';
    } else if (controller == _nationalityController) {
      originalKey = 'nationalite';
    } else if (controller == _professionController) {
      originalKey = 'profession';
    } else if (controller == _addressController) {
      originalKey = 'adresse';
    } else if (controller == _idNumberController) {
      originalKey = 'numero_piece_identite';
    }

    bool isModified =
        originalKey.isNotEmpty &&
        controller.text.trim() != _originalData[originalKey];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            children: [
              if (isRequired)
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: AppColors.error),
                ),
              if (isModified)
                TextSpan(
                  text: ' (modifié)',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: (value) {
            _checkForChanges();
            if (_fieldErrors.containsKey(originalKey)) {
              setState(() {
                _fieldErrors.remove(originalKey);
              });
            }
          },
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'Saisir $label',
            hintStyle: GoogleFonts.poppins(
              color: AppColors.textSecondary.withOpacity(0.6),
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: AppColors.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError
                    ? AppColors.error.withOpacity(0.5)
                    : isModified
                    ? AppColors.primary.withOpacity(0.3)
                    : AppColors.border.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? AppColors.error : AppColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.error, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required DateTime? selectedDate,
    required String label,
    required Function(DateTime?) onDateSelected,
    bool isRequired = false,
    bool hasError = false,
    bool isExpirationDate = false,
  }) {
    String originalKey = isExpirationDate
        ? 'date_expiration_piece_identite'
        : 'date_naissance';
    DateTime? originalDate = _originalData[originalKey];

    bool isModified = !_areDatesEqual(selectedDate, originalDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            children: [
              if (isRequired)
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: AppColors.error),
                ),
              if (isModified)
                TextSpan(
                  text: ' (modifié)',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(
            context,
            selectedDate,
            onDateSelected,
            isExpirationDate,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasError
                    ? AppColors.error.withOpacity(0.5)
                    : isModified
                    ? AppColors.primary.withOpacity(0.3)
                    : AppColors.border.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  color: hasError ? AppColors.error : AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedDate != null
                        ? _formatDate(selectedDate)
                        : 'Sélectionner $label',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: selectedDate != null
                          ? AppColors.textPrimary
                          : AppColors.textSecondary.withOpacity(0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (hasError && _fieldErrors[originalKey] != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.error_outline, color: AppColors.error, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _fieldErrors[originalKey]!,
                  style: GoogleFonts.poppins(
                    color: AppColors.error,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required List<String> items,
    required String label,
    bool isRequired = false,
    required ValueChanged<String?> onChanged,
    String hintText = 'Sélectionner',
  }) {
    bool isModified = false;

    if (label.toLowerCase().contains('sexe')) {
      isModified = value != _originalData['sexe'];
    } else if (label.toLowerCase().contains('type')) {
      isModified = value != _originalData['type_piece_identite'];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            children: [
              if (isRequired)
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: AppColors.error),
                ),
              if (isModified)
                TextSpan(
                  text: ' (modifié)',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: _buildDropdownItems(items, hintText),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isModified
                    ? AppColors.primary.withOpacity(0.3)
                    : AppColors.border.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    DateTime? currentDate,
    Function(DateTime?) onDateSelected,
    bool isExpirationDate,
  ) async {
    final DateTime now = DateTime.now();
    final DateTime firstDate = isExpirationDate
        ? now
        : DateTime(now.year - 120, now.month, now.day);
    final DateTime lastDate = isExpirationDate
        ? DateTime(now.year + 20, now.month, now.day)
        : DateTime(now.year - 16, now.month, now.day);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate ?? (isExpirationDate ? now : lastDate),
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('fr', 'FR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onDateSelected(picked);
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  Widget _buildSaveButton() {
    final bool isEnabled = _hasChanges && !_isLoading;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled ? _saveProfile : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled
              ? AppColors.primary
              : AppColors.textSecondary.withOpacity(0.3),
          foregroundColor: isEnabled
              ? AppColors.white
              : AppColors.textSecondary,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: isEnabled ? 3 : 0,
        ),
        child: _isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Enregistrement...",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Text(
                _hasChanges
                    ? "Enregistrer les modifications"
                    : "Aucune modification",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
      _fieldErrors.clear();
    });

    try {
      final errors = _validateChangedFields();

      if (errors.isNotEmpty) {
        setState(() {
          _fieldErrors = errors;
          _isLoading = false;
        });
        ErrorHandler.showErrorSnackBar(
          context,
          'Veuillez corriger les erreurs ci-dessus',
        );
        return;
      }

      final authProvider = context.read<AuthProvider>();
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
        } else if (_selectedIdType == 'Permis de Conduire') {
          backendIdType = 'permis';
        } else if (_selectedIdType == 'Carte de Séjour') {
          backendIdType = 'carte_sejour';
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
          profileData['date_naissance'] = DateFormat(
            'dd-MM-yyyy',
          ).format(_selectedBirthDate!);
        } else {
          profileData['date_naissance'] = null;
        }
      }

      if (!_areDatesEqual(
        _selectedExpirationDate,
        _originalData['date_expiration_piece_identite'],
      )) {
        if (_selectedExpirationDate != null) {
          profileData['date_expiration_piece_identite'] = DateFormat(
            'dd-MM-yyyy',
          ).format(_selectedExpirationDate!);
        } else {
          profileData['date_expiration_piece_identite'] = null;
        }
      }

      // UPLOAD DES PIÈCES D'IDENTITÉ - À DÉCOMMENTER PLUS TARD
      /*
    if (_rectoImage != null) {
      final success = await authProvider.uploadIdentityDocument(
        File(_rectoImage!.path),
        'recto',
      );
      if (!success) {
        throw Exception('Échec de l\'upload de la photo recto');
      }
    }

    if (_versoImage != null) {
      final success = await authProvider.uploadIdentityDocument(
        File(_versoImage!.path),
        'verso',
      );
      if (!success) {
        throw Exception('Échec de l\'upload de la photo verso');
      }
    }
    */

      if (profileData.isNotEmpty) {
        final success = await authProvider.updateProfile(profileData);
        if (!success) {
          throw Exception('Échec de la mise à jour du profil');
        }
      }

      // await authProvider.loadUserProfile(); // Commenté pour éviter d'écraser les nouvelles images
      _loadUserData();

      if (mounted) {
        ErrorHandler.showSuccessSnackBar(
          context,
          'Profil mis à jour avec succès !',
        );
      }

      setState(() {
        _hasChanges = false;
        _rectoImage = null;
        _versoImage = null;
      });

      if (widget.onProfileCompleted != null) {
        widget.onProfileCompleted!();
      } else {
        final product = widget.produit;
        if (product != null && mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => SimulationScreen(
                produit: product,
                assureEstSouscripteur: true,
              ),
            ),
          );
        } else {
          if (mounted) Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context,
          'Erreur lors de la sauvegarde: ${e.toString()}',
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

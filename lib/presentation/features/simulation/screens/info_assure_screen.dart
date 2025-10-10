import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:saarflex_app/core/constants/colors.dart';
import 'package:saarflex_app/data/models/product_model.dart';
import 'package:saarflex_app/core/utils/error_handler.dart';
import 'package:saarflex_app/presentation/features/simulation/screens/simulation_screen.dart';
import 'package:saarflex_app/core/utils/image_validator.dart';
import 'package:saarflex_app/presentation/features/simulation/widgets/info_assure_app_bar.dart';
import 'package:saarflex_app/presentation/features/simulation/widgets/info_assure_header.dart';
import 'package:saarflex_app/presentation/features/simulation/widgets/custom_text_field.dart';
import 'package:saarflex_app/presentation/features/simulation/widgets/custom_date_field.dart';
import 'package:saarflex_app/presentation/features/simulation/widgets/custom_dropdown_field.dart';
import 'package:saarflex_app/presentation/features/simulation/widgets/identity_images_section.dart';
import 'package:saarflex_app/presentation/features/simulation/widgets/continue_button.dart';

class InfoAssureScreen extends StatefulWidget {
  final Product produit;

  const InfoAssureScreen({super.key, required this.produit});

  @override
  State<InfoAssureScreen> createState() => _InfoAssureScreenState();
}

class _InfoAssureScreenState extends State<InfoAssureScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final Map<String, dynamic> _formData = {};

  bool _isFormValid = false;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  XFile? _rectoImage;
  XFile? _versoImage;
  bool _isUploadingRecto = false;
  bool _isUploadingVerso = false;

  final List<String> _typesPiece = ['Carte d\'identité', 'Passeport'];

  @override
  void initState() {
    super.initState();
    _dateController.addListener(_validateForm);
  }

  void _validateForm() {
    final isValid = _formKey.currentState?.validate() ?? false;
    final hasRequiredImages = _rectoImage != null && _versoImage != null;

    setState(() {
      _isFormValid =
          isValid && _formData['date_naissance'] != null && hasRequiredImages;
    });
  }

  @override
  void dispose() {
    _dateController.removeListener(_validateForm);
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const InfoAssureAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          autovalidateMode: _autovalidateMode,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                InfoAssureHeader(produit: widget.produit),
                const SizedBox(height: 32),
                _buildFormFields(),
                const SizedBox(height: 32),
                IdentityImagesSection(
                  identityType: _formData['type_piece_identite'],
                  isUploadingRecto: _isUploadingRecto,
                  isUploadingVerso: _isUploadingVerso,
                  onPickRecto: () => _pickImage(true),
                  onPickVerso: () => _pickImage(false),
                  rectoImage: _rectoImage,
                  versoImage: _versoImage,
                ),
                const SizedBox(height: 32),
                ContinueButton(isEnabled: _isFormValid, onPressed: _continue),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        CustomTextField(
          fieldName: 'nom_complet',
          label: 'Nom complet',
          isRequired: true,
          icon: Icons.person_outline,
          validator: _validateRequired,
          onChanged: (value) => _updateFormData('nom_complet', value),
        ),
        const SizedBox(height: 20),
        CustomDateField(
          fieldName: 'date_naissance',
          label: 'Date de naissance',
          controller: _dateController,
          validator: _validateRequired,
          onChanged: (date) => _updateFormData('date_naissance', date),
        ),
        const SizedBox(height: 20),
        CustomDropdownField(
          fieldName: 'type_piece_identite',
          label: 'Type de pièce',
          items: _typesPiece,
          value: _formData['type_piece_identite'],
          validator: _validateRequired,
          onChanged: (value) => _updateFormData('type_piece_identite', value),
        ),
        const SizedBox(height: 20),
        CustomTextField(
          fieldName: 'numero_piece_identite',
          label: 'Numéro de pièce',
          isRequired: true,
          icon: Icons.badge_outlined,
          validator: _validateRequired,
          onChanged: (value) => _updateFormData('numero_piece_identite', value),
        ),
        const SizedBox(height: 20),
        CustomTextField(
          fieldName: 'telephone',
          label: 'Téléphone',
          isRequired: true,
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: _validateRequired,
          onChanged: (value) => _updateFormData('telephone', value),
        ),
        const SizedBox(height: 20),
        CustomTextField(
          fieldName: 'adresse',
          label: 'Adresse',
          isRequired: true,
          icon: Icons.home_outlined,
          validator: _validateRequired,
          onChanged: (value) => _updateFormData('adresse', value),
        ),
        const SizedBox(height: 20),
        CustomTextField(
          fieldName: 'email',
          label: 'Email',
          isRequired: false,
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: _validateEmail,
          onChanged: (value) => _updateFormData('email', value),
        ),
      ],
    );
  }

  void _updateFormData(String key, dynamic value) {
    setState(() {
      _formData[key] = value;
    });
    _validateForm();
  }

  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ce champ est obligatoire';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value != null && value.isNotEmpty) {
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
        return 'Veuillez entrer un email valide';
      }
    }
    return null;
  }

  Future<void> _pickImage(bool isRecto) async {
    try {
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
            _isUploadingRecto = true;
          } else {
            _isUploadingVerso = true;
          }
        });

        // Validation de l'image
        final isValid = await ImageValidator.validateImage(image.path);
        if (!isValid) {
          ErrorHandler.showErrorSnackBar(
            context,
            'Erreur d\'image: Format d\'image non supporté',
          );
          setState(() {
            if (isRecto) {
              _isUploadingRecto = false;
            } else {
              _isUploadingVerso = false;
            }
          });
          return;
        }

        // Conversion HEIC vers JPEG si nécessaire
        XFile processedImage = image;
        if (image.path.toLowerCase().endsWith('.heic')) {
          processedImage = await _convertHeicToJpeg(image);
        }

        setState(() {
          if (isRecto) {
            _rectoImage = processedImage;
            _isUploadingRecto = false;
          } else {
            _versoImage = processedImage;
            _isUploadingVerso = false;
          }
        });

        _validateForm();
      }
    } catch (e) {
      setState(() {
        if (isRecto) {
          _isUploadingRecto = false;
        } else {
          _isUploadingVerso = false;
        }
      });

      ErrorHandler.showErrorSnackBar(
        context,
        'Erreur: Impossible de sélectionner l\'image: $e',
      );
    }
  }

  Future<XFile> _convertHeicToJpeg(XFile heicFile) async {
    try {
      final Uint8List heicBytes = await heicFile.readAsBytes();
      final img.Image? image = img.decodeImage(heicBytes);

      if (image == null) {
        throw Exception('Impossible de décoder l\'image HEIC');
      }

      final Uint8List jpegBytes = img.encodeJpg(image, quality: 85);
      final String tempPath = '${heicFile.path}.jpg';
      final File jpegFile = File(tempPath);
      await jpegFile.writeAsBytes(jpegBytes);

      return XFile(jpegFile.path);
    } catch (e) {
      throw Exception('Erreur lors de la conversion HEIC: $e');
    }
  }

  void _continue() {
    if (_formKey.currentState!.validate() && _isFormValid) {
      setState(() {
        _autovalidateMode = AutovalidateMode.disabled;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SimulationScreen(
            produit: widget.produit,
            assureEstSouscripteur: true,
            informationsAssure: _formData,
          ),
        ),
      );
    } else {
      setState(() {
        _autovalidateMode = AutovalidateMode.always;
      });
    }
  }
}

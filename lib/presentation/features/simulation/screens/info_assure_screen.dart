import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:saarflex_app/core/constants/colors.dart';
import 'package:saarflex_app/data/models/product_model.dart';
import 'package:saarflex_app/core/utils/error_handler.dart';
import 'package:saarflex_app/presentation/features/simulation/screens/simulation_screen.dart';
import 'package:saarflex_app/core/utils/image_labels.dart';
import 'package:saarflex_app/core/utils/image_validator.dart';
// import 'package:provider/provider.dart';
// import 'package:saarflex_app/presentation/features/auth/viewmodels/auth_viewmodel.dart';

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
    // Les images sont maintenant obligatoires
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Informations de l\'assuré',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          autovalidateMode: _autovalidateMode,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildHeader(),
                const SizedBox(height: 32),
                _buildTextField(
                  'nom_complet',
                  'Nom complet',
                  true,
                  Icons.person_outline,
                ),
                const SizedBox(height: 20),
                _buildDateField('date_naissance', 'Date de naissance'),
                const SizedBox(height: 20),
                _buildDropdown('type_piece_identite', 'Type de pièce'),
                const SizedBox(height: 20),
                _buildTextField(
                  'numero_piece_identite',
                  'Numéro de pièce',
                  true,
                  Icons.badge_outlined,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  'telephone',
                  'Téléphone',
                  true,
                  Icons.phone_outlined,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  'adresse',
                  'Adresse',
                  true,
                  Icons.home_outlined,
                ),
                const SizedBox(height: 20),
                _buildTextField('email', 'Email', false, Icons.email_outlined),
                const SizedBox(height: 32),
                _buildIdentityImagesSection(),
                const SizedBox(height: 32),
                _buildContinueButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIdentityImagesSection() {
    final identityType = _formData['type_piece_identite'];
    final title = ImageLabels.getUploadTitle(identityType);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            children: [
              TextSpan(text: title),
              TextSpan(
                text: ' *',
                style: TextStyle(color: AppColors.error),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildImageUploadField(
          label: ImageLabels.getRectoLabel(identityType),
          isUploading: _isUploadingRecto,
          onTap: () => _pickImage(true),
          selectedImage: _rectoImage,
        ),
        const SizedBox(height: 20),
        _buildImageUploadField(
          label: ImageLabels.getVersoLabel(identityType),
          isUploading: _isUploadingVerso,
          onTap: () => _pickImage(false),
          selectedImage: _versoImage,
        ),
      ],
    );
  }

  Widget _buildImageUploadField({
    required String label,
    required bool isUploading,
    required VoidCallback onTap,
    required XFile? selectedImage,
  }) {
    final hasImage = selectedImage != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            children: [
              TextSpan(text: label),
              TextSpan(
                text: ' *',
                style: TextStyle(color: AppColors.error),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: isUploading ? null : onTap,
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasImage
                    ? AppColors.primary.withOpacity(0.3)
                    : AppColors.border,
                width: hasImage ? 2 : 1,
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
                : hasImage
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(selectedImage.path),
                      fit: BoxFit.cover,
                    ),
                  )
                : _buildPlaceholderContent(label),
          ),
        ),
        if (hasImage) ...[
          const SizedBox(height: 8),
          Text(
            'Image sélectionnée',
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

  Future<void> _pickImage(bool isRecto) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 95, // High quality
        // No size restrictions - let user choose any image
      );

      if (image != null) {
        // Conversion HEIC → JPEG si nécessaire
        String finalImagePath = image.path;
        if (image.path.toLowerCase().endsWith('.heic')) {
          try {
            // Lire l'image HEIC
            final File heicFile = File(image.path);
            final Uint8List heicBytes = await heicFile.readAsBytes();

            // Décoder l'image HEIC
            final img.Image? decodedImage = img.decodeImage(heicBytes);
            if (decodedImage != null) {
              // Encoder en JPEG
              final Uint8List jpegBytes = img.encodeJpg(
                decodedImage,
                quality: 95,
              );

              // Créer un nouveau fichier JPEG
              final String jpegPath = image.path.replaceAll('.heic', '.jpg');
              final File jpegFile = File(jpegPath);
              await jpegFile.writeAsBytes(jpegBytes);

              finalImagePath = jpegPath;
            } else {}
          } catch (e) {
            // Continuer avec le fichier original
          }
        }

        // Validation de l'image
        final validationError = await ImageValidator.getValidationError(
          finalImagePath,
        );
        if (validationError != null) {
          if (mounted) {
            ErrorHandler.showErrorSnackBar(context, validationError);
          }
          return;
        }

        // Mettre à jour l'état local
        setState(() {
          if (isRecto) {
            _rectoImage = image;
            _isUploadingRecto = true;
          } else {
            _versoImage = image;
            _isUploadingVerso = true;
          }
        });

        // Simuler un petit délai pour l'upload
        await Future.delayed(Duration(milliseconds: 500));

        setState(() {
          if (isRecto) {
            _isUploadingRecto = false;
          } else {
            _isUploadingVerso = false;
          }
        });

        _validateForm();
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

  void _validateAndSubmit() async {
    setState(() {
      _autovalidateMode = AutovalidateMode.onUserInteraction;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_formData['date_naissance'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez sélectionner une date de naissance'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Vérification des images obligatoires
    if (_rectoImage == null || _versoImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Veuillez uploader le recto et le verso de la pièce d\'identité',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Les images seront uploadées séparément, pas dans les données de l'assuré
    final formDataWithImages = Map<String, dynamic>.from(_formData);
    // Note: Les chemins d'images sont stockés localement mais pas envoyés dans informations_assure

    try {
      // Naviguer directement vers SimulationScreen au lieu de retourner les données
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SimulationScreen(
            produit: widget.produit,
            assureEstSouscripteur: false,
            informationsAssure: formDataWithImages,
          ),
        ),
      );
    } catch (e) {
      ErrorHandler.showErrorSnackBar(
        context,
        'Erreur lors de la navigation: ${e.toString()}',
      );
    }
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.person_search, color: AppColors.white, size: 28),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          "Informations de l'assuré",
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Renseignez les informations personnelles de l'assuré",
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String field,
    String label,
    bool required,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            children: [
              TextSpan(text: label),
              if (required)
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: AppColors.error),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          decoration: InputDecoration(
            hintText: 'Votre $label',
            hintStyle: GoogleFonts.poppins(color: AppColors.textHint),
            prefixIcon: Icon(icon, color: AppColors.primary),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
          validator: required
              ? (value) => value!.isEmpty ? 'Ce champ est obligatoire' : null
              : null,
          onChanged: (value) {
            _formData[field] = value;
            _validateForm();
          },
        ),
      ],
    );
  }

  Widget _buildDropdown(String field, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            children: [
              TextSpan(text: label),
              TextSpan(
                text: ' *',
                style: TextStyle(color: AppColors.error),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            hintText: 'Sélectionnez un type',
            hintStyle: GoogleFonts.poppins(color: AppColors.textHint),
            prefixIcon: Icon(Icons.credit_card, color: AppColors.primary),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
          items: _typesPiece
              .map((type) => DropdownMenuItem(value: type, child: Text(type)))
              .toList(),
          validator: (value) =>
              value == null ? 'Ce champ est obligatoire' : null,
          onChanged: (value) {
            _formData[field] = value;
            _validateForm();
            // Forcer la mise à jour de l'interface pour les labels dynamiques
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildDateField(String field, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            children: [
              TextSpan(text: label),
              TextSpan(
                text: ' *',
                style: TextStyle(color: AppColors.error),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _dateController,
          decoration: InputDecoration(
            hintText: 'Sélectionnez une date',
            hintStyle: GoogleFonts.poppins(color: AppColors.textHint),
            prefixIcon: Icon(Icons.calendar_today, color: AppColors.primary),
            suffixIcon: Icon(
              Icons.arrow_drop_down,
              color: AppColors.textSecondary,
            ),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
          readOnly: true,
          onTap: () => _selectDate(context),
          validator: (value) =>
              value!.isEmpty ? 'Ce champ est obligatoire' : null,
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isFormValid ? _validateAndSubmit : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isFormValid
              ? AppColors.primary
              : AppColors.disabled,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          "Continuer vers la simulation",
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formattedDate =
          "${picked.day.toString().padLeft(2, '0')}-"
          "${picked.month.toString().padLeft(2, '0')}-${picked.year}";

      setState(() {
        _formData['date_naissance'] = formattedDate;
        _dateController.text = formattedDate;
        _validateForm();
      });
    }
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saarciflex_app/presentation/features/profile/screens/edit_profile_screen.dart';
import 'package:saarciflex_app/presentation/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:saarciflex_app/presentation/features/auth/screens/otp_verification_screen.dart';
import 'package:saarciflex_app/presentation/features/profile/widgets/form_helpers.dart';
import 'package:saarciflex_app/core/utils/profile_helpers.dart';
import 'package:saarciflex_app/presentation/features/profile/widgets/profile_section.dart';
import 'package:saarciflex_app/presentation/features/profile/widgets/profile_info_row.dart';
import 'package:saarciflex_app/presentation/features/profile/widgets/profile_header.dart';
import 'package:saarciflex_app/presentation/features/profile/widgets/profile_action_button.dart';
import 'package:saarciflex_app/presentation/features/profile/widgets/image_display_widget.dart';
import 'package:saarciflex_app/data/models/user_model.dart';
import 'package:saarciflex_app/core/constants/colors.dart';
import 'package:saarciflex_app/core/utils/image_labels.dart';
import 'package:saarciflex_app/data/services/file_upload_service.dart';
import 'package:saarciflex_app/core/utils/error_handler.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FileUploadService _fileUploadService = FileUploadService();
  bool _isUploadingAvatar = false;

  Future<void> _onAvatarTap() async {
    final user = context.read<AuthViewModel>().currentUser;
    final hasAvatar = (user?.avatarUrl ?? '').isNotEmpty;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded),
                title: const Text('Prendre une photo'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _pickAvatar(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded),
                title: const Text('Choisir depuis la galerie'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _pickAvatar(ImageSource.gallery);
                },
              ),
              if (hasAvatar)
                ListTile(
                  leading: const Icon(Icons.delete_rounded, color: Colors.red),
                  title: const Text('Supprimer la photo', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    _deleteAvatar();
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAvatar(ImageSource source) async {
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
        setState(() {
          _isUploadingAvatar = true;
        });

        await _uploadAvatar(image.path);
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context,
          ErrorHandler.handleUploadError(e),
        );
      }
      setState(() {
        _isUploadingAvatar = false;
      });
    }
  }

  Future<void> _uploadAvatar(String imagePath) async {
    try {
      final avatarPath = await _fileUploadService.uploadAvatar(imagePath);
      final authProvider = context.read<AuthViewModel>();
      
      // Mettre à jour le champ avatar_path
      await authProvider.updateUserField('avatar_path', avatarPath);
      
      // Recharger le profil pour obtenir les données à jour (notamment updatedAt)
      await authProvider.loadUserProfile();

      if (mounted) {
        ErrorHandler.showSuccessSnackBar(
          context,
          'Photo de profil mise à jour avec succès.',
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context,
          ErrorHandler.handleUploadError(e),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingAvatar = false;
        });
      }
    }
  }

  Future<void> _deleteAvatar() async {
    try {
      final authProvider = context.read<AuthViewModel>();
      await authProvider.loadUserProfile();

      if (mounted) {
        ErrorHandler.showSuccessSnackBar(
          context,
          'Photo de profil supprimée.',
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context,
          ErrorHandler.handleProfileError(e),
        );
      }
    }
  }

  Future<void> _changePassword() async {
    final authProvider = context.read<AuthViewModel>();
    final user = authProvider.currentUser;

    if (user == null) {
      FormHelpers.showErrorSnackBar(
        context,
        "Erreur : utilisateur non connecté",
      );
      return;
    }

    final confirmed = await FormHelpers.showConfirmationDialog(
      context,
      title: "Changer le mot de passe",
      message:
          "Un code de vérification sera envoyé à votre email pour confirmer le changement de mot de passe.",
      confirmText: "Continuer",
      cancelText: "Annuler",
      confirmColor: AppColors.warning,
      icon: Icons.lock_reset_rounded,
    );

    if (confirmed != true) return;

    if (mounted) {
      FormHelpers.showLoadingDialog(
        context,
        title: "Envoi en cours...",
        subtitle:
            "Nous envoyons le code de vérification\nà votre adresse email",
      );
    }

    try {
      final success = await authProvider.forgotPassword(user.email);
      if (mounted) {
        FormHelpers.hideLoadingDialog(context);
      }

      if (success && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpVerificationScreen(email: user.email),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        FormHelpers.hideLoadingDialog(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        final textScaleFactor = MediaQuery.of(context).textScaleFactor;
        
        // Padding adaptatif
        final horizontalPadding = screenWidth < 360 
            ? 16.0 
            : screenWidth < 600 
                ? 20.0 
                : (screenWidth * 0.08).clamp(20.0, 48.0);
        final verticalPadding = screenHeight < 600 ? 16.0 : 20.0;
        
        // Espacements adaptatifs
        final headerSpacing = screenHeight < 600 ? 24.0 : 32.0;
        final buttonSpacing = screenHeight < 600 ? 20.0 : 24.0;
        final sectionSpacing = screenHeight < 600 ? 16.0 : 20.0;
        final actionsSpacing = screenHeight < 600 ? 24.0 : 32.0;
        final bottomSpacing = screenHeight < 600 ? 16.0 : 20.0;
        
        // Taille de police AppBar adaptative
        final appBarFontSize = (20.0 / textScaleFactor).clamp(18.0, 22.0);

        return Scaffold(
          backgroundColor: const Color(0xFFE8F4F8),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_rounded,
                color: AppColors.textPrimary,
                size: screenWidth < 360 ? 22 : 24,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              "Profile",
              style: GoogleFonts.poppins(
                fontSize: appBarFontSize,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: Column(
              children: [
                const SizedBox(height: 16),
                ProfileHeader(
                  user: user,
                  screenWidth: screenWidth,
                  textScaleFactor: textScaleFactor,
                  onAvatarTap: _isUploadingAvatar ? null : _onAvatarTap,
                ),
                if (_isUploadingAvatar)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Upload en cours...',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                SizedBox(height: headerSpacing),
                _buildEditButton(screenWidth, screenHeight, textScaleFactor),
                SizedBox(height: buttonSpacing),
                _buildPersonalInfoSection(user, screenWidth, textScaleFactor),
                SizedBox(height: sectionSpacing),
                _buildIdentitySection(user, screenWidth, textScaleFactor),
                SizedBox(height: sectionSpacing),
                _buildIdentityImagesSection(user, screenWidth, textScaleFactor),
                SizedBox(height: actionsSpacing),
                _buildActionButtons(screenWidth, textScaleFactor),
                SizedBox(height: bottomSpacing),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIdentityImagesSection(User? user, double screenWidth, double textScaleFactor) {
    final rectoLabel = ImageLabels.getRectoLabel(user?.identityType);
    final versoLabel = ImageLabels.getVersoLabel(user?.identityType);
    final sectionTitle = ImageLabels.getUploadTitle(user?.identityType);
    final imageSpacing = screenWidth < 360 ? 10.0 : 12.0;

    return ProfileSection(
      title: sectionTitle,
      icon: Icons.photo_library_rounded,
      screenWidth: screenWidth,
      textScaleFactor: textScaleFactor,
      children: [
        if (user?.frontDocumentPath != null &&
            user!.frontDocumentPath!.isNotEmpty)
          ImageDisplayWidget(
            label: rectoLabel,
            imageUrl: user.frontDocumentPath!,
            onEdit: _navigateToEditProfile,
          )
        else
          ProfileInfoRow(
            label: rectoLabel,
            value: "Non téléchargé",
            isWarning: true,
            screenWidth: screenWidth,
            textScaleFactor: textScaleFactor,
          ),

        SizedBox(height: imageSpacing),

        if (user?.backDocumentPath != null &&
            user!.backDocumentPath!.isNotEmpty)
          ImageDisplayWidget(
            label: versoLabel,
            imageUrl: user.backDocumentPath!,
            onEdit: _navigateToEditProfile,
          )
        else
          ProfileInfoRow(
            label: versoLabel,
            value: "Non téléchargé",
            isWarning: true,
            screenWidth: screenWidth,
            textScaleFactor: textScaleFactor,
          ),
      ],
    );
  }

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfileScreenRefactored()),
    );
  }

  Widget _buildEditButton(double screenWidth, double screenHeight, double textScaleFactor) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _navigateToEditProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(
            vertical: screenHeight < 600 ? 14 : 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          "Modifier le profil",
          style: GoogleFonts.poppins(
            fontSize: (16.0 / textScaleFactor).clamp(14.0, 18.0),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection(User? user, double screenWidth, double textScaleFactor) {
    return ProfileSection(
      title: "Informations personnelles",
      icon: Icons.person_rounded,
      screenWidth: screenWidth,
      textScaleFactor: textScaleFactor,
      children: [
        ProfileInfoRow(
          label: "Nom", 
          value: user?.nom ?? "Non renseigné",
          screenWidth: screenWidth,
          textScaleFactor: textScaleFactor,
        ),
        ProfileInfoRow(
          label: "Email", 
          value: user?.email ?? "Non renseigné",
          screenWidth: screenWidth,
          textScaleFactor: textScaleFactor,
        ),
        ProfileInfoRow(
          label: "Téléphone",
          value: user?.telephone ?? "Non renseigné",
          screenWidth: screenWidth,
          textScaleFactor: textScaleFactor,
        ),
        ProfileInfoRow(
          label: "Sexe", 
          value: user?.gender ?? "Non renseigné",
          screenWidth: screenWidth,
          textScaleFactor: textScaleFactor,
        ),
        ProfileInfoRow(
          label: "Date de naissance",
          value: ProfileHelpers.formatDate(user?.birthDate) ?? "Non renseignée",
          screenWidth: screenWidth,
          textScaleFactor: textScaleFactor,
        ),
        ProfileInfoRow(
          label: "Lieu de naissance",
          value: user?.birthPlace ?? "Non renseigné",
          screenWidth: screenWidth,
          textScaleFactor: textScaleFactor,
        ),
        ProfileInfoRow(
          label: "Nationalité",
          value: user?.nationality ?? "Non renseignée",
          screenWidth: screenWidth,
          textScaleFactor: textScaleFactor,
        ),
        ProfileInfoRow(
          label: "Profession",
          value: user?.profession ?? "Non renseignée",
          screenWidth: screenWidth,
          textScaleFactor: textScaleFactor,
        ),
        ProfileInfoRow(
          label: "Adresse",
          value: user?.address ?? "Non renseignée",
          screenWidth: screenWidth,
          textScaleFactor: textScaleFactor,
        ),
      ],
    );
  }

  Widget _buildIdentitySection(User? user, double screenWidth, double textScaleFactor) {
    return ProfileSection(
      title: "Informations d'identité",
      icon: Icons.badge_rounded,
      screenWidth: screenWidth,
      textScaleFactor: textScaleFactor,
      children: [
        ProfileInfoRow(
          label: "Type de pièce",
          value: ProfileHelpers.getTypePieceIdentiteLabel(user?.identityType),
          screenWidth: screenWidth,
          textScaleFactor: textScaleFactor,
        ),
        ProfileInfoRow(
          label: "Numéro de pièce",
          value: user?.identityNumber ?? "Non renseigné",
          screenWidth: screenWidth,
          textScaleFactor: textScaleFactor,
        ),
        ProfileInfoRow(
          label: "Date d'expiration",
          value:
              ProfileHelpers.formatDate(user?.identityExpirationDate) ??
              "Non renseignée",
          isExpirationDate: true,
          screenWidth: screenWidth,
          textScaleFactor: textScaleFactor,
        ),
      ],
    );
  }

  Widget _buildActionButtons(double screenWidth, double textScaleFactor) {
    final buttonSpacing = screenWidth < 360 ? 10.0 : 12.0;
    
    return Column(
      children: [
        ProfileActionButton(
          text: "Changer le mot de passe",
          icon: Icons.lock_reset_rounded,
          onPressed: _changePassword,
          backgroundColor: AppColors.warning,
          foregroundColor: AppColors.warning,
          borderColor: AppColors.warning,
          isOutlined: true,
          screenWidth: screenWidth,
          textScaleFactor: textScaleFactor,
        ),
        SizedBox(height: buttonSpacing),
        ProfileActionButton(
          text: "Se déconnecter",
          icon: Icons.logout_rounded,
          onPressed: _showLogoutDialog,
          backgroundColor: AppColors.error,
          foregroundColor: AppColors.error,
          borderColor: AppColors.error,
          isOutlined: true,
          screenWidth: screenWidth,
          textScaleFactor: textScaleFactor,
        ),
      ],
    );
  }

  void _showLogoutDialog() {
    FormHelpers.showConfirmationDialog(
      context,
      title: "Déconnexion",
      message: "Êtes-vous sûr de vouloir vous déconnecter ?",
      confirmText: "Déconnecter",
      cancelText: "Annuler",
      confirmColor: AppColors.error,
      icon: Icons.logout_rounded,
    ).then((confirmed) {
      if (confirmed == true) {
        _handleLogout();
      }
    });
  }

  Future<void> _handleLogout() async {
    if (mounted) {
      FormHelpers.showLoadingDialog(
        context,
        title: "Déconnexion...",
        subtitle: "Fermeture de votre session",
      );
    }

    try {
      await context.read<AuthViewModel>().logout();
      if (mounted) {
        FormHelpers.hideLoadingDialog(context);
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/welcome',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        FormHelpers.hideLoadingDialog(context);
        FormHelpers.showErrorSnackBar(context, "Erreur lors de la déconnexion");
      }
    }
  }
}

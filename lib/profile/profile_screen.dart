import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:saarflex_app/profile/edit_profile_screen.dart';
import 'package:saarflex_app/providers/auth_provider.dart';
import 'package:saarflex_app/screens/auth/otp_verification_screen.dart';
import 'package:saarflex_app/widgets/form_helpers.dart';
import 'package:saarflex_app/profile/utils/profile_helpers.dart';
import 'package:saarflex_app/profile/widgets/profile_section.dart';
import 'package:saarflex_app/profile/widgets/profile_info_row.dart';
import 'package:saarflex_app/profile/widgets/profile_header.dart';
import 'package:saarflex_app/profile/widgets/profile_action_button.dart';
import 'package:saarflex_app/profile/widgets/image_display_widget.dart';
import '../models/user_model.dart';
import '../../constants/colors.dart';
import '../../utils/image_labels.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _changePassword() async {
    final authProvider = context.read<AuthProvider>();
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
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_rounded,
                color: AppColors.textPrimary,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              "Mon Profil",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                ProfileHeader(user: user),
                const SizedBox(height: 32),
                _buildEditButton(),
                const SizedBox(height: 24),
                _buildPersonalInfoSection(user),
                const SizedBox(height: 20),
                _buildIdentitySection(user),
                const SizedBox(height: 20),
                _buildIdentityImagesSection(user),
                const SizedBox(height: 32),
                _buildActionButtons(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIdentityImagesSection(User? user) {
    // Utiliser les labels contextuels selon le type de pièce
    final rectoLabel = ImageLabels.getRectoLabel(user?.identityType);
    final versoLabel = ImageLabels.getVersoLabel(user?.identityType);
    final sectionTitle = ImageLabels.getUploadTitle(user?.identityType);

    return ProfileSection(
      title: sectionTitle,
      icon: Icons.photo_library_rounded,
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
          ),

        const SizedBox(height: 12),

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
          ),
      ],
    );
  }

  // Méthode pour naviguer vers l'édition du profil
  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfileScreenRefactored()),
    );
  }

  Widget _buildEditButton() {
    return ProfileActionButton(
      text: "Modifier mon profil",
      icon: Icons.edit_rounded,
      onPressed: _navigateToEditProfile,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      borderColor: AppColors.primary,
    );
  }

  Widget _buildPersonalInfoSection(User? user) {
    return ProfileSection(
      title: "Informations personnelles",
      icon: Icons.person_rounded,
      children: [
        ProfileInfoRow(label: "Nom", value: user?.nom ?? "Non renseigné"),
        ProfileInfoRow(label: "Email", value: user?.email ?? "Non renseigné"),
        ProfileInfoRow(
          label: "Téléphone",
          value: user?.telephone ?? "Non renseigné",
        ),
        ProfileInfoRow(label: "Sexe", value: user?.gender ?? "Non renseigné"),
        ProfileInfoRow(
          label: "Date de naissance",
          value: ProfileHelpers.formatDate(user?.birthDate) ?? "Non renseignée",
        ),
        ProfileInfoRow(
          label: "Lieu de naissance",
          value: user?.birthPlace ?? "Non renseigné",
        ),
        ProfileInfoRow(
          label: "Nationalité",
          value: user?.nationality ?? "Non renseignée",
        ),
        ProfileInfoRow(
          label: "Profession",
          value: user?.profession ?? "Non renseignée",
        ),
        ProfileInfoRow(
          label: "Adresse",
          value: user?.address ?? "Non renseignée",
        ),
      ],
    );
  }

  Widget _buildIdentitySection(User? user) {
    return ProfileSection(
      title: "Informations d'identité",
      icon: Icons.badge_rounded,
      children: [
        ProfileInfoRow(
          label: "Type de pièce",
          value: ProfileHelpers.getTypePieceIdentiteLabel(user?.identityType),
        ),
        ProfileInfoRow(
          label: "Numéro de pièce",
          value: user?.identityNumber ?? "Non renseigné",
        ),
        ProfileInfoRow(
          label: "Date d'expiration",
          value:
              ProfileHelpers.formatDate(user?.identityExpirationDate) ??
              "Non renseignée",
          isExpirationDate: true,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
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
        ),
        const SizedBox(height: 12),
        ProfileActionButton(
          text: "Se déconnecter",
          icon: Icons.logout_rounded,
          onPressed: _showLogoutDialog,
          backgroundColor: AppColors.error,
          foregroundColor: AppColors.error,
          borderColor: AppColors.error,
          isOutlined: true,
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
      await context.read<AuthProvider>().logout();
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

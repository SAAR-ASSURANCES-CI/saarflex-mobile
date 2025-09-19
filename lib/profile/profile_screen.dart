import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:saarflex_app/profile/edit_profile_screen.dart';
import 'package:saarflex_app/providers/auth_provider.dart';
import 'package:saarflex_app/screens/auth/otp_verification_screen.dart';
import 'package:saarflex_app/widgets/form_helpers.dart';
import '../models/user_model.dart';
import '../../constants/colors.dart';
import '../../utils/image_labels.dart';
import '../../services/api_service.dart';

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

  String _getTypePieceIdentiteLabel(String? type) {
    switch (type?.toLowerCase()) {
      case 'cni':
        return 'Carte Nationale d\'Identité';
      case 'passport':
        return 'Passeport';
      case 'permis':
        return 'Permis de conduire';
      case 'carte_sejour':
        return 'Carte de séjour';
      default:
        return type ?? 'Non renseigné';
    }
  }

  String? _formatDate(DateTime? date) {
    if (date == null) return null;
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
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
                _buildProfileHeader(user),
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

    return _buildSection(
      title: sectionTitle,
      icon: Icons.photo_library_rounded,
      children: [
        if (user?.frontDocumentPath != null &&
            user!.frontDocumentPath!.isNotEmpty)
          _buildImageRow(rectoLabel, user.frontDocumentPath!)
        else
          _buildInfoRow(rectoLabel, "Non téléchargé", isWarning: true),

        const SizedBox(height: 12),

        if (user?.backDocumentPath != null &&
            user!.backDocumentPath!.isNotEmpty)
          _buildImageRow(versoLabel, user.backDocumentPath!)
        else
          _buildInfoRow(versoLabel, "Non téléchargé", isWarning: true),
      ],
    );
  }

  // Méthode pour afficher l'image en plein écran
  void _showImageDialog(String imageUrl, String label) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              // Image en plein écran
              Center(
                child: InteractiveViewer(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.surfaceVariant,
                        child: Icon(
                          Icons.error_outline_rounded,
                          color: AppColors.error,
                          size: 60,
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Bouton de fermeture
              Positioned(
                top: 40,
                right: 20,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: Colors.white, size: 24),
                  ),
                ),
              ),
              // Label de l'image
              Positioned(
                bottom: 40,
                left: 20,
                right: 20,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    label,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Méthode pour naviguer vers l'édition du profil
  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfileScreen()),
    );
  }

  Widget _buildImageRow(String label, String imageUrl) {
    print('🔍 DEBUG Profile Screen Image:');
    print('   - Label: $label');
    print('   - Image URL: $imageUrl');

    // SOLUTION SIMPLE : Afficher les images si elles existent
    final hasRealImage =
        imageUrl.isNotEmpty && imageUrl != 'null' && imageUrl != 'undefined';

    print('   - Has real image: $hasRealImage');
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _showImageDialog(
                      imageUrl.startsWith('http')
                          ? imageUrl
                          : 'http://192.168.4.179:3000/$imageUrl',
                      label,
                    ),
                    icon: Icon(
                      Icons.visibility,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    tooltip: 'Voir en grand',
                  ),
                  IconButton(
                    onPressed: () => _navigateToEditProfile(),
                    icon: Icon(
                      Icons.edit,
                      size: 20,
                      color: AppColors.secondary,
                    ),
                    tooltip: 'Modifier',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _showImageDialog(
              imageUrl.startsWith('http')
                  ? imageUrl
                  : 'http://192.168.4.179:3000/$imageUrl',
              label,
            ),
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: hasRealImage
                    ? Image.network(
                        imageUrl.startsWith('http')
                            ? imageUrl
                            : 'http://192.168.4.179:3000/$imageUrl',
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          print('🔍 DEBUG Image Error: $error');
                          return Container(
                            color: Colors.grey[100],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.photo_library_outlined,
                                  color: Colors.grey[400],
                                  size: 40,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Image non disponible',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[100],
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.photo_library_outlined,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Image non disponible',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(User? user) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.2),
                spreadRadius: 0,
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(Icons.person_rounded, color: AppColors.white, size: 50),
        ),
        const SizedBox(height: 16),
        Text(
          user?.nom ?? "Utilisateur",
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          user?.email ?? "Email non renseigné",
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildEditButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EditProfileScreen()),
          );
        },
        icon: const Icon(Icons.edit_rounded, size: 18),
        label: Text(
          "Modifier mon profil",
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection(User? user) {
    return _buildSection(
      title: "Informations personnelles",
      icon: Icons.person_rounded,
      children: [
        _buildInfoRow("Nom", user?.nom ?? "Non renseigné"),
        _buildInfoRow("Email", user?.email ?? "Non renseigné"),
        _buildInfoRow("Téléphone", user?.telephone ?? "Non renseigné"),
        _buildInfoRow("Sexe", user?.gender ?? "Non renseigné"),
        _buildInfoRow(
          "Date de naissance",
          _formatDate(user?.birthDate) ?? "Non renseignée",
        ),
        _buildInfoRow("Lieu de naissance", user?.birthPlace ?? "Non renseigné"),
        _buildInfoRow("Nationalité", user?.nationality ?? "Non renseignée"),
        _buildInfoRow("Profession", user?.profession ?? "Non renseignée"),
        _buildInfoRow("Adresse", user?.address ?? "Non renseignée"),
      ],
    );
  }

  Widget _buildIdentitySection(User? user) {
    return _buildSection(
      title: "Informations d'identité",
      icon: Icons.badge_rounded,
      children: [
        _buildInfoRow(
          "Type de pièce",
          _getTypePieceIdentiteLabel(user?.identityType),
        ),
        _buildInfoRow(
          "Numéro de pièce",
          user?.identityNumber ?? "Non renseigné",
        ),
        _buildInfoRow(
          "Date d'expiration",
          _formatDate(user?.identityExpirationDate) ?? "Non renseignée",
          isExpirationDate: true,
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
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
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isExpirationDate = false,
    bool isWarning = false,
  }) {
    Color? valueColor;

    if (isWarning) {
      valueColor = AppColors.warning;
    } else if (isExpirationDate && value != "Non renseignée") {
      try {
        final parts = value.split('/');
        if (parts.length == 3) {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          final expirationDate = DateTime(year, month, day);
          final now = DateTime.now();
          final daysUntilExpiration = expirationDate.difference(now).inDays;

          if (daysUntilExpiration < 0) {
            valueColor = AppColors.error;
          } else if (daysUntilExpiration <= 30) {
            valueColor = AppColors.warning;
          } else {
            valueColor = AppColors.success;
          }
        }
      } catch (e) {
        valueColor = AppColors.textPrimary;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: valueColor ?? AppColors.textPrimary,
                    ),
                  ),
                ),
                if (isWarning)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Tooltip(
                      message: "À compléter",
                      child: Icon(
                        Icons.warning_rounded,
                        color: AppColors.warning,
                        size: 16,
                      ),
                    ),
                  ),
                if (isExpirationDate && valueColor == AppColors.warning)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Tooltip(
                      message: "Expire bientôt",
                      child: Icon(
                        Icons.warning_rounded,
                        color: AppColors.warning,
                        size: 16,
                      ),
                    ),
                  ),
                if (isExpirationDate && valueColor == AppColors.error)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Tooltip(
                      message: "Pièce expirée",
                      child: Icon(
                        Icons.error_rounded,
                        color: AppColors.error,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _changePassword(),
            icon: const Icon(Icons.lock_reset_rounded, size: 18),
            label: Text(
              "Changer le mot de passe",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.warning,
              side: BorderSide(color: AppColors.warning),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showLogoutDialog(),
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: Text(
              "Se déconnecter",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
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

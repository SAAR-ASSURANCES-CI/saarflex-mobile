import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:saarflex_app/profile/edit_profile_screen.dart';
import 'package:saarflex_app/providers/auth_provider.dart';
import 'package:saarflex_app/screens/auth/otp_verification_screen.dart';
import 'package:saarflex_app/widgets/form_helpers.dart';
import '../models/user_model.dart';
import '../../constants/colors.dart';

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

    FormHelpers.showLoadingDialog(
      context,
      title: "Envoi en cours...",
      subtitle: "Nous envoyons le code de vérification\nà votre adresse email",
    );

    try {
      final success = await authProvider.forgotPassword(user.email);
      FormHelpers.hideLoadingDialog(context);

      if (success) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpVerificationScreen(email: user.email),
          ),
        );
      }
    } catch (e) {
      FormHelpers.hideLoadingDialog(context);
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
              icon: Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
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
          child: Icon(
            Icons.person_rounded,
            color: AppColors.white,
            size: 50,
          ),
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
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
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
        _buildInfoRow("Sexe", user?.sexe ?? "Non renseigné"),
        _buildInfoRow("Lieu de naissance", user?.lieuNaissance ?? "Non renseigné"),
        _buildInfoRow("Nationalité", user?.nationalite ?? "Non renseignée"),
        _buildInfoRow("Profession", user?.profession ?? "Non renseignée"),
        _buildInfoRow("Adresse", user?.adresse ?? "Non renseignée"),
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
          _getTypePieceIdentiteLabel(user?.typePieceIdentite),
        ),
        _buildInfoRow(
          "Numéro de pièce",
          user?.numeroPieceIdentite ?? "Non renseigné",
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
                  child: Icon(
                    icon,
                    color: AppColors.primary,
                    size: 20,
                  ),
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

  Widget _buildInfoRow(String label, String value) {
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
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
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
    FormHelpers.showLoadingDialog(
      context,
      title: "Déconnexion...",
      subtitle: "Fermeture de votre session",
    );

    try {
      await context.read<AuthProvider>().logout();
      FormHelpers.hideLoadingDialog(context);
      Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
    } catch (e) {
      FormHelpers.hideLoadingDialog(context);
      FormHelpers.showErrorSnackBar(context, "Erreur lors de la déconnexion");
    }
  }
}
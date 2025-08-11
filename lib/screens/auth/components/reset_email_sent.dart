import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/colors.dart';
import '../../../providers/auth_provider.dart';
import 'reset_password_widgets.dart';

class ResetEmailSent extends StatelessWidget {
  final String email;
  final AuthProvider authProvider;

  const ResetEmailSent({
    super.key,
    required this.email,
    required this.authProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        _buildConfirmationMessage(),
        const SizedBox(height: 32),
        _buildResendButton(context),
        const SizedBox(height: 16),
        _buildBackButton(context),
        const SizedBox(height: 24),
        _buildHelpInfo(),
      ],
    );
  }

  Widget _buildConfirmationMessage() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.secondary,
            size: 24,
          ),
          const SizedBox(height: 12),
          Text(
            "Email envoyé à :",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.primary.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResendButton(BuildContext context) {
    return ResetPasswordWidgets.buildModernButton(
      text: "Renvoyer l'email",
      onPressed: () => _handleResendEmail(context),
      icon: Icons.refresh_rounded,
      backgroundColor: AppColors.secondary,
      textColor: Colors.black,
      isEnabled: true,
      isLoading: authProvider.isLoading,
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return ResetPasswordWidgets.buildModernButton(
      text: "Retour à la connexion",
      onPressed: authProvider.isLoading ? null : () => Navigator.pop(context),
      icon: Icons.login_rounded,
      backgroundColor: Colors.transparent,
      textColor: AppColors.primary,
      borderColor: AppColors.primary,
      isEnabled: true,
      isLoading: false,
    );
  }

  Widget _buildHelpInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            color: AppColors.primary.withOpacity(0.7),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Vérifiez aussi vos spams si vous ne recevez pas l'email.",
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.primary.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleResendEmail(BuildContext context) async {
    final success = await authProvider.forgotPassword(email);

    if (success) {
      ResetPasswordWidgets.showSuccessSnackBar(
        context,
        "Code renvoyé avec succès !",
      );
    }
  }
}

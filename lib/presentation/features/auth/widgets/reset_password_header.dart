import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarflex_app/core/constants/colors.dart';

class ResetPasswordHeader extends StatelessWidget {
  final bool isEmailSent;

  const ResetPasswordHeader({
    super.key,
    required this.isEmailSent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildIcon(),
        const SizedBox(height: 32),
        _buildTitle(),
        const SizedBox(height: 12),
        _buildSubtitle(),
      ],
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: isEmailSent 
            ? AppColors.secondaryGradient
            : AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isEmailSent ? AppColors.secondary : AppColors.primary).withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        isEmailSent ? Icons.mark_email_read_rounded : Icons.lock_reset_rounded,
        size: 50,
        color: isEmailSent ? AppColors.textPrimary : AppColors.white,
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      isEmailSent ? "Email envoyé !" : "Réinitialiser votre mot de passe",
      style: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        isEmailSent 
            ? "Vérifiez votre boîte mail et suivez les instructions pour créer un nouveau mot de passe."
            : "Saisissez votre adresse email pour recevoir un lien de réinitialisation.",
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
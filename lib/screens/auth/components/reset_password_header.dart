import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/colors.dart';

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
        const SizedBox(height: 24),
        _buildTitle(),
        const SizedBox(height: 12),
        _buildSubtitle(),
      ],
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isEmailSent 
            ? AppColors.secondary.withOpacity(0.2)
            : AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isEmailSent 
              ? AppColors.secondary.withOpacity(0.3)
              : AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Icon(
        isEmailSent ? Icons.mark_email_read_rounded : Icons.lock_reset_rounded,
        size: 50,
        color: isEmailSent ? AppColors.secondary : AppColors.primary,
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      isEmailSent ? "Email envoyé !" : "Réinitialiser votre mot de passe",
      style: GoogleFonts.poppins(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle() {
    return Text(
      isEmailSent 
          ? "Vérifiez votre boîte mail et suivez les instructions pour créer un nouveau mot de passe."
          : "Saisissez votre adresse email pour recevoir un lien de réinitialisation.",
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.primary.withOpacity(0.7),
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    );
  }
}
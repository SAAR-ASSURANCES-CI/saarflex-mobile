// import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/colors.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isEmailSent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withOpacity(0.1),
              AppColors.white,
              AppColors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  foregroundColor: AppColors.primary,
                  title: Text(
                    "Mot de passe oublié",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              
              // Contenu défilable
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      
                      // Icône et titre selon l'état
                      _buildHeader(),

                      const SizedBox(height: 32),
                      
                      // Contenu selon l'état
                      if (!_isEmailSent) ...[
                        _buildResetForm(),
                      ] else ...[
                        _buildEmailSentContent(),
                      ],

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // En-tête avec icône
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _isEmailSent 
                ? AppColors.secondary.withOpacity(0.2)
                : AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isEmailSent 
                  ? AppColors.secondary.withOpacity(0.3)
                  : AppColors.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Icon(
            _isEmailSent ? Icons.mark_email_read_rounded : Icons.lock_reset_rounded,
            size: 50,
            color: _isEmailSent ? AppColors.secondary : AppColors.primary,
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Titre
        Text(
          _isEmailSent ? "Email envoyé !" : "Réinitialiser votre mot de passe",
          style: GoogleFonts.poppins(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 12),
        
        // Sous-titre
        Text(
          _isEmailSent 
              ? "Vérifiez votre boîte mail et suivez les instructions pour créer un nouveau mot de passe."
              : "Saisissez votre adresse email pour recevoir un lien de réinitialisation.",
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.primary.withOpacity(0.7),
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildResetForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        
        Text(
          "Adresse email",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        
        const SizedBox(height: 16),

        _buildModernTextField(
          controller: _emailController,
          label: 'Votre email',
          icon: Icons.email_rounded,
          keyboardType: TextInputType.emailAddress,
        ),

        const SizedBox(height: 32),

        // Bouton d'envoi
        _buildModernButton(
          text: "Envoyer le lien",
          onPressed: () {
            if (_emailController.text.isNotEmpty) {
              // TODO: Appeler le service de reset password
              setState(() {
                _isEmailSent = true;
              });
            } else {
              _showErrorSnackBar("Veuillez saisir votre adresse email");
            }
          },
          icon: Icons.send_rounded,
          backgroundColor: AppColors.primary,
        ),

        const SizedBox(height: 24),
        
        // Divider avec texte "OU"
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: AppColors.primary.withOpacity(0.3),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "OU",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary.withOpacity(0.7),
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                color: AppColors.primary.withOpacity(0.3),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Bouton retour à la connexion
        _buildModernButton(
          text: "Retour à la connexion",
          onPressed: () => Navigator.pop(context),
          icon: Icons.login_rounded,
          backgroundColor: Colors.transparent,
          textColor: AppColors.primary,
          borderColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildEmailSentContent() {
    return Column(
      children: [
        const SizedBox(height: 24),
        
        // Message de confirmation avec style
        Container(
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
                _emailController.text,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Actions après envoi
        _buildModernButton(
          text: "Renvoyer l'email",
          onPressed: () {
            // TODO: Renvoyer l'email de reset
            _showSuccessSnackBar("Email renvoyé avec succès !");
          },
          icon: Icons.refresh_rounded,
          backgroundColor: AppColors.secondary,
          textColor: Colors.black,
        ),

        const SizedBox(height: 16),
        
        _buildModernButton(
          text: "Retour à la connexion",
          onPressed: () => Navigator.pop(context),
          icon: Icons.login_rounded,
          backgroundColor: Colors.transparent,
          textColor: AppColors.primary,
          borderColor: AppColors.primary,
        ),

        const SizedBox(height: 24),
        
        // Info supplémentaire
        Container(
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
        ),
      ],
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            color: AppColors.primary.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: AppColors.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: AppColors.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildModernButton({
    required String text,
    required VoidCallback onPressed,
    required IconData icon,
    required Color backgroundColor,
    Color? textColor,
    Color? borderColor,
  }) {
    final isOutlined = backgroundColor == Colors.transparent;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: !isOutlined ? [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ] : null,
        border: isOutlined && borderColor != null 
            ? Border.all(color: borderColor, width: 2)
            : null,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor ?? AppColors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[400],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
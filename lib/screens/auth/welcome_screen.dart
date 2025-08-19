
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:saarflex_app/screens/auth/login_screen.dart';
import '../../constants/colors.dart';
import 'signup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            children: [
              Expanded(
                flex: 6,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 100),

                    FadeInDown(
                      duration: const Duration(milliseconds: 800),
                      child: Container(
                        height: 140,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.15),
                              spreadRadius: 0,
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            'lib/assets/images/saar.png',
                            fit: BoxFit.cover,
                            semanticLabel: "Logo SAAR Assurance",
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 50),

                    FadeInUp(
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 500),
                      child: Text(
                        'SAAR Assurances\nUn réservoir de sécurité',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const Spacer(),
                  ],
                ),
              ),

              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 700),
                      child: _buildSimpleButton(
                        text: 'Se connecter',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },
                        isPrimary: true,
                      ),
                    ),

                    const SizedBox(height: 16),

                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 900),
                      child: _buildSimpleButton(
                        text: 'Créer un compte',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SignupScreen(),
                            ),
                          );
                        },
                        isPrimary: false,
                      ),
                    ),

                    const SizedBox(height: 32),

                    FadeInUp(
                      duration: const Duration(milliseconds: 400),
                      delay: const Duration(milliseconds: 1100),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "En continuant, vous acceptez nos Conditions Générales d'Utilisation",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textHint,
                            fontWeight: FontWeight.w400,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleButton({
    required String text,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isPrimary ? AppColors.primary : AppColors.surface,
        border: isPrimary
            ? null
            : Border.all(color: AppColors.border, width: 1.5),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.25),
                  spreadRadius: 0,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isPrimary ? AppColors.white : AppColors.textPrimary,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:saarciflex_app/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:saarciflex_app/presentation/features/auth/screens/login_screen.dart';
import 'signup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final screenHeight = constraints.maxHeight;
            final textScaleFactor = MediaQuery.of(context).textScaleFactor;
            
            final horizontalPadding = screenWidth < 360 
                ? 16.0 
                : screenWidth < 600 
                    ? 24.0 
                    : (screenWidth * 0.08).clamp(24.0, 48.0);
            final verticalPadding = screenHeight < 600 
                ? 16.0 
                : 24.0;
            
            final logoContainerHeight = (screenWidth * 0.6).clamp(180.0, 280.0);
            final logoSize = (screenWidth * 0.5).clamp(180.0, 250.0);
            final decorativeCircleSize = (screenWidth * 0.3).clamp(80.0, 120.0);
            final titleFontSize = (28.0 / textScaleFactor).clamp(22.0, 32.0);
            final subtitleFontSize = (16.0 / textScaleFactor).clamp(14.0, 18.0);
            final buttonFontSize = (16.0 / textScaleFactor).clamp(14.0, 18.0);
            final termsFontSize = (12.0 / textScaleFactor).clamp(10.0, 14.0);
            
            final topSpacing = screenHeight < 600 ? 10.0 : 20.0;
            final logoToTitleSpacing = screenHeight < 600 ? 24.0 : 40.0;
            final titleToSubtitleSpacing = screenHeight < 600 ? 12.0 : 16.0;
            final contentToButtonsSpacing = screenHeight < 600 ? 24.0 : 32.0;
            final buttonSpacing = screenHeight < 600 ? 12.0 : 16.0;
            final bottomSpacing = screenHeight < 600 ? 16.0 : 20.0;
            
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: verticalPadding,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(height: topSpacing),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FadeInDown(
                            duration: const Duration(milliseconds: 800),
                            child: Container(
                              height: logoContainerHeight,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.primary.withOpacity(0.1),
                                    AppColors.secondary.withOpacity(0.15),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(32),
                              ),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned(
                                    right: -decorativeCircleSize * 0.15,
                                    top: -decorativeCircleSize * 0.15,
                                    child: Container(
                                      width: decorativeCircleSize,
                                      height: decorativeCircleSize,
                                      decoration: BoxDecoration(
                                        color: AppColors.secondary
                                            .withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(
                                          decorativeCircleSize / 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: SizedBox(
                                      width: logoSize,
                                      height: logoSize,
                                      child: Padding(
                                        padding: EdgeInsets.all(
                                          screenWidth < 360 ? 12.0 : 16.0,
                                        ),
                                        child: Image.asset(
                                          'lib/assets/logoSaarCI.png',
                                          fit: BoxFit.contain,
                                          semanticLabel:
                                              "Logo SAAR Assurance",
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: logoToTitleSpacing),
                          FadeInUp(
                            duration: const Duration(milliseconds: 800),
                            delay: const Duration(milliseconds: 300),
                            child: Text(
                              'SAAR Assurances',
                              style: GoogleFonts.poppins(
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                height: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: titleToSubtitleSpacing),
                          FadeInUp(
                            duration: const Duration(milliseconds: 800),
                            delay: const Duration(milliseconds: 500),
                            child: Text(
                              'Un réservoir de sécurité',
                              style: GoogleFonts.poppins(
                                fontSize: subtitleFontSize,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: contentToButtonsSpacing                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FadeInUp(
                            duration: const Duration(milliseconds: 600),
                            delay: const Duration(milliseconds: 700),
                            child: Container(
                              width: double.infinity,
                              height: screenWidth < 360 ? 52 : 56,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.primaryLight,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    spreadRadius: 0,
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const SignupScreen(),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(28),
                                  child: Center(
                                    child: Text(
                                      'Créer un compte',
                                      style: GoogleFonts.poppins(
                                        fontSize: buttonFontSize,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: buttonSpacing),
                          FadeInUp(
                            duration: const Duration(milliseconds: 600),
                            delay: const Duration(milliseconds: 900),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: screenHeight < 600 ? 12.0 : 16.0,
                                ),
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    style: GoogleFonts.poppins(
                                      fontSize: buttonFontSize,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.textSecondary,
                                    ),
                                    children: [
                                      const TextSpan(
                                        text: 'Déjà un compte ? ',
                                      ),
                                      TextSpan(
                                        text: 'Se connecter',
                                        style: GoogleFonts.poppins(
                                          fontSize: buttonFontSize,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight < 600 ? 8.0 : 12.0),
                          FadeInUp(
                            duration: const Duration(milliseconds: 400),
                            delay: const Duration(milliseconds: 1100),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth < 360 ? 8.0 : 16.0,
                              ),
                              child: Text(
                                "En continuant, vous acceptez nos Conditions Générales d'Utilisation",
                                style: GoogleFonts.poppins(
                                  fontSize: termsFontSize,
                                  color: AppColors.textHint,
                                  fontWeight: FontWeight.w400,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          SizedBox(height: bottomSpacing),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

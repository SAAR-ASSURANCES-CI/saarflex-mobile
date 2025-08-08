import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.primary.withOpacity(0.8),
              AppColors.primary.withOpacity(0.9),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        spreadRadius: 5,
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'lib/assets/images/welcome_img.png',
                      height: 120,
                      semanticLabel: "Logo SAAR Assurance",
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                  ),
                ),

                const SizedBox(height: 30),

                Text(
                  'SAAR Assurance',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                    letterSpacing: 1.5,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'Chargement en cours...',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.white.withOpacity(0.9),
                  ),
                ),

                const SizedBox(height: 50),

                _buildLoadingDots(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 600 + (index * 100)),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.5, end: 1.0),
            duration: Duration(milliseconds: 800),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(value),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            },
            onEnd: () {
            },
          ),
        );
      }),
    );
  }
}
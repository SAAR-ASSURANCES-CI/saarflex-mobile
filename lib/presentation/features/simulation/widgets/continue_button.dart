import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarciflex_app/core/constants/colors.dart';

class ContinueButton extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback onPressed;
  final bool isLoading;
  final String text;

  const ContinueButton({
    super.key,
    required this.isEnabled,
    required this.onPressed,
    this.isLoading = false,
    this.text = 'Continuer',
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    
    // Tailles adaptatives
    final buttonHeight = screenWidth < 360 ? 48.0 : 50.0;
    final fontSize = (16.0 / textScaleFactor).clamp(14.0, 18.0);
    
    return Container(
      width: double.infinity,
      height: buttonHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: isEnabled && !isLoading ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled
              ? AppColors.primary
              : AppColors.textSecondary,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: GoogleFonts.poppins(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

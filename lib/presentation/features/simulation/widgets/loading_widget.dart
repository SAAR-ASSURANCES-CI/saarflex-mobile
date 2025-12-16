import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarciflex_app/core/constants/colors.dart';

class SimulationLoadingWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final double size;

  const SimulationLoadingWidget({
    super.key,
    this.title = 'Chargement...',
    this.subtitle = 'Veuillez patienter',
    this.size = 60.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(size / 2),
            ),
            child: Center(
              child: SizedBox(
                width: size * 0.5,
                height: size * 0.5,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  strokeWidth: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class SimulationLoadingCompactWidget extends StatelessWidget {
  final String message;
  final double size;

  const SimulationLoadingCompactWidget({
    super.key,
    this.message = 'Chargement...',
    this.size = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            strokeWidth: 2,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          message,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

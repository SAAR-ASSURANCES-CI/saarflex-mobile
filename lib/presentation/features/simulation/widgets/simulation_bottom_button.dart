import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarflex_app/core/constants/colors.dart';
import 'package:saarflex_app/presentation/features/simulation/viewmodels/simulation_viewmodel.dart';

/// Widget du bouton en bas de l'écran de simulation
class SimulationBottomButton extends StatelessWidget {
  final SimulationViewModel provider;
  final VoidCallback onSimulate;

  const SimulationBottomButton({
    super.key,
    required this.provider,
    required this.onSimulate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: provider.canSimulate ? onSimulate : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: provider.canSimulate
                ? AppColors.primary
                : AppColors.textSecondary,
            foregroundColor: AppColors.white,
            elevation: 0,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: provider.isSimulating
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  'Obtenir mon devis',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}

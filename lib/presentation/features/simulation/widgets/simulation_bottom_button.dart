import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarciflex_app/core/constants/colors.dart';
import 'package:saarciflex_app/presentation/features/simulation/viewmodels/simulation_viewmodel.dart';

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
    final viewInsets = MediaQuery.of(context).viewInsets;
    final bottomPadding = viewInsets.bottom > 0 ? viewInsets.bottom : 0.0;
    final screenWidth = MediaQuery.of(context).size.width;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    
    final fontSize = (16.0 / textScaleFactor).clamp(14.0, 18.0);
    final horizontalPadding = screenWidth < 360 ? 16.0 : 24.0;
    final verticalPadding = screenWidth < 360 ? 16.0 : 24.0;
    
    return Container(
      padding: EdgeInsets.only(
        left: horizontalPadding,
        right: horizontalPadding,
        top: verticalPadding,
        bottom: verticalPadding + bottomPadding,
      ),
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
        top: false,
        child: ElevatedButton(
          onPressed: provider.canSimulate ? onSimulate : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: provider.canSimulate
                ? AppColors.primary
                : AppColors.textSecondary,
            foregroundColor: AppColors.white,
            elevation: 0,
            minimumSize: Size(
              double.infinity,
              screenWidth < 360 ? 48 : 50,
            ),
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
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}

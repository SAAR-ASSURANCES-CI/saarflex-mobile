import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarciflex_app/core/constants/colors.dart';
import 'package:saarciflex_app/presentation/features/products/viewmodels/product_viewmodel.dart';

class ProductListErrorState extends StatelessWidget {
  final String errorMessage;
  final ProductViewModel productProvider;

  const ProductListErrorState({
    super.key,
    required this.errorMessage,
    required this.productProvider,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final padding = screenWidth < 360 ? 24.0 : 32.0;
    final iconSize = screenWidth < 360 ? 52.0 : screenWidth < 600 ? 58.0 : 64.0;
    final titleFontSize = (20.0 / textScaleFactor).clamp(18.0, 22.0);
    final messageFontSize = (14.0 / textScaleFactor).clamp(12.0, 16.0);
    final buttonFontSize = (14.0 / textScaleFactor).clamp(12.0, 16.0);
    final spacing1 = screenWidth < 360 ? 20.0 : 24.0;
    final spacing2 = screenWidth < 360 ? 6.0 : 8.0;
    final spacing3 = screenWidth < 360 ? 20.0 : 24.0;
    final buttonPaddingH = screenWidth < 360 ? 20.0 : 24.0;
    final buttonPaddingV = screenWidth < 360 ? 10.0 : 12.0;
    final iconButtonSize = screenWidth < 360 ? 18.0 : 20.0;
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: AppColors.error, size: iconSize),
            SizedBox(height: spacing1),
            Text(
              'Erreur de chargement',
              style: GoogleFonts.poppins(
                fontSize: titleFontSize,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: spacing2),
            Text(
              errorMessage,
              style: GoogleFonts.poppins(
                fontSize: messageFontSize,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: spacing3),
            ElevatedButton.icon(
              onPressed: () => productProvider.loadProducts(),
              icon: Icon(Icons.refresh, size: iconButtonSize),
              label: Text(
                'Réessayer',
                style: GoogleFonts.poppins(
                  fontSize: buttonFontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: buttonPaddingH,
                  vertical: buttonPaddingV,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

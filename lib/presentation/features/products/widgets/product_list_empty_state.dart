import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductListEmptyState extends StatelessWidget {
  const ProductListEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final padding = screenWidth < 360 ? 24.0 : 32.0;
    final containerSize = screenWidth < 360 ? 64.0 : screenWidth < 600 ? 72.0 : 80.0;
    final iconSize = screenWidth < 360 ? 32.0 : screenWidth < 600 ? 36.0 : 40.0;
    final titleFontSize = (20.0 / textScaleFactor).clamp(18.0, 22.0);
    final messageFontSize = (14.0 / textScaleFactor).clamp(12.0, 16.0);
    final spacing1 = screenWidth < 360 ? 20.0 : 24.0;
    final spacing2 = screenWidth < 360 ? 6.0 : 8.0;
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: containerSize,
              height: containerSize,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                color: Colors.grey.shade500,
                size: iconSize,
              ),
            ),
            SizedBox(height: spacing1),
            Text(
              'Aucun produit disponible',
              style: GoogleFonts.poppins(
                fontSize: titleFontSize,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: spacing2),
            Text(
              'Il n\'y a actuellement aucun produit d\'assurance disponible.',
              style: GoogleFonts.poppins(
                fontSize: messageFontSize,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

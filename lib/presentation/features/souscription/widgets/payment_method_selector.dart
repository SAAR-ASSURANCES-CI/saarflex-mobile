import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarflex_app/core/constants/colors.dart';
import 'package:saarflex_app/data/models/souscription_model.dart';

class PaymentMethodSelector extends StatelessWidget {
  final MethodePaiement? selectedMethod;
  final Function(MethodePaiement) onMethodSelected;
  final bool hasError;
  final String? errorText;
  final double screenWidth;
  final double textScaleFactor;

  const PaymentMethodSelector({
    super.key,
    this.selectedMethod,
    required this.onMethodSelected,
    required this.screenWidth,
    required this.textScaleFactor,
    this.hasError = false,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final titleFontSize = (18.0 / textScaleFactor).clamp(16.0, 20.0);
    final errorFontSize = (12.0 / textScaleFactor).clamp(10.0, 14.0);
    final spacing1 = screenWidth < 360 ? 12.0 : 16.0;
    final spacing2 = screenWidth < 360 ? 6.0 : 8.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Méthode de paiement',
          style: GoogleFonts.poppins(
            fontSize: titleFontSize,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        SizedBox(height: spacing1),
        ...MethodePaiement.values.map((method) => _buildMethodCard(method)),
        if (hasError && errorText != null) ...[
          SizedBox(height: spacing2),
          Text(
            errorText!,
            style: GoogleFonts.poppins(
              fontSize: errorFontSize,
              color: AppColors.error,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildMethodCard(MethodePaiement method) {
    final isSelected = selectedMethod == method;
    final cardMargin = screenWidth < 360 ? 6.0 : 8.0;
    final horizontalPadding = screenWidth < 360 ? 12.0 : 16.0;
    final verticalPadding = screenWidth < 360 ? 10.0 : 12.0;
    final textFontSize = (16.0 / textScaleFactor).clamp(14.0, 18.0);
    final spacing = screenWidth < 360 ? 12.0 : 16.0;
    final checkSize = screenWidth < 360 ? 20.0 : 24.0;
    final checkIconSize = screenWidth < 360 ? 14.0 : 16.0;
    final borderWidth = screenWidth < 360 ? 1.5 : 2.0;

    return Container(
      margin: EdgeInsets.only(bottom: cardMargin),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onMethodSelected(method),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFE3F2FD)
                  : const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(
                      color: const Color(0xFF2196F3),
                      width: borderWidth,
                    )
                  : null,
            ),
            child: Row(
              children: [
                _buildMethodLogo(method),
                SizedBox(width: spacing),
                Expanded(
                  child: Text(
                    method.displayName,
                    style: GoogleFonts.poppins(
                      fontSize: textFontSize,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A1A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSelected)
                  Container(
                    width: checkSize,
                    height: checkSize,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2196F3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: checkIconSize,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMethodLogo(MethodePaiement method) {
    final logoSize = screenWidth < 360 ? 36.0 : 40.0;
    final iconSize = screenWidth < 360 ? 20.0 : 24.0;
    
    switch (method) {
      case MethodePaiement.wave:
        return Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            color: const Color(0xFF87CEEB),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Image.asset(
            'lib/assets/wave.png',
            width: iconSize,
            height: iconSize,
          ),
        );
      case MethodePaiement.mobileMoney:
        return Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.account_balance_wallet,
            color: Colors.white,
            size: iconSize,
          ),
        );
    }
  }
}

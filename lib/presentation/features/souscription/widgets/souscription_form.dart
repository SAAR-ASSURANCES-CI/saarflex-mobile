import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarciflex_app/core/constants/colors.dart';
import 'package:saarciflex_app/data/models/souscription_model.dart';

class souscriptionForm extends StatelessWidget {
  final String phoneNumber;
  final Function(String) onPhoneChanged;
  final bool hasError;
  final String? errorText;
  final String? userPhone;
  final MethodePaiement? selectedPaymentMethod;
  final double screenWidth;
  final double textScaleFactor;

  const souscriptionForm({
    super.key,
    required this.phoneNumber,
    required this.onPhoneChanged,
    required this.screenWidth,
    required this.textScaleFactor,
    this.hasError = false,
    this.errorText,
    this.userPhone,
    this.selectedPaymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    final titleFontSize = (16.0 / textScaleFactor).clamp(14.0, 18.0);
    final descriptionFontSize = (14.0 / textScaleFactor).clamp(12.0, 16.0);
    final inputFontSize = (16.0 / textScaleFactor).clamp(14.0, 18.0);
    final errorFontSize = (12.0 / textScaleFactor).clamp(10.0, 14.0);
    final spacing1 = screenWidth < 360 ? 6.0 : 8.0;
    final spacing2 = screenWidth < 360 ? 10.0 : 12.0;
    final spacing3 = screenWidth < 360 ? 6.0 : 8.0;
    final iconSize = screenWidth < 360 ? 18.0 : 20.0;
    final iconPadding = screenWidth < 360 ? 6.0 : 8.0;
    final iconMargin = screenWidth < 360 ? 10.0 : 12.0;
    final horizontalPadding = screenWidth < 360 ? 16.0 : 20.0;
    final verticalPadding = screenWidth < 360 ? 16.0 : 18.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Numéro de téléphone',
          style: GoogleFonts.poppins(
            fontSize: titleFontSize,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: spacing1),
        Text(
          _getPhoneDescription(),
          style: GoogleFonts.poppins(
            fontSize: descriptionFontSize,
            color: AppColors.textSecondary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: spacing2),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            initialValue: phoneNumber.isNotEmpty ? phoneNumber : userPhone,
            onChanged: onPhoneChanged,
            keyboardType: TextInputType.phone,
            style: GoogleFonts.poppins(
              fontSize: inputFontSize,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: _getPhonePlaceholder(),
              hintStyle: GoogleFonts.poppins(
                fontSize: inputFontSize,
                color: AppColors.textSecondary.withOpacity(0.7),
              ),
              prefixIcon: Container(
                margin: EdgeInsets.all(iconMargin),
                padding: EdgeInsets.all(iconPadding),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.phone_android,
                  color: AppColors.primary,
                  size: iconSize,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: hasError ? AppColors.error : Colors.transparent,
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.error, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.error, width: 2),
              ),
              filled: true,
              fillColor: hasError
                  ? AppColors.error.withOpacity(0.05)
                  : AppColors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
            ),
          ),
        ),
        if (hasError && errorText != null) ...[
          SizedBox(height: spacing3),
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

  String _getPhoneDescription() {
    if (selectedPaymentMethod == null) {
      return 'Sélectionnez d\'abord une méthode de paiement';
    }

    switch (selectedPaymentMethod!) {
      case MethodePaiement.wave:
        return 'Numéro Wave pour le paiement';
      case MethodePaiement.mobileMoney:
        return 'Numéro de téléphone pour le paiement Mobile Money (Orange, MTN, Moov)';
    }
  }

  String _getPhonePlaceholder() {
    if (selectedPaymentMethod == null) {
      return 'Ex: 771234567';
    }

    switch (selectedPaymentMethod!) {
      case MethodePaiement.wave:
        return 'Ex: 771234567 (Wave)';
      case MethodePaiement.mobileMoney:
        return 'Ex: 771234567 (Orange, MTN ou Moov)';
    }
  }
}

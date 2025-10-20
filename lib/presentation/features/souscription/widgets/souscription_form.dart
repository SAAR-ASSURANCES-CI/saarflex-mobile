import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarflex_app/core/constants/colors.dart';
import 'package:saarflex_app/data/models/souscription_model.dart';

class souscriptionForm extends StatelessWidget {
  final String phoneNumber;
  final Function(String) onPhoneChanged;
  final bool hasError;
  final String? errorText;
  final String? userPhone;
  final MethodePaiement? selectedPaymentMethod;

  const souscriptionForm({
    super.key,
    required this.phoneNumber,
    required this.onPhoneChanged,
    this.hasError = false,
    this.errorText,
    this.userPhone,
    this.selectedPaymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Numéro de téléphone',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _getPhoneDescription(),
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
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
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: _getPhonePlaceholder(),
              hintStyle: GoogleFonts.poppins(
                fontSize: 16,
                color: AppColors.textSecondary.withOpacity(0.7),
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.phone_android,
                  color: AppColors.primary,
                  size: 20,
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
          ),
        ),
        if (hasError && errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            errorText!,
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.error),
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
      case MethodePaiement.orangeMoney:
        return 'Numéro Orange Money pour le paiement';
      case MethodePaiement.mtn:
        return 'Numéro MTN Money pour le paiement';
      case MethodePaiement.moov:
        return 'Numéro Moov Money pour le paiement';
    }
  }

  String _getPhonePlaceholder() {
    if (selectedPaymentMethod == null) {
      return 'Ex: 771234567';
    }

    switch (selectedPaymentMethod!) {
      case MethodePaiement.wave:
        return 'Ex: 771234567 (Wave)';
      case MethodePaiement.orangeMoney:
        return 'Ex: 771234567 (Orange)';
      case MethodePaiement.mtn:
        return 'Ex: 771234567 (MTN)';
      case MethodePaiement.moov:
        return 'Ex: 771234567 (Moov)';
    }
  }
}

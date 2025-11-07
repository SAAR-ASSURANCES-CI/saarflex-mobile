import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarflex_app/core/constants/colors.dart';
import 'package:saarflex_app/data/models/souscription_model.dart';

class PaymentMethodSelector extends StatelessWidget {
  final MethodePaiement? selectedMethod;
  final Function(MethodePaiement) onMethodSelected;
  final bool hasError;
  final String? errorText;

  const PaymentMethodSelector({
    super.key,
    this.selectedMethod,
    required this.onMethodSelected,
    this.hasError = false,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Méthode de paiement',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 16),
        ...MethodePaiement.values.map((method) => _buildMethodCard(method)),
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

  Widget _buildMethodCard(MethodePaiement method) {
    final isSelected = selectedMethod == method;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onMethodSelected(method),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFE3F2FD)
                  : const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: const Color(0xFF2196F3), width: 2)
                  : null,
            ),
            child: Row(
              children: [
                _buildMethodLogo(method),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    method.displayName,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2196F3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
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
    switch (method) {
      case MethodePaiement.wave:
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF87CEEB),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Image.asset(
            'lib/assets/wave.png',
            width: 24,
            height: 24,
          ),
        );
      case MethodePaiement.mobileMoney:
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.account_balance_wallet,
            color: Colors.white,
            size: 24,
          ),
        );
    }
  }
}

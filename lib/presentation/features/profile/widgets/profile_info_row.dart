import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarflex_app/core/constants/colors.dart';
import 'package:saarflex_app/core/utils/profile_helpers.dart';

class ProfileInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isExpirationDate;
  final bool isWarning;

  const ProfileInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.isExpirationDate = false,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    final valueColor = _getValueColor();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: valueColor ?? AppColors.textPrimary,
                    ),
                  ),
                ),
                if (isWarning) _buildWarningIcon(),
                if (isExpirationDate && valueColor == AppColors.warning)
                  _buildExpirationWarningIcon(),
                if (isExpirationDate && valueColor == AppColors.error)
                  _buildExpiredIcon(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color? _getValueColor() {
    if (isWarning) {
      return AppColors.warning;
    } else if (isExpirationDate && value != "Non renseignée") {
      return ProfileHelpers.getExpirationDateColor(value);
    }
    return null;
  }

  Widget _buildWarningIcon() {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Tooltip(
        message: "À compléter",
        child: Icon(Icons.warning_rounded, color: AppColors.warning, size: 16),
      ),
    );
  }

  Widget _buildExpirationWarningIcon() {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Tooltip(
        message: "Expire bientôt",
        child: Icon(Icons.warning_rounded, color: AppColors.warning, size: 16),
      ),
    );
  }

  Widget _buildExpiredIcon() {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Tooltip(
        message: "Pièce expirée",
        child: Icon(Icons.error_rounded, color: AppColors.error, size: 16),
      ),
    );
  }
}

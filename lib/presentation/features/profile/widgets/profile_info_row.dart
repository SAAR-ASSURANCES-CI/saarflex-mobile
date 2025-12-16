import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarciflex_app/core/constants/colors.dart';
import 'package:saarciflex_app/core/utils/profile_helpers.dart';

class ProfileInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isExpirationDate;
  final bool isWarning;
  final double screenWidth;
  final double textScaleFactor;

  const ProfileInfoRow({
    super.key,
    required this.label,
    required this.value,
    required this.screenWidth,
    required this.textScaleFactor,
    this.isExpirationDate = false,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    final valueColor = _getValueColor();
    final labelFontSize = (14.0 / textScaleFactor).clamp(12.0, 16.0);
    final valueFontSize = (14.0 / textScaleFactor).clamp(12.0, 16.0);
    final bottomPadding = screenWidth < 360 ? 12.0 : 16.0;
    final rowSpacing = screenWidth < 360 ? 12.0 : 16.0;
    final iconSize = screenWidth < 360 ? 14.0 : 16.0;
    final iconPadding = screenWidth < 360 ? 6.0 : 8.0;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: labelFontSize,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          SizedBox(width: rowSpacing),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: valueFontSize,
                      fontWeight: FontWeight.w600,
                      color: valueColor ?? AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isWarning) _buildWarningIcon(iconSize, iconPadding),
                if (isExpirationDate && valueColor == AppColors.warning)
                  _buildExpirationWarningIcon(iconSize, iconPadding),
                if (isExpirationDate && valueColor == AppColors.error)
                  _buildExpiredIcon(iconSize, iconPadding),
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

  Widget _buildWarningIcon(double iconSize, double iconPadding) {
    return Padding(
      padding: EdgeInsets.only(left: iconPadding),
      child: Tooltip(
        message: "À compléter",
        child: Icon(Icons.warning_rounded, color: AppColors.warning, size: iconSize),
      ),
    );
  }

  Widget _buildExpirationWarningIcon(double iconSize, double iconPadding) {
    return Padding(
      padding: EdgeInsets.only(left: iconPadding),
      child: Tooltip(
        message: "Expire bientôt",
        child: Icon(Icons.warning_rounded, color: AppColors.warning, size: iconSize),
      ),
    );
  }

  Widget _buildExpiredIcon(double iconSize, double iconPadding) {
    return Padding(
      padding: EdgeInsets.only(left: iconPadding),
      child: Tooltip(
        message: "Pièce expirée",
        child: Icon(Icons.error_rounded, color: AppColors.error, size: iconSize),
      ),
    );
  }
}

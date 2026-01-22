import 'package:flutter/material.dart';
import 'package:saarciflex_app/core/utils/font_helper.dart';

class ProfileActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;
  final bool isOutlined;
  final double screenWidth;
  final double textScaleFactor;

  const ProfileActionButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
    required this.screenWidth,
    required this.textScaleFactor,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = screenWidth < 360 ? 16.0 : 18.0;
    final fontSize = (16.0 / textScaleFactor).clamp(14.0, 18.0);
    final verticalPadding = screenWidth < 360 ? 14.0 : 16.0;
    
    return SizedBox(
      width: double.infinity,
      child: isOutlined
          ? OutlinedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, size: iconSize),
              label: Text(
                text,
                style: FontHelper.poppins(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: foregroundColor,
                side: BorderSide(color: borderColor),
                padding: EdgeInsets.symmetric(vertical: verticalPadding),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )
          : ElevatedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, size: iconSize),
              label: Text(
                text,
                style: FontHelper.poppins(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor,
                foregroundColor: foregroundColor,
                padding: EdgeInsets.symmetric(vertical: verticalPadding),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
    );
  }
}

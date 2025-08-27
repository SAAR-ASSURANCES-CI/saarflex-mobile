import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';
import '../models/critere_tarification_model.dart';

class DynamicFormField extends StatelessWidget {
  final CritereTarification critere;
  final dynamic valeur;
  final Function(dynamic) onChanged;
  final String? errorText;

  const DynamicFormField({
    super.key,
    required this.critere,
    required this.valeur,
    required this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(),
        const SizedBox(height: 8),
        _buildField(),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          _buildError(),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLabel() {
    return RichText(
      text: TextSpan(
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        children: [
          TextSpan(text: critere.nom),
          if (critere.unite != null)
            TextSpan(
              text: ' (${critere.unite})',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
          if (critere.obligatoire)
            TextSpan(
              text: ' *',
              style: GoogleFonts.poppins(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildField() {
    switch (critere.type) {
      case TypeCritere.numerique:
        return _buildNumericField();
      case TypeCritere.categoriel:
        return _buildDropdownField();
      case TypeCritere.booleen:
        return _buildBooleanField();
    }
  }

  Widget _buildNumericField() {
    return TextFormField(
      initialValue: valeur?.toString() ?? '',
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      onChanged: (value) {
        if (value.isEmpty) {
          onChanged(null);
        } else {
          final doubleValue = double.tryParse(value);
          onChanged(doubleValue ?? value);
        }
      },
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: _getNumericHint(),
        hintStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: errorText != null ? AppColors.error : AppColors.border,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: errorText != null ? AppColors.error : AppColors.border,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: errorText != null ? AppColors.error : AppColors.primary,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildDropdownField() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: errorText != null ? AppColors.error : AppColors.border,
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: valeur?.toString(),
          hint: Text(
            'Sélectionnez ${critere.nom.toLowerCase()}',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textSecondary,
          ),
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
          ),
          dropdownColor: AppColors.white,
          items: critere.valeursString.map((String valeurItem) {
            return DropdownMenuItem<String>(
              value: valeurItem,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  valeurItem,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            onChanged(newValue);
          },
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildBooleanField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: errorText != null ? AppColors.error : AppColors.border,
          width: 1,
        ),
      ),
      child: SwitchListTile(
        title: Text(
          _getBooleanTitle(),
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
          ),
        ),
        value: valeur == true,
        onChanged: (bool value) {
          onChanged(value);
        },
        activeColor: AppColors.primary,
        inactiveThumbColor: AppColors.textSecondary,
        inactiveTrackColor: AppColors.border,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Text(
      errorText!,
      style: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.error,
      ),
    );
  }

  String _getNumericHint() {
    if (critere.valeurs.isNotEmpty) {
      final valeurCritere = critere.valeurs.first;
      if (valeurCritere.valeurMin != null && valeurCritere.valeurMax != null) {
        return 'Entre ${valeurCritere.valeurMin} et ${valeurCritere.valeurMax}';
      } else if (valeurCritere.valeurMin != null) {
        return 'Minimum ${valeurCritere.valeurMin}';
      } else if (valeurCritere.valeurMax != null) {
        return 'Maximum ${valeurCritere.valeurMax}';
      }
    }
    
    if (critere.unite != null) {
      return 'Saisissez la valeur en ${critere.unite}';
    }
    
    return 'Saisissez une valeur numérique';
  }

  String _getBooleanTitle() {
    final nomLower = critere.nom.toLowerCase();
    
    if (nomLower.contains('bonus') || nomLower.contains('malus')) {
      return 'Avez-vous un bonus ?';
    } else if (nomLower.contains('antecedent')) {
      return 'Avez-vous des antécédents ?';
    } else if (nomLower.contains('accident')) {
      return 'Avez-vous eu des accidents ?';
    } else if (nomLower.contains('sinistre')) {
      return 'Avez-vous déclaré des sinistres ?';
    }
    
    return critere.nom;
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarflex_app/core/constants/colors.dart';
import 'package:saarflex_app/data/models/critere_tarification_model.dart';

class DynamicFormField extends StatefulWidget {
  final CritereTarification critere;
  final dynamic valeur;
  final Function(dynamic) onChanged;
  final String? errorText;
  final bool formatMilliers;
  final bool enabled;
  final String? infoText;

  const DynamicFormField({
    super.key,
    required this.critere,
    required this.valeur,
    required this.onChanged,
    this.errorText,
    this.formatMilliers = false,
    this.enabled = true,
    this.infoText,
  });

  @override
  State<DynamicFormField> createState() => _DynamicFormFieldState();
}

class _DynamicFormFieldState extends State<DynamicFormField> {
  final TextEditingController _controller = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _updateControllerValue();
  }

  @override
  void didUpdateWidget(DynamicFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isEditing &&
        (oldWidget.valeur != widget.valeur ||
            oldWidget.formatMilliers != widget.formatMilliers)) {
      _updateControllerValue();
    }
  }

  String _formatNombreAvecSeparateurs(String valeur) {
    String valeurSansSeparateurs = valeur.replaceAll(RegExp(r'[^\d]'), '');
    final number = int.tryParse(valeurSansSeparateurs);
    if (number == null) return valeur;
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    );
  }

  String _enleverSeparateurs(String valeur) {
    return valeur.replaceAll(RegExp(r'[^\d]'), '');
  }

  void _updateControllerValue() {
    if (widget.valeur != null) {
      if (widget.formatMilliers) {
        _controller.text = _formatNombreAvecSeparateurs(
          widget.valeur.toString(),
        );
      } else {
        _controller.text = widget.valeur.toString();
      }
    } else {
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(),
        const SizedBox(height: 8),
        _buildField(),
        if (widget.errorText != null) ...[
          const SizedBox(height: 4),
          _buildError(),
        ],
        if (widget.infoText != null) ...[
          const SizedBox(height: 4),
          _buildInfoText(),
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
          TextSpan(text: widget.critere.nom),
          if (widget.critere.unite != null)
            TextSpan(
              text: ' (${widget.critere.unite})',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
          if (widget.critere.obligatoire)
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
    switch (widget.critere.type) {
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
      controller: _controller,
      enabled: widget.enabled,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d ]')),
      ],
      onChanged: (value) {
        _isEditing = true;
        String valeurAEnvoyer = value;
        if (widget.formatMilliers) {
          valeurAEnvoyer = _enleverSeparateurs(value);
        }

        if (valeurAEnvoyer.isEmpty) {
          widget.onChanged(null);
        } else {
          final doubleValue = double.tryParse(valeurAEnvoyer);
          widget.onChanged(doubleValue ?? valeurAEnvoyer);
        }
      },
      onEditingComplete: () {
        _isEditing = false;
        if (widget.formatMilliers) {
          setState(() {
            _controller.text = _formatNombreAvecSeparateurs(_controller.text);
          });
        }
      },
      onTap: () {
        _isEditing = true;
        if (widget.formatMilliers) {
          setState(() {
            _controller.text = _enleverSeparateurs(_controller.text);
          });
        }
      },
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: widget.enabled 
            ? AppColors.textPrimary 
            : AppColors.textPrimary.withOpacity(0.5),
      ),
      decoration: InputDecoration(
        hintText: _getNumericHint(),
        hintStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        filled: true,
        fillColor: widget.enabled 
            ? AppColors.surfaceVariant 
            : AppColors.surfaceVariant.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: widget.errorText != null
                ? AppColors.error
                : AppColors.border,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: widget.errorText != null
                ? AppColors.error
                : AppColors.border,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: widget.errorText != null
                ? AppColors.error
                : AppColors.primary,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: widget.enabled 
            ? AppColors.surfaceVariant 
            : AppColors.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.errorText != null ? AppColors.error : AppColors.border,
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: widget.valeur?.toString(),
          isExpanded: true,  // Ajoutez cette ligne
          hint: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Text(
              'Sélectionnez ${widget.critere.nom.toLowerCase()}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: widget.enabled 
                    ? AppColors.textSecondary 
                    : AppColors.textSecondary.withOpacity(0.5),
              ),
              overflow: TextOverflow.ellipsis,  // Ajoutez cette ligne
              maxLines: 1,  // Ajoutez cette ligne
            ),
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: widget.enabled 
                ? AppColors.textSecondary 
                : AppColors.textSecondary.withOpacity(0.5),
          ),
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: widget.enabled 
                ? AppColors.textPrimary 
                : AppColors.textPrimary.withOpacity(0.5),
          ),
          dropdownColor: AppColors.white,
          items: widget.critere.valeursString.map((String valeurItem) {
            String displayedValue = valeurItem;
            if (widget.formatMilliers && _isNumeric(valeurItem)) {
              final formatted = _formatNombreAvecSeparateurs(valeurItem);
              displayedValue = formatted;
            }

            return DropdownMenuItem<String>(
              value: valeurItem,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  displayedValue,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
          onChanged: widget.enabled ? (String? newValue) {
            widget.onChanged(newValue);
          } : null,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  bool _isNumeric(String str) {
    final cleanedStr = str.replaceAll(' ', '');
    final isNum = double.tryParse(cleanedStr) != null;
    return isNum;
  }

  Widget _buildBooleanField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.errorText != null ? AppColors.error : AppColors.border,
          width: 1,
        ),
      ),
      child: SwitchListTile(
        title: Text(
          _getBooleanTitle(),
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: widget.enabled 
                ? AppColors.textPrimary 
                : AppColors.textPrimary.withOpacity(0.5),
          ),
        ),
        value: widget.valeur == true,
        onChanged: widget.enabled ? (bool value) {
          widget.onChanged(value);
        } : null,
        activeColor: AppColors.primary,
        inactiveThumbColor: AppColors.textSecondary,
        inactiveTrackColor: AppColors.border,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildError() {
    return Text(
      widget.errorText!,
      style: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.error,
      ),
    );
  }

  Widget _buildInfoText() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.info_outline_rounded,
          size: 14,
          color: const Color.fromARGB(255, 248, 24, 24),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            widget.infoText!,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color.fromARGB(255, 248, 24, 24),
            ),
          ),
        ),
      ],
    );
  }

  String _getNumericHint() {
    if (widget.critere.valeurs.isNotEmpty) {
      final valeurCritere = widget.critere.valeurs.first;
      if (valeurCritere.valeurMin != null && valeurCritere.valeurMax != null) {
        return 'Entre ${valeurCritere.valeurMin} et ${valeurCritere.valeurMax}';
      } else if (valeurCritere.valeurMin != null) {
        return 'Minimum ${valeurCritere.valeurMin}';
      } else if (valeurCritere.valeurMax != null) {
        return 'Maximum ${valeurCritere.valeurMax}';
      }
    }

    if (widget.critere.unite != null) {
      return 'Saisissez la valeur en ${widget.critere.unite}';
    }

    return 'Saisissez une valeur numérique';
  }

  String _getBooleanTitle() {
    final nomLower = widget.critere.nom.toLowerCase();

    if (nomLower.contains('bonus') || nomLower.contains('malus')) {
      return 'Avez-vous un bonus ?';
    } else if (nomLower.contains('antecedent')) {
      return 'Avez-vous des antécédents ?';
    } else if (nomLower.contains('accident')) {
      return 'Avez-vous eu des accidents ?';
    } else if (nomLower.contains('sinistre')) {
      return 'Avez-vous déclaré des sinistres ?';
    }

    return widget.critere.nom;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}


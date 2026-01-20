import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarciflex_app/core/constants/colors.dart';
import 'package:saarciflex_app/data/models/critere_tarification_model.dart';

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
      } else if (widget.critere.type == TypeCritere.date && widget.valeur is DateTime) {
        _controller.text = _formatDate(widget.valeur as DateTime);
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
    final isDateField = widget.critere.type == TypeCritere.date ||
        (widget.critere.type == TypeCritere.texte &&
            (widget.critere.nom.toLowerCase().contains('expir') ||
             widget.critere.nom.toLowerCase().contains('expiration') ||
             widget.critere.nom.toLowerCase().contains('date')));

    if (isDateField && widget.critere.type != TypeCritere.date) {
      return _buildDateField();
    }

    switch (widget.critere.type) {
      case TypeCritere.numerique:
        return _buildNumericField();
      case TypeCritere.categoriel:
        return _buildDropdownField();
      case TypeCritere.booleen:
        return _buildBooleanField();
      case TypeCritere.date:
        return _buildDateField();
      case TypeCritere.texte:
        return _buildTextField();
    }
  }

  Widget _buildNumericField() {
    return TextFormField(
      controller: _controller,
      enabled: widget.enabled,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9 ,\\.]')),
      ],
      onChanged: (value) {
        _isEditing = true;
        String valeurAEnvoyer = value;
        if (widget.formatMilliers) {
          valeurAEnvoyer = _enleverSeparateurs(value);
        }

        final valeurNormalisee = _normalizeNumericInput(valeurAEnvoyer);

        if (valeurNormalisee.isEmpty) {
          widget.onChanged(null);
        } else {
          final doubleValue = double.tryParse(valeurNormalisee);
          widget.onChanged(doubleValue ?? valeurNormalisee);
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

  String _normalizeNumericInput(String valeur) {
    return valeur
        .replaceAll(' ', '')
        .replaceAll(',', '.')
        .trim();
  }

  String _formatNombre(double valeur) {
    if (valeur % 1 == 0) {
      return valeur.toStringAsFixed(0);
    }
    return valeur.toString();
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
      double? minGlobal;
      double? maxGlobal;

      for (final v in widget.critere.valeurs) {
        if (v.valeurMin != null) {
          minGlobal = minGlobal == null
              ? v.valeurMin
              : (v.valeurMin! < minGlobal ? v.valeurMin : minGlobal);
        }
        if (v.valeurMax != null) {
          maxGlobal = maxGlobal == null
              ? v.valeurMax
              : (v.valeurMax! > maxGlobal ? v.valeurMax : maxGlobal);
        }
      }

      if (minGlobal != null && maxGlobal != null) {
        return 'Entre ${_formatNombre(minGlobal)} et ${_formatNombre(maxGlobal)}';
      } else if (minGlobal != null) {
        return 'Minimum ${_formatNombre(minGlobal)}';
      } else if (maxGlobal != null) {
        return 'Maximum ${_formatNombre(maxGlobal)}';
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

  Widget _buildDateField() {
    DateTime? selectedDate;
    if (widget.valeur is DateTime) {
      selectedDate = widget.valeur as DateTime;
    } else if (widget.valeur is String && widget.valeur.toString().isNotEmpty) {
      selectedDate = DateTime.tryParse(widget.valeur.toString());
      if (selectedDate == null) {
        final parts = widget.valeur.toString().split('-');
        if (parts.length == 3) {
          try {
            final day = int.parse(parts[0]);
            final month = int.parse(parts[1]);
            final year = int.parse(parts[2]);
            selectedDate = DateTime(year, month, day);
          } catch (_) {
            selectedDate = null;
          }
        }
      }
    }

    return GestureDetector(
      onTap: widget.enabled ? () => _selectDate(context) : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: widget.enabled 
              ? AppColors.surfaceVariant 
              : AppColors.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.errorText != null
                ? AppColors.error
                : AppColors.border,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              color: widget.enabled 
                  ? (widget.errorText != null ? AppColors.error : AppColors.primary)
                  : AppColors.textSecondary.withOpacity(0.5),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedDate != null
                    ? _formatDate(selectedDate)
                    : 'Sélectionnez ${widget.critere.nom.toLowerCase()}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: selectedDate != null
                      ? (widget.enabled 
                          ? AppColors.textPrimary 
                          : AppColors.textPrimary.withOpacity(0.5))
                      : (widget.enabled 
                          ? AppColors.textSecondary 
                          : AppColors.textSecondary.withOpacity(0.5)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final isExpirationDate = widget.critere.nom.toLowerCase().contains('expir') ||
                             widget.critere.nom.toLowerCase().contains('expiration');
    
    final DateTime firstDate = isExpirationDate
        ? now // Pour les dates d'expiration, on commence à aujourd'hui
        : DateTime(now.year - 100, now.month, now.day);
    final DateTime lastDate = isExpirationDate
        ? DateTime(now.year + 20, now.month, now.day) // Jusqu'à 20 ans dans le futur
        : DateTime(now.year + 20, now.month, now.day);

    DateTime? currentDate;
    if (widget.valeur is DateTime) {
      currentDate = widget.valeur as DateTime;
    } else if (widget.valeur is String && widget.valeur.toString().isNotEmpty) {
      currentDate = DateTime.tryParse(widget.valeur.toString());
      if (currentDate == null) {
        final parts = widget.valeur.toString().split('-');
        if (parts.length == 3) {
          try {
            final day = int.parse(parts[0]);
            final month = int.parse(parts[1]);
            final year = int.parse(parts[2]);
            currentDate = DateTime(year, month, day);
          } catch (_) {
            currentDate = null;
          }
        }
      }
    }

    final DateTime initialDate = currentDate ?? now;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('fr', 'FR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              surface: AppColors.surfaceVariant,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      widget.onChanged(picked);
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  Widget _buildTextField() {
    return TextFormField(
      controller: _controller,
      enabled: widget.enabled,
      keyboardType: TextInputType.text,
      maxLines: 1,
      onChanged: (value) {
        _isEditing = true;
        if (value.trim().isEmpty) {
          widget.onChanged(null);
        } else {
          widget.onChanged(value.trim());
        }
      },
      onEditingComplete: () {
        _isEditing = false;
      },
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: widget.enabled 
            ? AppColors.textPrimary 
            : AppColors.textPrimary.withOpacity(0.5),
      ),
      decoration: InputDecoration(
        hintText: 'Saisissez ${widget.critere.nom.toLowerCase()}',
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}


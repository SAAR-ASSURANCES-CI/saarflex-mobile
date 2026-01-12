import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarciflex_app/core/constants/colors.dart';
import 'package:saarciflex_app/data/models/critere_tarification_model.dart';
import 'package:saarciflex_app/presentation/features/simulation/widgets/validation_error_widget.dart';

class CritereInputWidget extends StatefulWidget {
  final CritereTarification critere;
  final dynamic valeur;
  final Function(dynamic) onChanged;
  final String? errorText;
  final bool formatMilliers;

  const CritereInputWidget({
    super.key,
    required this.critere,
    required this.valeur,
    required this.onChanged,
    this.errorText,
    this.formatMilliers = false,
  });

  @override
  State<CritereInputWidget> createState() => _CritereInputWidgetState();
}

class _CritereInputWidgetState extends State<CritereInputWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _getDisplayValue());
  }

  @override
  void didUpdateWidget(CritereInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.valeur != widget.valeur) {
      _controller.text = _getDisplayValue();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getDisplayValue() {
    if (widget.valeur == null) return '';

    switch (widget.critere.type) {
      case TypeCritere.numerique:
        if (widget.formatMilliers && widget.valeur != null) {
          final numValue = num.tryParse(widget.valeur.toString());
          if (numValue != null) {
            return numValue.toString().replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (match) => '${match[1]} ',
            );
          }
        }
        return widget.valeur.toString();
      case TypeCritere.categoriel:
      case TypeCritere.texte:
        return widget.valeur.toString();
      case TypeCritere.booleen:
        return widget.valeur ? 'Oui' : 'Non';
      case TypeCritere.date:
        if (widget.valeur is DateTime) {
          final date = widget.valeur as DateTime;
          final day = date.day.toString().padLeft(2, '0');
          final month = date.month.toString().padLeft(2, '0');
          return '$day/$month/${date.year}';
        }
        return widget.valeur.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(),
        const SizedBox(height: 8),
        _buildInput(),
        if (widget.errorText != null) ...[
          const SizedBox(height: 8),
          ValidationErrorWidget(error: widget.errorText!, isCompact: true),
        ],
      ],
    );
  }

  Widget _buildLabel() {
    return RichText(
      text: TextSpan(
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        children: [
          TextSpan(text: widget.critere.nom),
          if (widget.critere.obligatoire)
            TextSpan(
              text: ' *',
              style: TextStyle(color: AppColors.error),
            ),
        ],
      ),
    );
  }

  Widget _buildInput() {
    // Détection automatique : si c'est un texte qui contient "expir", traiter comme date
    final isDateField = widget.critere.type == TypeCritere.date ||
        (widget.critere.type == TypeCritere.texte &&
            (widget.critere.nom.toLowerCase().contains('expir') ||
             widget.critere.nom.toLowerCase().contains('expiration') ||
             widget.critere.nom.toLowerCase().contains('date')));

    if (isDateField && widget.critere.type != TypeCritere.date) {
      return _buildDateInput();
    }

    switch (widget.critere.type) {
      case TypeCritere.numerique:
        return _buildNumericInput();
      case TypeCritere.categoriel:
        return _buildCategoricalInput();
      case TypeCritere.booleen:
        return _buildBooleanInput();
      case TypeCritere.date:
        return _buildDateInput();
      case TypeCritere.texte:
        return _buildTextInput();
    }
  }

  Widget _buildNumericInput() {
    return TextFormField(
      controller: _controller,
      keyboardType: TextInputType.number,
      inputFormatters: widget.formatMilliers
          ? [FilteringTextInputFormatter.digitsOnly]
          : [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
      decoration: InputDecoration(
        hintText: 'Votre ${widget.critere.nom.toLowerCase()}',
        hintStyle: GoogleFonts.poppins(color: AppColors.textHint),
        prefixIcon: Icon(Icons.calculate, color: AppColors.primary),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      style: GoogleFonts.poppins(fontSize: 16, color: AppColors.textPrimary),
      onChanged: (value) {
        if (widget.formatMilliers) {
          final cleanValue = value.replaceAll(RegExp(r'[^\d]'), '');
          final numericValue = num.tryParse(cleanValue);
          widget.onChanged(numericValue);
        } else {
          final numericValue = num.tryParse(value);
          widget.onChanged(numericValue);
        }
      },
    );
  }

  Widget _buildCategoricalInput() {
    return DropdownButtonFormField<String>(
      value: widget.valeur?.toString(),
      decoration: InputDecoration(
        hintText: 'Sélectionnez une option',
        hintStyle: GoogleFonts.poppins(color: AppColors.textHint),
        prefixIcon: Icon(Icons.list, color: AppColors.primary),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      style: GoogleFonts.poppins(fontSize: 16, color: AppColors.textPrimary),
      items: widget.critere.valeursString.map((valeur) {
        return DropdownMenuItem(value: valeur, child: Text(valeur));
      }).toList(),
      onChanged: (value) => widget.onChanged(value),
    );
  }

  Widget _buildBooleanInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(Icons.toggle_on, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(
            widget.critere.nom,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          Switch(
            value: widget.valeur ?? false,
            onChanged: widget.onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildDateInput() {
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

    return InkWell(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedDate != null
                    ? _formatDate(selectedDate)
                    : 'Sélectionnez ${widget.critere.nom.toLowerCase()}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: selectedDate != null
                      ? AppColors.textPrimary
                      : AppColors.textHint,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextInput() {
    return TextFormField(
      controller: _controller,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        hintText: 'Saisissez ${widget.critere.nom.toLowerCase()}',
        hintStyle: GoogleFonts.poppins(color: AppColors.textHint),
        prefixIcon: Icon(Icons.text_fields, color: AppColors.primary),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      style: GoogleFonts.poppins(fontSize: 16, color: AppColors.textPrimary),
      onChanged: (value) => widget.onChanged(value.trim().isEmpty ? null : value.trim()),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime firstDate = DateTime(now.year - 100, now.month, now.day);
    final DateTime lastDate = DateTime(now.year + 20, now.month, now.day);

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
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child ?? const SizedBox(),
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
}

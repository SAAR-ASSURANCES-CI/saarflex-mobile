import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarflex_app/core/constants/colors.dart';
import 'package:saarflex_app/data/models/critere_tarification_model.dart';
import 'package:saarflex_app/core/utils/simulation_formatters.dart';
import 'package:saarflex_app/presentation/features/simulation/widgets/validation_error_widget.dart';

/// Widget d'entrée spécialisé pour les critères de simulation
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
        if (widget.formatMilliers) {
          return SimulationFormatters.formatCritereValue(
            widget.critere,
            widget.valeur,
          );
        }
        return widget.valeur.toString();
      case TypeCritere.categoriel:
        return widget.valeur.toString();
      case TypeCritere.booleen:
        return widget.valeur ? 'Oui' : 'Non';
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
    switch (widget.critere.type) {
      case TypeCritere.numerique:
        return _buildNumericInput();
      case TypeCritere.categoriel:
        return _buildCategoricalInput();
      case TypeCritere.booleen:
        return _buildBooleanInput();
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
          // Nettoyer la valeur des séparateurs
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
}

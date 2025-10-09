import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarflex_app/core/constants/colors.dart';
import 'package:saarflex_app/data/models/critere_tarification_model.dart';

class DynamicFormField extends StatefulWidget {
  // Changé de StatelessWidget à StatefulWidget
  final CritereTarification critere;
  final dynamic valeur;
  final Function(dynamic) onChanged;
  final String? errorText;
  final bool formatMilliers; // Nouveau paramètre pour activer le formatage

  const DynamicFormField({
    super.key,
    required this.critere,
    required this.valeur,
    required this.onChanged,
    this.errorText,
    this.formatMilliers = false, // Valeur par défaut
  });

  @override
  State<DynamicFormField> createState() => _DynamicFormFieldState();
}

class _DynamicFormFieldState extends State<DynamicFormField> {
  final TextEditingController _controller =
      TextEditingController(); // Contrôleur pour gérer le texte
  bool _isEditing = false; // Pour savoir si l'utilisateur est en train d'éditer

  @override
  void initState() {
    super.initState();
    _updateControllerValue(); // Initialiser la valeur du contrôleur
  }

  @override
  void didUpdateWidget(DynamicFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Mettre à jour le contrôleur seulement si nécessaire
    if (!_isEditing &&
        (oldWidget.valeur != widget.valeur ||
            oldWidget.formatMilliers != widget.formatMilliers)) {
      _updateControllerValue();
    }
  }

  // Méthode pour formater un nombre avec séparateurs de milliers
  String _formatNombreAvecSeparateurs(String valeur) {
    // Enlever les séparateurs existants pour éviter les doublons
    String valeurSansSeparateurs = valeur.replaceAll(RegExp(r'[^\d]'), '');

    // Convertir en nombre
    final number = int.tryParse(valeurSansSeparateurs);
    if (number == null) return valeur;

    // Formater avec séparateurs d'espace (format français)
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    );
  }

  // Méthode pour enlever les séparateurs avant traitement
  String _enleverSeparateurs(String valeur) {
    return valeur.replaceAll(RegExp(r'[^\d]'), '');
  }

  // Mettre à jour la valeur du contrôleur selon le formatage
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
      controller: _controller, // Utiliser le contrôleur au lieu de initialValue
      keyboardType: TextInputType.number, // Type de clavier numérique
      inputFormatters: [
        // Autoriser les chiffres et les espaces (pour les séparateurs)
        FilteringTextInputFormatter.allow(RegExp(r'[\d ]')),
      ],
      onChanged: (value) {
        _isEditing = true;

        String valeurAEnvoyer = value;
        if (widget.formatMilliers) {
          // Enlever les séparateurs avant d'envoyer la valeur
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
          // Reformater quand l'édition est terminée
          setState(() {
            _controller.text = _formatNombreAvecSeparateurs(_controller.text);
          });
        }
      },
      onTap: () {
        _isEditing = true;
        if (widget.formatMilliers) {
          // Enlever les séparateurs pendant l'édition pour faciliter la saisie
          setState(() {
            _controller.text = _enleverSeparateurs(_controller.text);
          });
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
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.errorText != null ? AppColors.error : AppColors.border,
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: widget.valeur?.toString(),
          hint: Text(
            'Sélectionnez ${widget.critere.nom.toLowerCase()}',
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
          onChanged: (String? newValue) {
            widget.onChanged(newValue);
          },
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  // Méthode _isNumeric améliorée
  bool _isNumeric(String str) {
    // Enlever les espaces existants avant de tester
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
            color: AppColors.textPrimary,
          ),
        ),
        value: widget.valeur == true,
        onChanged: (bool value) {
          widget.onChanged(value);
        },
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
    _controller.dispose(); // Nettoyer le contrôleur
    super.dispose();
  }
}

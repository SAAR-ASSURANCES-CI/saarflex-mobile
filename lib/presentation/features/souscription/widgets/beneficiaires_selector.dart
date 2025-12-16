import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarciflex_app/core/constants/colors.dart';
import 'package:saarciflex_app/data/models/beneficiaire_model.dart';

class BeneficiairesSelector extends StatefulWidget {
  final List<Beneficiaire> beneficiaires;
  final Function(List<Beneficiaire>) onBeneficiairesChanged;
  final bool hasError;
  final String? errorText;
  final int maxBeneficiaires;
  final bool necessiteBeneficiaires;
  final double screenWidth;
  final double textScaleFactor;

  const BeneficiairesSelector({
    super.key,
    required this.beneficiaires,
    required this.onBeneficiairesChanged,
    required this.screenWidth,
    required this.textScaleFactor,
    this.hasError = false,
    this.errorText,
    this.maxBeneficiaires = 3,
    this.necessiteBeneficiaires = true,
  });

  @override
  State<BeneficiairesSelector> createState() => _BeneficiairesSelectorState();
}

class _BeneficiairesSelectorState extends State<BeneficiairesSelector> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _lienController = TextEditingController();
  String? _selectedLien;
  final List<String> _liensDisponibles = [
    'Épouse',
    'Époux',
    'Enfant',
    'Père',
    'Mère',
    'Frère',
    'Sœur',
    'Autre',
  ];

  @override
  void dispose() {
    _nomController.dispose();
    _lienController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titleFontSize = (16.0 / widget.textScaleFactor).clamp(14.0, 18.0);
    final descriptionFontSize = (14.0 / widget.textScaleFactor).clamp(12.0, 16.0);
    final badgeFontSize = (12.0 / widget.textScaleFactor).clamp(10.0, 14.0);
    final errorFontSize = (12.0 / widget.textScaleFactor).clamp(10.0, 14.0);
    final spacing1 = widget.screenWidth < 360 ? 6.0 : 8.0;
    final spacing2 = widget.screenWidth < 360 ? 12.0 : 16.0;
    final spacing3 = widget.screenWidth < 360 ? 6.0 : 8.0;
    final badgePaddingH = widget.screenWidth < 360 ? 6.0 : 8.0;
    final badgePaddingV = widget.screenWidth < 360 ? 3.0 : 4.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bénéficiaires',
          style: GoogleFonts.poppins(
            fontSize: titleFontSize,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: spacing1),
        Row(
          children: [
            Expanded(
              child: Text(
                'Ajoutez ou modifiez les informations des bénéficiaires',
                style: GoogleFonts.poppins(
                  fontSize: descriptionFontSize,
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: badgePaddingH,
                vertical: badgePaddingV,
              ),
              decoration: BoxDecoration(
                color: widget.beneficiaires.length >= widget.maxBeneficiaires
                    ? AppColors.error.withOpacity(0.1)
                    : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.beneficiaires.length >= widget.maxBeneficiaires
                      ? AppColors.error
                      : AppColors.primary,
                  width: 1,
                ),
              ),
              child: Text(
                '${widget.beneficiaires.length}/${widget.maxBeneficiaires}',
                style: GoogleFonts.poppins(
                  fontSize: badgeFontSize,
                  fontWeight: FontWeight.w600,
                  color: widget.beneficiaires.length >= widget.maxBeneficiaires
                      ? AppColors.error
                      : AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: spacing2),

        ...widget.beneficiaires.asMap().entries.map((entry) {
          final index = entry.key;
          final beneficiaire = entry.value;
          return _buildBeneficiaireCard(beneficiaire, index);
        }),

        if (widget.beneficiaires.length < widget.maxBeneficiaires)
          _buildAddBeneficiaireForm()
        else
          _buildLimitReachedMessage(),

        if (widget.hasError && widget.errorText != null) ...[
          SizedBox(height: spacing3),
          Text(
            widget.errorText!,
            style: GoogleFonts.poppins(
              fontSize: errorFontSize,
              color: AppColors.error,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildBeneficiaireCard(Beneficiaire beneficiaire, int index) {
    final cardMargin = widget.screenWidth < 360 ? 10.0 : 12.0;
    final cardPadding = widget.screenWidth < 360 ? 12.0 : 16.0;
    final badgeSize = widget.screenWidth < 360 ? 28.0 : 32.0;
    final badgeFontSize = (14.0 / widget.textScaleFactor).clamp(12.0, 16.0);
    final nameFontSize = (16.0 / widget.textScaleFactor).clamp(14.0, 18.0);
    final linkFontSize = (14.0 / widget.textScaleFactor).clamp(12.0, 16.0);
    final spacing1 = widget.screenWidth < 360 ? 12.0 : 16.0;
    final spacing2 = widget.screenWidth < 360 ? 3.0 : 4.0;
    final iconSize = widget.screenWidth < 360 ? 18.0 : 20.0;
    
    return Container(
      margin: EdgeInsets.only(bottom: cardMargin),
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: badgeSize,
            height: badgeSize,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(badgeSize / 2),
            ),
            child: Center(
              child: Text(
                beneficiaire.ordre.toString(),
                style: GoogleFonts.poppins(
                  fontSize: badgeFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          SizedBox(width: spacing1),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  beneficiaire.nomComplet,
                  style: GoogleFonts.poppins(
                    fontSize: nameFontSize,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: spacing2),
                Text(
                  beneficiaire.lienSouscripteur,
                  style: GoogleFonts.poppins(
                    fontSize: linkFontSize,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _editBeneficiaire(index),
                icon: Icon(
                  Icons.edit,
                  color: AppColors.primary,
                  size: iconSize,
                ),
                padding: EdgeInsets.all(widget.screenWidth < 360 ? 6.0 : 8.0),
                constraints: const BoxConstraints(),
              ),
              IconButton(
                onPressed: () => _removeBeneficiaire(index),
                icon: Icon(
                  Icons.delete,
                  color: AppColors.error,
                  size: iconSize,
                ),
                padding: EdgeInsets.all(widget.screenWidth < 360 ? 6.0 : 8.0),
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _editBeneficiaire(int index) {
    final beneficiaire = widget.beneficiaires[index];
    _nomController.text = beneficiaire.nomComplet;
    _selectedLien = beneficiaire.lienSouscripteur;
    _lienController.text = beneficiaire.lienSouscripteur;

    _showEditDialog(index);
  }

  void _showEditDialog(int index) {
    final dialogPadding = widget.screenWidth < 360 ? 16.0 : 24.0;
    final iconSize = widget.screenWidth < 360 ? 20.0 : 24.0;
    final iconPadding = widget.screenWidth < 360 ? 10.0 : 12.0;
    final titleFontSize = (20.0 / widget.textScaleFactor).clamp(18.0, 22.0);
    final buttonFontSize = (16.0 / widget.textScaleFactor).clamp(14.0, 18.0);
    final spacing1 = widget.screenWidth < 360 ? 12.0 : 16.0;
    final spacing2 = widget.screenWidth < 360 ? 20.0 : 24.0;
    final buttonSpacing = widget.screenWidth < 360 ? 12.0 : 16.0;
    final buttonPadding = widget.screenWidth < 360 ? 14.0 : 16.0;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 10,
        child: Container(
          padding: EdgeInsets.all(dialogPadding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(iconPadding),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.edit,
                      color: AppColors.primary,
                      size: iconSize,
                    ),
                  ),
                  SizedBox(width: spacing1),
                  Expanded(
                    child: Text(
                      'Modifier le bénéficiaire',
                      style: GoogleFonts.poppins(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: AppColors.textSecondary,
                      size: iconSize,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              SizedBox(height: spacing2),

              _buildBeneficiaireForm(),

              SizedBox(height: spacing2),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: buttonPadding),
                      ),
                      child: Text(
                        'Annuler',
                        style: GoogleFonts.poppins(
                          fontSize: buttonFontSize,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: buttonSpacing),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateBeneficiaire(index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: buttonPadding),
                        elevation: 0,
                      ),
                      child: Text(
                        'Modifier',
                        style: GoogleFonts.poppins(
                          fontSize: buttonFontSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddBeneficiaireForm() {
    final marginTop = widget.screenWidth < 360 ? 12.0 : 16.0;
    final padding = widget.screenWidth < 360 ? 12.0 : 16.0;
    final iconSize = widget.screenWidth < 360 ? 18.0 : 20.0;
    final titleFontSize = (16.0 / widget.textScaleFactor).clamp(14.0, 18.0);
    final buttonFontSize = (16.0 / widget.textScaleFactor).clamp(14.0, 18.0);
    final spacing1 = widget.screenWidth < 360 ? 6.0 : 8.0;
    final spacing2 = widget.screenWidth < 360 ? 12.0 : 16.0;
    final buttonPadding = widget.screenWidth < 360 ? 14.0 : 16.0;
    
    return Container(
      margin: EdgeInsets.only(top: marginTop),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_add, color: AppColors.primary, size: iconSize),
              SizedBox(width: spacing1),
              Expanded(
                child: Text(
                  'Ajouter un bénéficiaire',
                  style: GoogleFonts.poppins(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing2),
          _buildBeneficiaireForm(),
          SizedBox(height: spacing2),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _addBeneficiaire,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(vertical: buttonPadding),
              ),
              child: Text(
                'Ajouter',
                style: GoogleFonts.poppins(fontSize: buttonFontSize),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeneficiaireForm() {
    final inputFontSize = (16.0 / widget.textScaleFactor).clamp(14.0, 18.0);
    final labelFontSize = (14.0 / widget.textScaleFactor).clamp(12.0, 16.0);
    final hintFontSize = (14.0 / widget.textScaleFactor).clamp(12.0, 16.0);
    final iconSize = widget.screenWidth < 360 ? 20.0 : 24.0;
    final horizontalPadding = widget.screenWidth < 360 ? 12.0 : 16.0;
    final verticalPadding = widget.screenWidth < 360 ? 14.0 : 16.0;
    final spacing = widget.screenWidth < 360 ? 16.0 : 20.0;
    
    return Column(
      children: [
        TextFormField(
          controller: _nomController,
          style: GoogleFonts.poppins(
            fontSize: inputFontSize,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            labelText: 'Nom complet',
            hintText: 'Ex: Marie Dupont',
            hintStyle: GoogleFonts.poppins(
              fontSize: hintFontSize,
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
            labelStyle: GoogleFonts.poppins(
              fontSize: labelFontSize,
              color: AppColors.textSecondary,
            ),
            prefixIcon: Icon(Icons.person, color: AppColors.primary, size: iconSize),
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
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: AppColors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
          ),
        ),
        SizedBox(height: spacing),

        DropdownButtonFormField<String>(
          value: _liensDisponibles.contains(_selectedLien)
              ? _selectedLien
              : null,
          style: GoogleFonts.poppins(
            fontSize: inputFontSize,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            labelText: 'Lien avec le souscripteur',
            labelStyle: GoogleFonts.poppins(
              fontSize: labelFontSize,
              color: AppColors.textSecondary,
            ),
            prefixIcon: Icon(
              Icons.family_restroom,
              color: AppColors.primary,
              size: iconSize,
            ),
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
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: AppColors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
          ),
          items: [
            ..._liensDisponibles.map((lien) {
              return DropdownMenuItem(
                value: lien,
                child: Text(
                  lien,
                  style: GoogleFonts.poppins(
                    fontSize: inputFontSize,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              );
            }),
            if (_selectedLien != null &&
                !_liensDisponibles.contains(_selectedLien) &&
                _selectedLien != 'Autre')
              DropdownMenuItem(
                value: _selectedLien,
                child: Text(
                  _selectedLien!,
                  style: GoogleFonts.poppins(
                    fontSize: inputFontSize,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
          ],
          onChanged: (value) {
            setState(() {
              _selectedLien = value!;
            });
          },
        ),

        if (_selectedLien == 'Autre') ...[
          SizedBox(height: spacing),
          TextFormField(
            controller: _lienController,
            style: GoogleFonts.poppins(
              fontSize: inputFontSize,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              labelText: 'Précisez le lien',
              hintText: 'Ex: Cousin, Ami, etc.',
              hintStyle: GoogleFonts.poppins(
                fontSize: hintFontSize,
                color: AppColors.textSecondary.withOpacity(0.7),
              ),
              labelStyle: GoogleFonts.poppins(
                fontSize: labelFontSize,
                color: AppColors.textSecondary,
              ),
              prefixIcon: Icon(Icons.edit, color: AppColors.primary, size: iconSize),
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
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: AppColors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _addBeneficiaire() {
    if (widget.beneficiaires.length >= widget.maxBeneficiaires) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Limite de ${widget.maxBeneficiaires} bénéficiaire(s) atteinte',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_nomController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez saisir le nom du bénéficiaire'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final lien = _selectedLien == 'Autre'
        ? _lienController.text.trim()
        : _selectedLien ?? '';

    if (lien.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez préciser le lien avec le souscripteur'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final nouveauBeneficiaire = Beneficiaire(
      nomComplet: _nomController.text.trim(),
      lienSouscripteur: lien,
      ordre: widget.beneficiaires.length + 1,
    );

    final nouveauxBeneficiaires = List<Beneficiaire>.from(widget.beneficiaires);
    nouveauxBeneficiaires.add(nouveauBeneficiaire);

    widget.onBeneficiairesChanged(nouveauxBeneficiaires);
    _clearForm();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bénéficiaire ajouté avec succès'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _updateBeneficiaire(int index) {
    if (_nomController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez saisir le nom du bénéficiaire'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final lien = _selectedLien == 'Autre'
        ? _lienController.text.trim()
        : _selectedLien ?? '';

    if (lien.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez préciser le lien avec le souscripteur'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final beneficiaireModifie = Beneficiaire(
      nomComplet: _nomController.text.trim(),
      lienSouscripteur: lien,
      ordre: widget.beneficiaires[index].ordre,
    );

    final nouveauxBeneficiaires = List<Beneficiaire>.from(widget.beneficiaires);
    nouveauxBeneficiaires[index] = beneficiaireModifie;

    widget.onBeneficiairesChanged(nouveauxBeneficiaires);
    _clearForm();
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bénéficiaire modifié avec succès'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _removeBeneficiaire(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Supprimer le bénéficiaire',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer ce bénéficiaire ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final nouveauxBeneficiaires = List<Beneficiaire>.from(
                widget.beneficiaires,
              );
              nouveauxBeneficiaires.removeAt(index);

              for (int i = 0; i < nouveauxBeneficiaires.length; i++) {
                nouveauxBeneficiaires[i] = Beneficiaire(
                  nomComplet: nouveauxBeneficiaires[i].nomComplet,
                  lienSouscripteur: nouveauxBeneficiaires[i].lienSouscripteur,
                  ordre: i + 1,
                );
              }

              widget.onBeneficiairesChanged(nouveauxBeneficiaires);
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bénéficiaire supprimé'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    _nomController.clear();
    _lienController.clear();
    _selectedLien = null;
  }

  Widget _buildLimitReachedMessage() {
    final marginTop = widget.screenWidth < 360 ? 12.0 : 16.0;
    final padding = widget.screenWidth < 360 ? 12.0 : 16.0;
    final iconSize = widget.screenWidth < 360 ? 18.0 : 20.0;
    final fontSize = (14.0 / widget.textScaleFactor).clamp(12.0, 16.0);
    final spacing = widget.screenWidth < 360 ? 10.0 : 12.0;
    
    return Container(
      margin: EdgeInsets.only(top: marginTop),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.primary, size: iconSize),
          SizedBox(width: spacing),
          Expanded(
            child: Text(
              'Limite de ${widget.maxBeneficiaires} bénéficiaire(s) atteinte. Vous pouvez modifier ou supprimer les bénéficiaires existants.',
              style: GoogleFonts.poppins(
                fontSize: fontSize,
                color: AppColors.textSecondary,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

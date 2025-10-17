import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarflex_app/core/constants/colors.dart';
import 'package:saarflex_app/data/models/beneficiaire_model.dart';

class BeneficiairesSelector extends StatefulWidget {
  final List<Beneficiaire> beneficiaires;
  final Function(List<Beneficiaire>) onBeneficiairesChanged;
  final bool hasError;
  final String? errorText;
  final int maxBeneficiaires;
  final bool necessiteBeneficiaires;

  const BeneficiairesSelector({
    super.key,
    required this.beneficiaires,
    required this.onBeneficiairesChanged,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bénéficiaires',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                'Ajoutez ou modifiez les informations des bénéficiaires',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: widget.beneficiaires.length >= widget.maxBeneficiaires
                      ? AppColors.error
                      : AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

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
          const SizedBox(height: 8),
          Text(
            widget.errorText!,
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.error),
          ),
        ],
      ],
    );
  }

  Widget _buildBeneficiaireCard(Beneficiaire beneficiaire, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                beneficiaire.ordre.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  beneficiaire.nomComplet,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  beneficiaire.lienSouscripteur,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _editBeneficiaire(index),
                icon: const Icon(
                  Icons.edit,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              IconButton(
                onPressed: () => _removeBeneficiaire(index),
                icon: const Icon(
                  Icons.delete,
                  color: AppColors.error,
                  size: 20,
                ),
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 10,
        child: Container(
          padding: const EdgeInsets.all(24),
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
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Modifier le bénéficiaire',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _buildBeneficiaireForm(),

              const SizedBox(height: 24),

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
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'Annuler',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateBeneficiaire(index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      child: Text(
                        'Modifier',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
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
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
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
              Icon(Icons.person_add, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Ajouter un bénéficiaire',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildBeneficiaireForm(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _addBeneficiaire,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Ajouter'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeneficiaireForm() {
    return Column(
      children: [
        TextFormField(
          controller: _nomController,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            labelText: 'Nom complet',
            hintText: 'Ex: Marie Dupont',
            hintStyle: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
            labelStyle: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            prefixIcon: const Icon(Icons.person, color: AppColors.primary),
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
        const SizedBox(height: 20),

        DropdownButtonFormField<String>(
          value: _liensDisponibles.contains(_selectedLien)
              ? _selectedLien
              : null,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            labelText: 'Lien avec le souscripteur',
            labelStyle: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            prefixIcon: const Icon(
              Icons.family_restroom,
              color: AppColors.primary,
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          items: [
            ..._liensDisponibles.map((lien) {
              return DropdownMenuItem(
                value: lien,
                child: Text(
                  lien,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
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
                    fontSize: 16,
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
          const SizedBox(height: 20),
          TextFormField(
            controller: _lienController,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              labelText: 'Précisez le lien',
              hintText: 'Ex: Cousin, Ami, etc.',
              hintStyle: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary.withOpacity(0.7),
              ),
              labelStyle: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              prefixIcon: const Icon(Icons.edit, color: AppColors.primary),
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
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
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Limite de ${widget.maxBeneficiaires} bénéficiaire(s) atteinte. Vous pouvez modifier ou supprimer les bénéficiaires existants.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

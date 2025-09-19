import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/simulation_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/contract_provider.dart';
import '../../models/product_model.dart';
import '../../models/simulation_model.dart';
import '../../utils/format_helper.dart';
import '../contracts/contracts_screen.dart';

class SimulationResultScreen extends StatefulWidget {
  final Product produit;
  final SimulationResponse resultat;

  const SimulationResultScreen({
    super.key,
    required this.produit,
    required this.resultat,
  });

  @override
  State<SimulationResultScreen> createState() => _SimulationResultScreenState();
}

class _SimulationResultScreenState extends State<SimulationResultScreen> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _nomController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // Formater le texte des détails de calcul en ajoutant des séparateurs de milliers
  String _formatCalculationText(String text) {
    return FormatHelper.formatTexteCalcul(text);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<SimulationProvider, AuthProvider>(
      builder: (context, simulationProvider, authProvider, child) {
        _handleSaveMessages(simulationProvider);
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSuccessHeader(),
                const SizedBox(height: 32),
                _buildProductInfo(),
                const SizedBox(height: 24),
                _buildAssureInfoCard(), // ← AJOUTEZ CETTE LIGNE
                const SizedBox(height: 24),
                _buildResultsCard(),
                const SizedBox(height: 24),
                _buildDetailsCard(),
                if (authProvider.isLoggedIn) ...[
                  const SizedBox(height: 24),
                  _buildSaveSection(simulationProvider),
                ],
                const SizedBox(height: 100),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomButtons(
            authProvider,
            simulationProvider,
          ),
        );
      },
    );
  }

  // Gestion des messages de sauvegarde
  void _handleSaveMessages(SimulationProvider provider) {
    if (provider.saveError != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.saveError!),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
        provider.clearSaveError();
      });
    }
  }

  // Construction de l'AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.close_rounded, color: AppColors.primary),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Text(
        'Résultat de simulation',
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      centerTitle: true,
    );
  }

  // En-tête de succès
  Widget _buildSuccessHeader() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.check_circle_rounded,
              size: 40,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Devis calculé avec succès !',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Voici votre devis personnalisé',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // Informations sur le produit
  Widget _buildProductInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: widget.produit.type.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              widget.produit.type.icon,
              color: widget.produit.type.color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.produit.nom,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.produit.type.label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: widget.resultat.statut.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.resultat.statut.label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: widget.resultat.statut.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour afficher les informations de l'assuré
  Widget _buildAssureInfoCard() {
    // Vérifier si l'assuré n'est pas le souscripteur ET si les informations existent
    if (widget.resultat.assureEstSouscripteur ||
        widget.resultat.informationsAssure == null) {
      return const SizedBox.shrink(); // Ne rien afficher
    }

    final informations = widget.resultat.informationsAssure!;

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Informations de l\'assuré',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            'Nom complet',
            informations['nom_complet']?.toString() ?? '',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Date de naissance',
            informations['date_naissance']?.toString() ?? '',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Type de pièce',
            informations['type_piece_identite']?.toString() ?? '',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Numéro de pièce',
            informations['numero_piece_identite']?.toString() ?? '',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Téléphone',
            informations['telephone']?.toString() ?? '',
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Adresse', informations['adresse']?.toString() ?? ''),
          if (informations['email'] != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow('Email', informations['email']!.toString()),
          ],
        ],
      ),
    );
  }

  // Helper pour afficher une ligne d'information
  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            '$label :',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Text(
            value.isNotEmpty ? value : 'Non renseigné',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  // Carte des résultats principaux
  Widget _buildResultsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Votre devis',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 24),
          _buildResultItem(
            'Prime ${widget.resultat.periodicitePrimeFormatee}',
            widget.resultat.primeFormatee,
            Icons.attach_money_rounded,
            isMainResult: true,
          ),
          const SizedBox(height: 16),
          _buildResultItem(
            'Franchise',
            widget.resultat.franchiseFormatee,
            Icons.account_balance_wallet_rounded,
          ),
          if (widget.resultat.plafondFormate != null) ...[
            const SizedBox(height: 16),
            _buildResultItem(
              'Plafond de couverture',
              widget.resultat.plafondFormate!,
              Icons.security_rounded,
            ),
          ],
        ],
      ),
    );
  }

  // Élément de résultat individuel
  Widget _buildResultItem(
    String label,
    String value,
    IconData icon, {
    bool isMainResult = false,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: AppColors.white, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: isMainResult ? 20 : 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Carte des détails
  Widget _buildDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Détails du calcul',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _formatCalculationText(
              widget.resultat.detailsCalcul?.explication ??
                  'Détails de calcul non disponibles',
            ),
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          if (widget.resultat.expiresAt != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    color: Colors.orange[700],
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ce devis expire le ${widget.resultat.expiresAt!.formatDate()}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.orange[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Section de sauvegarde
  Widget _buildSaveSection(SimulationProvider provider) {
    if (widget.resultat.statut == StatutDevis.sauvegarde) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.success.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Ce devis a déjà été sauvegardé dans vos contrats',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.success,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sauvegarder ce devis',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nomController,
            decoration: InputDecoration(
              label: RichText(
                text: TextSpan(
                  text: 'Nom du devis ',
                  style: GoogleFonts.poppins(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                  children: [
                    TextSpan(
                      text: '*',
                      style: GoogleFonts.poppins(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              hintText: 'Ex: Devis voiture familiale',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Notes personnelles (optionnel)',
              hintText: 'Ajoutez vos commentaires...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Boutons en bas de page
  Widget _buildBottomButtons(
    AuthProvider authProvider,
    SimulationProvider provider,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (authProvider.isLoggedIn) ...[
              ElevatedButton(
                onPressed: provider.isSaving
                    ? null
                    : () => _handleSaveQuote(provider),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      widget.resultat.statut == StatutDevis.sauvegarde
                      ? AppColors.textSecondary
                      : AppColors.secondary,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: provider.isSaving
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.white,
                          ),
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        widget.resultat.statut == StatutDevis.sauvegarde
                            ? 'Déjà sauvegardé'
                            : 'Sauvegarder le devis',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              const SizedBox(height: 12),
            ],
            ElevatedButton(
              onPressed: () => _procederSouscription(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                elevation: 0,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Procéder à la souscription',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Gestion de la sauvegarde du devis
  void _handleSaveQuote(SimulationProvider provider) {
    if (widget.resultat.statut == StatutDevis.sauvegarde) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ce devis a déjà été sauvegardé.'),
          backgroundColor: AppColors.info,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // Vérifier que le nom est obligatoire
    if (_nomController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Le nom du devis est obligatoire pour la sauvegarde.'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    provider
        .sauvegarderDevis(
          context: context,
          devisId: widget.resultat.id,
          nomPersonnalise: _nomController.text.trim(),
          notes: _notesController.text.isNotEmpty
              ? _notesController.text.trim()
              : null,
        )
        .then((_) {
          if (provider.saveError == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Devis sauvegardé avec succès !'),
                backgroundColor: AppColors.success,
                duration: const Duration(seconds: 2),
                action: SnackBarAction(
                  label: 'Voir mes contrats',
                  textColor: AppColors.white,
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const ContractsScreen(initialTab: 0),
                      ),
                    );
                  },
                ),
              ),
            );

            // Rafraîchir les contrats pour inclure le nouveau devis
            Provider.of<ContractProvider>(
              context,
              listen: false,
            ).loadSavedQuotes(forceRefresh: true);
          }
        });
  }

  // Procédure de souscription
  void _procederSouscription() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Redirection vers la souscription...'),
        backgroundColor: AppColors.primary,
      ),
    );

    // Navigation vers l'écran de souscription
    // Navigator.push(context, MaterialPageRoute(builder: (context) => SouscriptionScreen(devis: widget.resultat)));
  }
}

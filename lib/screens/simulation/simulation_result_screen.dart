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
import '../products/product_list_screen.dart';

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
  void initState() {
    super.initState();
    // Plus besoin d'initialiser les bénéficiaires car ils sont déjà inclus dans la simulation
  }

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
                _buildAssureInfoCard(),
                const SizedBox(height: 24),
                _buildResultsCard(),
                const SizedBox(height: 24),
                _buildDetailsCard(),
                const SizedBox(height: 24),
                _buildBeneficiairesCard(),

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

  // Méthode de souscription simplifiée
  void _procederSouscription() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const ContractsScreen()));
  }

  // Construction de l'AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.close_rounded, color: AppColors.primary),
        onPressed: () {
          // Rediriger vers le dashboard au lieu de revenir en arrière
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/dashboard',
            (route) => false,
          );
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
                            : 'Sauvegarder',
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
                'Souscrire',
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
  void _handleSaveQuote(SimulationProvider provider) async {
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

    // Plus besoin de vérifier les bénéficiaires car ils sont déjà inclus dans la simulation

    // Plus besoin de sauvegarder les bénéficiaires séparément

    // Afficher le popup de confirmation avant la sauvegarde
    _showSaveConfirmationDialog(provider);
  }

  // Popup de confirmation avant sauvegarde
  void _showSaveConfirmationDialog(SimulationProvider provider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Bouton fermer en haut à droite
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close_rounded,
                        color: AppColors.textSecondary,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                // Icône de sauvegarde
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.save_rounded,
                    color: AppColors.primary,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),

                // Titre
                Text(
                  'Sauvegarder le devis',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Message
                Text(
                  'Votre devis "${_nomController.text.trim()}" sera sauvegardé. Que souhaitez-vous faire ensuite ?',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Boutons d'action
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context); // Fermer le popup
                          _performSaveAndNavigate(provider, toProducts: true);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Nouvelle simulation',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Fermer le popup
                          _performSaveAndNavigate(provider, toProducts: false);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Voir mes devis',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Effectuer la sauvegarde et naviguer
  void _performSaveAndNavigate(
    SimulationProvider provider, {
    required bool toProducts,
  }) {
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
            // Afficher un message de succès
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Devis sauvegardé avec succès !'),
                backgroundColor: AppColors.success,
                duration: const Duration(seconds: 2),
              ),
            );

            // Rafraîchir les contrats pour inclure le nouveau devis
            Provider.of<ContractProvider>(
              context,
              listen: false,
            ).loadSavedQuotes(forceRefresh: true);

            // Naviguer selon le choix
            if (toProducts) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProductListScreen(),
                ),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const ContractsScreen(initialTab: 0),
                ),
              );
            }
          }
        });
  }

  // Widget pour afficher les bénéficiaires
  Widget _buildBeneficiairesCard() {
    // Vérifier s'il y a des bénéficiaires à afficher
    if (widget.resultat.beneficiaires.isEmpty) {
      return const SizedBox.shrink();
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
          Row(
            children: [
              Icon(
                Icons.people_outline_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Bénéficiaires',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...widget.resultat.beneficiaires.asMap().entries.map((entry) {
            final index = entry.key;
            final beneficiaire = entry.value;

            return Container(
              margin: EdgeInsets.only(
                bottom: index < widget.resultat.beneficiaires.length - 1
                    ? 12
                    : 0,
              ),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          beneficiaire['nom_complet'] ?? 'Nom non renseigné',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          beneficiaire['lien_souscripteur'] ??
                              'Lien non renseigné',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

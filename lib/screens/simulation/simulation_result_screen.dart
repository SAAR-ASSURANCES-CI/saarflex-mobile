import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/simulation_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/product_model.dart';
import '../../models/simulation_model.dart';

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

  @override
  Widget build(BuildContext context) {
    return Consumer2<SimulationProvider, AuthProvider>(
      builder: (context, simulationProvider, authProvider, child) {
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

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.close_rounded, color: AppColors.primary),
        onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
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
            widget.resultat.detailsCalcul?.explication ??
                'Détails de calcul non disponibles',
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

  Widget _buildSaveSection(SimulationProvider provider) {
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
              labelText: 'Nom du devis (optionnel)',
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
                onPressed: () {
                  if (widget.resultat.statut == StatutDevis.sauvegarde) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Ce devis a déjà été sauvegardé.'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }

                  provider.sauvegarderDevis(
                    devisId: widget.resultat.id,
                    nomPersonnalise: _nomController.text.isNotEmpty
                        ? _nomController.text
                        : null,
                    notes: _notesController.text.isNotEmpty
                        ? _notesController.text
                        : null,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
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
                        'Sauvegarder le devis',
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

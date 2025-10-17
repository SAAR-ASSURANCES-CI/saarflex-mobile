import 'package:saarflex_app/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:saarflex_app/presentation/features/contracts/viewmodels/contract_viewmodel.dart';
import 'package:saarflex_app/data/models/saved_quote_model.dart';
import 'package:saarflex_app/core/utils/format_helper.dart';
import 'package:saarflex_app/presentation/shared/widgets/quote_card.dart';
import 'package:saarflex_app/presentation/shared/widgets/empty_state_widget.dart';
import 'package:saarflex_app/presentation/features/souscription/screens/souscription_screen.dart';

class SavedQuotesTab extends StatefulWidget {
  const SavedQuotesTab({super.key});

  @override
  State<SavedQuotesTab> createState() => _SavedQuotesTabState();
}

class _SavedQuotesTabState extends State<SavedQuotesTab> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreQuotes();
    }
  }

  Future<void> _loadMoreQuotes() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    // Pagination sera implémentée quand l'API le supportera
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoadingMore = false;
    });
  }

  Future<void> _onRefresh() async {
    await Provider.of<ContractViewModel>(
      context,
      listen: false,
    ).loadSavedQuotes(forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ContractViewModel>(
      builder: (context, contractProvider, child) {
        return RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppColors.primary,
          child: _buildContent(contractProvider),
        );
      },
    );
  }

  Widget _buildContent(ContractViewModel contractProvider) {
    if (contractProvider.isLoadingSavedQuotes &&
        contractProvider.savedQuotes.isEmpty) {
      return _buildLoadingState();
    }

    if (contractProvider.savedQuotesError != null) {
      return _buildErrorState(contractProvider.savedQuotesError!);
    }

    if (contractProvider.savedQuotes.isEmpty) {
      return _buildEmptyState();
    }

    return _buildQuotesList(contractProvider);
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          SizedBox(height: 16),
          Text(
            'Chargement de vos devis...',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Erreur de chargement',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Provider.of<ContractViewModel>(
                  context,
                  listen: false,
                ).loadSavedQuotes(forceRefresh: true);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return EmptyStateWidget(
      icon: Icons.description_outlined,
      title: 'Aucun devis sauvegardé',
      message:
          'Vous n\'avez pas encore sauvegardé de devis.\nCommencez par faire une simulation !',
      actionText: 'Faire une simulation',
      onAction: () {
        Navigator.pop(context);
        // Navigation vers la liste des produits
      },
    );
  }

  Widget _buildQuotesList(ContractViewModel contractProvider) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: contractProvider.savedQuotes.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= contractProvider.savedQuotes.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          );
        }

        final quote = contractProvider.savedQuotes[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: QuoteCard(
            quote: quote,
            onTap: () => _showQuoteDetails(quote),
            onDelete: () => _deleteQuote(quote),
            onSubscribe: () => _subscribeQuote(quote),
          ),
        );
      },
    );
  }

  void _showQuoteDetails(SavedQuote quote) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildQuoteDetailsModal(quote),
    );
  }

  Widget _buildQuoteDetailsModal(SavedQuote quote) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.textSecondary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quote.nomPersonnalise ?? quote.nomProduit,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    quote.typeProduit,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildDetailRow(
                    'Prime calculée',
                    FormatHelper.formatMontant(quote.primeCalculee),
                  ),
                  _buildDetailRow(
                    'Franchise',
                    FormatHelper.formatMontant(quote.franchiseCalculee),
                  ),
                  if (quote.plafondCalcule != null)
                    _buildDetailRow(
                      'Plafond',
                      FormatHelper.formatMontant(quote.plafondCalcule!),
                    ),
                  _buildDetailRow('Statut', quote.statut),
                  _buildDetailRow(
                    'Date de création',
                    _formatDate(quote.createdAt),
                  ),

                  // Section Informations de l'assuré
                  if (quote.informationsAssure != null) ...[
                    const SizedBox(height: 24),
                    _buildSectionTitle('Informations de l\'assuré'),
                    const SizedBox(height: 16),
                    _buildAssureInfo(
                      quote.informationsAssure!,
                      quote.beneficiaires,
                    ),
                  ],
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _deleteQuote(quote);
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Supprimer'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _subscribeQuote(quote);
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Souscrire'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _deleteQuote(SavedQuote quote) async {
    final confirmed = await _showDeleteConfirmation(quote);
    if (!confirmed) return;

    try {
      await Provider.of<ContractViewModel>(
        context,
        listen: false,
      ).deleteSavedQuote(quote.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Devis "${quote.nomPersonnalise ?? quote.nomProduit}" supprimé',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la suppression: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<bool> _showDeleteConfirmation(SavedQuote quote) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Supprimer le devis',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            content: Text(
              'Êtes-vous sûr de vouloir supprimer le devis "${quote.nomPersonnalise ?? quote.nomProduit}" ?',
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.white,
                ),
                child: const Text('Supprimer'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _subscribeQuote(SavedQuote quote) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => souscriptionScreen(
          savedQuote: quote,
          source: 'saved_quote',
          // TODO: Récupérer le produit depuis l'API ou le cache
          // product: await _getProductById(quote.productId),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Icon(Icons.person_outline_rounded, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildAssureInfo(
    Map<String, dynamic> informations,
    List<Map<String, dynamic>>? beneficiaires,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow(
          'Nom complet',
          informations['nom_complet']?.toString() ?? 'Non renseigné',
        ),
        if (informations['email'] != null)
          _buildDetailRow('Email', informations['email']!.toString()),
        if (informations['telephone'] != null)
          _buildDetailRow('Téléphone', informations['telephone']!.toString()),
        if (informations['adresse'] != null)
          _buildDetailRow('Adresse', informations['adresse']!.toString()),
        if (informations['date_naissance'] != null)
          _buildDetailRow(
            'Date de naissance',
            informations['date_naissance']!.toString(),
          ),
        if (informations['type_piece_identite'] != null &&
            informations['numero_piece_identite'] != null)
          _buildDetailRow(
            'Pièce d\'identité',
            '${informations['type_piece_identite']} - ${informations['numero_piece_identite']}',
          ),

        // Section Bénéficiaires
        if ((beneficiaires != null && beneficiaires.isNotEmpty) ||
            (informations['nombre_beneficiaires'] != null &&
                informations['nombre_beneficiaires'] > 0)) ...[
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(
                Icons.people_outline_rounded,
                color: AppColors.primary,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Bénéficiaires',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (beneficiaires != null && beneficiaires.isNotEmpty) ...[
            ...beneficiaires.asMap().entries.map((entry) {
              final index = entry.key;
              final beneficiaire = entry.value;

              return Container(
                margin: EdgeInsets.only(
                  bottom: index < beneficiaires.length - 1 ? 8 : 0,
                ),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
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
                            beneficiaire['nom_complet']?.toString() ??
                                'Nom non renseigné',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            beneficiaire['lien_souscripteur']?.toString() ??
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
          ] else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${informations['nombre_beneficiaires'] ?? 0} bénéficiaire(s) configuré(s)',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ],
    );
  }
}

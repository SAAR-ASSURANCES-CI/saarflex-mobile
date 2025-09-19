import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/contract_provider.dart';
import '../../models/saved_quote_model.dart';
import '../../utils/format_helper.dart';
import '../widgets/quote_card.dart';
import '../widgets/empty_state_widget.dart';

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

    // TODO: Implémenter la pagination quand l'API le supportera
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoadingMore = false;
    });
  }

  Future<void> _onRefresh() async {
    await Provider.of<ContractProvider>(
      context,
      listen: false,
    ).loadSavedQuotes(forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ContractProvider>(
      builder: (context, contractProvider, child) {
        return RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppColors.primary,
          child: _buildContent(contractProvider),
        );
      },
    );
  }

  Widget _buildContent(ContractProvider contractProvider) {
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
                Provider.of<ContractProvider>(
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
        // TODO: Naviguer vers la liste des produits
      },
    );
  }

  Widget _buildQuotesList(ContractProvider contractProvider) {
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
                  if (quote.notes != null && quote.notes!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Notes',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      quote.notes!,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
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
      await Provider.of<ContractProvider>(
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
    try {
      await Provider.of<ContractProvider>(
        context,
        listen: false,
      ).subscribeQuote(quote.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Devis "${quote.nomPersonnalise ?? quote.nomProduit}" souscrit avec succès !',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la souscription: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

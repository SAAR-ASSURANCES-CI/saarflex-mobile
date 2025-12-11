import 'package:saarflex_app/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:saarflex_app/presentation/features/contracts/viewmodels/contract_viewmodel.dart';
import 'package:saarflex_app/data/models/saved_quote_model.dart';
import 'package:saarflex_app/core/utils/format_helper.dart';
import 'package:saarflex_app/presentation/features/contracts/widgets/quote_card.dart';
import 'package:saarflex_app/presentation/shared/empty_state_widget.dart';
import 'package:saarflex_app/presentation/features/souscription/screens/souscription_screen.dart';

class SavedQuotesTab extends StatefulWidget {
  final double screenWidth;
  final double textScaleFactor;

  const SavedQuotesTab({
    super.key,
    required this.screenWidth,
    required this.textScaleFactor,
  });

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
    final fontSize = (16.0 / widget.textScaleFactor).clamp(14.0, 18.0);
    final spacing = widget.screenWidth < 360 ? 12.0 : 16.0;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          SizedBox(height: spacing),
          Text(
            'Chargement de vos devis...',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    final padding = widget.screenWidth < 360 ? 16.0 : 24.0;
    final iconSize = widget.screenWidth < 360 ? 48.0 : 64.0;
    final titleFontSize = (18.0 / widget.textScaleFactor).clamp(16.0, 20.0);
    final errorFontSize = (14.0 / widget.textScaleFactor).clamp(12.0, 16.0);
    final buttonFontSize = (16.0 / widget.textScaleFactor).clamp(14.0, 18.0);
    final spacing1 = widget.screenWidth < 360 ? 12.0 : 16.0;
    final spacing2 = widget.screenWidth < 360 ? 6.0 : 8.0;
    final spacing3 = widget.screenWidth < 360 ? 20.0 : 24.0;
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: iconSize, color: AppColors.error),
            SizedBox(height: spacing1),
            Text(
              'Erreur de chargement',
              style: GoogleFonts.poppins(
                fontSize: titleFontSize,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacing2),
            Text(
              error,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: errorFontSize,
                color: AppColors.textSecondary,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: spacing3),
            ElevatedButton.icon(
              onPressed: () {
                Provider.of<ContractViewModel>(
                  context,
                  listen: false,
                ).loadSavedQuotes(forceRefresh: true);
              },
              icon: Icon(
                Icons.refresh,
                size: widget.screenWidth < 360 ? 18 : 20,
              ),
              label: Text(
                'Réessayer',
                style: GoogleFonts.poppins(fontSize: buttonFontSize),
              ),
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

      },
    );
  }

  Widget _buildQuotesList(ContractViewModel contractProvider) {
    final padding = widget.screenWidth < 360 ? 12.0 : 16.0;
    final cardSpacing = widget.screenWidth < 360 ? 12.0 : 16.0;
    
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(padding),
      itemCount: contractProvider.savedQuotes.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= contractProvider.savedQuotes.length) {
          return Padding(
            padding: EdgeInsets.all(padding),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          );
        }

        final quote = contractProvider.savedQuotes[index];
        return Padding(
          padding: EdgeInsets.only(bottom: cardSpacing),
          child: QuoteCard(
            quote: quote,
            onTap: () => _showQuoteDetails(quote),
            onDelete: () => _deleteQuote(quote),
            onSubscribe: () => _subscribeQuote(quote),
            screenWidth: widget.screenWidth,
            textScaleFactor: widget.textScaleFactor,
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
    final screenHeight = MediaQuery.of(context).size.height;
    final modalHeight = screenHeight < 600 
        ? screenHeight * 0.9 
        : screenHeight * 0.8;
    final padding = widget.screenWidth < 360 ? 16.0 : 24.0;
    final titleFontSize = (24.0 / widget.textScaleFactor).clamp(20.0, 28.0);
    final subtitleFontSize = (16.0 / widget.textScaleFactor).clamp(14.0, 18.0);
    final buttonFontSize = (16.0 / widget.textScaleFactor).clamp(14.0, 18.0);
    final buttonIconSize = widget.screenWidth < 360 ? 18.0 : 20.0;
    final buttonSpacing = widget.screenWidth < 360 ? 12.0 : 16.0;
    final buttonPadding = widget.screenWidth < 360 ? 16.0 : 24.0;
    
    return Container(
      height: modalHeight,
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
            margin: EdgeInsets.symmetric(vertical: widget.screenWidth < 360 ? 10.0 : 12.0),
            decoration: BoxDecoration(
              color: AppColors.textSecondary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quote.nomPersonnalise ?? quote.nomProduit,
                    style: GoogleFonts.poppins(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: widget.screenWidth < 360 ? 6.0 : 8.0),
                  Text(
                    quote.typeProduit,
                    style: GoogleFonts.poppins(
                      fontSize: subtitleFontSize,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: widget.screenWidth < 360 ? 20.0 : 24.0),
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

                  if (quote.informationsAssure != null) ...[
                    SizedBox(height: widget.screenWidth < 360 ? 20.0 : 24.0),
                    _buildSectionTitle('Informations de l\'assuré'),
                    SizedBox(height: widget.screenWidth < 360 ? 12.0 : 16.0),
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
            padding: EdgeInsets.all(buttonPadding),
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
                    icon: Icon(Icons.delete_outline, size: buttonIconSize),
                    label: Text(
                      'Supprimer',
                      style: GoogleFonts.poppins(fontSize: buttonFontSize),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      padding: EdgeInsets.symmetric(
                        vertical: widget.screenWidth < 360 ? 12.0 : 14.0,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: buttonSpacing),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _subscribeQuote(quote);
                    },
                    icon: Icon(Icons.check, size: buttonIconSize),
                    label: Text(
                      'Souscrire',
                      style: GoogleFonts.poppins(fontSize: buttonFontSize),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: widget.screenWidth < 360 ? 12.0 : 14.0,
                      ),
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
    final labelWidth = widget.screenWidth < 360 ? 100.0 : 120.0;
    final fontSize = (14.0 / widget.textScaleFactor).clamp(12.0, 16.0);
    final bottomPadding = widget.screenWidth < 360 ? 10.0 : 12.0;
    
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: labelWidth,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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


        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final iconSize = widget.screenWidth < 360 ? 18.0 : 20.0;
    final fontSize = (16.0 / widget.textScaleFactor).clamp(14.0, 18.0);
    final spacing = widget.screenWidth < 360 ? 6.0 : 8.0;
    
    return Row(
      children: [
        Icon(Icons.person_outline_rounded, color: AppColors.primary, size: iconSize),
        SizedBox(width: spacing),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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

        if ((beneficiaires != null && beneficiaires.isNotEmpty) ||
            (informations['nombre_beneficiaires'] != null &&
                informations['nombre_beneficiaires'] > 0)) ...[
          SizedBox(height: widget.screenWidth < 360 ? 16.0 : 20.0),
          Row(
            children: [
              Icon(
                Icons.people_outline_rounded,
                color: AppColors.primary,
                size: widget.screenWidth < 360 ? 14.0 : 16.0,
              ),
              SizedBox(width: widget.screenWidth < 360 ? 6.0 : 8.0),
              Expanded(
                child: Text(
                  'Bénéficiaires',
                  style: GoogleFonts.poppins(
                    fontSize: (14.0 / widget.textScaleFactor).clamp(12.0, 16.0),
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: widget.screenWidth < 360 ? 10.0 : 12.0),
          if (beneficiaires != null && beneficiaires.isNotEmpty) ...[
            ...beneficiaires.asMap().entries.map((entry) {
              final index = entry.key;
              final beneficiaire = entry.value;
              final containerPadding = widget.screenWidth < 360 ? 10.0 : 12.0;
              final badgeSize = widget.screenWidth < 360 ? 20.0 : 24.0;
              final badgeFontSize = (12.0 / widget.textScaleFactor).clamp(10.0, 14.0);
              final nameFontSize = (14.0 / widget.textScaleFactor).clamp(12.0, 16.0);
              final linkFontSize = (12.0 / widget.textScaleFactor).clamp(10.0, 14.0);
              final spacing1 = widget.screenWidth < 360 ? 10.0 : 12.0;
              final spacing2 = widget.screenWidth < 360 ? 2.0 : 2.0;
              final marginBottom = widget.screenWidth < 360 ? 6.0 : 8.0;

              return Container(
                margin: EdgeInsets.only(
                  bottom: index < beneficiaires.length - 1 ? marginBottom : 0,
                ),
                padding: EdgeInsets.all(containerPadding),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Row(
                  children: [
                    Container(
                      width: badgeSize,
                      height: badgeSize,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(badgeSize / 2),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
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
                            beneficiaire['nom_complet']?.toString() ??
                                'Nom non renseigné',
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
                            beneficiaire['lien_souscripteur']?.toString() ??
                                'Lien non renseigné',
                            style: GoogleFonts.poppins(
                              fontSize: linkFontSize,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
              padding: EdgeInsets.all(widget.screenWidth < 360 ? 10.0 : 12.0),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.primary,
                    size: widget.screenWidth < 360 ? 18.0 : 20.0,
                  ),
                  SizedBox(width: widget.screenWidth < 360 ? 10.0 : 12.0),
                  Expanded(
                    child: Text(
                      '${informations['nombre_beneficiaires'] ?? 0} bénéficiaire(s) configuré(s)',
                      style: GoogleFonts.poppins(
                        fontSize: (14.0 / widget.textScaleFactor).clamp(12.0, 16.0),
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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

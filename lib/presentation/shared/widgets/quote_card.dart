import 'package:saarflex_app/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:saarflex_app/data/models/saved_quote_model.dart';
import 'package:saarflex_app/core/utils/format_helper.dart';

class QuoteCard extends StatelessWidget {
  final SavedQuote quote;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onSubscribe;

  const QuoteCard({
    super.key,
    required this.quote,
    required this.onTap,
    required this.onDelete,
    required this.onSubscribe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showQuoteDetails(context),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildInfoRow(),
                const SizedBox(height: 16),
                _buildActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.description, color: AppColors.primary, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                quote.nomPersonnalise ?? quote.nomProduit,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                quote.typeProduit,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor().withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _getStatusText(),
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _getStatusColor(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow() {
    return Row(
      children: [
        Expanded(
          child: _buildInfoItem(
            'Prime',
            FormatHelper.formatMontant(quote.primeCalculee),
            Icons.payments,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildInfoItem(
            'Franchise',
            FormatHelper.formatMontant(quote.franchiseCalculee),
            Icons.security,
          ),
        ),
      ],
    );
  }

  String _formatNumber(String numberStr) {
    final number = double.tryParse(numberStr);
    if (number == null) return numberStr;

    return FormatHelper.formatMontant(number);
  }

  void _showQuoteDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.description_outlined, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                quote.nomPersonnalise ?? quote.nomProduit,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Informations du devis (simplifiées)
              _buildDetailSection('Informations du devis', Icons.info_outline, [
                _buildDetailRow('Produit', quote.nomProduit),
                _buildDetailRow(
                  'Prime',
                  _formatNumber(quote.primeCalculee.toString()),
                ),
                _buildDetailRow(
                  'Franchise',
                  _formatNumber(quote.franchiseCalculee.toString()),
                ),
                _buildDetailRow(
                  'Date',
                  DateFormat(
                    'dd/MM/yyyy à HH:mm',
                    'fr_FR',
                  ).format(quote.createdAt),
                ),
              ]),

              if (quote.informationsAssure != null) ...[
                const SizedBox(height: 16),
                _buildDetailSection(
                  'Informations de l\'assuré',
                  Icons.person_outline,
                  [
                    _buildDetailRow(
                      'Nom complet',
                      quote.informationsAssure?['nom_complet'] ??
                          'Non renseigné',
                    ),
                    _buildDetailRow(
                      'Email',
                      quote.informationsAssure?['email'] ?? 'Non renseigné',
                    ),
                    _buildDetailRow(
                      'Téléphone',
                      quote.informationsAssure?['telephone'] ?? 'Non renseigné',
                    ),
                    _buildDetailRow(
                      'Adresse',
                      quote.informationsAssure?['adresse'] ?? 'Non renseigné',
                    ),
                    _buildDetailRow(
                      'Date de naissance',
                      _formatDateString(
                        quote.informationsAssure?['date_naissance'],
                      ),
                    ),
                    _buildDetailRow(
                      'Pièce d\'identité',
                      '${quote.informationsAssure?['type_piece_identite'] ?? 'Non renseigné'} - ${quote.informationsAssure?['numero_piece_identite'] ?? 'N/A'}',
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Fermer',
              style: GoogleFonts.poppins(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty) ...[
            SizedBox(
              width: 100,
              child: Text(
                '$label:',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateString(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'Non renseigné';

    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy', 'fr_FR').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('Supprimer'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onSubscribe,
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Souscrire'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (quote.statut.toLowerCase()) {
      case 'sauvegarde':
        return AppColors.info;
      case 'souscrit':
        return AppColors.success;
      case 'expire':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusText() {
    switch (quote.statut.toLowerCase()) {
      case 'sauvegarde':
        return 'Sauvegardé';
      case 'souscrit':
        return 'Souscrit';
      case 'expire':
        return 'Expiré';
      default:
        return quote.statut;
    }
  }
}

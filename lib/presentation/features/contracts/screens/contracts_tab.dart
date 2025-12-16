import 'package:saarciflex_app/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:saarciflex_app/presentation/features/contracts/viewmodels/contract_viewmodel.dart';
import 'package:saarciflex_app/core/utils/format_helper.dart';
import 'package:saarciflex_app/presentation/shared/empty_state_widget.dart';

class ContractsTab extends StatefulWidget {
  final TabController? tabController;
  final double screenWidth;
  final double textScaleFactor;

  const ContractsTab({
    super.key,
    this.tabController,
    required this.screenWidth,
    required this.textScaleFactor,
  });

  @override
  State<ContractsTab> createState() => _ContractsTabState();
}

class _ContractsTabState extends State<ContractsTab> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ContractViewModel>(context, listen: false).loadContracts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ContractViewModel>(
      builder: (context, contractProvider, child) {
        return RefreshIndicator(
          onRefresh: () async {
            await contractProvider.loadContracts(forceRefresh: true);
          },
          color: AppColors.primary,
          child: _buildContent(contractProvider),
        );
      },
    );
  }

  Widget _buildContent(ContractViewModel contractProvider) {
    if (contractProvider.isLoadingContracts &&
        contractProvider.contracts.isEmpty) {
      return _buildLoadingState();
    }

    if (contractProvider.contractsError != null) {
      return _buildErrorState(contractProvider.contractsError!);
    }

    if (contractProvider.contracts.isEmpty) {
      return _buildEmptyState();
    }

    return _buildContractsList(contractProvider);
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
            'Chargement de vos contrats...',
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
                ).loadContracts(forceRefresh: true);
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
      icon: Icons.assignment_outlined,
      title: 'Aucun contrat actif',
      message:
          'Vous n\'avez pas encore de contrats actifs.\nSouscrivez un devis pour créer votre premier contrat !',
      actionText: 'Voir mes devis',
      onAction: () {

        widget.tabController?.animateTo(0);
      },
    );
  }

  Widget _buildContractsList(ContractViewModel contractProvider) {
    final padding = widget.screenWidth < 360 ? 12.0 : 16.0;
    final cardSpacing = widget.screenWidth < 360 ? 12.0 : 16.0;
    
    return ListView.builder(
      padding: EdgeInsets.all(padding),
      itemCount: contractProvider.contracts.length,
      itemBuilder: (context, index) {
        final contract = contractProvider.contracts[index];
        return Padding(
          padding: EdgeInsets.only(bottom: cardSpacing),
          child: _buildContractCard(contract),
        );
      },
    );
  }

  Widget _buildContractCard(contract) {
    final cardPadding = widget.screenWidth < 360 ? 16.0 : 20.0;
    final iconSize = widget.screenWidth < 360 ? 20.0 : 24.0;
    final iconPadding = widget.screenWidth < 360 ? 6.0 : 8.0;
    final titleFontSize = (16.0 / widget.textScaleFactor).clamp(14.0, 18.0);
    final subtitleFontSize = (14.0 / widget.textScaleFactor).clamp(12.0, 16.0);
    final statusFontSize = (12.0 / widget.textScaleFactor).clamp(10.0, 14.0);
    final spacing1 = widget.screenWidth < 360 ? 10.0 : 12.0;
    final spacing2 = widget.screenWidth < 360 ? 3.0 : 4.0;
    final spacing3 = widget.screenWidth < 360 ? 12.0 : 16.0;
    final spacing4 = widget.screenWidth < 360 ? 16.0 : 20.0;
    final buttonIconSize = widget.screenWidth < 360 ? 16.0 : 18.0;
    final buttonFontSize = (14.0 / widget.textScaleFactor).clamp(12.0, 16.0);
    final buttonSpacing = widget.screenWidth < 360 ? 10.0 : 12.0;
    final statusPaddingH = widget.screenWidth < 360 ? 10.0 : 12.0;
    final statusPaddingV = widget.screenWidth < 360 ? 5.0 : 6.0;
    
    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
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
              Container(
                padding: EdgeInsets.all(iconPadding),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.assignment,
                  color: AppColors.primary,
                  size: iconSize,
                ),
              ),
              SizedBox(width: spacing1),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contract.nomPersonnalise ?? contract.nomProduit,
                      style: GoogleFonts.poppins(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: spacing2),
                    Text(
                      contract.typeProduit,
                      style: GoogleFonts.poppins(
                        fontSize: subtitleFontSize,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: statusPaddingH,
                  vertical: statusPaddingV,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(contract.statut).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  contract.statusDisplayName,
                  style: GoogleFonts.poppins(
                    fontSize: statusFontSize,
                    fontWeight: FontWeight.w500,
                    color: _getStatusColor(contract.statut),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing3),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'Prime',
                  FormatHelper.formatMontant(contract.primeCalculee),
                  Icons.payments,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  'Franchise',
                  FormatHelper.formatMontant(contract.franchiseCalculee),
                  Icons.security,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing3),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'N° Contrat',
                  contract.numeroContrat,
                  Icons.confirmation_number,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  'Date souscription',
                  _formatDate(contract.dateSouscription),
                  Icons.calendar_today,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing4),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showContractDetails(contract),
                  icon: Icon(Icons.visibility, size: buttonIconSize),
                  label: Text(
                    'Détails',
                    style: GoogleFonts.poppins(fontSize: buttonFontSize),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: EdgeInsets.symmetric(
                      vertical: widget.screenWidth < 360 ? 10.0 : 12.0,
                    ),
                  ),
                ),
              ),
              SizedBox(width: buttonSpacing),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _downloadContract(contract),
                  icon: Icon(Icons.download, size: buttonIconSize),
                  label: Text(
                    'Télécharger',
                    style: GoogleFonts.poppins(fontSize: buttonFontSize),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: widget.screenWidth < 360 ? 10.0 : 12.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    final iconSize = widget.screenWidth < 360 ? 14.0 : 16.0;
    final labelFontSize = (12.0 / widget.textScaleFactor).clamp(10.0, 14.0);
    final valueFontSize = (14.0 / widget.textScaleFactor).clamp(12.0, 16.0);
    final iconSpacing = widget.screenWidth < 360 ? 5.0 : 6.0;
    final valueSpacing = widget.screenWidth < 360 ? 3.0 : 4.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: iconSize, color: AppColors.textSecondary),
            SizedBox(width: iconSpacing),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: labelFontSize,
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: valueSpacing),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: valueFontSize,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'actif':
        return AppColors.success;
      case 'expire':
        return AppColors.error;
      case 'suspendu':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _showContractDetails(contract) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildContractDetailsModal(contract),
    );
  }

  Widget _buildContractDetailsModal(contract) {
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
                    contract.nomPersonnalise ?? contract.nomProduit,
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
                    contract.typeProduit,
                    style: GoogleFonts.poppins(
                      fontSize: subtitleFontSize,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: widget.screenWidth < 360 ? 20.0 : 24.0),
                  _buildDetailRow('Numéro de contrat', contract.numeroContrat),
                  _buildDetailRow('Statut', contract.statusDisplayName),
                  _buildDetailRow(
                    'Prime',
                    FormatHelper.formatMontant(contract.primeCalculee),
                  ),
                  _buildDetailRow(
                    'Franchise',
                    FormatHelper.formatMontant(contract.franchiseCalculee),
                  ),
                  if (contract.plafondCalcule != null)
                    _buildDetailRow(
                      'Plafond',
                      FormatHelper.formatMontant(contract.plafondCalcule!),
                    ),
                  _buildDetailRow(
                    'Date de souscription',
                    _formatDate(contract.dateSouscription),
                  ),
                  if (contract.dateExpiration != null)
                    _buildDetailRow(
                      'Date d\'expiration',
                      _formatDate(contract.dateExpiration!),
                    ),
                  _buildDetailRow(
                    'Bénéficiaires',
                    '${contract.nombreBeneficiaires}',
                  ),
                  _buildDetailRow('Documents', '${contract.nombreDocuments}'),
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
                      _downloadContract(contract);
                    },
                    icon: Icon(Icons.download, size: buttonIconSize),
                    label: Text(
                      'Télécharger',
                      style: GoogleFonts.poppins(fontSize: buttonFontSize),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
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
                      _manageContract(contract);
                    },
                    icon: Icon(Icons.settings, size: buttonIconSize),
                    label: Text(
                      'Gérer',
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
    final labelWidth = widget.screenWidth < 360 ? 100.0 : 140.0;
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

  void _downloadContract(contract) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Téléchargement du contrat ${contract.numeroContrat}...'),
        backgroundColor: AppColors.primary,
      ),
    );

  }

  void _manageContract(contract) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Gestion du contrat ${contract.numeroContrat}...'),
        backgroundColor: AppColors.primary,
      ),
    );

  }
}

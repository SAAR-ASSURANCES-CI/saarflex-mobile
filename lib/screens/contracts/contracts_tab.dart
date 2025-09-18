import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/contract_provider.dart';
import '../widgets/empty_state_widget.dart';

class ContractsTab extends StatefulWidget {
  final TabController? tabController;

  const ContractsTab({super.key, this.tabController});

  @override
  State<ContractsTab> createState() => _ContractsTabState();
}

class _ContractsTabState extends State<ContractsTab> {
  @override
  void initState() {
    super.initState();
    // Charger les contrats au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ContractProvider>(context, listen: false).loadContracts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ContractProvider>(
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

  Widget _buildContent(ContractProvider contractProvider) {
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
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          SizedBox(height: 16),
          Text(
            'Chargement de vos contrats...',
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
                ).loadContracts(forceRefresh: true);
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
      icon: Icons.assignment_outlined,
      title: 'Aucun contrat actif',
      message:
          'Vous n\'avez pas encore de contrats actifs.\nSouscrivez un devis pour créer votre premier contrat !',
      actionText: 'Voir mes devis',
      onAction: () {
        // Changer vers l'onglet des devis simulés
        widget.tabController?.animateTo(0);
      },
    );
  }

  Widget _buildContractsList(ContractProvider contractProvider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: contractProvider.contracts.length,
      itemBuilder: (context, index) {
        final contract = contractProvider.contracts[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildContractCard(contract),
        );
      },
    );
  }

  Widget _buildContractCard(contract) {
    return Container(
      padding: const EdgeInsets.all(20),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.assignment,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contract.nomPersonnalise ?? contract.nomProduit,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      contract.typeProduit,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(contract.statut).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  contract.statusDisplayName,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _getStatusColor(contract.statut),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'Prime',
                  '${contract.primeCalculee.toStringAsFixed(0)} FCFA',
                  Icons.payments,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  'Franchise',
                  '${contract.franchiseCalculee.toStringAsFixed(0)} FCFA',
                  Icons.security,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showContractDetails(contract),
                  icon: const Icon(Icons.visibility, size: 18),
                  label: const Text('Détails'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _downloadContract(contract),
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('Télécharger'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
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
                    contract.nomPersonnalise ?? contract.nomProduit,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    contract.typeProduit,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildDetailRow('Numéro de contrat', contract.numeroContrat),
                  _buildDetailRow('Statut', contract.statusDisplayName),
                  _buildDetailRow(
                    'Prime',
                    '${contract.primeCalculee.toStringAsFixed(0)} FCFA',
                  ),
                  _buildDetailRow(
                    'Franchise',
                    '${contract.franchiseCalculee.toStringAsFixed(0)} FCFA',
                  ),
                  if (contract.plafondCalcule != null)
                    _buildDetailRow(
                      'Plafond',
                      '${contract.plafondCalcule!.toStringAsFixed(0)} FCFA',
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
                      _downloadContract(contract);
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Télécharger'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _manageContract(contract);
                    },
                    icon: const Icon(Icons.settings),
                    label: const Text('Gérer'),
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
            width: 140,
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

  void _downloadContract(contract) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Téléchargement du contrat ${contract.numeroContrat}...'),
        backgroundColor: AppColors.primary,
      ),
    );
    // TODO: Implémenter le téléchargement réel
  }

  void _manageContract(contract) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Gestion du contrat ${contract.numeroContrat}...'),
        backgroundColor: AppColors.primary,
      ),
    );
    // TODO: Implémenter la gestion du contrat
  }
}

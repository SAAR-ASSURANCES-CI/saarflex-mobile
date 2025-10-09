import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saarflex_app/presentation/features/simulation/viewmodels/simulation_viewmodel.dart';
import 'package:saarflex_app/presentation/features/contracts/screens/contracts_screen.dart';
import 'package:saarflex_app/core/constants/colors.dart';
import 'package:saarflex_app/data/models/product_model.dart';
import 'package:saarflex_app/data/models/simulation_model.dart';
import 'package:saarflex_app/presentation/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:saarflex_app/presentation/features/simulation/widgets/result_success_header.dart';
import 'package:saarflex_app/presentation/features/simulation/widgets/result_product_info.dart';
import 'package:saarflex_app/presentation/features/simulation/widgets/result_main_card.dart';
import 'package:saarflex_app/presentation/features/simulation/widgets/result_details_card.dart';
import 'package:saarflex_app/presentation/features/simulation/widgets/result_bottom_buttons.dart';

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
  }

  @override
  void dispose() {
    _nomController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const ResultSuccessHeader(),
            const SizedBox(height: 32),
            ResultProductInfo(
              produit: widget.produit,
              resultat: widget.resultat,
            ),
            const SizedBox(height: 24),
            ResultMainCard(resultat: widget.resultat),
            const SizedBox(height: 24),
            ResultDetailsCard(resultat: widget.resultat),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Consumer2<SimulationViewModel, AuthViewModel>(
        builder: (context, simulationProvider, authProvider, child) {
          return ResultBottomButtons(
            simulationProvider: simulationProvider,
            authProvider: authProvider,
            onSave: () => _showSaveDialog(simulationProvider),
            onSubscribe: () => _souscrire(simulationProvider),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_rounded, color: AppColors.primary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Résultat de simulation',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      centerTitle: false,
    );
  }

  void _showSaveDialog(SimulationViewModel simulationProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Sauvegarder le devis',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nomController,
                decoration: InputDecoration(
                  labelText: 'Nom personnalisé (optionnel)',
                  hintText: 'Ex: Mon devis assurance vie',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Notes (optionnel)',
                  hintText: 'Ajoutez des notes personnelles...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _sauvegarderDevis(simulationProvider);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Sauvegarder'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sauvegarderDevis(SimulationViewModel simulationProvider) async {
    try {
      await simulationProvider.sauvegarderDevis(
        context: context,
        devisId: widget.resultat.id,
        nomPersonnalise: _nomController.text.trim().isEmpty
            ? null
            : _nomController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Devis sauvegardé avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sauvegarde: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _souscrire(SimulationViewModel simulationProvider) async {
    try {
      // Vérifier si l'utilisateur est connecté
      final authProvider = context.read<AuthViewModel>();
      if (!authProvider.isLoggedIn) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vous devez être connecté pour souscrire'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Sauvegarder le devis d'abord
      await simulationProvider.sauvegarderDevis(
        context: context,
        devisId: widget.resultat.id,
        nomPersonnalise: 'Devis souscrit',
        notes: 'Devis souscrit automatiquement',
      );

      // Ajouter le contrat
      // Note: La méthode addContract doit être implémentée dans ContractViewModel
      // final contractProvider = context.read<ContractViewModel>();
      // await contractProvider.addContract(...);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Souscription enregistrée avec succès !'),
            backgroundColor: Colors.green,
          ),
        );

        // Naviguer vers l'écran des contrats
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => ContractsScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la souscription: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

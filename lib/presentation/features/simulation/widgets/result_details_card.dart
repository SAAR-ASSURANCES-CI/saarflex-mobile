import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarciflex_app/core/constants/colors.dart';
import 'package:saarciflex_app/core/utils/format_helper.dart';
import 'package:saarciflex_app/data/models/simulation_model.dart';
import 'package:saarciflex_app/data/models/critere_tarification_model.dart';
import 'package:saarciflex_app/data/models/product_model.dart';
import 'package:saarciflex_app/data/services/product_service.dart';

class ResultDetailsCard extends StatefulWidget {
  final SimulationResponse resultat;
  final Product produit;
  final double screenWidth;
  final double textScaleFactor;

  const ResultDetailsCard({
    super.key,
    required this.resultat,
    required this.produit,
    required this.screenWidth,
    required this.textScaleFactor,
  });

  @override
  State<ResultDetailsCard> createState() => _ResultDetailsCardState();
}

class _ResultDetailsCardState extends State<ResultDetailsCard> {
  List<CritereTarification>? _criteresProduit;
  bool _isLoadingCriteres = false;

  @override
  void initState() {
    super.initState();
    _loadCriteresProduit();
  }

  Future<void> _loadCriteresProduit() async {
    setState(() {
      _isLoadingCriteres = true;
    });

    try {
      final productService = ProductService();
      final criteres = await productService.getProductCriteres(widget.produit.id);
      if (mounted) {
        setState(() {
          _criteresProduit = criteres;
          _isLoadingCriteres = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCriteres = false;
        });
      }
    }
  }

  String _buildDynamicCalculationText() {
    // Si on a les critères du produit, construire dynamiquement
    if (_criteresProduit != null && _criteresProduit!.isNotEmpty) {
      final criteresUtilisateur = widget.resultat.criteresUtilisateur;
      final periodiciteFormatee = widget.resultat.periodicitePrimeFormatee;
      final prime = widget.resultat.primeCalculee;

      // Trier les critères par ordre
      final criteresTries = List<CritereTarification>.from(_criteresProduit!);
      criteresTries.sort((a, b) => a.ordre.compareTo(b.ordre));

      final buffer = StringBuffer();
      buffer.writeln('Prime calculée sur la base des critères fournis:');

      for (final critere in criteresTries) {
        final valeur = criteresUtilisateur[critere.nom];
        if (valeur != null) {
          String valeurFormatee = _formatCritereValue(critere, valeur);
          buffer.writeln('• ${critere.nom}: $valeurFormatee');
        }
      }

      // Ajouter la prime à la fin
      buffer.write('• Prime $periodiciteFormatee: ${prime.toStringAsFixed(0)} FCFA');

      return buffer.toString();
    }

    // Sinon, utiliser l'explication par défaut si disponible
    if (widget.resultat.detailsCalcul?.explication != null) {
      return FormatHelper.formatTexteCalcul(widget.resultat.detailsCalcul!.explication);
    }

    return 'Détails de calcul non disponibles';
  }

  String _formatCritereValue(CritereTarification critere, dynamic valeur) {
    if (valeur == null) return 'N/A';

    String valeurStr = valeur.toString();

    // Formater selon le type de critère
    if (critere.type == TypeCritere.numerique) {
      // Si c'est un nombre, formater avec séparateurs de milliers si nécessaire
      final num? numericValue = num.tryParse(valeurStr);
      if (numericValue != null) {
        // Vérifier si le critère nécessite un formatage monétaire
        final nomLower = critere.nom.toLowerCase();
        if (nomLower.contains('capital') || 
            nomLower.contains('montant') || 
            nomLower.contains('prime') ||
            nomLower.contains('franchise') ||
            nomLower.contains('plafond')) {
          valeurStr = FormatHelper.formatMontant(numericValue.toDouble());
        } else {
          // Pour les autres valeurs numériques, formater avec séparateurs
          valeurStr = numericValue.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]} ',
          );
        }
      }
    }

    // Ajouter l'unité si disponible
    if (critere.unite != null && critere.unite!.isNotEmpty) {
      valeurStr += ' ${critere.unite}';
    }

    return valeurStr;
  }

  @override
  Widget build(BuildContext context) {
    final padding = widget.screenWidth < 360 ? 16.0 : 20.0;
    final iconSize = widget.screenWidth < 360 ? 18.0 : 20.0;
    final titleFontSize = (16.0 / widget.textScaleFactor).clamp(14.0, 18.0);
    final textFontSize = (14.0 / widget.textScaleFactor).clamp(12.0, 16.0);
    final expirationFontSize = (12.0 / widget.textScaleFactor).clamp(10.0, 14.0);
    final spacing1 = widget.screenWidth < 360 ? 6.0 : 8.0;
    final spacing2 = widget.screenWidth < 360 ? 12.0 : 16.0;
    final expirationPadding = widget.screenWidth < 360 ? 10.0 : 12.0;
    final expirationIconSize = widget.screenWidth < 360 ? 14.0 : 16.0;
    final expirationSpacing = widget.screenWidth < 360 ? 6.0 : 8.0;
    
    return Container(
      padding: EdgeInsets.all(padding),
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
                size: iconSize,
              ),
              SizedBox(width: spacing1),
              Expanded(
                child: Text(
                  'Détails du calcul',
                  style: GoogleFonts.poppins(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing2),
          if (_isLoadingCriteres)
            Text(
              'Chargement des détails...',
              style: GoogleFonts.poppins(
                fontSize: textFontSize,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            )
          else
            Text(
              _buildDynamicCalculationText(),
              style: GoogleFonts.poppins(
                fontSize: textFontSize,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          if (widget.resultat.expiresAt != null) ...[
            SizedBox(height: spacing2),
            Container(
              padding: EdgeInsets.all(expirationPadding),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    color: Colors.orange[700],
                    size: expirationIconSize,
                  ),
                  SizedBox(width: expirationSpacing),
                  Expanded(
                    child: Text(
                      'Ce devis expire le ${widget.resultat.expiresAt!.formatDate()}',
                      style: GoogleFonts.poppins(
                        fontSize: expirationFontSize,
                        fontWeight: FontWeight.w500,
                        color: Colors.orange[700],
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
      ),
    );
  }
}

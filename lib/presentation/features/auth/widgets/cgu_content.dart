import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarciflex_app/core/constants/colors.dart';

class CGUContent extends StatelessWidget {
  const CGUContent({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    
    final mainTitleFontSize = (22.0 / textScaleFactor).clamp(20.0, 24.0);
    final subtitleFontSize = (16.0 / textScaleFactor).clamp(14.0, 18.0);
    final sectionTitleFontSize = (18.0 / textScaleFactor).clamp(16.0, 20.0);
    final bodyFontSize = (14.0 / textScaleFactor).clamp(12.0, 16.0);
    final horizontalPadding = screenWidth < 360 ? 16.0 : 20.0;
    final verticalSpacing = screenWidth < 360 ? 16.0 : 20.0;
    final sectionSpacing = screenWidth < 360 ? 24.0 : 32.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: verticalSpacing),
          // Titre principal
          Text(  
            'CONDITIONS GÉNÉRALES D\'UTILISATION DE SAARCI FLEX',
            style: GoogleFonts.poppins(
              fontSize: mainTitleFontSize,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'CHARTE DE CONFIDENTIALITÉ ET DE PROTECTION DES DONNÉES À CARACTÈRE PERSONNEL',
            style: GoogleFonts.poppins(
              fontSize: subtitleFontSize,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: sectionSpacing),
          // Préambule
          _buildSection(
            context,
            'Préambule',
            'La présente Charte encadre l\'ensemble des traitements de données à caractère personnel réalisés par SAAR ASSURANCES CÔTE D\'IVOIRE, dans le cadre de ses activités et de l\'utilisation de ses espaces et services digitaux, en qualité de Responsable de traitement.',
            sectionTitleFontSize,
            bodyFontSize,
          ),
          SizedBox(height: sectionSpacing),
          // Section 1
          _buildSection(
            context,
            '1. Collecte et traitement des données personnelles',
            'Dans le cadre de l\'utilisation de l\'application SAAR CI FLEX, SAAR Assurances Côte d\'Ivoire, en sa qualité de Responsable de traitement, est amenée à collecter, enregistrer, organiser, conserver, consulter, utiliser et, le cas échéant, communiquer des données à caractère personnel concernant les Utilisateurs.\n\nCes traitements sont effectués dans le strict respect :\n• de la loi n°2013-450 du 19 juin 2013 relative à la protection des données à caractère personnel en République de Côte d\'Ivoire ;\n• des exigences de l\'Autorité de Régulation des Télécommunications/TIC de Côte d\'Ivoire (ARTCI) ;\n• des dispositions du Code des Assurances des États membres de la CIMA et des textes réglementaires applicables au secteur des assurances ;\n• ainsi que de toute autre réglementation nationale ou communautaire en vigueur.\n\nLa présente charte de confidentialité a pour objet d\'informer l\'Utilisateur, de manière claire et transparente, des modalités de collecte, d\'utilisation, de conservation, de sécurisation et de protection de ses données personnelles. Elle est accessible à tout moment depuis l\'Application.',
            sectionTitleFontSize,
            bodyFontSize,
          ),
          SizedBox(height: sectionSpacing),
          // Section 2
          _buildSectionWithList(
            context,
            '2. Catégories de données collectées',
            'Selon la nature des services utilisés, des produits souscrits et des relations établies avec SAAR CI, les catégories de données susceptibles d\'être collectées incluent notamment, sans que cette liste soit exhaustive :',
            [
              'Données d\'identification et de contact (nom, prénoms, sexe, date et lieu de naissance, nationalité, adresse, e-mail, téléphone, pièce d\'identité, photographie)',
              'Données relatives à la situation familiale et patrimoniale (situation matrimoniale, composition du foyer, personnes à charge, bénéficiaires, informations patrimoniales, revenus)',
              'Données relatives à la situation professionnelle et au mode de vie (profession, employeur, secteur d\'activité, statut professionnel, habitudes de vie pertinentes)',
              'Données contractuelles et de souscription (informations relatives aux contrats, déclarations de risque, éléments de tarification, garanties, options, bénéficiaires)',
              'Données relatives aux sinistres et prestations (nature du sinistre, circonstances, dommages, montants, expertises, indemnisations)',
              'Données de santé (le cas échéant) (informations médicales strictement nécessaires, traitées conformément à la réglementation)',
              'Données relatives aux échanges et interactions (courriels, messages, appels, échanges via l\'Application, réclamations)',
              'Données financières et bancaires (données de paiement, cartes, Wave, Mobile Money, références bancaires, transactions liées aux primes et cotisations)',
            ],
            sectionTitleFontSize,
            bodyFontSize,
          ),
          SizedBox(height: sectionSpacing),
          // Section 3
          _buildSection(
            context,
            '3. Finalités et fondements juridiques du traitement',
            'Les données personnelles sont traitées par SAAR CI pour des finalités déterminées, explicites, légitimes et conformes à la réglementation, sur la base de fondements juridiques clairement identifiés.',
            sectionTitleFontSize,
            bodyFontSize,
          ),
          SizedBox(height: sectionSpacing),
          // Section 4
          _buildSection(
            context,
            '4. Exécution des obligations légales et réglementaires',
            'SAAR CI est tenue de traiter certaines données afin de respecter ses obligations légales, réglementaires et professionnelles, notamment en matière de :\n• identification et connaissance de la clientèle (KYC) ;\n• lutte contre le blanchiment de capitaux le financement du terrorisme et la prolifération des armes de destruction massive (LBC/FT/FP) ;\n• déclarations obligatoires auprès des autorités de tutelle et organismes compétents ;\n• réponses aux réquisitions judiciaires, administratives ou fiscales légalement formées ;\n\nCes traitements sont réalisés sur le fondement des textes légaux et réglementaires qui s\'imposent à SAAR CI.',
            sectionTitleFontSize,
            bodyFontSize,
          ),
          SizedBox(height: sectionSpacing),
          // Section 5
          _buildSection(
            context,
            '5. Exécution des contrats et mesures précontractuelles',
            'Les données sont traitées sur le fondement de l\'exécution du contrat ou de mesures précontractuelles prises à la demande de l\'Utilisateur, notamment pour :\n• la création, l\'authentification et la gestion des comptes utilisateurs sur l\'Application ;\n• L\'analyse, la souscription, la modification et la résiliation des contrats d\'assurance;\n• l\'établissement de devis, simulations et propositions commerciales ;\n• la gestion des paiements, encaissements, échéanciers ;\n• l\'analyse, l\'acceptation, le contrôle et la surveillance du risque ;\n• la gestion des prestations, indemnisations et recours ;',
            sectionTitleFontSize,
            bodyFontSize,
          ),
          SizedBox(height: sectionSpacing),
          // Section 6
          _buildSectionWithList(
            context,
            '6. Droits de l\'Utilisateur',
            'Conformément à la loi n°2013-450 du 19 juin 2013, l\'Utilisateur dispose des droits suivants :',
            [
              'Droit d\'accès : obtenir la confirmation que des données le concernant sont ou ne sont pas traitées et, le cas échéant, en recevoir communication dans un format compréhensible.',
              'Droit de rectification : demander la correction, la mise à jour ou la complétion des données inexactes, incomplètes ou obsolètes.',
              'Droit d\'opposition : s\'opposer, pour des motifs légitimes tenant à sa situation particulière, au traitement de ses données, notamment à des fins de prospection commerciale.',
              'Droit à la portabilité : recevoir les données qu\'il a fournies dans un format structuré, couramment utilisé et lisible par machine, ou demander leur transmission à un autre responsable de traitement.',
            ],
            sectionTitleFontSize,
            bodyFontSize,
            additionalText: '\nL\'Utilisateur peut exercer ses droits en adressant une demande écrite à SAAR Assurances Côte d\'Ivoire, via les coordonnées indiquées dans l\'Application ou par tout autre canal officiel de la compagnie, accompagnée d\'un justificatif d\'identité.\n\nUne réponse est apportée dans un délai maximal de trente (30) jours à compter de la réception de la demande complète.',
          ),
          SizedBox(height: sectionSpacing),
          // Section 7
          _buildSection(
            context,
            '7. Sécurité et confidentialité des données',
            'SAAR Assurances Côte d\'Ivoire met en œuvre l\'ensemble des mesures techniques, organisationnelles, physiques et logiques appropriées afin d\'assurer la sécurité, l\'intégrité, la disponibilité et la confidentialité des données personnelles traitées via l\'Application SAAR CI FLEX.\n\nL\'ensemble du personnel, partenaires, prestataires et sous-traitants intervenant dans le traitement des données est soumis à une obligation stricte de confidentialité et est tenu au respect des règles internes de sécurité de l\'information.',
            sectionTitleFontSize,
            bodyFontSize,
          ),
          SizedBox(height: sectionSpacing),
          // Section 8
          _buildSection(
            context,
            '8. Durée de conservation des données',
            'Les données personnelles sont conservées par SAAR CI pendant au moins dix ans (10) ans.',
            sectionTitleFontSize,
            bodyFontSize,
          ),
          SizedBox(height: sectionSpacing),
          // Section 9
          _buildSection(
            context,
            '9. Exactitude des données',
            'L\'Utilisateur s\'engage à fournir des informations sincères et exactes et à signaler toute modification de sa situation personnelle, familiale, professionnelle ou financière.\n\nSAAR CI ne saurait être tenue responsable des conséquences résultant de la communication d\'informations inexactes, incomplètes ou obsolètes par l\'Utilisateur.',
            sectionTitleFontSize,
            bodyFontSize,
          ),
          SizedBox(height: sectionSpacing),
          // Section 10
          _buildSection(
            context,
            '10. Modification des conditions générales',
            'SAAR Assurances Côte d\'Ivoire se réserve le droit de modifier, à tout moment, tout ou partie des présentes Conditions Générales afin de les adapter notamment à l\'évolution de la réglementation, des services proposés ou des fonctionnalités de l\'Application.\n\nToute modification fera l\'objet d\'une information portée à la connaissance de l\'Utilisateur par tout moyen approprié (notification dans l\'Application, message, etc.).\n\nLa poursuite de l\'utilisation de l\'Application après l\'entrée en vigueur des modifications vaut acceptation pleine et entière des nouvelles Conditions par l\'Utilisateur.',
            sectionTitleFontSize,
            bodyFontSize,
          ),
          SizedBox(height: sectionSpacing),
          // Section 11
          _buildSection(
            context,
            '11. Résiliation',
            'L\'Utilisateur peut, à tout moment, demander la suppression ou la désactivation de son compte via les fonctionnalités prévues à cet effet dans l\'Application ou en contactant les services de SAAR Assurances Côte d\'Ivoire.\n\nSAAR Assurances Côte d\'Ivoire se réserve le droit de suspendre ou de résilier, de plein droit et sans préavis, tout compte Utilisateur en cas de :\n• non-respect des présentes Conditions Générales ;\n• utilisation frauduleuse ou abusive de l\'Application ;\n• atteinte aux droits, à la sécurité ou aux intérêts de SAAR Assurances Côte d\'Ivoire ou de tiers.\n\nLa résiliation du compte entraîne la perte de l\'accès aux services de l\'Application, sans préjudice des obligations légales ou contractuelles en cours.',
            sectionTitleFontSize,
            bodyFontSize,
          ),
          SizedBox(height: sectionSpacing),
          // Section 12
          _buildSection(
            context,
            '12. Droit applicable et juridiction compétente',
            'Les présentes Conditions Générales sont régies et interprétées conformément au droit ivoirien.\n\nTout litige relatif à leur validité, leur interprétation, leur exécution ou leur résiliation sera soumis à la compétence des juridictions ivoiriennes territorialement compétentes, conformément aux règles en vigueur.\n\nPour toute information, question ou réclamation, l\'Utilisateur peut contacter SAAR Assurances Côte d\'Ivoire via à l\'adresse suivante : saarci@saar-assurances.com',
            sectionTitleFontSize,
            bodyFontSize,
          ),
          SizedBox(height: verticalSpacing * 2),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    String content,
    double titleSize,
    double bodySize,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: titleSize,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: GoogleFonts.poppins(
            fontSize: bodySize,
            color: AppColors.textPrimary,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionWithList(
    BuildContext context,
    String title,
    String introText,
    List<String> items,
    double titleSize,
    double bodySize, {
    String? additionalText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: titleSize,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        if (introText.isNotEmpty) ...[
          Text(
            introText,
            style: GoogleFonts.poppins(
              fontSize: bodySize,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
        ],
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: GoogleFonts.poppins(
                      fontSize: bodySize,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: GoogleFonts.poppins(
                        fontSize: bodySize,
                        color: AppColors.textPrimary,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            )),
        if (additionalText != null && additionalText.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            additionalText,
            style: GoogleFonts.poppins(
              fontSize: bodySize,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
        ],
      ],
    );
  }
}

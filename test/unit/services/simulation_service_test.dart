import 'package:flutter_test/flutter_test.dart';
import 'package:saarciflex_app/data/services/simulation_service.dart';
import 'package:saarciflex_app/data/models/critere_tarification_model.dart';

void main() {
  group('SimulationService', () {
    group('calculerAge', () {
      test('calcule correctement l\'âge pour une date de naissance', () {
        final service = SimulationService();
        final birthDate = DateTime(1990, 1, 1);
        final age = service.calculerAge(birthDate);
        final expectedAge = DateTime.now().year - 1990;
        expect(age, expectedAge);
      });

      test('calcule correctement l\'âge pour une personne née cette année', () {
        final service = SimulationService();
        final birthDate = DateTime(DateTime.now().year, 1, 1);
        final age = service.calculerAge(birthDate);
        expect(age, greaterThanOrEqualTo(0));
        expect(age, lessThanOrEqualTo(1));
      });

      test('calcule correctement l\'âge pour une personne née il y a 25 ans', () {
        final service = SimulationService();
        final birthDate = DateTime(DateTime.now().year - 25, 6, 15);
        final age = service.calculerAge(birthDate);
        // L'âge peut être 24 ou 25 selon le mois actuel
        expect(age, greaterThanOrEqualTo(24));
        expect(age, lessThanOrEqualTo(25));
      });
    });

    group('calculerDureeAuto', () {
      test('retourne 10 pour âge entre 18 et 68', () {
        final service = SimulationService();
        expect(service.calculerDureeAuto(25), 10);
        expect(service.calculerDureeAuto(50), 10);
        expect(service.calculerDureeAuto(68), 10);
      });

      test('retourne 5 pour âge entre 69 et 71', () {
        final service = SimulationService();
        expect(service.calculerDureeAuto(69), 5);
        expect(service.calculerDureeAuto(70), 5);
        expect(service.calculerDureeAuto(71), 5);
      });

      test('retourne 2 pour âge entre 72 et 75', () {
        final service = SimulationService();
        expect(service.calculerDureeAuto(72), 2);
        expect(service.calculerDureeAuto(75), 2);
      });

      test('retourne null pour âge < 18', () {
        final service = SimulationService();
        expect(service.calculerDureeAuto(17), null);
        expect(service.calculerDureeAuto(10), null);
      });

      test('retourne null pour âge > 75', () {
        final service = SimulationService();
        expect(service.calculerDureeAuto(76), null);
        expect(service.calculerDureeAuto(80), null);
      });
    });

    group('validateCritere', () {
      test('retourne null pour critère obligatoire avec valeur valide', () {
        final service = SimulationService();
        final critere = CritereTarification(
          id: '1',
          produitId: 'prod1',
          nom: 'capital',
          type: TypeCritere.numerique,
          ordre: 1,
          obligatoire: true,
          valeurs: [],
        );
        expect(service.validateCritere(critere, 1000000), null);
      });

      test('retourne erreur pour critère obligatoire sans valeur', () {
        final service = SimulationService();
        final critere = CritereTarification(
          id: '1',
          produitId: 'prod1',
          nom: 'capital',
          type: TypeCritere.numerique,
          ordre: 1,
          obligatoire: true,
          valeurs: [],
        );
        final error = service.validateCritere(critere, null);
        expect(error, isNotNull);
        expect(error, contains('obligatoire'));
      });

      test('valide critère numérique avec plage de valeurs', () {
        final service = SimulationService();
        final critere = CritereTarification(
          id: '1',
          produitId: 'prod1',
          nom: 'capital',
          type: TypeCritere.numerique,
          ordre: 1,
          obligatoire: true,
          valeurs: [
            ValeurCritere(
              id: '1',
              valeur: '1000000-5000000',
              valeurMin: 1000000,
              valeurMax: 5000000,
              ordre: 1,
            ),
          ],
        );
        expect(service.validateCritere(critere, 2000000), null);
        final error = service.validateCritere(critere, 500000);
        expect(error, isNotNull);
        expect(error, contains('minimum'));
      });

      test('valide critère catégoriel avec valeurs autorisées', () {
        final service = SimulationService();
        final critere = CritereTarification(
          id: '1',
          produitId: 'prod1',
          nom: 'type',
          type: TypeCritere.categoriel,
          ordre: 1,
          obligatoire: true,
          valeurs: [
            ValeurCritere(id: '1', valeur: 'option1', ordre: 1),
            ValeurCritere(id: '2', valeur: 'option2', ordre: 2),
          ],
        );
        expect(service.validateCritere(critere, 'option1'), null);
        final error = service.validateCritere(critere, 'invalid');
        expect(error, isNotNull);
        expect(error, contains('autorisée'));
      });
    });

    group('nettoyerCriteres', () {
      test('nettoie les critères numériques avec séparateurs', () {
        final service = SimulationService();
        final criteres = {
          'capital': '1 000 000',
          'duree': 12,
        };
        final criteresProduit = [
          CritereTarification(
            id: '1',
            produitId: 'prod1',
            nom: 'capital',
            type: TypeCritere.numerique,
            ordre: 1,
            obligatoire: true,
            valeurs: [],
          ),
        ];
        final nettoyes = service.nettoyerCriteres(criteres, criteresProduit);
        expect(nettoyes['capital'], isA<num>());
      });

      test('préserve les valeurs non numériques', () {
        final service = SimulationService();
        final criteres = {
          'nom': 'Test',
          'duree': 12,
        };
        final criteresProduit = [
          CritereTarification(
            id: '1',
            produitId: 'prod1',
            nom: 'nom',
            type: TypeCritere.texte,
            ordre: 1,
            obligatoire: true,
            valeurs: [],
          ),
        ];
        final nettoyes = service.nettoyerCriteres(criteres, criteresProduit);
        expect(nettoyes['nom'], 'Test');
      });
    });

    group('isSaarNansou', () {
      test('retourne true pour ID Saar Nansou', () {
        final service = SimulationService();
        const saarNansouId = '5a024ee8-6e8c-4cce-88a4-00b998248604';
        expect(service.isSaarNansou(saarNansouId), true);
      });

      test('retourne false pour autre ID', () {
        final service = SimulationService();
        expect(service.isSaarNansou('other-id'), false);
        expect(service.isSaarNansou(null), false);
      });
    });
  });
}

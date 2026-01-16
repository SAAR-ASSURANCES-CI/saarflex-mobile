import 'package:flutter_test/flutter_test.dart';
import 'package:saarciflex_app/core/utils/simulation_validators.dart';

void main() {
  group('SimulationValidators', () {
    group('validateAssureInfo', () {
      test('retourne valide pour informations complètes valides', () {
        final informations = {
          'nom_complet': 'John Doe',
          'date_naissance': '1990-01-01',
          'telephone': '0123456789',
          'email': 'test@test.com',
        };
        final result = SimulationValidators.validateAssureInfo(informations);
        expect(result.isValid, true);
        expect(result.errors, isEmpty);
      });

      test('retourne erreur si nom_complet manquant', () {
        final informations = {
          'date_naissance': '1990-01-01',
        };
        final result = SimulationValidators.validateAssureInfo(informations);
        expect(result.isValid, false);
        expect(result.errors['nom_complet'], 'Le nom complet est obligatoire');
      });

      test('retourne erreur si nom_complet trop court', () {
        final informations = {
          'nom_complet': 'A',
        };
        final result = SimulationValidators.validateAssureInfo(informations);
        expect(result.isValid, false);
        expect(result.errors['nom_complet'], 'Le nom doit contenir au moins 2 caractères');
      });

      test('retourne erreur si date_naissance invalide', () {
        final informations = {
          'nom_complet': 'John Doe',
          'date_naissance': 'invalid-date',
        };
        final result = SimulationValidators.validateAssureInfo(informations);
        expect(result.isValid, false);
        expect(result.errors['date_naissance'], 'Format de date invalide');
      });

      test('retourne erreur si âge < 18', () {
        final dateNaissance = DateTime.now().subtract(const Duration(days: 365 * 17));
        final informations = {
          'nom_complet': 'John Doe',
          'date_naissance': dateNaissance.toIso8601String(),
        };
        final result = SimulationValidators.validateAssureInfo(informations);
        expect(result.isValid, false);
        expect(result.errors['date_naissance'], 'L\'âge minimum est de 18 ans');
      });

      test('retourne erreur si âge > 100', () {
        final dateNaissance = DateTime.now().subtract(const Duration(days: 365 * 101));
        final informations = {
          'nom_complet': 'John Doe',
          'date_naissance': dateNaissance.toIso8601String(),
        };
        final result = SimulationValidators.validateAssureInfo(informations);
        expect(result.isValid, false);
        expect(result.errors['date_naissance'], 'L\'âge maximum est de 100 ans');
      });

      test('retourne erreur si téléphone invalide', () {
        final informations = {
          'nom_complet': 'John Doe',
          'telephone': '123', // Trop court
        };
        final result = SimulationValidators.validateAssureInfo(informations);
        expect(result.isValid, false);
        expect(result.errors['telephone'], 'Format de téléphone invalide');
      });

      test('retourne erreur si email invalide', () {
        final informations = {
          'nom_complet': 'John Doe',
          'email': 'invalid-email',
        };
        final result = SimulationValidators.validateAssureInfo(informations);
        expect(result.isValid, false);
        expect(result.errors['email'], 'Format d\'email invalide');
      });

      test('accepte informations partielles valides', () {
        final informations = {
          'nom_complet': 'John Doe',
        };
        final result = SimulationValidators.validateAssureInfo(informations);
        expect(result.isValid, true);
        expect(result.errors, isEmpty);
      });
    });

    group('validateCriteres', () {
      test('retourne valide si tous les critères obligatoires présents', () {
        final criteres = {
          'capital': 1000000,
          'duree': 12,
        };
        final criteresObligatoires = ['capital', 'duree'];
        final result = SimulationValidators.validateCriteres(
          criteres,
          criteresObligatoires,
        );
        expect(result.isValid, true);
        expect(result.errors, isEmpty);
      });

      test('retourne erreur si critère obligatoire manquant', () {
        final criteres = {
          'capital': 1000000,
        };
        final criteresObligatoires = ['capital', 'duree'];
        final result = SimulationValidators.validateCriteres(
          criteres,
          criteresObligatoires,
        );
        expect(result.isValid, false);
        expect(result.errors['duree'], 'Ce critère est obligatoire');
      });

      test('retourne erreur si critère obligatoire vide', () {
        final criteres = {
          'capital': '',
          'duree': 12,
        };
        final criteresObligatoires = ['capital', 'duree'];
        final result = SimulationValidators.validateCriteres(
          criteres,
          criteresObligatoires,
        );
        expect(result.isValid, false);
        expect(result.errors['capital'], 'Ce critère est obligatoire');
      });

      test('retourne valide si aucun critère obligatoire', () {
        final criteres = {
          'capital': 1000000,
        };
        final criteresObligatoires = <String>[];
        final result = SimulationValidators.validateCriteres(
          criteres,
          criteresObligatoires,
        );
        expect(result.isValid, true);
        expect(result.errors, isEmpty);
      });
    });

    group('validateSaveInfo', () {
      test('retourne valide pour devisId valide', () {
        final result = SimulationValidators.validateSaveInfo(
          devisId: 'test-devis-id',
        );
        expect(result.isValid, true);
        expect(result.errors, isEmpty);
      });

      test('retourne erreur si devisId vide', () {
        final result = SimulationValidators.validateSaveInfo(
          devisId: '',
        );
        expect(result.isValid, false);
        expect(result.errors['devis_id'], 'L\'ID du devis est obligatoire');
      });

      test('retourne erreur si nomPersonnalise trop court', () {
        final result = SimulationValidators.validateSaveInfo(
          devisId: 'test-devis-id',
          nomPersonnalise: 'A',
        );
        expect(result.isValid, false);
        expect(result.errors['nom_personnalise'], 'Le nom doit contenir au moins 2 caractères');
      });

      test('retourne erreur si nomPersonnalise trop long', () {
        final nomLong = 'A' * 101;
        final result = SimulationValidators.validateSaveInfo(
          devisId: 'test-devis-id',
          nomPersonnalise: nomLong,
        );
        expect(result.isValid, false);
        expect(result.errors['nom_personnalise'], 'Le nom ne peut pas dépasser 100 caractères');
      });

      test('retourne erreur si notes trop longues', () {
        final notesLongues = 'A' * 501;
        final result = SimulationValidators.validateSaveInfo(
          devisId: 'test-devis-id',
          notes: notesLongues,
        );
        expect(result.isValid, false);
        expect(result.errors['notes'], 'Les notes ne peuvent pas dépasser 500 caractères');
      });

      test('retourne valide avec nomPersonnalise et notes valides', () {
        final result = SimulationValidators.validateSaveInfo(
          devisId: 'test-devis-id',
          nomPersonnalise: 'Mon Devis',
          notes: 'Notes de test',
        );
        expect(result.isValid, true);
        expect(result.errors, isEmpty);
      });
    });
  });
}

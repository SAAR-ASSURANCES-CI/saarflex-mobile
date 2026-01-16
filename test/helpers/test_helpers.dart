import 'package:saarciflex_app/data/models/user_model.dart';
import 'package:saarciflex_app/data/models/simulation_model.dart';
import 'package:saarciflex_app/data/services/api_service.dart';

/// Helpers pour les tests unitaires
class TestHelpers {
  /// Crée un utilisateur de test
  static User createTestUser({
    String? id,
    String? nom,
    String? email,
    String? telephone,
    TypeUtilisateur? typeUtilisateur,
    bool? statut,
  }) {
    return User(
      id: id ?? 'test-user-id',
      nom: nom ?? 'Test User',
      email: email ?? 'test@test.com',
      telephone: telephone ?? '+2250123456789',
      typeUtilisateur: typeUtilisateur ?? TypeUtilisateur.client,
      statut: statut ?? true,
      dateCreation: DateTime.now(),
    );
  }

  /// Crée une réponse d'authentification de test
  static AuthResponse createTestAuthResponse({
    String? token,
    User? user,
  }) {
    return AuthResponse(
      token: token ?? 'test-token-123',
      user: user ?? createTestUser(),
    );
  }

  /// Crée une SimulationResponse de test
  static SimulationResponse createTestSimulationResponse({
    String? id,
    String? nomProduit,
    double? primeCalculee,
  }) {
    return SimulationResponse(
      id: id ?? 'test-devis-id',
      nomProduit: nomProduit ?? 'Test Produit',
      typeProduit: 'assurance',
      periodicitePrime: 'mensuel',
      criteresUtilisateur: {'capital': 1000000},
      primeCalculee: primeCalculee ?? 50000.0,
      assureEstSouscripteur: true,
      beneficiaires: [],
      createdAt: DateTime.now(),
    );
  }

  /// Crée une ApiException de test
  static ApiException createTestApiException({
    int? statusCode,
    String? message,
  }) {
    return ApiException(
      message ?? 'Test error message',
      statusCode ?? 400,
    );
  }

  /// Attend qu'une condition soit vraie (pour les tests async)
  static Future<void> waitForCondition(
    bool Function() condition, {
    Duration timeout = const Duration(seconds: 5),
    Duration pollInterval = const Duration(milliseconds: 100),
  }) async {
    final endTime = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(endTime)) {
      if (condition()) {
        return;
      }
      await Future.delayed(pollInterval);
    }
    throw TimeoutException('Condition not met within timeout');
  }
}

/// Exception pour les timeouts de test
class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
  
  @override
  String toString() => message;
}

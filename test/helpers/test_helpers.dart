import 'package:saarciflex_app/data/models/user_model.dart';
import 'package:saarciflex_app/data/models/simulation_model.dart';
import 'package:saarciflex_app/data/services/api_service.dart';

class TestHelpers {
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

  static AuthResponse createTestAuthResponse({
    String? token,
    User? user,
  }) {
    return AuthResponse(
      token: token ?? 'test-token-123',
      user: user ?? createTestUser(),
    );
  }

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

  static ApiException createTestApiException({
    int? statusCode,
    String? message,
  }) {
    return ApiException(
      message ?? 'Test error message',
      statusCode ?? 400,
    );
  }

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

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
  
  @override
  String toString() => message;
}

// Mocks manuels pour les tests
// Note: Les mocks générés automatiquement causent des problèmes avec build_runner
// Ces mocks manuels permettent de continuer les tests

import 'package:mockito/mockito.dart';
import 'package:saarciflex_app/data/repositories/auth_repository.dart';
import 'package:saarciflex_app/data/repositories/simulation_repository.dart';
import 'package:saarciflex_app/data/repositories/product_repository.dart';

// Mocks manuels pour les repositories
class MockAuthRepository extends Mock implements AuthRepository {}
class MockSimulationRepository extends Mock implements SimulationRepository {}
class MockProductRepository extends Mock implements ProductRepository {}

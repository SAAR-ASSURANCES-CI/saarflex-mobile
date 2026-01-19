// Mocks manuels pour les tests
// Note: Les mocks générés automatiquement causent des problèmes avec build_runner
// Ces mocks manuels permettent de continuer les tests

import 'package:mockito/mockito.dart';
import 'package:saarciflex_app/data/repositories/auth_repository.dart';
import 'package:saarciflex_app/data/repositories/simulation_repository.dart';
import 'package:saarciflex_app/data/repositories/product_repository.dart';
import 'package:saarciflex_app/data/repositories/profile_repository.dart';
import 'package:saarciflex_app/data/repositories/contract_repository.dart';
import 'package:saarciflex_app/data/repositories/souscription_repository.dart';
import 'package:saarciflex_app/data/services/auth_service.dart';
import 'package:saarciflex_app/data/services/api_service.dart';
import 'package:saarciflex_app/data/services/file_upload_service.dart';
import 'package:saarciflex_app/data/services/simulation_service.dart';

// Mocks manuels pour les repositories
class MockAuthRepository extends Mock implements AuthRepository {}
class MockSimulationRepository extends Mock implements SimulationRepository {}
class MockProductRepository extends Mock implements ProductRepository {}
class MockProfileRepository extends Mock implements ProfileRepository {}
class MockContractRepository extends Mock implements ContractRepository {}
class MockSouscriptionRepository extends Mock implements SouscriptionRepository {}

// Mocks manuels pour les services
class MockAuthService extends Mock implements AuthService {}
class MockApiService extends Mock implements ApiService {}
class MockFileUploadService extends Mock implements FileUploadService {}
class MockSimulationService extends Mock implements SimulationService {}

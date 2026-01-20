
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
import 'package:saarciflex_app/data/services/contract_service.dart';
import 'package:saarciflex_app/data/services/product_service.dart';
import 'package:saarciflex_app/data/services/user_service.dart';
import 'package:saarciflex_app/data/services/profile_service.dart';
import 'package:saarciflex_app/data/services/souscription_service.dart';
import 'package:saarciflex_app/data/models/user_model.dart';
import 'package:saarciflex_app/data/models/critere_tarification_model.dart';
import 'package:saarciflex_app/data/models/simulation_model.dart';
import 'package:saarciflex_app/data/models/contract_model.dart';
import 'package:saarciflex_app/data/models/saved_quote_model.dart';
import 'package:saarciflex_app/data/models/product_model.dart';
import 'package:saarciflex_app/data/models/souscription_model.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockSimulationRepository extends Mock implements SimulationRepository {}
class MockProductRepository extends Mock implements ProductRepository {}
class MockProfileRepository extends Mock implements ProfileRepository {}
class MockContractRepository extends Mock implements ContractRepository {}
class MockSouscriptionRepository extends Mock implements SouscriptionRepository {}

class MockAuthService extends Mock implements AuthService {
  static final User _dummyUser = User(
    id: 'dummy',
    nom: 'Dummy',
    email: 'dummy@example.com',
    typeUtilisateur: TypeUtilisateur.client,
    statut: true,
  );

  @override
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) {
    return super.noSuchMethod(
      Invocation.method(#login, [], {#email: email, #password: password}),
      returnValue: Future.value(AuthResponse(user: _dummyUser, token: '')),
    ) as Future<AuthResponse>;
  }

  @override
  Future<AuthResponse> signup({
    required String nom,
    required String email,
    required String password,
  }) {
    return super.noSuchMethod(
      Invocation.method(
        #signup,
        [],
        {#nom: nom, #email: email, #password: password},
      ),
      returnValue: Future.value(AuthResponse(user: _dummyUser, token: '')),
    ) as Future<AuthResponse>;
  }

  @override
  Future<void> logout() {
    return super.noSuchMethod(
      Invocation.method(#logout, []),
      returnValue: Future.value(),
    ) as Future<void>;
  }

  @override
  Future<bool> isLoggedIn() {
    return super.noSuchMethod(
      Invocation.method(#isLoggedIn, []),
      returnValue: Future.value(false),
    ) as Future<bool>;
  }

  @override
  Future<void> forgotPassword(String email) {
    return super.noSuchMethod(
      Invocation.method(#forgotPassword, [email]),
      returnValue: Future.value(),
    ) as Future<void>;
  }

  @override
  Future<void> verifyOtp({required String email, required String code}) {
    return super.noSuchMethod(
      Invocation.method(#verifyOtp, [], {#email: email, #code: code}),
      returnValue: Future.value(),
    ) as Future<void>;
  }

  @override
  Future<void> resetPasswordWithCode({
    required String email,
    required String code,
    required String newPassword,
  }) {
    return super.noSuchMethod(
      Invocation.method(
        #resetPasswordWithCode,
        [],
        {#email: email, #code: code, #newPassword: newPassword},
      ),
      returnValue: Future.value(),
    ) as Future<void>;
  }

  @override
  Future<bool> checkTokenValidity() {
    return super.noSuchMethod(
      Invocation.method(#checkTokenValidity, []),
      returnValue: Future.value(false),
    ) as Future<bool>;
  }

  @override
  Future<bool> initializeAuth() {
    return super.noSuchMethod(
      Invocation.method(#initializeAuth, []),
      returnValue: Future.value(false),
    ) as Future<bool>;
  }
}
class MockApiService extends Mock implements ApiService {}
class MockFileUploadService extends Mock implements FileUploadService {}
class MockSimulationService extends Mock implements SimulationService {
  @override
  Future<List<CritereTarification>> getCriteresProduit(
    String produitId, {
    int page = 1,
    int limit = 100,
  }) {
    return super.noSuchMethod(
      Invocation.method(
        #getCriteresProduit,
        [produitId],
        {#page: page, #limit: limit},
      ),
      returnValue: Future.value(<CritereTarification>[]),
    ) as Future<List<CritereTarification>>;
  }

  @override
  Future<SimulationResponse> simulerDevisSimplifie({
    required String produitId,
    required Map<String, dynamic> criteres,
    required bool assureEstSouscripteur,
    Map<String, dynamic>? informationsAssure,
    Map<String, dynamic>? informationsVehicule,
  }) {
    final dummy = SimulationResponse(
      id: 'dummy',
      nomProduit: 'Dummy',
      typeProduit: 'vie',
      periodicitePrime: 'mensuelle',
      criteresUtilisateur: const {},
      primeCalculee: 0,
      assureEstSouscripteur: true,
      beneficiaires: const [],
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    );
    return super.noSuchMethod(
      Invocation.method(
        #simulerDevisSimplifie,
        [],
        {
          #produitId: produitId,
          #criteres: criteres,
          #assureEstSouscripteur: assureEstSouscripteur,
          #informationsAssure: informationsAssure,
          #informationsVehicule: informationsVehicule,
        },
      ),
      returnValue: Future.value(dummy),
    ) as Future<SimulationResponse>;
  }

  @override
  Future<void> sauvegarderDevis(SauvegardeDevisRequest request) {
    return super.noSuchMethod(
      Invocation.method(#sauvegarderDevis, [request]),
      returnValue: Future.value(),
    ) as Future<void>;
  }

  @override
  Future<String?> getGrilleTarifaireForProduit(String produitId) {
    return super.noSuchMethod(
      Invocation.method(#getGrilleTarifaireForProduit, [produitId]),
      returnValue: Future.value(null),
    ) as Future<String?>;
  }

  @override
  Future<List<SimulationResponse>> getMesDevis({int page = 1, int limit = 10}) {
    return super.noSuchMethod(
      Invocation.method(#getMesDevis, [], {#page: page, #limit: limit}),
      returnValue: Future.value(<SimulationResponse>[]),
    ) as Future<List<SimulationResponse>>;
  }

  @override
  Future<void> supprimerDevis(String devisId) {
    return super.noSuchMethod(
      Invocation.method(#supprimerDevis, [devisId]),
      returnValue: Future.value(),
    ) as Future<void>;
  }

  @override
  bool critereNecessiteFormatage(CritereTarification critere) {
    return super.noSuchMethod(
      Invocation.method(#critereNecessiteFormatage, [critere]),
      returnValue: false,
    ) as bool;
  }

  @override
  Map<String, dynamic> nettoyerCriteres(
    Map<String, dynamic> criteres,
    List<CritereTarification> criteresProduit,
  ) {
    return super.noSuchMethod(
      Invocation.method(#nettoyerCriteres, [criteres, criteresProduit]),
      returnValue: <String, dynamic>{},
    ) as Map<String, dynamic>;
  }

  @override
  String? validateCritere(CritereTarification critere, dynamic valeur) {
    return super.noSuchMethod(
      Invocation.method(#validateCritere, [critere, valeur]),
      returnValue: null,
    ) as String?;
  }

  @override
  Map<String, String> validateAllCriteres(
    Map<String, dynamic> criteresReponses,
    List<CritereTarification> criteresProduit,
  ) {
    return super.noSuchMethod(
      Invocation.method(#validateAllCriteres, [criteresReponses, criteresProduit]),
      returnValue: <String, String>{},
    ) as Map<String, String>;
  }

  @override
  bool isSaarNansou(String? produitId) {
    return super.noSuchMethod(
      Invocation.method(#isSaarNansou, [produitId]),
      returnValue: false,
    ) as bool;
  }

  @override
  Future<int?> calculerDureeAuto(int age, {String? produitId}) {
    return super.noSuchMethod(
      Invocation.method(#calculerDureeAuto, [age], {#produitId: produitId}),
      returnValue: Future.value(null),
    ) as Future<int?>;
  }

  @override
  int calculerAge(DateTime birthDate) {
    return super.noSuchMethod(
      Invocation.method(#calculerAge, [birthDate]),
      returnValue: 0,
    ) as int;
  }
}

class MockContractService extends Mock implements ContractService {
  @override
  Future<List<SavedQuote>> getSavedQuotes({int page = 1, int limit = 20}) {
    return super.noSuchMethod(
      Invocation.method(#getSavedQuotes, [], {#page: page, #limit: limit}),
      returnValue: Future.value(<SavedQuote>[]),
    ) as Future<List<SavedQuote>>;
  }

  @override
  Future<List<Contract>> getContracts({int page = 1, int limit = 20}) {
    return super.noSuchMethod(
      Invocation.method(#getContracts, [], {#page: page, #limit: limit}),
      returnValue: Future.value(<Contract>[]),
    ) as Future<List<Contract>>;
  }

  @override
  Future<void> deleteSavedQuote(String quoteId) {
    return super.noSuchMethod(
      Invocation.method(#deleteSavedQuote, [quoteId]),
      returnValue: Future.value(),
    ) as Future<void>;
  }

  @override
  Future<Contract> subscribeQuote(String quoteId) {
    final dummy = Contract(
      id: 'dummy',
      nomProduit: 'Dummy',
      typeProduit: 'vie',
      primeCalculee: 0,
      franchiseCalculee: 0,
      statut: 'actif',
      dateSouscription: DateTime.fromMillisecondsSinceEpoch(0),
      numeroContrat: 'DUMMY',
      nombreBeneficiaires: 0,
      nombreDocuments: 0,
    );
    return super.noSuchMethod(
      Invocation.method(#subscribeQuote, [quoteId]),
      returnValue: Future.value(dummy),
    ) as Future<Contract>;
  }

  @override
  Future<SavedQuote> updateSavedQuote({
    required String quoteId,
    String? nomPersonnalise,
    String? notes,
  }) {
    final dummy = SavedQuote(
      id: quoteId,
      nomProduit: 'Dummy',
      typeProduit: 'vie',
      primeCalculee: 0,
      franchiseCalculee: 0,
      statut: 'sauvegarde',
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      nombreBeneficiaires: 0,
      nombreDocuments: 0,
      nomPersonnalise: nomPersonnalise,
      notes: notes,
    );
    return super.noSuchMethod(
      Invocation.method(
        #updateSavedQuote,
        [],
        {#quoteId: quoteId, #nomPersonnalise: nomPersonnalise, #notes: notes},
      ),
      returnValue: Future.value(dummy),
    ) as Future<SavedQuote>;
  }

  @override
  Future<SavedQuote> getSavedQuoteDetails(String quoteId) {
    final dummy = SavedQuote(
      id: quoteId,
      nomProduit: 'Dummy',
      typeProduit: 'vie',
      primeCalculee: 0,
      franchiseCalculee: 0,
      statut: 'sauvegarde',
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      nombreBeneficiaires: 0,
      nombreDocuments: 0,
    );
    return super.noSuchMethod(
      Invocation.method(#getSavedQuoteDetails, [quoteId]),
      returnValue: Future.value(dummy),
    ) as Future<SavedQuote>;
  }

  @override
  Future<int> getActiveContractsCount() {
    return super.noSuchMethod(
      Invocation.method(#getActiveContractsCount, []),
      returnValue: Future.value(0),
    ) as Future<int>;
  }
}

class MockProductService extends Mock implements ProductService {
  @override
  Future<List<Product>> getAllProducts() {
    return super.noSuchMethod(
      Invocation.method(#getAllProducts, []),
      returnValue: Future.value(<Product>[]),
    ) as Future<List<Product>>;
  }

  @override
  Future<Product?> getProductById(String id) {
    return super.noSuchMethod(
      Invocation.method(#getProductById, [id]),
      returnValue: Future.value(null),
    ) as Future<Product?>;
  }

  @override
  Future<List<Product>> searchProducts(String query) {
    return super.noSuchMethod(
      Invocation.method(#searchProducts, [query]),
      returnValue: Future.value(<Product>[]),
    ) as Future<List<Product>>;
  }

  @override
  Future<List<Product>> getProductsByType(ProductType type) {
    return super.noSuchMethod(
      Invocation.method(#getProductsByType, [type]),
      returnValue: Future.value(<Product>[]),
    ) as Future<List<Product>>;
  }

  @override
  Future<List<Product>> filterProducts({ProductType? type, String? searchQuery}) {
    return super.noSuchMethod(
      Invocation.method(#filterProducts, [], {#type: type, #searchQuery: searchQuery}),
      returnValue: Future.value(<Product>[]),
    ) as Future<List<Product>>;
  }

  @override
  Future<Map<ProductType, int>> getProductCountByType() {
    return super.noSuchMethod(
      Invocation.method(#getProductCountByType, []),
      returnValue: Future.value(<ProductType, int>{}),
    ) as Future<Map<ProductType, int>>;
  }

  @override
  Future<bool> productExists(String id) {
    return super.noSuchMethod(
      Invocation.method(#productExists, [id]),
      returnValue: Future.value(false),
    ) as Future<bool>;
  }
}

class MockUserService extends Mock implements UserService {
  @override
  Future<User> getUserProfile() {
    return super.noSuchMethod(
      Invocation.method(#getUserProfile, []),
      returnValue: Future.value(MockAuthService._dummyUser),
    ) as Future<User>;
  }

  @override
  Future<User> updateProfile(Map<String, dynamic> updates) {
    return super.noSuchMethod(
      Invocation.method(#updateProfile, [updates]),
      returnValue: Future.value(MockAuthService._dummyUser),
    ) as Future<User>;
  }

  @override
  Future<User> updateUserField(String fieldName, dynamic value) {
    return super.noSuchMethod(
      Invocation.method(#updateUserField, [fieldName, value]),
      returnValue: Future.value(MockAuthService._dummyUser),
    ) as Future<User>;
  }
}

class MockProfileService extends Mock implements ProfileService {
  @override
  Map<String, String> validateProfileData(Map<String, dynamic> data) {
    return super.noSuchMethod(
      Invocation.method(#validateProfileData, [data]),
      returnValue: <String, String>{},
    ) as Map<String, String>;
  }

  @override
  bool isProfileComplete(User user) {
    return super.noSuchMethod(
      Invocation.method(#isProfileComplete, [user]),
      returnValue: false,
    ) as bool;
  }
}

class MockSouscriptionService extends Mock implements SouscriptionService {
  @override
  Future<SouscriptionResponse> souscrire(SouscriptionRequest request) {
    final dummy = SouscriptionResponse(
      id: 'dummy',
      statut: '',
      message: '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    );
    return super.noSuchMethod(
      Invocation.method(#souscrire, [request]),
      returnValue: Future.value(dummy),
    ) as Future<SouscriptionResponse>;
  }

  @override
  Future<List<SouscriptionResponse>> getMesSouscriptions({int page = 1, int limit = 20}) {
    return super.noSuchMethod(
      Invocation.method(#getMesSouscriptions, [], {#page: page, #limit: limit}),
      returnValue: Future.value(<SouscriptionResponse>[]),
    ) as Future<List<SouscriptionResponse>>;
  }

  @override
  Future<SouscriptionResponse> getSouscriptionById(String id) {
    final dummy = SouscriptionResponse(
      id: id,
      statut: '',
      message: '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    );
    return super.noSuchMethod(
      Invocation.method(#getSouscriptionById, [id]),
      returnValue: Future.value(dummy),
    ) as Future<SouscriptionResponse>;
  }

  @override
  Future<void> annulerSouscription(String id) {
    return super.noSuchMethod(
      Invocation.method(#annulerSouscription, [id]),
      returnValue: Future.value(),
    ) as Future<void>;
  }

  @override
  bool validatesouscriptionData(SouscriptionRequest request) {
    return super.noSuchMethod(
      Invocation.method(#validatesouscriptionData, [request]),
      returnValue: false,
    ) as bool;
  }

  @override
  String formatPhoneNumber(String phone) {
    return super.noSuchMethod(
      Invocation.method(#formatPhoneNumber, [phone]),
      returnValue: phone,
    ) as String;
  }
}

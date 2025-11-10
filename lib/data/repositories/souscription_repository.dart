import 'package:saarflex_app/data/models/souscription_model.dart';
import 'package:saarflex_app/data/services/souscription_service.dart';

class SouscriptionRepository {
  final souscriptionService _souscriptionService;

  SouscriptionRepository({souscriptionService? service})
      : _souscriptionService = service ?? souscriptionService();

  Future<SouscriptionResponse> souscrire(SouscriptionRequest request) async {
    try {
      return await _souscriptionService.souscrire(request);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<SouscriptionResponse>> getMesSouscriptions({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      return await _souscriptionService.getMesSouscriptions(
        page: page,
        limit: limit,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<SouscriptionResponse> getSouscriptionById(String id) async {
    try {
      return await _souscriptionService.getSouscriptionById(id);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> annulerSouscription(String id) async {
    try {
      await _souscriptionService.annulerSouscription(id);
    } catch (e) {
      rethrow;
    }
  }

  bool validateSouscriptionData(SouscriptionRequest request) {
    return _souscriptionService.validatesouscriptionData(request);
  }

  String formatPhoneNumber(String phone) {
    return _souscriptionService.formatPhoneNumber(phone);
  }
}


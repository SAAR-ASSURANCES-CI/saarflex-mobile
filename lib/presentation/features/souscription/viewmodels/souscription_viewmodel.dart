import 'package:flutter/material.dart';
import 'package:saarflex_app/data/models/souscription_model.dart';
import 'package:saarflex_app/data/models/beneficiaire_model.dart';
import 'package:saarflex_app/data/repositories/souscription_repository.dart';

class SouscriptionViewModel extends ChangeNotifier {
  final SouscriptionRepository _souscriptionRepository =
      SouscriptionRepository();

  bool _isLoading = false;
  bool _isSubscribing = false;
  String? _devisId;
  MethodePaiement? _selectedMethodePaiement;
  String _numeroTelephone = '';
  final List<Beneficiaire> _beneficiaires = [];

  String? _error;
  final Map<String, String> _fieldErrors = {};

  SouscriptionResponse? _souscriptionResponse;
  bool get isLoading => _isLoading;
  bool get isSubscribing => _isSubscribing;
  String? get error => _error;
  bool get hasError => _error != null;
  Map<String, String> get fieldErrors => Map.unmodifiable(_fieldErrors);
  SouscriptionResponse? get souscriptionResponse => _souscriptionResponse;
  String? get paymentUrl => _souscriptionResponse?.paymentUrl;

  String? get devisId => _devisId;
  MethodePaiement? get selectedMethodePaiement => _selectedMethodePaiement;
  String get numeroTelephone => _numeroTelephone;
  List<Beneficiaire> get beneficiaires => List.unmodifiable(_beneficiaires);

  bool get isFormValid {
    final phoneValid = _selectedMethodePaiement == MethodePaiement.mobileMoney
        ? _numeroTelephone.trim().isNotEmpty && _isValidPhone(_numeroTelephone)
        : true; // Pour wallet, le téléphone n'est pas requis
    
    return _devisId != null &&
        _selectedMethodePaiement != null &&
        phoneValid &&
        _beneficiaires.isNotEmpty &&
        _beneficiaires.every((b) => b.isValid);
  }

  void initializesouscription({
    required String devisId,
    required List<Beneficiaire> beneficiaires,
    String? phoneNumber,
  }) {
    _devisId = devisId;
    _beneficiaires.clear();
    _beneficiaires.addAll(beneficiaires);
    _numeroTelephone = phoneNumber ?? '';
    _clearError();
    notifyListeners();
  }

  void setMethodePaiement(MethodePaiement methode) {
    _selectedMethodePaiement = methode;
    _clearFieldError('methode_paiement');
    notifyListeners();
  }

  void setNumeroTelephone(String phone) {
    _numeroTelephone = phone;
    _clearFieldError('numero_telephone');
    notifyListeners();
  }

  void addBeneficiaire(Beneficiaire beneficiaire) {
    _beneficiaires.add(beneficiaire);
    notifyListeners();
  }

  void removeBeneficiaire(int index) {
    if (index >= 0 && index < _beneficiaires.length) {
      _beneficiaires.removeAt(index);
      notifyListeners();
    }
  }

  void updateBeneficiaire(int index, Beneficiaire beneficiaire) {
    if (index >= 0 && index < _beneficiaires.length) {
      _beneficiaires[index] = beneficiaire;
      notifyListeners();
    }
  }

  void setBeneficiaires(List<Beneficiaire> beneficiaires) {
    _beneficiaires.clear();
    _beneficiaires.addAll(beneficiaires);
    notifyListeners();
  }

  bool validateForm() {
    _fieldErrors.clear();
    bool isValid = true;

    if (_selectedMethodePaiement == null) {
      _fieldErrors['methode_paiement'] =
          'Veuillez sélectionner une méthode de paiement';
      isValid = false;
    }

    // Numéro de téléphone requis seulement pour mobile_money
    if (_selectedMethodePaiement == MethodePaiement.mobileMoney) {
      if (_numeroTelephone.trim().isEmpty) {
        _fieldErrors['numero_telephone'] =
            'Le numéro de téléphone est obligatoire pour Mobile Money';
        isValid = false;
      } else if (!_isValidPhone(_numeroTelephone)) {
        _fieldErrors['numero_telephone'] = 'Numéro de téléphone invalide';
        isValid = false;
      }
    }

    if (_beneficiaires.isEmpty) {
      _fieldErrors['beneficiaires'] = 'Au moins un bénéficiaire est requis';
      isValid = false;
    } else {
      for (int i = 0; i < _beneficiaires.length; i++) {
        final beneficiaire = _beneficiaires[i];
        if (!beneficiaire.isValid) {
          _fieldErrors['beneficiaire_$i'] = 'Bénéficiaire ${i + 1} invalide';
          isValid = false;
        }
      }
    }

    notifyListeners();
    return isValid;
  }

  Future<bool> souscrire() async {
    if (!validateForm()) {
      return false;
    }

    _isSubscribing = true;
    _clearError();
    notifyListeners();

    try {
      final request = SouscriptionRequest(
        devisId: _devisId!,
        methodePaiement: _selectedMethodePaiement!.apiValue,
        numeroTelephone: _selectedMethodePaiement == MethodePaiement.mobileMoney
            ? _souscriptionRepository.formatPhoneNumber(_numeroTelephone)
            : null,
        beneficiaires: _beneficiaires,
      );

      _souscriptionResponse = await _souscriptionRepository.souscrire(request);
      _clearError();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSubscribing = false;
      notifyListeners();
    }
  }

  Future<List<SouscriptionResponse>> getMesSouscriptions() async {
    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      final souscriptions =
          await _souscriptionRepository.getMesSouscriptions();
      _clearError();
      return souscriptions;
    } catch (e) {
      _error = e.toString();
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> annulerSouscription(String id) async {
    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      await _souscriptionRepository.annulerSouscription(id);
      _clearError();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void resetForm() {
    _devisId = null;
    _selectedMethodePaiement = null;
    _numeroTelephone = '';
    _beneficiaires.clear();
    _souscriptionResponse = null;
    _clearError();
    _fieldErrors.clear();
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void _clearFieldError(String field) {
    _fieldErrors.remove(field);
  }

  bool _isValidPhone(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    return cleanPhone.length >= 8 && cleanPhone.length <= 15;
  }

  String? getFieldError(String field) {
    return _fieldErrors[field];
  }

  bool hasFieldError(String field) {
    return _fieldErrors.containsKey(field);
  }
}

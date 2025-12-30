import 'package:intl/intl.dart';

class User {
  final String id;
  final String nom;
  final String email;
  final String? telephone;
  final String? avatarUrl;
  final TypeUtilisateur typeUtilisateur;
  final bool statut;
  final DateTime? derniereConnexion;
  final DateTime? dateCreation;
  final DateTime? updatedAt;

  final String? birthPlace;
  final String? gender;
  final String? nationality;
  final String? profession;
  final String? address;
  final String? identityNumber;
  final String? identityType;
  final bool? isProfileComplete;
  final DateTime? birthDate;
  final DateTime? identityExpirationDate;
  final String? frontDocumentPath;
  final String? backDocumentPath;

  User({
    required this.id,
    required this.nom,
    required this.email,
    this.telephone,
    this.avatarUrl,
    required this.typeUtilisateur,
    required this.statut,
    this.derniereConnexion,
    this.dateCreation,
    this.updatedAt,
    this.birthPlace,
    this.gender,
    this.nationality,
    this.profession,
    this.address,
    this.identityNumber,
    this.identityType,
    this.isProfileComplete,
    this.birthDate,
    this.identityExpirationDate,
    this.frontDocumentPath,
    this.backDocumentPath,
  });

  static DateTime? _parseDate(dynamic dateValue, String fieldName) {
    if (dateValue == null) {
      return null;
    }

    try {
      String dateStr = dateValue.toString();

      if (dateStr.contains('-') && dateStr.length == 10) {
        List<String> parts = dateStr.split('-');
        if (parts.length == 3) {
          int day = int.parse(parts[0]);
          int month = int.parse(parts[1]);
          int year = int.parse(parts[2]);

          DateTime parsedDate = DateTime(year, month, day);
          return parsedDate;
        }
      }

      if (dateStr.contains('/') && dateStr.length == 10) {
        List<String> parts = dateStr.split('/');
        if (parts.length == 3) {
          int day = int.parse(parts[0]);
          int month = int.parse(parts[1]);
          int year = int.parse(parts[2]);

          DateTime parsedDate = DateTime(year, month, day);
          return parsedDate;
        }
      }

      final parsedDate = DateTime.parse(dateStr);
      return parsedDate;
    } catch (e) {
      try {
        String dateStr = dateValue.toString();
        if (dateStr.contains('-')) {
          final DateFormat formatter = DateFormat('dd-MM-yyyy');
          DateTime parsedDate = formatter.parse(dateStr);
          return parsedDate;
        } else if (dateStr.contains('/')) {
          final DateFormat formatter = DateFormat('dd/MM/yyyy');
          DateTime parsedDate = formatter.parse(dateStr);
          return parsedDate;
        }

      } catch (e2) {}

      return null;
    }
  }

  factory User.fromJson(Map<String, dynamic> json) {
    final avatarUrl = json['avatar_path'] ?? json['avatarUrl'] ?? json['avatar_url'];
    
    return User(
      id: json['id'],
      nom: json['nom'],
      email: json['email'],
      telephone: json['telephone'],
      avatarUrl: avatarUrl,
      typeUtilisateur: TypeUtilisateur.values.firstWhere(
        (e) => e.toString().split('.').last == json['type_utilisateur'],
        orElse: () => TypeUtilisateur.client,
      ),
      statut: json['statut'] ?? true,
      derniereConnexion: json['dernière_connexion'] != null
          ? DateTime.parse(json['dernière_connexion'])
          : null,
      dateCreation: json['date_creation'] != null
          ? DateTime.parse(json['date_creation'])
          : null,
      updatedAt: json['date_modification'] != null
          ? DateTime.parse(json['date_modification'])
          : null,
      birthPlace: json['lieu_naissance'],
      gender: json['sexe'],
      nationality: json['nationalite'],
      profession: json['profession'],
      address: json['adresse'],
      identityNumber: json['numero_piece_identite'],
      identityType: json['type_piece_identite'],
      isProfileComplete: json['profil_complet'],
      birthDate: _parseDate(json['date_naissance'], 'date_naissance'),
      identityExpirationDate: _parseDate(
        json['date_expiration_piece_identite'],
        'date_expiration_piece_identite',
      ),
      // URLs complètes du backend
      frontDocumentPath: json['frontDocumentUrl'] ?? json['front_document_url'],
      backDocumentPath: json['backDocumentUrl'] ?? json['back_document_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'email': email,
      'telephone': telephone,
      'avatarUrl': avatarUrl,
      'type_utilisateur': typeUtilisateur.toString().split('.').last,
      'statut': statut,
      'dernière_connexion': derniereConnexion?.toIso8601String(),
      'date_creation': dateCreation?.toIso8601String(),
      'date_modification': updatedAt?.toIso8601String(),
      'lieu_naissance': birthPlace,
      'sexe': gender,
      'nationalite': nationality,
      'profession': profession,
      'adresse': address,
      'numero_piece_identite': identityNumber,
      'type_piece_identite': identityType,
      'profil_complet': isProfileComplete,
      'date_naissance': birthDate?.toIso8601String(),
      'date_expiration_piece_identite': identityExpirationDate
          ?.toIso8601String(),
      'front_document_path': frontDocumentPath,
      'back_document_path': backDocumentPath,
    };
  }

  User copyWith({
    String? id,
    String? nom,
    String? email,
    String? telephone,
    String? avatarUrl,
    TypeUtilisateur? typeUtilisateur,
    bool? statut,
    DateTime? derniereConnexion,
    DateTime? dateCreation,
    DateTime? updatedAt,
    String? birthPlace,
    String? gender,
    String? nationality,
    String? profession,
    String? address,
    String? identityNumber,
    String? identityType,
    bool? isProfileComplete,
    DateTime? birthDate,
    DateTime? identityExpirationDate,
    String? frontDocumentPath,
    String? backDocumentPath,
  }) {
    return User(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      email: email ?? this.email,
      telephone: telephone ?? this.telephone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      typeUtilisateur: typeUtilisateur ?? this.typeUtilisateur,
      statut: statut ?? this.statut,
      derniereConnexion: derniereConnexion ?? this.derniereConnexion,
      dateCreation: dateCreation ?? this.dateCreation,
      updatedAt: updatedAt ?? this.updatedAt,
      birthPlace: birthPlace ?? this.birthPlace,
      gender: gender ?? this.gender,
      nationality: nationality ?? this.nationality,
      profession: profession ?? this.profession,
      address: address ?? this.address,
      identityNumber: identityNumber ?? this.identityNumber,
      identityType: identityType ?? this.identityType,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      birthDate: birthDate ?? this.birthDate,
      identityExpirationDate:
          identityExpirationDate ?? this.identityExpirationDate,
      frontDocumentPath: frontDocumentPath ?? this.frontDocumentPath,
      backDocumentPath: backDocumentPath ?? this.backDocumentPath,
    );
  }

  String get displayName => nom;
  bool get isActive => statut;
  bool get isClient => typeUtilisateur == TypeUtilisateur.client;
  bool get isAgent => typeUtilisateur == TypeUtilisateur.agent;
  bool get isAdmin => typeUtilisateur == TypeUtilisateur.admin;
  bool get isDrh => typeUtilisateur == TypeUtilisateur.drh;

  bool get hasProfileData =>
      birthPlace != null ||
      gender != null ||
      nationality != null ||
      profession != null;

  bool get isProfileCompleteValue =>
      isProfileComplete ?? _checkProfileComplete();

  bool _checkProfileComplete() {
    return birthPlace?.isNotEmpty == true &&
        gender?.isNotEmpty == true &&
        nationality?.isNotEmpty == true &&
        profession?.isNotEmpty == true &&
        address?.isNotEmpty == true &&
        identityNumber?.isNotEmpty == true &&
        identityType?.isNotEmpty == true &&
        birthDate != null &&
        identityExpirationDate != null &&
        frontDocumentPath?.isNotEmpty == true &&
        backDocumentPath?.isNotEmpty == true;
  }

  String get genderDisplay => gender?.toLowerCase() == 'masculin'
      ? 'Masculin'
      : gender?.toLowerCase() == 'feminin'
      ? 'Féminin'
      : gender ?? 'Non renseigné';

  String get profileStatus =>
      isProfileCompleteValue ? 'Profil complet' : 'Profil incomplet';
}

enum TypeUtilisateur { client, agent, drh, admin }

extension TypeUtilisateurExtension on TypeUtilisateur {
  String get label {
    switch (this) {
      case TypeUtilisateur.client:
        return 'Client';
      case TypeUtilisateur.agent:
        return 'Agent';
      case TypeUtilisateur.drh:
        return 'DRH';
      case TypeUtilisateur.admin:
        return 'Administrateur';
    }
  }
}

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

  final String? lieuNaissance;
  final String? sexe;
  final String? nationalite;
  final String? profession;
  final String? adresse;
  final String? numeroPieceIdentite;
  final String? typePieceIdentite;
  final bool? profilComplet;

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
    this.lieuNaissance,
    this.sexe,
    this.nationalite,
    this.profession,
    this.adresse,
    this.numeroPieceIdentite,
    this.typePieceIdentite,
    this.profilComplet,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nom: json['nom'],
      email: json['email'],
      telephone: json['telephone'],
      avatarUrl: json['avatarUrl'],
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
      lieuNaissance: json['lieu_naissance'],
      sexe: json['sexe'],
      nationalite: json['nationalite'],
      profession: json['profession'],
      adresse: json['adresse'],
      numeroPieceIdentite: json['numero_piece_identite'],
      typePieceIdentite: json['type_piece_identite'],
      profilComplet: json['profil_complet'],
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
      'lieu_naissance': lieuNaissance,
      'sexe': sexe,
      'nationalite': nationalite,
      'profession': profession,
      'adresse': adresse,
      'numero_piece_identite': numeroPieceIdentite,
      'type_piece_identite': typePieceIdentite,
      'profil_complet': profilComplet,
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
    String? lieuNaissance,
    String? sexe,
    String? nationalite,
    String? profession,
    String? adresse,
    String? numeroPieceIdentite,
    String? typePieceIdentite,
    bool? profilComplet,
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
      lieuNaissance: lieuNaissance ?? this.lieuNaissance,
      sexe: sexe ?? this.sexe,
      nationalite: nationalite ?? this.nationalite,
      profession: profession ?? this.profession,
      adresse: adresse ?? this.adresse,
      numeroPieceIdentite: numeroPieceIdentite ?? this.numeroPieceIdentite,
      typePieceIdentite: typePieceIdentite ?? this.typePieceIdentite,
      profilComplet: profilComplet ?? this.profilComplet,
    );
  }

  String get displayName => nom;
  bool get isActive => statut;
  bool get isClient => typeUtilisateur == TypeUtilisateur.client;
  bool get isAgent => typeUtilisateur == TypeUtilisateur.agent;
  bool get isAdmin => typeUtilisateur == TypeUtilisateur.admin;
  bool get isDrh => typeUtilisateur == TypeUtilisateur.drh;

  bool get hasProfileData =>
      lieuNaissance != null ||
      sexe != null ||
      nationalite != null ||
      profession != null;

  bool get isProfileComplete => profilComplet ?? _checkProfileComplete();

  bool _checkProfileComplete() {
    return lieuNaissance?.isNotEmpty == true &&
        sexe?.isNotEmpty == true &&
        nationalite?.isNotEmpty == true &&
        profession?.isNotEmpty == true &&
        adresse?.isNotEmpty == true &&
        numeroPieceIdentite?.isNotEmpty == true &&
        typePieceIdentite?.isNotEmpty == true;
  }

  String get genderDisplay => sexe?.toLowerCase() == 'masculin'
      ? 'Masculin'
      : sexe?.toLowerCase() == 'feminin'
      ? 'Féminin'
      : sexe ?? 'Non renseigné';

  String get profileStatus =>
      isProfileComplete ? 'Profil complet' : 'Profil incomplet';
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

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
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nom: json['nom'],
      email: json['email'],
      telephone: json['téléphone'],
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
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'email': email,
      'téléphone': telephone,
      'avatarUrl': avatarUrl,
      'type_utilisateur': typeUtilisateur.toString().split('.').last,
      'statut': statut,
      'dernière_connexion': derniereConnexion?.toIso8601String(),
      'date_creation': dateCreation?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
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
    );
  }

  String get displayName => nom;
  bool get isActive => statut;
  bool get isClient => typeUtilisateur == TypeUtilisateur.client;
  bool get isAgent => typeUtilisateur == TypeUtilisateur.agent;
  bool get isAdmin => typeUtilisateur == TypeUtilisateur.admin;
}

enum TypeUtilisateur {
  client,
  agent,
  drh,
  admin,
}

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
class ImageLabels {
  static String getRectoLabel(String? identityType) {
    switch (identityType?.toLowerCase()) {
      case 'passeport':
      case 'passport': // Support pour les deux formats
        return 'Première page de votre passeport';
      case 'carte_identite':
      case 'cni': // Support pour les deux formats
      default:
        return 'Recto de votre carte d\'identité';
    }
  }

  static String getVersoLabel(String? identityType) {
    switch (identityType?.toLowerCase()) {
      case 'passeport':
      case 'passport': // Support pour les deux formats
        return 'Deuxième page de votre passeport';
      case 'carte_identite':
      case 'cni': // Support pour les deux formats
      default:
        return 'Verso de votre carte d\'identité';
    }
  }

  static String getUploadTitle(String? identityType) {
    switch (identityType?.toLowerCase()) {
      case 'passeport':
      case 'passport': // Support pour les deux formats
        return 'Photos de votre passeport';
      case 'carte_identite':
      case 'cni': // Support pour les deux formats
      default:
        return 'Photos de votre pièce';
    }
  }

  static String getUploadDescription(String? identityType) {
    switch (identityType?.toLowerCase()) {
      case 'passeport':
      case 'passport': // Support pour les deux formats
        return 'Uploadez la première page et la deuxième page de votre passeport';
      case 'carte_identite':
      case 'cni': // Support pour les deux formats
      default:
        return 'Uploadez le recto et le verso de votre carte d\'identité';
    }
  }
}

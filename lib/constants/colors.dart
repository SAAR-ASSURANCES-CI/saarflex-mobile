import 'package:flutter/material.dart';

class AppColors {
  // === COULEURS PRINCIPALES ===
  // Rouge SAAR (couleur signature de la marque)
  static const Color primary = Color(0xFFE53E3E);           // Rouge principal plus vibrant
  static const Color primaryLight = Color(0xFFED6A6A);      // Rouge clair pour les états hover
  static const Color primaryDark = Color(0xFFCC2D2D);       // Rouge foncé pour les ombres
  
  // Or/Doré SAAR (couleur premium de la marque)
  static const Color secondary = Color(0xFFD4AF37);         // Or riche et élégant
  static const Color secondaryLight = Color(0xFFE6C555);    // Or clair
  static const Color secondaryDark = Color(0xFFB8941F);     // Or foncé
  
  // Bleu royal (inspiré du gradient de l'app mobile)
  static const Color accent = Color(0xFF4F46E5);            // Bleu moderne
  static const Color accentLight = Color(0xFF6366F1);       // Bleu clair
  static const Color accentDark = Color(0xFF3730A3);        // Bleu foncé
  
  // === COULEURS NEUTRES ===
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFFAFAFA);        // Fond très léger
  static const Color surface = Color(0xFFFFFFFF);           // Surface des cartes
  static const Color surfaceVariant = Color(0xFFF5F5F7);    // Surface alternative
  
  // Texte et icônes
  static const Color textPrimary = Color(0xFF1A1A1A);       // Texte principal
  static const Color textSecondary = Color(0xFF6B7280);     // Texte secondaire
  static const Color textHint = Color(0xFF9CA3AF);          // Texte d'indication
  
  // === COULEURS FONCTIONNELLES ===
  // Succès (vert élégant)
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color successDark = Color(0xFF059669);
  
  // Avertissement (orange chaleureux)
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningDark = Color(0xFFD97706);
  
  // Erreur (rouge distinctif du primary)
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorDark = Color(0xFFDC2626);
  
  // Information (bleu doux)
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);
  static const Color infoDark = Color(0xFF2563EB);
  
  // === COULEURS SPÉCIALISÉES ===
  // Bordures et dividers
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF3F4F6);
  static const Color borderDark = Color(0xFFD1D5DB);
  
  // Ombres et élévations
  static const Color shadow = Color(0x1A000000);            // Ombre légère
  static const Color shadowMedium = Color(0x33000000);      // Ombre moyenne
  static const Color shadowStrong = Color(0x4D000000);      // Ombre forte
  
  // États des composants
  static const Color disabled = Color(0xFFD1D5DB);
  static const Color disabledText = Color(0xFF9CA3AF);
  
  // Overlay et masques
  static const Color overlay = Color(0x80000000);           // Overlay sombre
  static const Color overlayLight = Color(0x40000000);      // Overlay léger
  
  // === GRADIENTS PERSONNALISÉS ===
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primary],
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryLight, secondary],
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentLight, accent],
  );
  
  // Gradient signature SAAR (rouge vers or)
  static const LinearGradient saarGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primary, secondary],
  );
  
  // Gradient de fond élégant
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFAFAFA),
      Color(0xFFFFFFFF),
    ],
  );
  
  // === MÉTHODES UTILITAIRES ===
  // Obtenir une couleur avec opacité
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
  
  // Obtenir une variante plus claire d'une couleur
  static Color lighter(Color color, [double amount = 0.1]) {
    return Color.lerp(color, white, amount) ?? color;
  }
  
  // Obtenir une variante plus foncée d'une couleur
  static Color darker(Color color, [double amount = 0.1]) {
    return Color.lerp(color, Color(0xFF000000), amount) ?? color;
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saarciflex_app/data/models/product_model.dart';

/// Widget pour afficher l'icône d'un produit
/// Utilise SvgPicture.network si iconUrl est disponible, sinon utilise l'icône par défaut
class ProductIconWidget extends StatelessWidget {
  final Product product;
  final double size;
  final Color? color;

  const ProductIconWidget({
    super.key,
    required this.product,
    required this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? product.displayColor;

    // Si le produit a une URL d'icône SVG, l'utiliser
    if (product.iconUrl != null && product.iconUrl!.isNotEmpty) {
      return SvgPicture.network(
        product.iconUrl!,
        width: size,
        height: size,
        colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
        placeholderBuilder: (context) => Icon(
          product.displayIcon,
          color: iconColor,
          size: size,
        ),
      );
    }

    // Sinon, utiliser l'icône par défaut
    return Icon(
      product.displayIcon,
      color: iconColor,
      size: size,
    );
  }
}

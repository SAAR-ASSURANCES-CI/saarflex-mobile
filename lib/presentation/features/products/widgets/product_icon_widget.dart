import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saarciflex_app/data/models/product_model.dart';

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

    return Icon(
      product.displayIcon,
      color: iconColor,
      size: size,
    );
  }
}

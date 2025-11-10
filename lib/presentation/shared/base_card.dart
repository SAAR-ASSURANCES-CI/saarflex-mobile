import 'package:flutter/material.dart';
import 'package:saarflex_app/core/constants/design_system.dart';

class BaseCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final BoxDecoration? decoration;
  final VoidCallback? onTap;

  const BaseCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.decoration,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(20),
        decoration: decoration ?? DesignSystem.cardDecoration,
        child: child,
      ),
    );
  }
}

class PrimaryCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const PrimaryCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(24),
      decoration: DesignSystem.primaryCardDecoration,
      child: child,
    );
  }
}

class ErrorCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const ErrorCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: DesignSystem.errorDecoration,
      child: child,
    );
  }
}


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarciflex_app/core/constants/colors.dart';

class ProductSearchBar extends StatefulWidget {
  final String hintText;
  final String? initialValue;
  final Function(String) onSearch;
  final Function()? onClear;
  final bool enabled;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const ProductSearchBar({
    super.key,
    this.hintText = 'Rechercher un produit...',
    this.initialValue,
    required this.onSearch,
    this.onClear,
    this.enabled = true,
    this.margin,
    this.padding,
  });

  @override
  State<ProductSearchBar> createState() => _ProductSearchBarState();
}

class _ProductSearchBarState extends State<ProductSearchBar> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          widget.margin ??
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: widget.padding,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        enabled: widget.enabled,
        onChanged: widget.onSearch,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 20),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey[500], size: 20),
                  onPressed: _clearSearch,
                )
              : null,
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[800]),
      ),
    );
  }

  void _clearSearch() {
    _controller.clear();
    widget.onSearch('');
    if (widget.onClear != null) {
      widget.onClear!();
    }
  }
}

class ProductSearchBarCompact extends StatefulWidget {
  final String hintText;
  final String? initialValue;
  final Function(String) onSearch;
  final Function()? onClear;
  final bool enabled;

  const ProductSearchBarCompact({
    super.key,
    this.hintText = 'Rechercher...',
    this.initialValue,
    required this.onSearch,
    this.onClear,
    this.enabled = true,
  });

  @override
  State<ProductSearchBarCompact> createState() =>
      _ProductSearchBarCompactState();
}

class _ProductSearchBarCompactState extends State<ProductSearchBarCompact> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        enabled: widget.enabled,
        onChanged: widget.onSearch,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 16),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey[500], size: 16),
                  onPressed: _clearSearch,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
        ),
        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[800]),
      ),
    );
  }

  void _clearSearch() {
    _controller.clear();
    widget.onSearch('');
    if (widget.onClear != null) {
      widget.onClear!();
    }
  }
}

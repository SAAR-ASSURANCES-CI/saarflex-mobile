import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarflex_app/core/constants/colors.dart';
import 'package:saarflex_app/data/models/product_model.dart';

class ProductFilterChip extends StatelessWidget {
  final ProductType type;
  final bool isSelected;
  final VoidCallback onTap;
  final int? count;

  const ProductFilterChip({
    super.key,
    required this.type,
    required this.isSelected,
    required this.onTap,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: isSelected,
      onSelected: (_) => onTap(),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            type.icon,
            size: 16,
            color: isSelected ? Colors.white : type.color,
          ),
          const SizedBox(width: 6),
          Text(
            type.shortLabel,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : type.color,
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : type.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                count.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : type.color,
                ),
              ),
            ),
          ],
        ],
      ),
      backgroundColor: isSelected ? type.color : type.color.withOpacity(0.1),
      selectedColor: type.color,
      checkmarkColor: Colors.white,
      side: BorderSide(
        color: isSelected ? type.color : type.color.withOpacity(0.3),
        width: 1,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}

class ProductFilterChips extends StatelessWidget {
  final ProductType? selectedType;
  final Map<ProductType, int> productCountByType;
  final Function(ProductType?) onTypeChanged;
  final bool showAllOption;

  const ProductFilterChips({
    super.key,
    required this.selectedType,
    required this.productCountByType,
    required this.onTypeChanged,
    this.showAllOption = true,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (showAllOption) ...[
            FilterChip(
              selected: selectedType == null,
              onSelected: (_) => onTypeChanged(null),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.all_inclusive,
                    size: 16,
                    color: selectedType == null
                        ? Colors.white
                        : Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Tous',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: selectedType == null
                          ? Colors.white
                          : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: selectedType == null
                          ? Colors.white.withOpacity(0.2)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      productCountByType.values
                          .fold(0, (sum, count) => sum + count)
                          .toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: selectedType == null
                            ? Colors.white
                            : Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: selectedType == null
                  ? AppColors.primary
                  : Colors.grey[100]!,
              selectedColor: AppColors.primary,
              checkmarkColor: Colors.white,
              side: BorderSide(
                color: selectedType == null
                    ? AppColors.primary
                    : Colors.grey[300]!,
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(width: 8),
          ],
          ...ProductType.values.map((type) {
            final count = productCountByType[type] ?? 0;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ProductFilterChip(
                type: type,
                isSelected: selectedType == type,
                onTap: () => onTypeChanged(selectedType == type ? null : type),
                count: count,
              ),
            );
          }),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Reference chips: selected forest green fill; unselected white + light border, navy label.
abstract final class _CategoryPalette {
  static const Color forestGreen = Color(0xFF004D40);
  static const Color border = Color(0xFFE0E0E0);
  static const Color navyTitle = Color(0xFF1A237E);
  static const Color chipFill = Color(0xFFFFFFFF);
}

class MenuCategoryTabs extends StatelessWidget {
  const MenuCategoryTabs({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onCategorySelected,
  });

  final List<MenuCategoryTabItem> categories;
  final int selectedIndex;
  final ValueChanged<int> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    // Same accent as menu item price in dark mode.
    final accentColor = isLight ? _CategoryPalette.forestGreen : theme.colorScheme.primary;
    final accentOnColor = isLight ? Colors.white : theme.colorScheme.onPrimary;
    final unselectedBorder = isLight
        ? _CategoryPalette.border
        : theme.colorScheme.outlineVariant.withValues(alpha: 0.55);
    final isCompact = MediaQuery.sizeOf(context).width < 400;
    final hPad = isCompact ? 16.0 : 20.0;
    return Container(
      height: isCompact ? 46 : 50,
      alignment: Alignment.centerLeft,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: hPad),
        itemCount: categories.length,
        itemBuilder: (context, i) {
          final cat = categories[i];
          final selected = i == selectedIndex;
          return Padding(
            padding: EdgeInsets.only(right: isCompact ? 8 : 10),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onCategorySelected(i),
                borderRadius: BorderRadius.circular(22),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  padding: EdgeInsets.symmetric(
                    horizontal: isCompact ? 16 : 18,
                    vertical: isCompact ? 10 : 11,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? accentColor
                        : (isLight ? _CategoryPalette.chipFill : theme.colorScheme.surface),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: selected ? accentColor : unselectedBorder,
                      width: 1,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: accentColor.withValues(alpha: 0.22),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      cat.name,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: selected
                            ? accentOnColor
                            : (isLight ? _CategoryPalette.navyTitle : theme.colorScheme.onSurface),
                        fontWeight: FontWeight.w700,
                        fontSize: isCompact ? 13 : 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class MenuCategoryTabItem {
  const MenuCategoryTabItem({required this.id, required this.name, this.itemCount = 0});
  final int id;
  final String name;
  final int itemCount;
}

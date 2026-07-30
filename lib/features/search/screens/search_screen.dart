import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/loading_shimmer.dart';
import '../../../core/utils/font_helper.dart';
import '../../../core/controllers/locale_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../../restaurant/models/restaurant_details_args.dart';
import '../../restaurant/screens/restaurant_details_screen.dart';
import '../../restaurants/models/restaurant_model.dart';
import '../controllers/search_controller.dart';
import '../models/food_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  late final GlobalSearchController ctrl;
  final _textCtrl = TextEditingController();
  final _focus = FocusNode();

  late final AnimationController _anim;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    ctrl = Get.put(GlobalSearchController());
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 360));
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(begin: const Offset(0, 0.02), end: Offset.zero).animate(_fade);
    _anim.forward();
    // Auto focus after transition starts.
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _focus.dispose();
    _anim.dispose();
    Get.delete<GlobalSearchController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.arrow_back_ios_new_rounded),
                      ),
                      const SizedBox(width: 6),
                      Expanded(child: _SearchBar(textCtrl: _textCtrl, focusNode: _focus, onChanged: ctrl.setQuery)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 2, 12, 10),
                  child: Obx(() {
                    return _AnimatedTabs(
                      selected: ctrl.tab.value,
                      onChanged: ctrl.setTab,
                      allLabel: l10n.all,
                      restaurantsLabel: l10n.restaurants,
                      foodsLabel: l10n.foods,
                    );
                  }),
                ),
                Expanded(
                  child: Obx(() {
                    final q = ctrl.query.value.trim();
                    if (q.isEmpty) {
                      return _EmptyHint(
                        title: l10n.search,
                        subtitle: l10n.searchAllHint,
                      );
                    }
                    if (ctrl.isLoading.value) {
                      return const SearchResultsSkeleton();
                    }
                    if (ctrl.tab.value == SearchTab.all) {
                      return _AllResults(
                        restaurants: ctrl.restaurants.toList(),
                        foods: ctrl.foods.toList(),
                        onRestaurant: (r) => _openRestaurant(context, r),
                        onFood: (f) => _openFood(context, f),
                      );
                    }
                    if (ctrl.tab.value == SearchTab.restaurants) {
                      return _RestaurantResults(
                        query: q,
                        items: ctrl.restaurants.toList(),
                        onOpen: (r) => _openRestaurant(context, r),
                      );
                    }
                    return _FoodResults(
                      query: q,
                      items: ctrl.foods.toList(),
                      onOpen: (f) => _openFood(context, f),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openRestaurant(BuildContext context, RestaurantModel r) {
    Get.to<void>(
      () => RestaurantDetailsScreen(
        restaurantId: r.id,
        args: RestaurantDetailsArgs(
          restaurantId: r.id,
          initialName: r.displayName,
          initialImage: r.image,
          initialLogo: r.logo,
          initialCover: r.cover,
          initialRating: r.rating,
          initialTotalReviews: r.totalReviews,
          initialDeliveryTime: r.deliveryTime,
          initialLocation: r.displayLocation,
          initialCategory: r.displayCategoryNames,
          isOpen: r.isOpen,
          deliveryFee: r.deliveryFee,
          minOrder: r.minimumOrder,
          freeDeliveryAbove: r.freeDeliveryAbove,
        ),
      ),
      preventDuplicates: true,
      transition: Transition.cupertino,
      duration: const Duration(milliseconds: 220),
    );
  }

  void _openFood(BuildContext context, FoodModel f) {
    if (f.restaurantId == null || f.restaurantId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.openRestaurantNotAvailable,
            style: FontHelper.getTextStyle(
              text: AppLocalizations.of(context)!.openRestaurantNotAvailable,
              languageCode: Get.find<LocaleController>().locale.languageCode,
              fontSize: 14.0,
              fontWeight: FontWeight.normal,
              color: Colors.white,
            ),
          ),
        ),
      );
      return;
    }
    Get.to<void>(
      () => RestaurantDetailsScreen(
        restaurantId: f.restaurantId!,
        args: RestaurantDetailsArgs(
          restaurantId: f.restaurantId!,
          initialName: f.restaurantName ?? '',
        ),
      ),
      preventDuplicates: true,
      transition: Transition.cupertino,
      duration: const Duration(milliseconds: 220),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.textCtrl, required this.focusNode, required this.onChanged});

  final TextEditingController textCtrl;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          Icon(Icons.search_rounded, color: theme.colorScheme.onSurface.withOpacity(0.45)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: textCtrl,
              focusNode: focusNode,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: l10n.searchAllHint,
                border: InputBorder.none,
              ),
            ),
          ),
          if (textCtrl.text.isNotEmpty)
            IconButton(
              onPressed: () {
                textCtrl.clear();
                onChanged('');
              },
              icon: Icon(Icons.close_rounded, size: 18),
            ),
        ],
      ),
    );
  }
}

class _AnimatedTabs extends StatelessWidget {
  const _AnimatedTabs({
    required this.selected,
    required this.onChanged,
    required this.allLabel,
    required this.restaurantsLabel,
    required this.foodsLabel,
  });

  final SearchTab selected;
  final ValueChanged<SearchTab> onChanged;
  final String allLabel;
  final String restaurantsLabel;
  final String foodsLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TabChip(
            active: selected == SearchTab.all,
            label: allLabel,
            icon: Icons.dashboard_rounded,
            onTap: () => onChanged(SearchTab.all),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _TabChip(
            active: selected == SearchTab.restaurants,
            label: restaurantsLabel,
            icon: Icons.restaurant_rounded,
            onTap: () => onChanged(SearchTab.restaurants),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _TabChip(
            active: selected == SearchTab.foods,
            label: foodsLabel,
            icon: Icons.fastfood_rounded,
            onTap: () => onChanged(SearchTab.foods),
          ),
        ),
      ],
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({required this.active, required this.label, required this.icon, required this.onTap});

  final bool active;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: active ? Colors.transparent : theme.dividerColor.withOpacity(0.25)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 17, color: active ? Colors.white : AppColors.primary),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: FontHelper.getTextStyle(
                  text: label,
                  languageCode: Get.find<LocaleController>().locale.languageCode,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: active ? Colors.white : theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(Icons.search_rounded, color: AppColors.primary, size: 34),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: FontHelper.getTextStyle(
                text: title,
                languageCode: Get.find<LocaleController>().locale.languageCode,
                fontSize: 22.0,
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: FontHelper.getTextStyle(
                text: subtitle,
                languageCode: Get.find<LocaleController>().locale.languageCode,
                fontSize: 14.0,
                fontWeight: FontWeight.normal,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AllResults extends StatelessWidget {
  const _AllResults({
    required this.restaurants,
    required this.foods,
    required this.onRestaurant,
    required this.onFood,
  });

  final List<RestaurantModel> restaurants;
  final List<FoodModel> foods;
  final ValueChanged<RestaurantModel> onRestaurant;
  final ValueChanged<FoodModel> onFood;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    if (restaurants.isEmpty && foods.isEmpty) {
      return _EmptyHint(title: l10n.noResults, subtitle: l10n.tryDifferentKeywords);
    }
    var index = 0;
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
      children: [
        if (restaurants.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
            child: Text(
              l10n.restaurants,
              style: FontHelper.getTextStyle(
                text: l10n.restaurants,
                languageCode: Get.find<LocaleController>().locale.languageCode,
                fontSize: 14.0,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ...restaurants.map((r) {
            final i = index++;
            return _AnimatedResultTile(
              index: i,
              leading: Icon(Icons.restaurant_rounded, color: AppColors.primary),
              title: r.displayName,
              subtitle: r.categoryNames ?? '',
              onTap: () => onRestaurant(r),
            );
          }),
        ],
        if (foods.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.fromLTRB(4, restaurants.isNotEmpty ? 14 : 4, 4, 8),
            child: Text(
              l10n.foods,
              style: FontHelper.getTextStyle(
                text: l10n.foods,
                languageCode: Get.find<LocaleController>().locale.languageCode,
                fontSize: 14.0,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ...foods.map((f) {
            final i = index++;
            return _AnimatedResultTile(
              index: i,
              leading: Icon(Icons.fastfood_rounded, color: AppColors.primary),
              title: f.displayName,
              subtitle: f.restaurantName ?? '',
              onTap: () => onFood(f),
            );
          }),
        ],
      ],
    );
  }
}

class _RestaurantResults extends StatelessWidget {
  const _RestaurantResults({required this.query, required this.items, required this.onOpen});
  final String query;
  final List<RestaurantModel> items;
  final ValueChanged<RestaurantModel> onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (items.isEmpty) {
      return _EmptyHint(title: l10n.noResults, subtitle: l10n.tryDifferentKeywords);
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final r = items[i];
        return _AnimatedResultTile(
          index: i,
          leading: Icon(Icons.restaurant_rounded, color: AppColors.primary),
          title: r.name,
          subtitle: r.categoryNames ?? '',
          onTap: () => onOpen(r),
        );
      },
    );
  }
}

class _FoodResults extends StatelessWidget {
  const _FoodResults({required this.query, required this.items, required this.onOpen});
  final String query;
  final List<FoodModel> items;
  final ValueChanged<FoodModel> onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (items.isEmpty) {
      return _EmptyHint(title: l10n.noResults, subtitle: l10n.tryDifferentKeywords);
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final f = items[i];
        return _AnimatedResultTile(
          index: i,
          leading: Icon(Icons.fastfood_rounded, color: AppColors.primary),
          title: f.name,
          subtitle: f.restaurantName ?? '',
          onTap: () => onOpen(f),
        );
      },
    );
  }
}

class _AnimatedResultTile extends StatelessWidget {
  const _AnimatedResultTile({
    required this.index,
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final int index;
  final Widget leading;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 280 + (index * 25)),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) {
        final t = v.clamp(0.0, 1.0);
        return Opacity(
          opacity: t,
          child: Transform.translate(offset: Offset(0, 10 * (1 - t)), child: child),
        );
      },
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 10),
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          onTap: onTap,
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(child: leading),
          ),
          title: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: FontHelper.getTextStyle(
              text: title,
              languageCode: Get.find<LocaleController>().locale.languageCode,
              fontSize: 14.0,
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.onSurface,
            ),
          ),
          subtitle: subtitle.isEmpty
              ? null
              : Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: FontHelper.getTextStyle(
                    text: subtitle,
                    languageCode: Get.find<LocaleController>().locale.languageCode,
                    fontSize: 12.0,
                    fontWeight: FontWeight.normal,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
          trailing: Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurface.withOpacity(0.35)),
        ),
      ),
    );
  }
}


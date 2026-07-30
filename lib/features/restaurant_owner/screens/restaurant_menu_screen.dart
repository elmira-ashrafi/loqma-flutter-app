import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_currency.dart';
import '../../../core/utils/error_parser.dart';
import '../models/restaurant_owner_models.dart';
import '../services/restaurant_owner_service.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/app_page_loading.dart';
import '../../../l10n/app_localizations.dart';

class RestaurantMenuScreen extends StatefulWidget {
  const RestaurantMenuScreen({super.key});

  @override
  State<RestaurantMenuScreen> createState() => _RestaurantMenuScreenState();
}

class _RestaurantMenuScreenState extends State<RestaurantMenuScreen> {
  final RestaurantOwnerService _service = RestaurantOwnerService();
  List<RestaurantMenuCategory> _categories = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _service.getMenu();
      if (!mounted) return;
      setState(() {
        _categories = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = userFriendlyErrorMessage(e);
        _loading = false;
      });
    }
  }

  Future<void> _showCategoryDialog([RestaurantMenuCategory? category]) async {
    final name = TextEditingController(text: category?.name ?? '');
    final nameFa = TextEditingController(text: category?.nameFa ?? '');
    final description = TextEditingController(text: category?.description ?? '');
    bool isActive = category?.isActive ?? true;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final l10n = AppLocalizations.of(dialogContext)!;
        return StatefulBuilder(
          builder: (context, setStateDialog) => AlertDialog(
          title: Text(category == null ? l10n.newCategoryDialogTitle : l10n.editCategoryDialogTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
             
              children: [
                TextField(controller: name, decoration: InputDecoration(labelText: l10n.name)),
                const SizedBox(height: 12),
                TextField(controller: nameFa, decoration: InputDecoration(labelText: l10n.categoryNameFaLabel)),
                const SizedBox(height: 12),
                TextField(controller: description, decoration: InputDecoration(labelText: l10n.descriptionFieldLabel)),
                const SizedBox(height: 8),
                SwitchListTile(
                  value: isActive,
                  onChanged: (value) => setStateDialog(() => isActive = value),
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.active),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.ticketCancel)),
            FilledButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                try {
                  final body = {
                    'name': name.text.trim(),
                    'name_fa': nameFa.text.trim(),
                    'description': description.text.trim(),
                    'is_active': isActive,
                  };
                  if (category == null) {
                    await _service.createCategory(body);
                  } else {
                    await _service.updateCategory(category.id, body);
                  }
                  if (!mounted) return;
                  navigator.pop();
                  await _load();
                } catch (e) {
                  if (!mounted) return;
                  messenger.showSnackBar(
                    SnackBar(content: Text(userFriendlyErrorMessage(e)), backgroundColor: AppColors.error),
                  );
                }
              },
              child: Text(l10n.save),
            ),
          ],
        ),
        );
      },
    );
  }

  Future<void> _showItemDialog({RestaurantMenuCategory? category, RestaurantMenuItem? item}) async {
    final categories = _categories;
    int selectedCategoryId = category?.id ?? item?.categoryId ?? (categories.isNotEmpty ? categories.first.id : 0);
    final name = TextEditingController(text: item?.name ?? '');
    final nameFa = TextEditingController(text: item?.nameFa ?? '');
    final description = TextEditingController(text: item?.description ?? '');
    final price = TextEditingController(text: item?.price.toStringAsFixed(0) ?? '');
    final discountPrice = TextEditingController(text: item?.discountedPrice?.toStringAsFixed(0) ?? '');
    final offerLabel = TextEditingController(text: item?.offerLabel ?? '');
    final discountStart = TextEditingController(text: item?.discountStart ?? '');
    final discountEnd = TextEditingController(text: item?.discountEnd ?? '');
    final prepTime = TextEditingController(text: item?.preparationTime?.toString() ?? '');
    bool isAvailable = item?.isAvailable ?? true;
    bool isFeatured = item?.isFeatured ?? false;
    bool isSpecialOffer = item?.isSpecialOffer ?? false;
    bool hasSizes = item?.hasSizes ?? false;
    final kidsPrice = TextEditingController(
      text: item?.sizePrice('Kids')?.toStringAsFixed(0) ?? '',
    );
    final smallPrice = TextEditingController(
      text: item?.sizePrice('Small')?.toStringAsFixed(0) ?? '',
    );
    final mediumPrice = TextEditingController(
      text: item?.sizePrice('Medium')?.toStringAsFixed(0) ?? '',
    );
    final largePrice = TextEditingController(
      text: item?.sizePrice('Large')?.toStringAsFixed(0) ?? '',
    );
    final familyPrice = TextEditingController(
      text: item?.sizePrice('Family Size')?.toStringAsFixed(0) ??
          item?.sizePrice('Family')?.toStringAsFixed(0) ??
          '',
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final l10n = AppLocalizations.of(dialogContext)!;
        return StatefulBuilder(
          builder: (context, setStateDialog) => AlertDialog(
          title: Text(item == null ? l10n.newMenuItemTitle : l10n.editMenuItemTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  initialValue: selectedCategoryId == 0 ? null : selectedCategoryId,
                  items: categories
                      .map((e) => DropdownMenuItem<int>(value: e.id, child: Text(e.name)))
                      .toList(),
                  onChanged: (value) => setStateDialog(() => selectedCategoryId = value ?? 0),
                  decoration: InputDecoration(labelText: l10n.foodCategoryDropdownLabel),
                ),
                const SizedBox(height: 12),
                TextField(controller: name, decoration: InputDecoration(labelText: l10n.name)),
                const SizedBox(height: 12),
                TextField(controller: nameFa, decoration: InputDecoration(labelText: l10n.categoryNameFaLabel)),
                const SizedBox(height: 12),
                TextField(controller: description, decoration: InputDecoration(labelText: l10n.descriptionFieldLabel)),
                const SizedBox(height: 12),
                TextField(controller: price, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: l10n.summaryAmountLabel)),
                const SizedBox(height: 8),
                SwitchListTile(
                  value: hasSizes,
                  onChanged: (value) => setStateDialog(() => hasSizes = value),
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.menuItemHasSizesLabel),
                  subtitle: hasSizes ? Text(l10n.menuItemSmallPriceHint) : null,
                ),
                if (hasSizes) ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: kidsPrice,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: l10n.menuItemKidsPriceLabel),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: smallPrice,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: l10n.menuItemSmallPriceLabel),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: mediumPrice,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: l10n.menuItemMediumPriceLabel),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: largePrice,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: l10n.menuItemLargePriceLabel),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: familyPrice,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: l10n.menuItemFamilyPriceLabel),
                  ),
                ],
                const SizedBox(height: 12),
                TextField(controller: discountPrice, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: l10n.discountedPriceFieldLabel)),
                const SizedBox(height: 12),
                TextField(controller: prepTime, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: l10n.preparationTimeMinutesLabel)),
                SwitchListTile(
                  value: isAvailable,
                  onChanged: (value) => setStateDialog(() => isAvailable = value),
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.available),
                ),
                SwitchListTile(
                  value: isFeatured,
                  onChanged: (value) => setStateDialog(() => isFeatured = value),
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.featured),
                ),
                SwitchListTile(
                  value: isSpecialOffer,
                  onChanged: (value) => setStateDialog(() => isSpecialOffer = value),
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.specialOfferDealsTab),
                  subtitle: Text(l10n.specialOfferDealsSubtitle),
                ),
                if (isSpecialOffer) ...[
                  TextField(
                    controller: offerLabel,
                    decoration: InputDecoration(labelText: l10n.offerLabelOptionalField),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: discountStart,
                    decoration: InputDecoration(
                      labelText: l10n.discountStartOptionalField,
                      hintText: l10n.dateHintExampleStart,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: discountEnd,
                    decoration: InputDecoration(
                      labelText: l10n.discountEndOptionalField,
                      hintText: l10n.dateHintExampleEnd,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.ticketCancel)),
            FilledButton(
              onPressed: selectedCategoryId == 0
                  ? null
                  : () async {
                      final navigator = Navigator.of(context);
                      final messenger = ScaffoldMessenger.of(context);
                      try {
                        final parsedPrice = double.tryParse(price.text.trim()) ?? 0;
                        final body = {
                          'food_category_id': selectedCategoryId,
                          'name': name.text.trim(),
                          'name_fa': nameFa.text.trim(),
                          'description': description.text.trim(),
                          'price': parsedPrice,
                          'discounted_price': discountPrice.text.trim().isEmpty ? null : (double.tryParse(discountPrice.text.trim()) ?? 0),
                          'discount_start': !isSpecialOffer || discountStart.text.trim().isEmpty ? null : discountStart.text.trim(),
                          'discount_end': !isSpecialOffer || discountEnd.text.trim().isEmpty ? null : discountEnd.text.trim(),
                          'preparation_time': prepTime.text.trim().isEmpty ? null : (int.tryParse(prepTime.text.trim()) ?? 0),
                          'is_available': isAvailable,
                          'is_featured': isFeatured,
                          'is_special_offer': isSpecialOffer,
                          'offer_label': isSpecialOffer && offerLabel.text.trim().isNotEmpty ? offerLabel.text.trim() : null,
                          'is_vegetarian': false,
                          'is_vegan': false,
                          'is_halal': true,
                          'is_spicy': false,
                          'is_gluten_free': false,
                        };
                        RestaurantMenuItem savedItem;
                        if (item == null) {
                          savedItem = await _service.createItem(body);
                        } else {
                          savedItem = await _service.updateItem(item.id, body);
                        }
                        await _service.syncItemSizes(
                          itemId: savedItem.id,
                          hasSizes: hasSizes,
                          basePrice: parsedPrice,
                          kidsPrice: hasSizes && kidsPrice.text.trim().isNotEmpty
                              ? double.tryParse(kidsPrice.text.trim())
                              : null,
                          smallPrice: hasSizes && smallPrice.text.trim().isNotEmpty
                              ? double.tryParse(smallPrice.text.trim())
                              : null,
                          mediumPrice: hasSizes && mediumPrice.text.trim().isNotEmpty
                              ? double.tryParse(mediumPrice.text.trim())
                              : null,
                          largePrice: hasSizes && largePrice.text.trim().isNotEmpty
                              ? double.tryParse(largePrice.text.trim())
                              : null,
                          familyPrice: hasSizes && familyPrice.text.trim().isNotEmpty
                              ? double.tryParse(familyPrice.text.trim())
                              : null,
                          existingGroupId: item?.sizeGroupId,
                          existingVariants: item?.sizeVariants ?? const [],
                        );
                        if (!mounted) return;
                        navigator.pop();
                        await _load();
                      } catch (e) {
                        if (!mounted) return;
                        messenger.showSnackBar(
                          SnackBar(content: Text(userFriendlyErrorMessage(e)), backgroundColor: AppColors.error),
                        );
                      }
                    },
              child: Text(l10n.save),
            ),
          ],
        ),
        );
      },
    );
  }

  Future<void> _showSpecialOfferDialog(RestaurantMenuItem item) async {
    bool isOn = item.isSpecialOffer;
    final discountPrice = TextEditingController(text: item.discountedPrice?.toStringAsFixed(0) ?? '');
    final offerLabel = TextEditingController(text: item.offerLabel ?? '');
    final discountStart = TextEditingController(text: item.discountStart ?? '');
    final discountEnd = TextEditingController(text: item.discountEnd ?? '');

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final l10n = AppLocalizations.of(dialogContext)!;
        return StatefulBuilder(
          builder: (context, setStateDialog) => AlertDialog(
          title: Text(l10n.specialOfferDialogTitle(item.name)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SwitchListTile(
                  value: isOn,
                  onChanged: (v) => setStateDialog(() => isOn = v),
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.listUnderDeals),
                  subtitle: Text(l10n.listUnderDealsSubtitle),
                ),
                if (isOn) ...[
                  TextField(
                    controller: discountPrice,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: l10n.discountedPriceCurrencyHint),
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: offerLabel, decoration: InputDecoration(labelText: l10n.labelOptionalField)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: discountStart,
                    decoration: InputDecoration(labelText: l10n.optionalStartLabel, hintText: l10n.isoDateHint),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: discountEnd,
                    decoration: InputDecoration(labelText: l10n.optionalEndLabel, hintText: l10n.isoDateHint),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.ticketCancel)),
            FilledButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                try {
                  if (isOn) {
                    final dp = double.tryParse(discountPrice.text.trim());
                    if (dp == null || dp <= 0) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(l10n.enterDiscountedPricePositive),
                          backgroundColor: AppColors.error,
                        ),
                      );
                      return;
                    }
                    if (dp >= item.price) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            l10n.discountedMustBeBelowRegular(item.price.toStringAsFixed(0)),
                          ),
                          backgroundColor: AppColors.error,
                        ),
                      );
                      return;
                    }
                  }
                  final body = <String, dynamic>{
                    'is_special_offer': isOn,
                    if (isOn) ...{
                      'discounted_price': double.parse(discountPrice.text.trim()),
                      if (offerLabel.text.trim().isNotEmpty) 'offer_label': offerLabel.text.trim(),
                      if (discountStart.text.trim().isNotEmpty) 'discount_start': discountStart.text.trim(),
                      if (discountEnd.text.trim().isNotEmpty) 'discount_end': discountEnd.text.trim(),
                    },
                  };
                  await _service.updateItemSpecialOffer(item.id, body);
                  if (!mounted) return;
                  navigator.pop();
                  await _load();
                } catch (e) {
                  if (!mounted) return;
                  messenger.showSnackBar(
                    SnackBar(content: Text(userFriendlyErrorMessage(e)), backgroundColor: AppColors.error),
                  );
                }
              },
              child: Text(l10n.save),
            ),
          ],
        ),
        );
      },
    );
  }

  Future<void> _deleteCategory(RestaurantMenuCategory category) async {
    try {
      await _service.deleteCategory(category.id);
      if (!mounted) return;
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFriendlyErrorMessage(e)), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _deleteItem(RestaurantMenuItem item) async {
    try {
      await _service.deleteItem(item.id);
      if (!mounted) return;
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFriendlyErrorMessage(e)), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _toggleItem(RestaurantMenuItem item) async {
    try {
      await _service.toggleItemAvailability(item.id);
      if (!mounted) return;
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFriendlyErrorMessage(e)), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.menuManagement),
        actions: [
          IconButton(
            onPressed: _categories.isEmpty ? null : () => _showItemDialog(),
            icon: Icon(Icons.add_box_rounded),
            tooltip: l10n.addItemTooltip,
          ),
          IconButton(
            onPressed: _showCategoryDialog,
            icon: Icon(Icons.playlist_add_rounded),
            tooltip: l10n.addCategoryTooltip,
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: _loading
          ? const AppPageLoading()
          : _error != null
              ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_error!, textAlign: TextAlign.center)))
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppColors.primary,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (_categories.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                          child: Column(
                            children: [
                              Icon(Icons.restaurant_menu_rounded, size: 56, color: AppColors.primary),
                              const SizedBox(height: 12),
                              Text(l10n.noMenuCategoriesYet, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 8),
                              Text(l10n.createFirstCategoryHint),
                              const SizedBox(height: 16),
                              FilledButton(
                                onPressed: _showCategoryDialog,
                                child: Text(l10n.createFirstCategory),
                              ),
                            ],
                          ),
                        )
                      else
                        ..._categories.map(
                          (category) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _CategoryCard(
                              category: category,
                              onAddItem: () => _showItemDialog(category: category),
                              onEditCategory: () => _showCategoryDialog(category),
                              onDeleteCategory: category.items.isNotEmpty ? null : () => _deleteCategory(category),
                              onEditItem: (item) => _showItemDialog(category: category, item: item),
                              onDeleteItem: _deleteItem,
                              onToggleItem: _toggleItem,
                              onSpecialOffer: _showSpecialOfferDialog,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.onAddItem,
    required this.onEditCategory,
    required this.onDeleteCategory,
    required this.onEditItem,
    required this.onDeleteItem,
    required this.onToggleItem,
    required this.onSpecialOffer,
  });

  final RestaurantMenuCategory category;
  final VoidCallback onAddItem;
  final VoidCallback onEditCategory;
  final VoidCallback? onDeleteCategory;
  final ValueChanged<RestaurantMenuItem> onEditItem;
  final ValueChanged<RestaurantMenuItem> onDeleteItem;
  final ValueChanged<RestaurantMenuItem> onToggleItem;
  final ValueChanged<RestaurantMenuItem> onSpecialOffer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(category.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(l10n.itemsCountInCategory('${category.items.length}'), style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                IconButton(onPressed: onAddItem, icon: Icon(Icons.add_circle_outline_rounded)),
                IconButton(onPressed: onEditCategory, icon: Icon(Icons.edit_outlined)),
                IconButton(
                  onPressed: onDeleteCategory,
                  icon: Icon(Icons.delete_outline_rounded, color: onDeleteCategory == null ? Colors.grey : AppColors.error),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (category.items.isEmpty)
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(l10n.noItemsInCategory, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            )
          else
            ...category.items.map(
              (item) => _ItemTile(
                item: item,
                onEdit: () => onEditItem(item),
                onDelete: () => onDeleteItem(item),
                onToggle: () => onToggleItem(item),
                onSpecialOffer: () => onSpecialOffer(item),
              ),
            ),
        ],
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({
    required this.item,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
    required this.onSpecialOffer,
  });

  final RestaurantMenuItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;
  final VoidCallback onSpecialOffer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: item.imageUrl != null && item.imageUrl!.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AppNetworkImage(
                imageUrl: item.imageUrl!,
                width: 52,
                height: 52,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _fallbackIcon(),
              ),
            )
          : _fallbackIcon(),
      title: Row(
        children: [
          Expanded(child: Text(item.name, style: TextStyle(fontWeight: FontWeight.w700))),
          if (item.isSpecialOffer)
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Icon(Icons.local_offer_rounded, size: 18, color: AppColors.primary.withValues(alpha: 0.9)),
            ),
        ],
      ),
      subtitle: Text(
        '${AppCurrency.format(item.discountedPrice ?? item.price, decimalDigits: 0)}'
        '${item.hasSizes ? ' • ${l10n.menuItemSizesAvailable}' : ''}'
        '${item.preparationTime != null ? ' • ${l10n.minLabel('${item.preparationTime}')}' : ''}',
      ),
      trailing: Wrap(
        spacing: 2,
        children: [
          IconButton(
            onPressed: onSpecialOffer,
            icon: Icon(Icons.local_offer_outlined),
            color: AppColors.primary,
            tooltip: l10n.specialOfferTooltip,
          ),
          IconButton(
            onPressed: onToggle,
            icon: Icon(item.isAvailable ? Icons.visibility_rounded : Icons.visibility_off_rounded),
            color: item.isAvailable ? Colors.green : Colors.grey,
          ),
          IconButton(onPressed: onEdit, icon: Icon(Icons.edit_outlined)),
          IconButton(onPressed: onDelete, icon: Icon(Icons.delete_outline_rounded, color: AppColors.error)),
        ],
      ),
    );
  }

  Widget _fallbackIcon() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(Icons.fastfood_rounded, color: AppColors.primary),
    );
  }
}

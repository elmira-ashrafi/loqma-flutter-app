import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/layout/max_width_body.dart';
import '../../../core/layout/responsive_context.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/error_parser.dart';
import '../../../core/utils/font_helper.dart';
import '../../../core/controllers/locale_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../controllers/order_controller.dart';
import '../models/order_model.dart';
import '../orders_l10n.dart';
import 'order_detail_screen.dart';

class OrderReviewScreen extends StatefulWidget {
  const OrderReviewScreen({
    super.key,
    required this.orderId,
    required this.order,
  });

  final int orderId;
  final OrderModel order;

  @override
  State<OrderReviewScreen> createState() => _OrderReviewScreenState();
}

class _OrderReviewScreenState extends State<OrderReviewScreen>
    with SingleTickerProviderStateMixin {
  int _restaurantRating = 0;
  int _foodRating = 0;
  int _deliveryRating = 0;
  final TextEditingController _restaurantReviewController = TextEditingController();
  final TextEditingController _deliveryReviewController = TextEditingController();
  final List<String> _photoPaths = [];
  bool _submitting = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic);
    _animController.forward();
  }

  @override
  void dispose() {
    _restaurantReviewController.dispose();
    _deliveryReviewController.dispose();
    _animController.dispose();
    super.dispose();
  }

  bool _compact(BuildContext context) => MediaQuery.sizeOf(context).width < 400;
  bool _narrow(BuildContext context) => MediaQuery.sizeOf(context).width < 360;

  double _listBottomPad(BuildContext context) =>
      MediaQuery.paddingOf(context).bottom + (_compact(context) ? 88.0 : 100.0);

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (!mounted) return;
      setState(() {
        _photoPaths.addAll(images.map((e) => e.path));
      });
    } catch (_) {}
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (_restaurantRating == 0 || _foodRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.pleaseRateRestaurantAndFood,
            style: FontHelper.getTextStyle(
              text: l10n.pleaseRateRestaurantAndFood,
              languageCode: Get.find<LocaleController>().locale.languageCode,
              fontSize: 14.0,
              fontWeight: FontWeight.normal,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    if (_submitting) return;
    setState(() => _submitting = true);
    final ctrl = Get.isRegistered<OrderController>()
        ? Get.find<OrderController>()
        : Get.put(OrderController());
    try {
      await ctrl.submitReview(
        orderId: widget.orderId,
        restaurantRating: _restaurantRating,
        foodRating: _foodRating,
        restaurantReview: _restaurantReviewController.text.trim().isEmpty
            ? null
            : _restaurantReviewController.text.trim(),
        deliveryRating: widget.order.driver != null && _deliveryRating > 0
            ? _deliveryRating
            : null,
        deliveryReview: _deliveryReviewController.text.trim().isEmpty
            ? null
            : _deliveryReviewController.text.trim(),
        photoPaths: _photoPaths.isEmpty ? null : _photoPaths,
      );
      if (!mounted) return;
      ctrl.loadOrders();
      Navigator.of(context).popUntil((r) => r.isFirst);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => OrderDetailScreen(
            orderId: widget.orderId,
            initialOrder: widget.order,
          ),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.thankYouReviewSubmitted,
            style: FontHelper.getTextStyle(
              text: l10n.thankYouReviewSubmitted,
              languageCode: Get.find<LocaleController>().locale.languageCode,
              fontSize: 14.0,
              fontWeight: FontWeight.normal,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.failedSubmitReview(userFriendlyErrorMessage(e)),
              style: FontHelper.getTextStyle(
                text: l10n.failedSubmitReview(userFriendlyErrorMessage(e)),
                languageCode: Get.find<LocaleController>().locale.languageCode,
                fontSize: 14.0,
                fontWeight: FontWeight.normal,
                color: Colors.white,
              ),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final order = widget.order;
    final restaurantTitle = OrdersL10n.restaurantTitle(context, l10n, order);
    final base = ApiConstants.baseUrl.replaceAll(RegExp(r'/api/v1.*'), '');
    final hasDriver = order.driver != null;
    final hPad = context.pageHorizontalPadding;
    final compact = _compact(context);
    final narrow = _narrow(context);
    final thumb = narrow ? 44.0 : (compact ? 46.0 : 48.0);
    final avatarR = narrow ? 20.0 : (compact ? 22.0 : 24.0);
    final photoH = compact ? 72.0 : 80.0;
    final sectionGap = compact ? 18.0 : 24.0;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.chevron_left_rounded, size: compact ? 22 : 24),
          visualDensity: compact ? VisualDensity.compact : VisualDensity.standard,
        ),
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.center,
          child: Text(
            l10n.leaveAReview,
            maxLines: 1,
            style: FontHelper.getTextStyle(
              text: l10n.leaveAReview,
              languageCode: Get.find<LocaleController>().locale.languageCode,
              fontSize: compact ? 17.0 : 19.0,
              fontWeight: FontWeight.normal,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: MaxWidthBody(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(hPad, 16, hPad, _listBottomPad(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.orderReviewScreenSubtitle,
                  style: FontHelper.getTextStyle(
                    text: l10n.orderReviewScreenSubtitle,
                    languageCode: Get.find<LocaleController>().locale.languageCode,
                    fontSize: compact ? 13.5 : 14.0,
                    fontWeight: FontWeight.normal,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: sectionGap),
                _Section(
                  title: l10n.orderReviewRateRestaurantTitle,
                  compact: compact,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (order.restaurantImage != null && order.restaurantImage!.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: order.restaurantImage!.startsWith('http')
                                    ? order.restaurantImage!
                                    : '$base${order.restaurantImage}',
                                width: thumb,
                                height: thumb,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => _placeholder(thumb),
                                errorWidget: (_, __, ___) => _placeholder(thumb),
                              ),
                            )
                          else
                            _placeholder(thumb),
                          SizedBox(width: compact ? 10 : 12),
                          Expanded(
                            child: Text(
                              restaurantTitle,
                              style: FontHelper.getTextStyle(
                                text: restaurantTitle,
                                languageCode: Get.find<LocaleController>().locale.languageCode,
                                fontSize: compact ? 14.5 : 16.0,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: compact ? 10 : 12),
                      _StarRating(
                        value: _restaurantRating,
                        compact: compact,
                        onChanged: (v) => setState(() => _restaurantRating = v),
                      ),
                      SizedBox(height: compact ? 10 : 12),
                      TextField(
                        controller: _restaurantReviewController,
                        maxLines: 3,
                        style: FontHelper.getTextStyle(
                          text: '',
                          languageCode: Get.find<LocaleController>().locale.languageCode,
                          fontSize: compact ? 14.0 : 16.0,
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: l10n.reviewRestaurantHint,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surfaceContainer,
                          isDense: compact,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: sectionGap),
                _Section(
                  title: l10n.orderReviewRateFoodTitle,
                  compact: compact,
                  child: _StarRating(
                    value: _foodRating,
                    compact: compact,
                    onChanged: (v) => setState(() => _foodRating = v),
                  ),
                ),
                if (hasDriver) ...[
                  SizedBox(height: sectionGap),
                  _Section(
                    title: l10n.orderReviewRateDeliveryTitle,
                    compact: compact,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: avatarR,
                              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                              child: Text(
                                (order.driver!.name.isNotEmpty ? order.driver!.name[0] : 'D').toUpperCase(),
                                style: FontHelper.getTextStyle(
                                  text: (order.driver!.name.isNotEmpty ? order.driver!.name[0] : 'D').toUpperCase(),
                                  languageCode: Get.find<LocaleController>().locale.languageCode,
                                  fontSize: compact ? 16.0 : 18.0,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            SizedBox(width: compact ? 10 : 12),
                            Expanded(
                              child: Text(
                                order.driver!.name,
                                style: FontHelper.getTextStyle(
                                  text: order.driver!.name,
                                  languageCode: Get.find<LocaleController>().locale.languageCode,
                                  fontSize: compact ? 14.5 : 16.0,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: compact ? 10 : 12),
                        _StarRating(
                          value: _deliveryRating,
                          compact: compact,
                          onChanged: (v) => setState(() => _deliveryRating = v),
                        ),
                        SizedBox(height: compact ? 10 : 12),
                        TextField(
                          controller: _deliveryReviewController,
                          maxLines: 2,
                          style: FontHelper.getTextStyle(
                            text: '',
                            languageCode: Get.find<LocaleController>().locale.languageCode,
                            fontSize: compact ? 14.0 : 16.0,
                            fontWeight: FontWeight.normal,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          decoration: InputDecoration(
                            hintText: l10n.reviewDeliveryHint,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surfaceContainer,
                            isDense: compact,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                SizedBox(height: sectionGap),
                _Section(
                  title: l10n.orderReviewAddPhotosSectionTitle,
                  compact: compact,
                  child: Column(
                    children: [
                      OutlinedButton.icon(
                        onPressed: _pickImages,
                        icon: Icon(Icons.add_photo_alternate_rounded, size: compact ? 20 : 24),
                        label: Text(
                          l10n.addPhotos,
                          style: FontHelper.getTextStyle(
                            text: l10n.addPhotos,
                            languageCode: Get.find<LocaleController>().locale.languageCode,
                            fontSize: 14.0,
                            fontWeight: FontWeight.normal,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size(double.infinity, compact ? 44 : 48),
                          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                          padding: EdgeInsets.symmetric(vertical: compact ? 10 : 12),
                        ),
                      ),
                      if (_photoPaths.isNotEmpty) ...[
                        SizedBox(height: compact ? 10 : 12),
                        SizedBox(
                          height: photoH,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _photoPaths.length,
                            itemBuilder: (context, i) {
                              return Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(_photoPaths[i]),
                                        width: photoH,
                                        height: photoH,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 12,
                                    child: GestureDetector(
                                      onTap: () => setState(() => _photoPaths.removeAt(i)),
                                      child: CircleAvatar(
                                        radius: compact ? 11 : 12,
                                        backgroundColor: AppColors.error,
                                        child: Icon(Icons.close_rounded, size: compact ? 14 : 16, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: compact ? 24 : 32),
                FilledButton(
                  onPressed: _submitting ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: compact ? 14 : 16),
                    minimumSize: Size.fromHeight(compact ? 48 : 52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          l10n.submitReview,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: FontHelper.getTextStyle(
                            text: l10n.submitReview,
                            languageCode: Get.find<LocaleController>().locale.languageCode,
                            fontSize: 16.0,
                            fontWeight: FontWeight.normal,
                            color: Colors.white,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _placeholder(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.outlineVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.restaurant_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant, size: size * 0.45),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.child,
    required this.compact,
  });

  final String title;
  final Widget child;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 14 : 18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: FontHelper.getTextStyle(
              text: title,
              languageCode: Get.find<LocaleController>().locale.languageCode,
              fontSize: compact ? 16.0 : 18.0,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: compact ? 12 : 14),
          child,
        ],
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  const _StarRating({
    required this.value,
    required this.onChanged,
    required this.compact,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final starSize = compact ? 32.0 : 40.0;
    final hPad = compact ? 2.0 : 4.0;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (i) {
          final star = i + 1;
          final selected = value >= star;
          return GestureDetector(
            onTap: () => onChanged(star),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: AnimatedScale(
                scale: selected ? 1.08 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: Icon(
                  selected ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: starSize,
                  color: selected ? AppColors.rating : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/controllers/locale_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/error_parser.dart';
import '../../../core/utils/font_helper.dart';
import '../../orders/controllers/order_controller.dart';
import '../../orders/models/order_model.dart';
import '../services/ticket_service.dart';
import '../support_l10n.dart';
import '../../../l10n/app_localizations.dart';

class TicketCreateScreen extends StatefulWidget {
  const TicketCreateScreen({super.key});

  @override
  State<TicketCreateScreen> createState() => _TicketCreateScreenState();
}

class _TicketCreateScreenState extends State<TicketCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  String _category = 'order';
  String _priority = 'medium';
  int? _orderId;
  bool _submitting = false;
  final TicketService _service = TicketService();
  Worker? _localeWorker;

  String get _languageCode => Get.find<LocaleController>().locale.languageCode;

  TextStyle _textStyle(
    String text, {
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
  }) {
    return FontHelper.getTextStyle(
      text: text,
      languageCode: _languageCode,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? Colors.black,
    );
  }

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<LocaleController>()) {
      _localeWorker = ever(Get.find<LocaleController>().localeRx, (_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _localeWorker?.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (_messageController.text.trim().length < 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.ticketMessageTooShort),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      await _service.createTicket(
        subject: _subjectController.text.trim(),
        category: _category,
        priority: _priority,
        message: _messageController.text.trim(),
        orderId: _orderId,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.ticketSubmitted),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.ticketSubmitFailed(userFriendlyErrorMessage(e))),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _orderOptionLabel(AppLocalizations l10n, OrderModel order) {
    final orderId = order.orderNumber ?? '${order.id}';
    final restaurant = order.displayRestaurantName ?? l10n.restaurantDefaultName;
    return l10n.ticketRelatedOrderOption(orderId, restaurant);
  }

  @override
  Widget build(BuildContext context) {
    List<OrderModel> recentOrders = [];
    if (Get.isRegistered<OrderController>()) {
      recentOrders = Get.find<OrderController>().orders.take(5).toList();
    }

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        title: Text(
          l10n.newTicket,
          style: _textStyle(
            l10n.newTicket,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final media = MediaQuery.of(context);
            final isWide = constraints.maxWidth >= 600;
            final horizontalPadding = isWide ? constraints.maxWidth * 0.15 : 20.0;

            final content = Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.ticketFormTitle,
                    style: _textStyle(
                      l10n.ticketFormTitle,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.ticketFormSubtitle,
                    style: _textStyle(
                      l10n.ticketFormSubtitle,
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _subjectController,
                    style: _textStyle(_subjectController.text),
                    decoration: InputDecoration(
                      labelText: l10n.ticketSubjectLabel,
                      hintText: l10n.ticketSubjectHint,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: colorScheme.surfaceContainer,
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? l10n.fieldRequired : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _category,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: l10n.ticketCategoryLabel,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: colorScheme.surfaceContainer,
                    ),
                    items: SupportL10n.categoryKeys
                        .map(
                          (key) => DropdownMenuItem(
                            value: key,
                            child: Text(
                              SupportL10n.categoryLabel(l10n, key),
                              style: _textStyle(SupportL10n.categoryLabel(l10n, key)),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _category = v ?? _category),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _priority,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: l10n.ticketPriorityLabel,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: colorScheme.surfaceContainer,
                    ),
                    items: SupportL10n.priorityKeys
                        .map(
                          (key) => DropdownMenuItem(
                            value: key,
                            child: Text(
                              SupportL10n.priorityLabel(l10n, key),
                              style: _textStyle(SupportL10n.priorityLabel(l10n, key)),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _priority = v ?? _priority),
                  ),
                  if (recentOrders.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int?>(
                      initialValue: _orderId,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: l10n.ticketRelatedOrderLabel,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: colorScheme.surfaceContainer,
                      ),
                      items: [
                        DropdownMenuItem<int?>(
                          value: null,
                          child: Text(
                            l10n.ticketRelatedOrderNone,
                            style: _textStyle(l10n.ticketRelatedOrderNone),
                          ),
                        ),
                        ...recentOrders.map(
                          (o) => DropdownMenuItem<int?>(
                            value: o.id,
                            child: Text(
                              _orderOptionLabel(l10n, o),
                              style: _textStyle(_orderOptionLabel(l10n, o)),
                            ),
                          ),
                        ),
                      ],
                      onChanged: (v) => setState(() => _orderId = v),
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _messageController,
                    maxLines: isWide ? 10 : 6,
                    style: _textStyle(_messageController.text),
                    decoration: InputDecoration(
                      labelText: l10n.ticketMessageLabel,
                      hintText: l10n.ticketMessageHint,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: colorScheme.surfaceContainer,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return l10n.fieldRequired;
                      if (v.trim().length < 20) return l10n.ticketMessageTooShort;
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.ticketMessageMinCharsHint,
                    style: _textStyle(
                      l10n.ticketMessageMinCharsHint,
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 28),
                  if (constraints.maxWidth < 380)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        OutlinedButton(
                          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: colorScheme.outlineVariant),
                          ),
                          child: Text(l10n.ticketCancel),
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: _submitting ? null : _submit,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: _submitting
                              ? SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colorScheme.onPrimary,
                                  ),
                                )
                              : Text(l10n.ticketSubmit),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _submitting ? null : () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(color: colorScheme.outlineVariant),
                            ),
                            child: Text(l10n.ticketCancel),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: FilledButton(
                            onPressed: _submitting ? null : _submit,
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: _submitting
                                ? SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: colorScheme.onPrimary,
                                    ),
                                  )
                                : Text(l10n.ticketSubmit),
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: media.viewInsets.bottom > 0 ? 12 : 0),
                ],
              ),
            );

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                20,
                horizontalPadding,
                20 + media.viewInsets.bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 40,
                ),
                child: IntrinsicHeight(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    padding: EdgeInsets.symmetric(
                      horizontal: isWide ? 32 : 20,
                      vertical: isWide ? 28 : 20,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(isWide ? 24 : 20),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withValues(
                            alpha: theme.brightness == Brightness.dark ? 0.35 : 0.06,
                          ),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(
                        color: colorScheme.outlineVariant.withValues(alpha: 0.7),
                      ),
                    ),
                    child: content,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
